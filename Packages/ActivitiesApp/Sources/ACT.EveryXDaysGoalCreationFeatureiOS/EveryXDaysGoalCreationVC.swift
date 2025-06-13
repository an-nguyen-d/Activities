import UIKit
import ComposableArchitecture
import ElixirShared
import ACT_SharedModels
import ACT_SharedUI
import ACT_Shared
import ACT_EveryXDaysGoalCreationFeature

@MainActor
public final class EveryXDaysGoalCreationVC: UIViewController {

  // MARK: - Module
  
  public typealias Module = EveryXDaysGoalCreationFeature
  public typealias ViewState = Module.State
  public typealias ViewAction = Module.Action
  
  // MARK: - Properties
  
  private let store: StoreOf<Module>
  private let viewStore: ViewStoreOf<Module>
  private let dependencies: Module.Dependencies
  private var router: EveryXDaysGoalCreationRouter!
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let stackView = UIStackView()
  
  private let intervalSectionLabel = UILabel()
  private let intervalStepperView = IntervalStepperView()
  
  private let targetSectionLabel = UILabel()
  private let targetView = ActivityTargetInputView()
  
  private let descriptionLabel = UILabel()
  
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
    router = EveryXDaysGoalCreationRouter(
      viewController: self,
      store: store,
      dependencies: dependencies
    )
  }
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    title = "Every X Days Goal"
    
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
    intervalStepperView.suffixText = "days"
    intervalStepperView.minimumValue = 1
    intervalStepperView.maximumValue = 365
    
    // Target section label
    targetSectionLabel.text = "Target"
    targetSectionLabel.font = .preferredFont(forTextStyle: .headline)
    targetSectionLabel.textColor = .label
    
    // Configure target view based on session unit
    let sessionUnit = viewStore.sessionUnit
    switch sessionUnit {
    case .integer:
      targetView.unitType = .integer
    case .floating:
      targetView.unitType = .floating
    case .seconds:
      targetView.unitType = .time
    }
    
    // Description label
    descriptionLabel.font = .preferredFont(forTextStyle: .body)
    descriptionLabel.textColor = .secondaryLabel
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .center
    
    // Assemble views
    stackView.addArrangedSubview(intervalSectionLabel)
    stackView.addArrangedSubview(intervalStepperView)
    stackView.addArrangedSubview(targetSectionLabel)
    stackView.addArrangedSubview(targetView)
    
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
      self?.viewStore.send(.view(.daysIntervalChanged(value)))
    }
    
    // Bind target view actions
    targetView.onTargetValueChanged = { [weak self] value in
      self?.viewStore.send(.view(.targetValueChanged(value)))
    }
    
    targetView.onTargetTextChanged = { [weak self] string in
      self?.viewStore.send(.view(.targetValueStringChanged(string)))
    }
    
    targetView.onSuccessCriteriaChanged = { [weak self] criteria in
      self?.viewStore.send(.view(.targetSuccessCriteriaChanged(criteria)))
    }
    
    targetView.onClearTapped = { [weak self] in
      self?.viewStore.send(.view(.clearTargetTapped))
    }
    
    targetView.onTimeEditTapped = { [weak self] in
      self?.viewStore.send(.view(.timeEditTapped))
    }
    
    // Observe state changes
    observe { [weak self] in
      guard let self else { return }
      
      // Update interval stepper
      self.intervalStepperView.value = self.viewStore.daysInterval
      
      // Update target view
      self.targetView.setValue(self.viewStore.targetValue)
      self.targetView.setSuccessCriteria(self.viewStore.successCriteria)
      
      // Update target title color based on validation
      self.updateTargetTitleColor()
      
      // Update save button state
      self.navigationItem.rightBarButtonItem?.isEnabled = self.viewStore.isValid
      
      // Update description
      self.updateDescription()
    }
  }
  
  private func updateDescription() {
    let interval = viewStore.daysInterval
    let intervalText = interval == 1 ? "day" : "\(interval) days"
    
    if let targetValue = viewStore.targetValue,
       let criteria = viewStore.successCriteria {
      
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
        criteriaText = "at least"
      case .exactly:
        criteriaText = "exactly"
      case .lessThan:
        criteriaText = "less than"
      }
      
      descriptionLabel.text = "Complete \(criteriaText) \(targetText) every \(intervalText)"
    } else {
      descriptionLabel.text = "Set a target to see goal description"
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
  
  private func updateTargetTitleColor() {
    let validationState = validateTarget()
    
    switch validationState {
    case .valid:
      targetView.setTitleColor(.systemGreen)
    case .invalid:
      targetView.setTitleColor(.systemRed)
    case .empty:
      targetView.setTitleColor(.label)
    }
  }
  
  private func validateTarget() -> ValidationState {
    guard let value = viewStore.targetValue, let criteria = viewStore.successCriteria else {
      return .empty
    }
    
    return ActivityGoalTargetModel.isValidCombination(value: value, criteria: criteria) ? .valid : .invalid
  }
  
  private enum ValidationState {
    case valid
    case invalid
    case empty
  }
}