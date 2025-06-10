import UIKit
import ComposableArchitecture
import ACT_ActivityDetailFeature
import ACT_SharedModels
import ACT_ActivityGeneralTabFeatureiOS
import ACT_ActivityGoalsTabFeatureiOS
import ACT_ActivitySessionsTabFeatureiOS

public class ActivityDetailVC: UITabBarController {
  
  private let store: StoreOf<ActivityDetailFeature>
  private let viewStore: ViewStoreOf<ActivityDetailFeature>
  
  public init(store: StoreOf<ActivityDetailFeature>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTabs()
  }
  
  private func setupTabs() {
    let activityID = viewStore.activityID
    
    // General Tab
    let generalVC = ActivityGeneralTabVC(activityID: activityID)
    generalVC.tabBarItem = UITabBarItem(
      title: "General",
      image: UIImage(systemName: "info.circle"),
      selectedImage: UIImage(systemName: "info.circle.fill")
    )
    
    // Goals Tab
    let goalsVC = ActivityGoalsTabVC(activityID: activityID)
    goalsVC.tabBarItem = UITabBarItem(
      title: "Goals",
      image: UIImage(systemName: "target"),
      selectedImage: UIImage(systemName: "target")
    )
    
    // Sessions Tab
    let sessionsVC = ActivitySessionsTabVC(activityID: activityID)
    sessionsVC.tabBarItem = UITabBarItem(
      title: "Sessions",
      image: UIImage(systemName: "clock"),
      selectedImage: UIImage(systemName: "clock.fill")
    )
    
    // Set view controllers
    viewControllers = [generalVC, goalsVC, sessionsVC]
    
    // Send view actions
    viewStore.send(.view(.willAppear))
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.view(.willDisappear))
  }
}