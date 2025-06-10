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
  private var router: Router!
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
    
    view.backgroundColor = .black
    navigationItem.title = "Select Tags"
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelTapped)
    )
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(createButtonTapped)
    )
    
    setupUI()
    setupTagsManager()
    observeStore()
    bindRouting()
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
      self?.viewStore.send(.tagSelected(tagID))
    }
  }
  
  private func observeStore() {
    observe { [weak self] in
      guard let self = self else { return }
      
      // Update collection view with real tags
      let tagModels = self.viewStore.state.tags.map { tag in
        TagsCollection.Cell.Tag.Model(
          id: tag.id,
          name: tag.name,
          colorHex: tag.associatedColorHex
        )
      }
      
      self.tagsManager.updateTags(Array(tagModels))
    }
  }
  
  @objc private func cancelTapped() {
    dismiss(animated: true)
  }
  
  @objc private func createButtonTapped() {
    viewStore.send(.createButtonTapped)
  }
  
  private func bindRouting() {
    observe { [weak self] in
      guard let self else { return }
      
      switch viewStore.state.destination {
      case let .alert(alertState):
        switch alertState {
        case .createTag:
          var nameField: UITextField!
          var colorField: UITextField!
          
          router.routeToAlert(
            from: self,
            title: "Create Tag",
            message: "Enter tag details",
            preferredStyle: .alert,
            addCancel: true,
            actions: [
              .init(
                title: "Create",
                action: { [weak self] _ in
                  let name = nameField.text ?? ""
                  let colorHex = colorField.text ?? ""
                  self?.viewStore.send(.alert(.createTag(.confirm(name: name, colorHex: colorHex))))
                },
                style: .default
              )
            ],
            textFields: [
              { textField in
                nameField = textField
                textField.placeholder = "Tag Name"
                textField.autocapitalizationType = .words
              },
              { textField in
                colorField = textField
                textField.placeholder = "Color Hex (e.g., FF0000)"
                textField.autocapitalizationType = .allCharacters
              }
            ],
            didSelectAction: { [weak self] in
              self?.viewStore.send(.didSelectAlertAction)
            }
          )
        }
      default:
        break
      }
    }
  }
}
