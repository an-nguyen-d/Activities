import UIKit
import Combine
import ComposableArchitecture
import ElixirShared
import ACT_ActivityCreationFeature
import ACT_DaysOfWeekGoalCreationFeature
import ACT_DaysOfWeekGoalCreationFeatureiOS
import ACT_EveryXDaysGoalCreationFeature
import ACT_EveryXDaysGoalCreationFeatureiOS
import ACT_WeeksPeriodGoalCreationFeature
import ACT_WeeksPeriodGoalCreationFeatureiOS

public final class ActivityCreationVC: BaseViewController {

  public typealias Module = ActivityCreationFeature
  private typealias View = ActivityCreationView
  private typealias State = Module.State
  private typealias ViewAction = Module.Action.ViewAction
  public typealias Dependencies = Module.Dependencies

  private let contentView = View()
  private var router: Router!
  private var viewStore: Store<State, ViewAction>
  let dependencies: Dependencies


  public init(
    store: StoreOf<Module>,
    dependencies: Dependencies
  ) {
    self.viewStore = store.scope(
      state: \.self,
      action: \.view
    )
    self.dependencies = dependencies
    super.init()
    self.router = Router(
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
    bindRouting()
  }


  private func setupNavigationBar() {
    title = "Create Activity"

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

      // Update activity name
      if contentView.activityNameTextField.text != viewStore.activityName {
        contentView.activityNameTextField.text = viewStore.activityName
      }

      // Update unit selection
      let units = ActivityCreationFeature.State.SessionUnitType.allCases
      let unitIndex = units.firstIndex(of: viewStore.selectedSessionUnit) ?? 0
      if contentView.unitSegmentedControl.selectedSegmentIndex != unitIndex {
        contentView.unitSegmentedControl.selectedSegmentIndex = unitIndex
      }

      // Update custom unit name
      if contentView.customUnitTextField.text != viewStore.customUnitName {
        contentView.customUnitTextField.text = viewStore.customUnitName
      }

      // Show/hide custom unit field based on selection
      let showCustomUnit = viewStore.selectedSessionUnit != .time
      contentView.updateCustomUnitVisibility(isVisible: showCustomUnit)

      // Update goal description
      contentView.updateGoalDescription(viewStore.goalDescription)

      // Update save button state
      navigationItem.rightBarButtonItem?.isEnabled = viewStore.isValid

    }
  }


  private func bindView() {
    // Text field actions
    contentView.activityNameTextField.addTarget(
      self,
      action: #selector(activityNameDidChange),
      for: .editingChanged
    )

    contentView.customUnitTextField.addTarget(
      self,
      action: #selector(customUnitNameDidChange),
      for: .editingChanged
    )

    // Segmented control action
    contentView.unitSegmentedControl.addTarget(
      self,
      action: #selector(unitSelectionDidChange),
      for: .valueChanged
    )

    // Goal button action
    contentView.editGoalButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.editGoalButtonTapped)
    }
  }

  @objc private func activityNameDidChange() {
    let text = contentView.activityNameTextField.text ?? ""
    viewStore.send(.activityNameChanged(text))
  }

  @objc private func customUnitNameDidChange() {
    let text = contentView.customUnitTextField.text ?? ""
    viewStore.send(.customUnitNameChanged(text))
  }

  @objc private func unitSelectionDidChange() {
    let selectedIndex = contentView.unitSegmentedControl.selectedSegmentIndex
    let units = ActivityCreationFeature.State.SessionUnitType.allCases
    if selectedIndex < units.count {
      viewStore.send(.sessionUnitChanged(units[selectedIndex]))
    }
  }

  @objc private func cancelButtonTapped() {
    dismiss(animated: true)
  }

  @objc private func saveButtonTapped() {
    viewStore.send(.saveButtonTapped)
  }

  private func bindRouting() {
    router.bindRouting()

    observe { [weak self] in
      guard let self else { return }

      /// A bit hacky but when working with UIAlert, we need to observe it specficially
      switch viewStore.state.destination {
      case let .alert(alertState):
        switch alertState {
        case .goalSelection:
          router.routeToAlert(
            from: self,
            title: "Select Goal Type",
            message: "Choose how you'd like to track this activity",
            preferredStyle: .actionSheet,
            addCancel: true,
            actions: [
              .init(
                title: "Days of Week",
                action: { [weak self] action in
                  self?.viewStore.send(.alert(.goalSelection(.daysOfWeek)))
                },
                style: .default
              ),
              .init(
                title: "Every X Days",
                action: { [weak self] action in
                  self?.viewStore.send(.alert(.goalSelection(.everyXDays)))
                },
                style: .default
              ),
              .init(
                title: "Weeks Period",
                action: { [weak self] action in
                  self?.viewStore.send(.alert(.goalSelection(.weeksPeriod)))
                },
                style: .default
              )
            ],
            textFields: [],
            didSelectAction: { [weak self] in
              self?.viewStore.send(.didSelectAlertAction)
            }
          )
        }

      default:
        break
      }
    }
  }
}
