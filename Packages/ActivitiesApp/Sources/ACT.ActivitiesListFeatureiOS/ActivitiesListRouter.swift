import UIKit
import ComposableArchitecture
import ACT_ActivitiesListFeature

@MainActor
final class ActivitiesListRouter {

  public typealias Module = ActivitiesListFeature
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

  }

}
