import UIKit
import ACT_SharedModels
import ACT_ActivitiesListFeature
import ACT_GoalEvaluationClient
import IdentifiedCollections
import ElixirShared

extension ActivitiesCollection {

  @MainActor
  final class Manager: NSObject {
    
    enum Section: Hashable {
      case main
    }
    
    private let collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, Cell.Activity.Model>!
    private var viewModelCache: [ActivityModel.ID: Cell.Activity.Model] = [:]
    private var lastUpdateTimer: Timer?
    private var currentActivities: IdentifiedArrayOf<ActivityListItemModel> = []
    private var currentCalendarDate: CalendarDate = CalendarDate("2024-01-01")
    private var lastCalculatedCalendarDate: CalendarDate = CalendarDate("2024-01-01")
    
    // Closures to handle cell interactions
    var onQuickLogTapped: ((ActivityModel.ID) -> Void)?
    var onCellTapped: ((ActivityModel.ID) -> Void)?
    var onCellLongPressed: ((ActivityModel.ID) -> Void)?
    
    // Dependencies for view model creation
    typealias Dependencies = 
      HasDateMaker &
      HasTimeZone &
      HasGoalEvaluationClient
    
    private let dependencies: Dependencies
    
    init(collectionView: UICollectionView, dependencies: Dependencies) {
      self.collectionView = collectionView
      self.dependencies = dependencies
      super.init()
      
      collectionView.register(Cell.Activity.self)
      setupDataSource()
      setupCollectionView()
    }
    
    private func setupDataSource() {
      dataSource = UICollectionViewDiffableDataSource<Section, Cell.Activity.Model>(
        collectionView: collectionView
      ) { [weak self] collectionView, indexPath, model in
        let cell: Cell.Activity = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: model)
        cell.onQuickLogTapped = self?.onQuickLogTapped
        return cell
      }
    }
    
    private func setupCollectionView() {
      collectionView.delegate = self
      
      // Add long press gesture recognizer
      let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
      collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
      guard gesture.state == .began else { return }
      
      let location = gesture.location(in: collectionView)
      guard let indexPath = collectionView.indexPathForItem(at: location),
            let model = dataSource?.itemIdentifier(for: indexPath) else { return }
      
      onCellLongPressed?(model.id)
    }
    
