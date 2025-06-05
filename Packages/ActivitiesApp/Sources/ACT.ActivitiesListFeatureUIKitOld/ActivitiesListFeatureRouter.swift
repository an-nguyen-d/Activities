import UIKit
import ComposableArchitecture
import ACT_ActivitiesListFeatureOld


extension ActivitiesListFeatureVC {

  @MainActor
  final class Router {

    public typealias Module = ActivitiesListFeature

    weak var viewController: UIViewController?

    @UIBindable
    private var store: StoreOf<Module>

    init(viewController: UIViewController, store: StoreOf<Module>) {
      self.viewController = viewController
      self.store = store
      bindRouting()
    }

    private func bindRouting() {
      viewController?.present(
        item: $store.scope(state: \.destination?.createActivity, action: \.destination.createActivity)
      ) { store in
        CreateActivityFeatureVC(store: store)
      }
    } 

  }

}
