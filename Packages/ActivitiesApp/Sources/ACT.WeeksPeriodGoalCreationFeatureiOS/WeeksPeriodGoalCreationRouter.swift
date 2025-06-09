import UIKit
import ComposableArchitecture
import ACT_WeeksPeriodGoalCreationFeature
import ACT_SharedUI

@MainActor
final class WeeksPeriodGoalCreationRouter {

  public typealias Module = WeeksPeriodGoalCreationFeature
  public typealias Dependencies = Module.Dependencies

  weak var viewController: UIViewController?

  @UIBindable
  private var store: StoreOf<Module>

  private let dependencies: Dependencies

  init(
    viewController: UIViewController,
    store: StoreOf<Module>,
    dependencies: Dependencies
  ) {
    self.viewController = viewController
    self.store = store
    self.dependencies = dependencies
    bindRouting()
  }

  private func bindRouting() {
    viewController?.present(
      item: $store.scope(
        state: \.destination?.timePicker,
        action: \.destination.timePicker
      )
    ) { timePickerStore in
      let timePickerVC = TimePickerVC(store: timePickerStore)
      return UINavigationController(rootViewController: timePickerVC)
    }
  }

}