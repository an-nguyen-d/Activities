import UIKit
import ComposableArchitecture
import ACT_ActivityGoalsTabFeature
import ACT_SharedModels

public class ActivityGoalsTabVC: UIViewController {
  
  private let store: StoreOf<ActivityGoalsTabFeature>
  private let viewStore: ViewStoreOf<ActivityGoalsTabFeature>
  
  public init(store: StoreOf<ActivityGoalsTabFeature>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set blue background for visual testing
    view.backgroundColor = .systemBlue
    
    // Add a label to show the activity ID
    let label = UILabel()
    label.text = "Goals Tab\nActivity ID: \(viewStore.activityID.rawValue)"
    label.textAlignment = .center
    label.numberOfLines = 0
    label.textColor = .white
    label.font = .systemFont(ofSize: 20, weight: .medium)
    label.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewStore.send(.view(.willAppear))
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.view(.willDisappear))
  }
}