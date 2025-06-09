import UIKit
import ComposableArchitecture
import ElixirShared
import ACT_WeeksPeriodGoalCreationFeature
import ACT_SharedUI
import ACT_SharedModels
import ACT_Shared

public final class WeeksPeriodGoalCreationVC: BaseViewController {

  public typealias Module = WeeksPeriodGoalCreationFeature
  private typealias View = WeeksPeriodGoalCreationView
  private typealias State = Module.State
  private typealias ViewAction = Module.Action.ViewAction
  public typealias Dependencies = Module.Dependencies

  private let contentView = View()
  private var viewStore: Store<State, ViewAction>
  private let store: StoreOf<Module>
  private let dependencies: Dependencies
  private var router: WeeksPeriodGoalCreationRouter!

  public init(
    store: StoreOf<Module>,
    dependencies: Dependencies
  ) {
    self.store = store
    self.viewStore = store.scope(
      state: \.self,
      action: \.view
    )
    self.dependencies = dependencies
    super.init()
    self.router = WeeksPeriodGoalCreationRouter(
      viewController: self,
      store: store,
      dependencies: dependencies
    )
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    view = contentView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    setupNavigationBar()
    observeStore()
    bindView()
  }

  private func setupNavigationBar() {
    title = "Weeks Period Goal"

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelButtonTapped)
    )

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .save,
      target: self,
      action: #selector(saveButtonTapped)
    )
  }

  private func observeStore() {
    observe { [weak self] in
      guard let self else { return }

      // Determine unit type from session unit
      let unitType: SessionUnitType
      switch viewStore.sessionUnit {
      case .integer:
        unitType = .integer
      case .floating:
        unitType = .floating
      case .seconds:
        unitType = .time
      }
      
      // Update target input view
      contentView.targetInputView.unitType = unitType
      contentView.targetInputView.setValue(viewStore.targetValue)
      contentView.targetInputView.setSuccessCriteria(viewStore.successCriteria)
      
      // Create goal description
      let goalDescription = createGoalDescription(
        targetValue: viewStore.targetValue,
        successCriteria: viewStore.successCriteria,
        sessionUnit: viewStore.sessionUnit
      )
      contentView.goalDescriptionLabel.text = goalDescription

      // Update save button state
      navigationItem.rightBarButtonItem?.isEnabled = viewStore.isValid
    }
  }
  
  private func createGoalDescription(
    targetValue: Double?,
    successCriteria: GoalSuccessCriteria?,
    sessionUnit: ActivityModel.SessionUnit
  ) -> String {
    // No value and no criteria
    if targetValue == nil && successCriteria == nil {
      return "No target"
    }
    
    // Has criteria but no value
    if targetValue == nil && successCriteria != nil {
      return "Missing value"
    }
    
    // Has value but no criteria
    if targetValue != nil && successCriteria == nil {
      return "Missing criteria"
    }
    
    // Has both value and criteria
    guard let value = targetValue, let criteria = successCriteria else {
      return "No target"
    }
    
    let formattedValue = formatValue(value, sessionUnit: sessionUnit)
    return "\(criteria.displayName) \(formattedValue) every week"
  }
  
  private func formatValue(_ value: Double, sessionUnit: ActivityModel.SessionUnit) -> String {
    switch sessionUnit {
    case .integer(let unitName):
      let intValue = Int(value)
      let units = intValue == 1 ? unitName.singularized() : unitName
      return "\(intValue) \(units)"
      
    case .floating(let unitName):
      // Format to remove unnecessary decimal places
      let formattedValue = value.truncatingRemainder(dividingBy: 1) == 0 
        ? String(format: "%.0f", value) 
        : String(format: "%.1f", value)
      let units = value == 1.0 ? unitName.singularized() : unitName
      return "\(formattedValue) \(units)"
      
    case .seconds:
      return TimeFormatting.formatTimeDescription(seconds: value)
    }
  }

  private func bindView() {
    // Bind target input view completion handlers
    contentView.targetInputView.onTargetValueChanged = { [weak self] value in
      self?.viewStore.send(.targetValueChanged(value))
    }
    
    // Handle text changes for better float input UX
    contentView.targetInputView.onTargetTextChanged = { [weak self] text in
      self?.viewStore.send(.targetValueStringChanged(text))
    }

    contentView.targetInputView.onSuccessCriteriaChanged = { [weak self] criteria in
      self?.viewStore.send(.targetSuccessCriteriaChanged(criteria))
    }

    contentView.targetInputView.onClearTapped = { [weak self] in
      self?.viewStore.send(.clearTargetTapped)
    }

    contentView.targetInputView.onTimeEditTapped = { [weak self] in
      guard let self else { return }
      
      // Only present time picker if we're in time mode
      guard case .seconds = self.viewStore.sessionUnit else { return }
      
      self.router?.presentTimePicker(
        from: self,
        initialTimeInSeconds: self.viewStore.targetValue ?? 0,
        onTimeSelected: { timeInSeconds in
          self.viewStore.send(.targetValueChanged(timeInSeconds))
        }
      )
    }
  }


  @objc private func cancelButtonTapped() {
    viewStore.send(.cancelButtonTapped)
  }

  @objc private func saveButtonTapped() {
    viewStore.send(.saveButtonTapped)
  }
}

