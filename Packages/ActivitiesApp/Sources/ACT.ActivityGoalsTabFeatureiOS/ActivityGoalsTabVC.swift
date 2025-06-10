import UIKit
import ComposableArchitecture
import ACT_ActivityGoalsTabFeature
import ACT_SharedModels
import ACT_SharedUI
import Foundation

public class ActivityGoalsTabVC: UIViewController {
  
  private let store: StoreOf<ActivityGoalsTabFeature>
  private let goalsTabView = ActivityGoalsTabView()
  private var goalsManager: GoalsCollection.Manager!
  private let dependencies: ActivityGoalsTabFeature.Dependencies
  
  public init(
    store: StoreOf<ActivityGoalsTabFeature>,
    dependencies: ActivityGoalsTabFeature.Dependencies
  ) {
    self.store = store
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
    setupGoalsManager()
    bindActions()
    observeGoals()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.send(.view(.willAppear))
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    store.send(.view(.willDisappear))
  }
  
  // MARK: - Setup
  
  private func setupUI() {
    goalsTabView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(goalsTabView)
    
    NSLayoutConstraint.activate([
      goalsTabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      goalsTabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      goalsTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      goalsTabView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  private func setupGoalsManager() {
    goalsManager = GoalsCollection.Manager(collectionView: goalsTabView.collectionView)
  }
  
  private func bindActions() {
    goalsTabView.createGoalButton.onTapHandler = { [weak self] in
      self?.store.send(.view(.createGoalTapped))
    }
  }
  
  private func observeGoals() {
    observe { [weak self] in
      guard let self = self else { return }
      
      let goals = self.store.withState(\.goals)
      let cellModels = goals.map { goal in
        GoalsCollection.Cell.Goal.Model(
          id: goal.id.rawValue.description,
          effectiveDate: "Effective CalendarDate: \(goal.effectiveCalendarDate.value)",
          description: GoalDescriptions.description(for: goal),
          goalType: GoalDescriptions.goalTypeName(for: goal)
        )
      }
      
      self.goalsManager.updateGoals(cellModels)
    }
  }
}