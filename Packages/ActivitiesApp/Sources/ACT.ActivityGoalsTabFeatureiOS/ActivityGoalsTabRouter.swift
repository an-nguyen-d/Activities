import UIKit
import ComposableArchitecture
import ACT_ActivityGoalsTabFeature
import ACT_GoalCreationFeature
import ACT_GoalCreationFeatureiOS

@MainActor
final class ActivityGoalsTabRouter {
  
  public typealias Module = ActivityGoalsTabFeature
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
        state: \.destination?.goalCreation,
        action: \.destination.goalCreation
      )
    ) { [dependencies] store in
      let goalCreationVC = GoalCreationVC(
        store: store,
        dependencies: dependencies
      )
      goalCreationVC.modalPresentationStyle = .overFullScreen
      goalCreationVC.modalTransitionStyle = .crossDissolve
      return goalCreationVC
    }
  }
}