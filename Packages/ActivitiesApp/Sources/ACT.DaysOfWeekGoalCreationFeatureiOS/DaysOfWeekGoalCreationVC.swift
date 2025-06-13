import UIKit
import ComposableArchitecture
import ElixirShared
import ACT_SharedModels
import ACT_SharedUI
import ACT_Shared
import ACT_DaysOfWeekGoalCreationFeature

@MainActor
public final class DaysOfWeekGoalCreationVC: UIViewController {

  // MARK: - Module
  
  public typealias Module = DaysOfWeekGoalCreationFeature
  public typealias ViewState = Module.State
  public typealias ViewAction = Module.Action
  
  // MARK: - Properties
  
  private let store: StoreOf<Module>
  private let viewStore: ViewStoreOf<Module>
  private let dependencies: Module.Dependencies
  private var router: DaysOfWeekGoalCreationRouter!
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let stackView = UIStackView()
  
  private let intervalSectionLabel = UILabel()
  private let intervalStepperView = IntervalStepperView()
  
  private let daysSectionLabel = UILabel()
  private var dayTargetViews: [DayOfWeek: ActivityTargetInputView] = [:]
  
  private let descriptionLabel = UILabel()
  
  // MARK: - Constants
  
  // Monday first order for UI
  private let orderedDaysOfWeek: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
  
  // MARK: - Lifecycle
  
