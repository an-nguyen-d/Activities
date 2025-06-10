import UIKit
import ComposableArchitecture
import ACT_ActivityDetailFeature
import ACT_SharedModels

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
    
    setupNavigationBar()
    observeDelegateActions()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    viewStore.send(.willAppear)
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
      // TODO: Add observations when needed
    }
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.willDisappear)
  }
}
