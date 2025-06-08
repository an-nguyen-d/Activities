import UIKit
import ComposableArchitecture
import ElixirShared
import ACT_DaysOfWeekGoalCreationFeature

public final class DaysOfWeekGoalCreationVC: BaseViewController {
    
    public typealias Module = DaysOfWeekGoalCreationFeature
    private typealias View = DaysOfWeekGoalCreationView
    private typealias State = Module.State
    private typealias ViewAction = Module.Action.ViewAction
    public typealias Dependencies = Module.Dependencies
    
    private let contentView = View()
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
    }
    
    private func setupNavigationBar() {
        title = "Days of Week Goal"
        
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
            // Observe state changes here
        }
    }
    
    private func bindView() {
        // Bind view actions here
    }
    
    @objc private func cancelButtonTapped() {
      viewStore.send(.cancelButtonTapped)
//        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        viewStore.send(.saveButtonTapped)
    }
}