  public init(
    store: StoreOf<Module>,
    dependencies: Module.Dependencies
  ) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
    self.dependencies = dependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupRouter()
    setupUI()
    setupConstraints()
    setupBindings()
  }
  
  // MARK: - Setup
  
  private func setupRouter() {
    router = DaysOfWeekGoalCreationRouter(
      viewController: self,
      store: store,
      dependencies: dependencies
    )
  }
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    title = "Days of Week Goal"
    
    // Navigation items
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelTapped)
    )
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .save,
      target: self,
      action: #selector(saveTapped)
    )
    
    // Configure scroll view
    scrollView.alwaysBounceVertical = true
    scrollView.keyboardDismissMode = .onDrag
    
    // Configure stack view
    stackView.axis = .vertical
    stackView.spacing = 32
    stackView.alignment = .fill
    
    // Interval section label
    intervalSectionLabel.text = "Frequency"
    intervalSectionLabel.font = .preferredFont(forTextStyle: .headline)
    intervalSectionLabel.textColor = .label
    
    // Configure interval stepper
    intervalStepperView.prefixText = "Every"
    intervalStepperView.suffixText = "weeks"
    intervalStepperView.minimumValue = 1
    intervalStepperView.maximumValue = 52
    
    // Days section label
    daysSectionLabel.text = "Days"
    daysSectionLabel.font = .preferredFont(forTextStyle: .headline)
    daysSectionLabel.textColor = .label
    
    // Create target views for each day
    let sessionUnit = viewStore.sessionUnit
    for day in orderedDaysOfWeek {
      let targetView = ActivityTargetInputView()
      targetView.showClearButton = true
      targetView.setTitle(day.name)
      
      switch sessionUnit {
      case .integer:
        targetView.unitType = .integer
      case .floating:
        targetView.unitType = .floating
      case .seconds:
        targetView.unitType = .time
      }
      
      dayTargetViews[day] = targetView
    }
    
    // Description label
    descriptionLabel.font = .preferredFont(forTextStyle: .body)
    descriptionLabel.textColor = .secondaryLabel
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .left
    
    // Assemble views
    stackView.addArrangedSubview(intervalSectionLabel)
    stackView.addArrangedSubview(intervalStepperView)
    stackView.addArrangedSubview(daysSectionLabel)
    
    // Add day target views (Monday first)
    for day in orderedDaysOfWeek {
      if let targetView = dayTargetViews[day] {
        stackView.addArrangedSubview(targetView)
      }
    }
    
    // Add spacing before description
    let spacer = UIView()
    spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
    stackView.addArrangedSubview(spacer)
    
    stackView.addArrangedSubview(descriptionLabel)
    
    contentView.addSubview(stackView)
    scrollView.addSubview(contentView)
    view.addSubview(scrollView)
  }
  
  private func setupConstraints() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      // Scroll view fills the safe area
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
      
      // Content view defines scrollable area
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      
      // Stack view with padding
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
    ])
  }
  
  private func setupBindings() {
    // Bind interval stepper
    intervalStepperView.onValueChanged = { [weak self] value in
      self?.viewStore.send(.view(.weeksIntervalChanged(value)))
    }
    
    // Bind target views for each day
    for day in orderedDaysOfWeek {
      guard let targetView = dayTargetViews[day] else { continue }
      
      targetView.onTargetValueChanged = { [weak self] value in
        self?.viewStore.send(.view(.dayTargetValueChanged(day, value)))
      }
      
      targetView.onTargetTextChanged = { [weak self] string in
        self?.viewStore.send(.view(.dayTargetValueStringChanged(day, string)))
      }
      
      targetView.onSuccessCriteriaChanged = { [weak self] criteria in
        self?.viewStore.send(.view(.dayTargetSuccessCriteriaChanged(day, criteria)))
      }
      
      targetView.onClearTapped = { [weak self] in
        self?.viewStore.send(.view(.dayTargetClearTapped(day)))
      }
      
      targetView.onTimeEditTapped = { [weak self] in
        self?.viewStore.send(.view(.dayTimeEditTapped(day)))
      }
    }
    
    // Observe state changes
    observe { [weak self] in
      guard let self else { return }
      
      // Update interval stepper
      self.intervalStepperView.value = self.viewStore.weeksInterval
      
      // Update target views for each day
      for day in self.orderedDaysOfWeek {
        guard let targetView = self.dayTargetViews[day] else { continue }
        let target = self.viewStore.state.getTarget(for: day)
        
        targetView.setValue(target.targetValue)
        targetView.setSuccessCriteria(target.successCriteria)
        
        // Update title color based on validation
        self.updateDayTitleColor(for: day, target: target, targetView: targetView)
      }
      
      // Update description
      self.updateDescription()
    }
  }
  
  private func updateDescription() {
    let interval = viewStore.weeksInterval
    let intervalText = interval == 1 ? "week" : "\(interval) weeks"
    
    var lines: [String] = []
    
    for day in orderedDaysOfWeek {
      let target = viewStore.state.getTarget(for: day)
      
      if let targetValue = target.targetValue,
         let criteria = target.successCriteria {
        
        let targetText: String
        switch viewStore.sessionUnit {
        case .integer(let unitName):
          let formattedValue = ValueFormatting.formatValue(targetValue, for: viewStore.sessionUnit)
          let finalUnitName = targetValue == 1 ? unitName.singularized() : unitName
          targetText = "\(formattedValue) \(finalUnitName)"
        case .floating(let unitName):
          let formattedValue = ValueFormatting.formatValue(targetValue, for: viewStore.sessionUnit)
          // For floating, check if the value is approximately 1 for singularization
          let finalUnitName = abs(targetValue - 1.0) < 0.01 ? unitName.singularized() : unitName
          targetText = "\(formattedValue) \(finalUnitName)"
        case .seconds:
          targetText = TimeFormatting.formatTimeDescription(seconds: targetValue)
        }
        
        let criteriaText: String
        switch criteria {
        case .atLeast:
          criteriaText = "At least"
        case .exactly:
          criteriaText = "Exactly"
        case .lessThan:
          criteriaText = "Less than"
        }
        
        lines.append("\(criteriaText) \(targetText) on \(day.name)")
      }
    }
    
    if lines.isEmpty {
      descriptionLabel.text = "Add targets for specific days (every \(intervalText))"
    } else {
      descriptionLabel.text = lines.joined(separator: "\n")
    }
  }
  
  // MARK: - Actions
  
  @objc private func cancelTapped() {
    viewStore.send(.view(.cancelButtonTapped))
  }
  
  @objc private func saveTapped() {
    viewStore.send(.view(.saveButtonTapped))
  }
  
  // MARK: - Helpers
  
  private func getUnitName(for sessionUnit: ActivityModel.SessionUnit, value: Double) -> String {
    switch sessionUnit {
    case .integer(let unit):
      return Int(value) == 1 ? unit.singularized() : unit
    case .floating(let unit):
      return abs(value - 1.0) < 0.01 ? unit.singularized() : unit
    case .seconds:
      return ""
    }
  }
  
  private func updateDayTitleColor(for day: DayOfWeek, target: DaysOfWeekGoalCreationFeature.State.DayTarget, targetView: ActivityTargetInputView) {
    let validationState = validateTarget(target)
    
    // Update the title color based on validation
    switch validationState {
    case .valid:
      targetView.setTitleColor(.systemGreen)
    case .invalid:
      targetView.setTitleColor(.systemRed)
    case .empty:
      targetView.setTitleColor(.label)
    }
  }
  
  private func validateTarget(_ target: DaysOfWeekGoalCreationFeature.State.DayTarget) -> ValidationState {
    guard let value = target.targetValue, let criteria = target.successCriteria else {
      return .empty
    }
    
    // Use the shared validation logic
    return ActivityGoalTargetModel.isValidCombination(value: value, criteria: criteria) ? .valid : .invalid
  }
  
  private enum ValidationState {
    case valid
    case invalid
    case empty
  }
}
