import UIKit
import ComposableArchitecture
import ElixirShared
import ACT_GoalCreationFeature
import ACT_SharedUI

public final class GoalCreationVC: BaseViewController {
  
  // MARK: - Types
  
  public typealias Module = GoalCreationFeature
  private typealias View = GoalCreationView
  public typealias Dependencies = Module.Dependencies
  private typealias State = Module.State
  private typealias ViewAction = Module.Action.ViewAction
  
  // MARK: - Properties
  
  private let contentView = View()
  private var viewStore: Store<State, ViewAction>
  private var router: GoalCreationRouter!
  
  // MARK: - Init
  
  public init(
    store: StoreOf<Module>,
    dependencies: Dependencies
  ) {
    self.viewStore = store.scope(
      state: \.self,
      action: \.view
    )
    super.init()
    self.router = GoalCreationRouter(
      viewController: self,
      store: store,
      dependencies: dependencies
    )
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  public override func loadView() {
    view = contentView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    observeStore()
    bindView()
    bindGestures()
  }
  
  // MARK: - Store Observation
  
  private func observeStore() {
    observe { [weak self] in
      guard let self = self else { return }
      
      contentView.titleLabel.text = "Select Goal Type"
      contentView.messageLabel.text = "Choose how you'd like to track this activity"
      contentView.daysOfWeekButton.setTitle("Days of Week", for: .normal)
      contentView.everyXDaysButton.setTitle("Every X Days", for: .normal)
      contentView.weeksPeriodButton.setTitle("Weeks Period", for: .normal)
      contentView.containerView.isHidden = !viewStore.withState(\.goalTypeSelectionVisible)
    }
  }
  
  // MARK: - Bind View
  
  private func bindView() {
    contentView.daysOfWeekButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.daysOfWeekTapped)
    }
    
    contentView.everyXDaysButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.everyXDaysTapped)
    }
    
    contentView.weeksPeriodButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.weeksPeriodTapped)
    }
  }
  
  // MARK: - Bind Gestures
  
  private func bindGestures() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
    tapGesture.delegate = self
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc private func backgroundTapped() {
    viewStore.send(.cancelTapped)
  }
}

// MARK: - UIGestureRecognizerDelegate

extension GoalCreationVC: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    // Only handle taps outside the container
    return !contentView.containerView.bounds.contains(touch.location(in: contentView.containerView))
  }
}