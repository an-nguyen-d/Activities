import UIKit
import ComposableArchitecture
import ACT_TagsListFeature
import ACT_SharedModels
import ElixirShared

public class TagsListVC: BaseViewController {
  
  // MARK: - Typealiases
  
  public typealias Module = TagsListFeature
  public typealias Dependencies = Module.Dependencies
  
  private typealias View = TagsListView
  private typealias State = Module.State
  private typealias ViewAction = Module.Action.ViewAction
  
  // MARK: - Properties
  
  private let contentView = View()
  private var viewStore: Store<State, ViewAction>
  private let dependencies: Dependencies
  
  private var tagsManager: TagsCollection.Manager!
  
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
    super.init()
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .black
    navigationItem.title = "Select Tags"
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelTapped)
    )
    
    setupUI()
    setupTagsManager()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewStore.send(.willAppear)
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.willDisappear)
  }
  
  // MARK: - Setup
  
  private func setupUI() {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(contentView)
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func setupTagsManager() {
    tagsManager = TagsCollection.Manager(collectionView: contentView.collectionView)
    
    tagsManager.onTagSelected = { [weak self] tagID in
      
    }
  }
  
  @objc private func cancelTapped() {
    dismiss(animated: true)
  }
}