    func startTimer() {
      stopTimer()
      
      lastUpdateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
        Task { @MainActor in
          self?.updateLastCompletedTexts()
        }
      }
    }
    
    func stopTimer() {
      lastUpdateTimer?.invalidate()
      lastUpdateTimer = nil
    }
    
    private func updateLastCompletedTexts() {
      // Only update if we have activities to update
      guard !currentActivities.isEmpty else { return }

      // Timer fired - update last completed texts
      
      // Check if calendar date has changed
      let now = dependencies.dateMaker.date()
      let todayCalendarDate = CalendarDate(from: now, timeZone: dependencies.timeZone)
      
      if todayCalendarDate != lastCalculatedCalendarDate {
        // Calendar date changed - recalculate all view models
        lastCalculatedCalendarDate = todayCalendarDate
        // Force full recalculation by clearing cache and re-updating
        viewModelCache.removeAll()
        updateActivities(currentActivities, currentCalendarDate: todayCalendarDate)
        return
      }
      
      // Get current snapshot
      guard let currentSnapshot = dataSource?.snapshot() else { return }
      
      // Check if we still have activities
      guard !currentActivities.isEmpty else { return }
      let currentItems = currentSnapshot.itemIdentifiers
      
      // Find items that need updating
      var updatedItems: [Cell.Activity.Model] = []
      
      for item in currentItems {
        // Check if this item needs its "last completed" text updated
        if let lastCompletedDate = item.lastCompletedDate {
          let newText = formatLastCompleted(from: lastCompletedDate)
          if newText != item.lastCompletedText {
            // Create updated model with new text
            let updatedModel = Cell.Activity.Model(
              id: item.id,
              activityName: item.activityName,
              goalStatusText: item.goalStatusText,
              lastCompletedText: newText,
              lastCompletedDate: item.lastCompletedDate,
              streakNumber: item.streakNumber,
              streakColor: item.streakColor,
              progressPercentage: item.progressPercentage,
              goalStatus: item.goalStatus,
              sourceDataHash: item.sourceDataHash
            )
            updatedItems.append(updatedModel)
            // Update cache
            viewModelCache[item.id] = updatedModel
          }
        }
      }
      
      // Apply updates if any
      if !updatedItems.isEmpty {
        // We need to replace items, not reload them, because the hash has changed
        var newSnapshot = NSDiffableDataSourceSnapshot<Section, Cell.Activity.Model>()
        newSnapshot.appendSections([.main])
        
        // Build new array with updated items
        var newItems: [Cell.Activity.Model] = []
        for item in currentItems {
          if let updatedItem = updatedItems.first(where: { $0.id == item.id }) {
            newItems.append(updatedItem)
          } else {
            newItems.append(item)
          }
        }
        
        // Sort using the goalStatus stored in each model
        let sortedItems = newItems.sorted { lhs, rhs in
          // Define status priority (lower number = higher priority)
          func statusPriority(_ status: GoalStatus) -> Int {
            switch status {
            case .incomplete: return 0
            case .success: return 1
            case .failure: return 2
            case .skip: return 3
            }
          }
          
          let lhsPriority = statusPriority(lhs.goalStatus)
          let rhsPriority = statusPriority(rhs.goalStatus)
          
          if lhsPriority != rhsPriority {
            return lhsPriority < rhsPriority
          } else {
            // Same status, sort alphabetically by activity name
            return lhs.activityName < rhs.activityName
          }
        }
        
        newSnapshot.appendItems(sortedItems)
        dataSource.apply(newSnapshot, animatingDifferences: false)
      }
    }
    
    func updateActivities(
      _ activities: IdentifiedArrayOf<ActivityListItemModel>,
      currentCalendarDate: CalendarDate
    ) {
      // Update activities
      
      // Store for timer updates
      self.currentActivities = activities
      self.currentCalendarDate = currentCalendarDate
      self.lastCalculatedCalendarDate = currentCalendarDate
      
      // Create view models with caching
      let viewModels = activities.map { activity -> Cell.Activity.Model in
        // Create a stable hash from the activity data and calendar date
        var hasher = Hasher()
        hasher.combine(activity.activity.id)
        hasher.combine(activity.activity.activityName)
        hasher.combine(activity.activity.currentStreakCount)
        hasher.combine(activity.sessions.count)
        hasher.combine(activity.effectiveGoal.id)
        hasher.combine(currentCalendarDate.value) // Include calendar date in hash
        let sourceHash = hasher.finalize()
        
        // Check cache
        if let cached = viewModelCache[activity.id],
           cached.sourceDataHash == sourceHash {
          return cached
        }
        
        // Compute new view model
        
        // Get goal target for today
        let goalTarget = activity.effectiveGoal.getGoalTarget(for: currentCalendarDate)
        let targetValue = goalTarget?.goalValue ?? 0
        
        // Calculate completed value for the goal's date range
        let completedValue: Double
        if let _ = goalTarget {
          let goalSessionsDateRange = activity.effectiveGoal.getSessionsDateRangeForTarget(
            onCalendarDate: currentCalendarDate
          )
          completedValue = activity.sessions
            .filter { $0.completeCalendarDate >= goalSessionsDateRange.start && $0.completeCalendarDate <= goalSessionsDateRange.end }
            .reduce(0) { $0 + $1.value }
        } else {
          completedValue = 0
        }
        
        // Compute goal status text and progress
        let goalStatusText = formatGoalStatus(
          activity: activity.activity,
          goalTarget: goalTarget,
          completedValue: completedValue,
          targetValue: targetValue
        )
        
        // Get last completed date
        let lastCompletedDate = activity.sessions.first?.completeDate
        let lastCompletedText = formatLastCompleted(from: lastCompletedDate)
        
        let progressInfo = calculateProgressAndStatus(
          goal: activity.effectiveGoal,
          goalTarget: goalTarget,
          completedValue: completedValue,
          targetValue: targetValue,
          currentCalendarDate: currentCalendarDate
        )
        
        let streakColor = determineStreakColor(
          goalStatus: progressInfo.status,
          activity: activity.activity
        )

        let currentStreakCount = activity.activity.currentStreakCount
        let streakNumber: Int = {
          switch progressInfo.status {
          case .failure:
            return 0
          case .skip:
            return currentStreakCount
          case .success:
            return currentStreakCount + 1
          case .incomplete:
            return currentStreakCount
          }
        }()

        // Create new view model with computed data
        let model = Cell.Activity.Model(
          id: activity.id,
          activityName: activity.activity.activityName,
          goalStatusText: goalStatusText,
          lastCompletedText: lastCompletedText,
          lastCompletedDate: lastCompletedDate,
          streakNumber: "\(streakNumber)",
          streakColor: streakColor,
          progressPercentage: progressInfo.percentage,
          goalStatus: progressInfo.status,
          sourceDataHash: sourceHash
        )
        
        // Cache it
        viewModelCache[activity.id] = model
        return model
      }
      
      // Sort the view models using the goalStatus stored in each model
      let sortedViewModels = viewModels.sorted { lhs, rhs in
        // Define status priority (lower number = higher priority)
        func statusPriority(_ status: GoalStatus) -> Int {
          switch status {
          case .incomplete: return 0
          case .success: return 1
          case .failure: return 2
          case .skip: return 3
          }
        }
        
        let lhsPriority = statusPriority(lhs.goalStatus)
        let rhsPriority = statusPriority(rhs.goalStatus)
        
        if lhsPriority != rhsPriority {
          return lhsPriority < rhsPriority
        } else {
          // Same status, sort alphabetically by activity name
          return lhs.activityName < rhs.activityName
        }
      }
      
      // Apply to diffable data source
      var snapshot = NSDiffableDataSourceSnapshot<Section, Cell.Activity.Model>()
      snapshot.appendSections([.main])
      snapshot.appendItems(sortedViewModels)
      dataSource.apply(snapshot, animatingDifferences: true)
      
      // Start timer if not already running and we have activities
      if lastUpdateTimer == nil && !activities.isEmpty {
        startTimer()
      }
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ActivitiesCollection.Manager: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard let superviewSize = collectionView.superview?.bounds.size else {
      assertionFailure("Collection view has no superview")
      return .zero
    }
    
    return .init(
      width: superviewSize.width,
      height: 100
    )
  }
}

