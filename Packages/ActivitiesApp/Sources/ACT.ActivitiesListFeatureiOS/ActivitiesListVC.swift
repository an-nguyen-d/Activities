import UIKit
import ElixirShared
import ComposableArchitecture
import ACT_ActivitiesListFeature
import ACT_GoalEvaluationClient

public final class ActivitiesListVC: BaseViewController {

  // MARK: - Typealiases

  public typealias Module = ActivitiesListFeature
  public typealias Dependencies = Module.Dependencies & HasGoalEvaluationClient

  private typealias View = ActivitiesListView
  private typealias Router = ActivitiesListRouter
  private typealias State = Module.State
  private typealias ViewAction = Module.Action.ViewAction

  // MARK: - Properties

  private let contentView = View()
  private var router: Router!
  private var viewStore: Store<State, ViewAction>
  private let dependencies: Dependencies

  private var collectionManager: ActivitiesCollection.Manager!

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

  // MARK: - View

  public override func loadView() {
    view = contentView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    collectionManager = .init(
      collectionView: contentView.collectionView,
      dependencies: dependencies
    )
    
    // Set up quick log handler
    collectionManager.onQuickLogTapped = { [weak self] activityId in
      self?.viewStore.send(.quickLogTapped(activityId: activityId))
    }

    setupNavigationBar()
    observeStore()
    bindView()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewStore.send(.willAppear)
    
    // Start timer for updating "last completed" texts
    collectionManager.startTimer()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.willDisappear)
    
    // Stop timer to prevent unnecessary updates when not visible
    collectionManager.stopTimer()
  }
  
  private func setupNavigationBar() {
    title = "Activities"
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addButtonTapped)
    )
  }

  private func observeStore() {
    observe { [weak self] in
      guard let self else { return }

      // Update collection view with activities
      let activities = self.viewStore.activities
      let currentCalendarDate = self.viewStore.currentCalendarDate
      
      self.collectionManager.updateActivities(
        activities,
        currentCalendarDate: currentCalendarDate
      )
    }
  }

  private func bindView() {
    // Binding the view to send actions into viewStore
  }
  
  @objc private func addButtonTapped() {
    viewStore.send(.addButtonTapped)
  }

}

import SwiftUI

/*
struct VC_Preview: PreviewProvider {

  struct Dependencies {

  }

  static let dependencies = Dependencies()

  static var previews: some View {
    BaseVCRepresentable(
      vc: ActivitiesListVC(
        store: .init(
          initialState: ActivitiesListFeature.State(),
          reducer: {
            ActivitiesListFeature(
              dependencies: self.dependencies
            )
          }
        ),
        dependencies: self.dependencies
      )
    )
    .previewDevice("iPhone 14 Pro")
    .previewDisplayName("iPhone 14 Pro")

  }
}
*/
