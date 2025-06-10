import UIKit
import ComposableArchitecture
import ElixirShared
import ACT_ActivityCreationFeature
import ACT_GoalCreationFeatureiOS

extension ActivityCreationVC {

  @MainActor
  final class Router: NSObject {
    public typealias Module = ActivityCreationFeature
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
      super.init()
      bindRouting()
    }

    func bindRouting() {
      // Goal creation
      viewController?.present(
        item: $store.scope(
          state: \.destination?.goalCreation,
          action: \.destination.goalCreation
        )
      ) { [dependencies] store in
        let destinationVC = GoalCreationVC(
          store: store,
          dependencies: dependencies
        )
        destinationVC.modalPresentationStyle = .overFullScreen
        destinationVC.modalTransitionStyle = .crossDissolve
        return destinationVC
      }
    }

  }
}

// MARK: - AlertRouting
extension ActivityCreationVC.Router: AlertRouting {
}
