import UIKit
import ComposableArchitecture
import ACT_ActivitiesListFeature
import ACT_ActivitiesListFeatureiOS

struct AppDependencies {

}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    // Create the window
    window = UIWindow(windowScene: windowScene)

    let dependencies = AppDependencies()

    // Create your view controller with store
    let destinationVC = ActivitiesListVC(
      store: .init(
        initialState: ActivitiesListFeature.State(),
        reducer: {
          return ActivitiesListFeature(dependencies: dependencies)
        }
      ),
      dependencies: dependencies
    )
    
    // Option 1: Set directly as root
//    window?.rootViewController = destinationVC
    
    // Option 2: Wrap in navigation controller (recommended)
     let navController = UINavigationController(rootViewController: destinationVC)
     window?.rootViewController = navController
    
    // Make window visible
    window?.makeKeyAndVisible()
  }
}
