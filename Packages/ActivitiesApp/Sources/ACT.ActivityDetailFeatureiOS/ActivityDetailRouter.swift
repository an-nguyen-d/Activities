import UIKit
import ComposableArchitecture
import ACT_ActivityDetailFeature
import ACT_SharedModels
import ACT_ActivityGeneralTabFeature
import ACT_ActivityGeneralTabFeatureiOS

@MainActor
final class ActivityDetailRouter {

  public typealias Module = ActivityDetailFeature
  public typealias Dependencies = Module.Dependencies

  weak var viewController: UITabBarController?

  @UIBindable
  private var store: StoreOf<Module>

  private let dependencies: Dependencies

  public lazy var generalVC: ActivityGeneralTabVC = {
    let generalStore = store.scope(
      state: \.generalTab,
      action: \.generalTab
    )
    let generalVC = ActivityGeneralTabVC(
      store: generalStore,
      dependencies: dependencies
    )
    generalVC.tabBarItem = UITabBarItem(
      title: "General",
      image: UIImage(systemName: "info.circle"),
      selectedImage: UIImage(systemName: "info.circle.fill")
    )
    return generalVC
  }()

  init(
    viewController: UITabBarController,
    store: StoreOf<Module>,
    dependencies: Dependencies
  ) {
    self.viewController = viewController
    self.store = store
    self.dependencies = dependencies
    bindRouting()


    viewController.viewControllers = [
      generalVC
    ]
  }

  private func bindRouting() {

  }

}
