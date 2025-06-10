import UIKit
import ComposableArchitecture
import ACT_ActivityDetailFeature
import ACT_SharedModels
import ACT_ActivityGeneralTabFeatureiOS
import ACT_ActivityGoalsTabFeatureiOS
import ACT_ActivitySessionsTabFeatureiOS

public class ActivityDetailVC: UITabBarController {

  // MARK: - Typealiases

  public typealias Module = ActivityDetailFeature
  public typealias Dependencies = Module.Dependencies

  private typealias Router = ActivityDetailRouter
  private typealias State = Module.State
  private typealias ViewAction = Module.Action.ViewAction

  // MARK: - Properties

  private var router: Router!
  private var viewStore: Store<State, ViewAction>
  private let dependencies: Dependencies

  // MARK: - Init

  public init(
    store: StoreOf<Module>,
    dependencies: Dependencies
  ) {
    self.viewStore = store.scope(
      state: \.self,
      action: \.view
    )
    self.dependencies = dependencies
    super.init(nibName: nil, bundle: nil)
    self.router = Router(
      viewController: self,
      store: store,
      dependencies: dependencies
    )
  }

  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTabs()
    setupNavigationBar()
    observeDelegateActions()
  }
  
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(dismissTapped)
    )
  }
  
  @objc private func dismissTapped() {
    dismiss(animated: true)
  }
  
  private func observeDelegateActions() {
    observe { [weak self] in
      guard let self = self else { return }

    }
  }
  
  private func setupTabs() {
    // General Tab
    /*
    let generalStore = store.scope(
      state: \.generalTab,
      action: \.generalTab
    )
    let generalVC = ActivityGeneralTabVC(store: generalStore)
    generalVC.tabBarItem = UITabBarItem(
      title: "General",
      image: UIImage(systemName: "info.circle"),
      selectedImage: UIImage(systemName: "info.circle.fill")
    )
    
    // Goals Tab
    let goalsStore = store.scope(
      state: \.goalsTab,
      action: \.goalsTab
    )
    let goalsVC = ActivityGoalsTabVC(store: goalsStore)
    goalsVC.tabBarItem = UITabBarItem(
      title: "Goals",
      image: UIImage(systemName: "target"),
      selectedImage: UIImage(systemName: "target")
    )
    
    // Sessions Tab
    let sessionsStore = store.scope(
      state: \.sessionsTab,
      action: \.sessionsTab
    )
    let sessionsVC = ActivitySessionsTabVC(store: sessionsStore)
    sessionsVC.tabBarItem = UITabBarItem(
      title: "Sessions",
      image: UIImage(systemName: "clock"),
      selectedImage: UIImage(systemName: "clock.fill")
    )
    
    // Set view controllers
    viewControllers = [generalVC, goalsVC, sessionsVC]
    */


    // Send view actions
    viewStore.send(.willAppear)
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.willDisappear)
  }
}
