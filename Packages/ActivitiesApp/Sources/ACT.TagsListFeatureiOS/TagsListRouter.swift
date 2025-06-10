import UIKit
import ComposableArchitecture
import ElixirShared
import ACT_TagsListFeature

extension TagsListVC {
  
  @MainActor
  final class Router: NSObject {
    public typealias Module = TagsListFeature
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
    }
  }
}

// MARK: - AlertRouting
extension TagsListVC.Router: AlertRouting {
}