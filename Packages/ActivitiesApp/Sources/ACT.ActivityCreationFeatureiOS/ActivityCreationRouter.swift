import UIKit
import ComposableArchitecture
import ACT_ActivityCreationFeature

extension ActivityCreationVC {
    @MainActor
    final class Router {
        public typealias Module = ActivityCreationFeature
        
        weak var viewController: UIViewController?
        
        @UIBindable
        private var store: StoreOf<Module>
        
        init(viewController: UIViewController, store: StoreOf<Module>) {
            self.viewController = viewController
            self.store = store
        }
        
        func bindRouting() {
            // No navigation destinations yet
        }
    }
}