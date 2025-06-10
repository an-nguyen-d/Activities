import UIKit
import Combine
import ComposableArchitecture
import ACT_ActivityGeneralTabFeature
import ACT_TagsListFeature
import ACT_TagsListFeatureiOS
import ElixirShared

@MainActor
final class ActivityGeneralTabRouter {
  
  private weak var viewController: UIViewController?
  @UIBindable private var store: StoreOf<ActivityGeneralTabFeature>
  private let dependencies: ActivityGeneralTabFeature.Dependencies
  
  init(
    viewController: UIViewController,
    store: StoreOf<ActivityGeneralTabFeature>,
    dependencies: ActivityGeneralTabFeature.Dependencies
  ) {
    self.viewController = viewController
    self.store = store
    self.dependencies = dependencies
    
    bindRouting()
  }
  
  private func bindRouting() {
    viewController?.present(
      item: $store.scope(
        state: \.destination?.tagsList,
        action: \.destination.tagsList
      )
    ) { [dependencies] store in
      let tagsListVC = TagsListVC(store: store, dependencies: dependencies)
      return UINavigationController(rootViewController: tagsListVC)
    }
  }
}

// MARK: - AlertRouting
extension ActivityGeneralTabRouter: AlertRouting {}