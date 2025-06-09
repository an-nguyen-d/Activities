import UIKit
import ACT_SharedModels
import ACT_ActivitiesListFeature
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
    
    // Dependencies for view model creation
    typealias Dependencies = 
      HasDateMaker &
      HasTimeZone
    
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
      ) { collectionView, indexPath, model in
        let cell: Cell.Activity = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: model)
        return cell
      }
    }
    
    private func setupCollectionView() {
      collectionView.delegate = self
    }
    
    func updateActivities(
      _ activities: IdentifiedArrayOf<ActivityListItemModel>,
      currentCalendarDate: CalendarDate
    ) {
      print("🔄 Updating activities: \(activities.count) items")
      
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
          print("✅ Using cached view model for: \(activity.activity.activityName)")
          return cached
        }
        
        print("🔨 Computing new view model for: \(activity.activity.activityName)")
        
        // Create new view model with placeholder data
        let model = Cell.Activity.Model(
          id: activity.id,
          activityName: activity.activity.activityName,
          goalStatusText: "0 / 1 Sessions (-1)", // TODO: Compute from effectiveGoal
          lastCompletedText: "Last completed: 2 days ago",
          streakNumber: "\(activity.activity.currentStreakCount)",
          streakColor: .white,
          progressPercentage: 0.3,
          sourceDataHash: sourceHash
        )
        
        // Cache it
        viewModelCache[activity.id] = model
        return model
      }
      
      // Apply to diffable data source
      var snapshot = NSDiffableDataSourceSnapshot<Section, Cell.Activity.Model>()
      snapshot.appendSections([.main])
      snapshot.appendItems(viewModels)
      dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ActivitiesCollection.Manager: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard let superviewSize = collectionView.superview?.bounds.size else { return .zero }
    
    return .init(
      width: superviewSize.width,
      height: 100
    )
  }
}

// MARK: - UICollectionViewDelegate
extension ActivitiesCollection.Manager: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // TODO: Handle selection
  }
}
