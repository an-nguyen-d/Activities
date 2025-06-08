import UIKit
import ComposableArchitecture
import ACT_ActivitiesListFeature
import ACT_ActivityCreationFeatureiOS

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
    viewController?.present(
      item: $store.scope(
        state: \.destination?.activityCreation,
        action: \.destination.activityCreation
      )
    ) { [dependencies] store in
      let activityCreationVC = ActivityCreationVC(
        store: store,
        dependencies: dependencies
      )
      return UINavigationController(rootViewController: activityCreationVC)
    }
  }

}
