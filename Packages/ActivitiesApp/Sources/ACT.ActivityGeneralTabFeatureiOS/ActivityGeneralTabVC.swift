import UIKit
import ComposableArchitecture
import ACT_ActivityGeneralTabFeature
import ACT_SharedModels
import ACT_SharedUI

public class ActivityGeneralTabVC: UIViewController {
  
  private let store: StoreOf<ActivityGeneralTabFeature>
  private let viewStore: ViewStoreOf<ActivityGeneralTabFeature>
  private let generalTabView = ActivityGeneralTabView()
  private var tagsManager: TagsCollection.Manager!
  private var router: ActivityGeneralTabRouter!
  private let dependencies: ActivityGeneralTabFeature.Dependencies
  
  public init(
    store: StoreOf<ActivityGeneralTabFeature>,
    dependencies: ActivityGeneralTabFeature.Dependencies
  ) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
    self.dependencies = dependencies
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .black
    
    setupUI()
    setupTagsManager()
    bindState()
    bindActions()
    
    router = ActivityGeneralTabRouter(
      viewController: self,
      store: store,
      dependencies: dependencies
    )
    
    bindRouting()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewStore.send(.view(.willAppear))
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.view(.willDisappear))
  }
  
  // MARK: - Setup
  
  private func setupUI() {
    generalTabView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(generalTabView)
    
    NSLayoutConstraint.activate([
      generalTabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      generalTabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      generalTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      generalTabView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func setupTagsManager() {
    tagsManager = TagsCollection.Manager(collectionView: generalTabView.tagsCollectionView)
    
    // Set up delete handler
    tagsManager.onDeleteTapped = { [weak self] tagID in
      guard let self = self,
            let tag = self.viewStore.tags.first(where: { $0.id == tagID }) else { return }
      self.viewStore.send(.view(.deleteTagTapped(tag)))
    }
  }
  
  private func bindState() {
    // Observe activity changes
    observe { [weak self] in
      guard let self = self else { return }
      
      // Update UI when activity changes
      if let activity = self.viewStore.activity {
        self.generalTabView.configure(activity: activity)
      }
      
      self.tagsManager.updateTags(Array(self.viewStore.tags))
    }
  }
  
  private func bindActions() {
    generalTabView.editNameButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.view(.editNameTapped))
    }
    
    generalTabView.addTagButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.view(.addTagTapped))
    }
    
    generalTabView.deleteActivityButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.view(.deleteActivityTapped))
    }
  }
  
  private func bindRouting() {
    observe { [weak self] in
      guard let self else { return }
      
      switch viewStore.state.destination {
      case let .alert(alertState):
        switch alertState {
        case .deleteActivity:
          router.routeToAlert(
            from: self,
            title: "Delete Activity",
            message: "Are you sure you want to delete this activity? This action cannot be undone.",
            preferredStyle: .alert,
            addCancel: true,
            actions: [
              .init(
                title: "Delete",
                action: { [weak self] _ in
                  self?.viewStore.send(.view(.alert(.deleteActivity(.confirm))))
                },
                style: .destructive
              )
            ],
            textFields: [],
            didSelectAction: { [weak self] in
              self?.viewStore.send(.view(.didSelectAlertAction))
            }
          )
        }
      default:
        break
      }
    }
  }
}