// MARK: - Helper Methods
private extension ActivitiesCollection.Manager {
  
  func formatGoalStatus(
    activity: ActivityModel,
    goalTarget: ActivityGoalTargetModel?,
    completedValue: Double,
    targetValue: Double
  ) -> String {
    // Check if there's a goal for today
    guard goalTarget != nil else {
      return "No goal today"
    }
    
    // Format values based on activity unit type
    switch activity.sessionUnit {
    case .seconds:
      // For time-based activities, format as time
      let targetSeconds = Int(targetValue)
      let currentSeconds = Int(completedValue)
      let differenceSeconds = targetSeconds - currentSeconds
      
      let currentFormatted = TimeFormatting.formatTimeDescription(seconds: Double(currentSeconds))
      let targetFormatted = TimeFormatting.formatTimeDescription(seconds: Double(targetSeconds))
      let differenceFormatted = TimeFormatting.formatTimeDescription(seconds: Double(abs(differenceSeconds)))
      let differenceSign = differenceSeconds > 0 ? "-" : "+"
      
      return "\(currentFormatted) / \(targetFormatted) (\(differenceSign)\(differenceFormatted))"
      
    case .integer(let unitName), .floating(let unitName):
      // For non-time activities, use the unit name
      let target = Int(targetValue)
      let current = Int(completedValue)
      let difference = target - current
      let differenceText = difference > 0 ? "-\(difference)" : "+\(abs(difference))"
      
      return "\(current) / \(target) \(unitName) (\(differenceText))"
    }
  }
  
