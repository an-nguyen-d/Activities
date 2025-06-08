import UIKit
import ComposableArchitecture
import ElixirShared
import ACT_ActivityCreationFeature

public final class ActivityCreationVC: BaseViewController {
    
    public typealias Module = ActivityCreationFeature
    private typealias View = ActivityCreationView
    private typealias State = Module.State
    private typealias ViewAction = Module.Action.ViewAction
    public typealias Dependencies = Module.Dependencies
    
    private let contentView = View()
    private var router: Router!
    private var viewStore: Store<State, ViewAction>
    private let dependencies: Dependencies
    
    public init(
        store: StoreOf<Module>,
        dependencies: Dependencies
    ) {
        self.viewStore = store.scope(
            state: \.self,
            action: \.view
        )
        self.dependencies = dependencies
        super.init()
        self.router = Router(viewController: self, store: store)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = contentView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        observeStore()
        bindView()
        bindRouting()
    }
    
    private func setupNavigationBar() {
        title = "Create Activity"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveButtonTapped)
        )
    }
    
    private func observeStore() {
        observe { [weak self] in
            guard let self else { return }
            // Update UI based on viewStore state
        }
    }
    
    private func bindView() {
        // UIBarButtonItem actions are handled via target-action pattern in setupNavigationBar
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        viewStore.send(.saveButtonTapped)
    }
    
    private func bindRouting() {
        router.bindRouting()
    }
}