import UIKit
import ComposableArchitecture
import ACT_WeeksPeriodGoalCreationFeature
import ACT_SharedUI

@MainActor
final class WeeksPeriodGoalCreationRouter: TimePickerPresenting {

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
    // Currently no navigation destinations for this feature
    // Time picker is presented modally using the protocol
  }

}