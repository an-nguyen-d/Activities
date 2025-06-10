import UIKit
import ElixirShared
import ComposableArchitecture
import ACT_CreateSessionFeature

final class CreateSessionRouter {
  
  // MARK: - Properties
  
  weak var viewController: UIViewController?
  let store: StoreOf<CreateSessionFeature>
  let dependencies: CreateSessionFeature.Dependencies
  
  // MARK: - Init
  
  init(
    viewController: UIViewController,
    store: StoreOf<CreateSessionFeature>,
    dependencies: CreateSessionFeature.Dependencies
  ) {
    self.viewController = viewController
    self.store = store
    self.dependencies = dependencies
  }
}