  func formatLastCompleted(from date: Date?) -> String {
    guard let date = date else {
      return "Never completed"
    }
    
    let now = dependencies.dateMaker.date()
    let timeInterval = now.timeIntervalSince(date)
    
    // Less than a minute
    if timeInterval < 60 {
      return "Last completed: Just now"
    }
    
    // Less than an hour - show minutes
    if timeInterval < 3600 {
      let minutes = Int(timeInterval / 60)
      return "Last completed: \(minutes)m ago"
    }
    
    // Less than a day - show hours
    if timeInterval < 86400 {
      let hours = Int(timeInterval / 3600)
      return "Last completed: \(hours)h ago"
    }
    
    // Calculate days difference using calendar dates for accuracy
    let currentCalendarDate = CalendarDate(from: now, timeZone: dependencies.timeZone)
    let lastCompletedCalendarDate = CalendarDate(from: date, timeZone: dependencies.timeZone)
    let daysSince = currentCalendarDate.daysSince(lastCompletedCalendarDate)
    
    switch daysSince {
    case 1:
      return "Last completed: Yesterday"
    case 2...6:
      return "Last completed: \(daysSince) days ago"
    case 7...29:
      let weeks = daysSince / 7
      return "Last completed: \(weeks) week\(weeks == 1 ? "" : "s") ago"
    case 30...364:
      let months = daysSince / 30
      return "Last completed: \(months) month\(months == 1 ? "" : "s") ago"
    default:
      let years = daysSince / 365
      return "Last completed: \(years) year\(years == 1 ? "" : "s") ago"
    }
  }
  
  struct ProgressInfo {
    let percentage: Double
    let status: GoalStatus
  }
  
  func calculateProgressAndStatus(
    goal: any ActivityGoal.Modelling,
    goalTarget: ActivityGoalTargetModel?,
    completedValue: Double,
    targetValue: Double,
    currentCalendarDate: CalendarDate
  ) -> ProgressInfo {
    // Check if there's a goal for today
    guard goalTarget != nil else {
      return ProgressInfo(percentage: 0.0, status: .skip)
    }
    
    // Calculate progress - simple division
    let progress = targetValue > 0 ? completedValue / targetValue : 0.0
    
    // Evaluate status
    let status = dependencies.goalEvaluationClient.evaluateStatus(
      .init(
        goal: goal,
        sessionsInGoalPeriodValueTotal: completedValue,
        evaluationDate: currentCalendarDate,
        currentDate: currentCalendarDate
      )
    )
    
    return ProgressInfo(
      percentage: min(1.0, progress),
      status: status
    )
  }
  
  func determineStreakColor(
    goalStatus: GoalStatus,
    activity: ActivityModel
  ) -> UIColor {
    switch goalStatus {
    case .skip:
      return UIColor.white.withAlphaComponent(0.5)
    case .incomplete:
      return .white
    case .failure:
      return .init(hex: "e74c3c")
    case .success:
      return .init(hex: "2ecc71")
    }
  }
}

// MARK: - UICollectionViewDelegate

extension ActivitiesCollection.Manager: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // Deselect immediately for better UX
    collectionView.deselectItem(at: indexPath, animated: true)
    
    // Get the activity ID from the data source
    guard let model = dataSource?.itemIdentifier(for: indexPath) else { return }
    
    // Call the onCellTapped handler
    onCellTapped?(model.id)
  }
}
