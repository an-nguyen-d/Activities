import UIKit
import ComposableArchitecture
import ACT_GoalCreationFeature
import ACT_DaysOfWeekGoalCreationFeatureiOS
import ACT_EveryXDaysGoalCreationFeatureiOS
import ACT_WeeksPeriodGoalCreationFeatureiOS

@MainActor
final class GoalCreationRouter {
  
  public typealias Module = GoalCreationFeature
  public typealias Dependencies = Module.Dependencies
  
  weak var viewController: UIViewController?
  
  @UIBindable
  private var store: StoreOf<Module>
  
  private let dependencies: Dependencies
  
  init(
    viewController: UIViewController,
    store: StoreOf<Module>,
    dependencies: Dependencies
  ) {
    self.viewController = viewController
    self.store = store
    self.dependencies = dependencies
    bindRouting()
  }
  
  private func bindRouting() {
    // DaysOfWeek goal creation
    viewController?.present(
      item: $store.scope(
        state: \.destination?.daysOfWeekGoalCreation,
        action: \.destination.daysOfWeekGoalCreation
      )
    ) { [dependencies] store in
      let destinationVC = DaysOfWeekGoalCreationVC(
        store: store,
        dependencies: dependencies
      )
      return UINavigationController(rootViewController: destinationVC)
    }
    
    // EveryXDays goal creation
    viewController?.present(
      item: $store.scope(
        state: \.destination?.everyXDaysGoalCreation,
        action: \.destination.everyXDaysGoalCreation
      )
    ) { [dependencies] store in
      let destinationVC = EveryXDaysGoalCreationVC(
        store: store,
        dependencies: dependencies
      )
      return UINavigationController(rootViewController: destinationVC)
    }
    
    // WeeksPeriod goal creation
    viewController?.present(
      item: $store.scope(
        state: \.destination?.weeksPeriodGoalCreation,
        action: \.destination.weeksPeriodGoalCreation
      )
    ) { [dependencies] store in
      let destinationVC = WeeksPeriodGoalCreationVC(
        store: store,
        dependencies: dependencies
      )
      return UINavigationController(rootViewController: destinationVC)
    }
  }
}