import ComposableArchitecture
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_DaysOfWeekGoalCreationFeature
import ACT_EveryXDaysGoalCreationFeature
import ACT_WeeksPeriodGoalCreationFeature
import ElixirShared

@Reducer
public struct GoalCreationFeature {
  
  public typealias Dependencies = 
    HasDateMaker &
    HasTimeZone
  
  private let dependencies: Dependencies
  
  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  @ObservableState
  public struct State: Equatable {
    public let sessionUnit: ActivityModel.SessionUnit
    public var goalTypeSelectionVisible = true
    
    @Presents
    public var destination: Destination.State?
    
    public init(sessionUnit: ActivityModel.SessionUnit) {
      self.sessionUnit = sessionUnit
    }
  }
  
  public enum Action: TCAFeatureAction, Equatable {
    @CasePathable
    public enum ViewAction: Equatable {
      case cancelTapped
      case daysOfWeekTapped
      case everyXDaysTapped
      case weeksPeriodTapped
    }
    
    public enum InternalAction: Equatable {
      // No internal actions needed for this feature
    }
    
    public enum DelegateAction: Equatable {
      case dismissed
      case goalCreated(GoalCreationRequest)
    }
    
    case view(ViewAction)
    case _internal(InternalAction)
    case delegate(DelegateAction)
    case destination(PresentationAction<Destination.Action>)
  }
  
  public enum GoalCreationRequest: Equatable, Sendable {
    case everyXDays(daysInterval: Int, target: DatabaseClient.CreateActivityGoalTarget.Request)
    case daysOfWeek(
      weeksInterval: Int,
      sundayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
      mondayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
      tuesdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
      wednesdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
      thursdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
      fridayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
      saturdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?
    )
    case weeksPeriod(target: DatabaseClient.CreateActivityGoalTarget.Request)
  }
  
  @Reducer
  public struct Destination {
    @CasePathable
    public enum State: Equatable {
      case daysOfWeekGoalCreation(DaysOfWeekGoalCreationFeature.State)
      case everyXDaysGoalCreation(EveryXDaysGoalCreationFeature.State)
      case weeksPeriodGoalCreation(WeeksPeriodGoalCreationFeature.State)
    }
    
    @CasePathable
    public enum Action: Equatable {
      case daysOfWeekGoalCreation(DaysOfWeekGoalCreationFeature.Action)
      case everyXDaysGoalCreation(EveryXDaysGoalCreationFeature.Action)
      case weeksPeriodGoalCreation(WeeksPeriodGoalCreationFeature.Action)
    }
    
    let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
      self.dependencies = dependencies
    }
    
    public var body: some Reducer<State, Action> {
      Scope(state: \.daysOfWeekGoalCreation, action: \.daysOfWeekGoalCreation) {
        DaysOfWeekGoalCreationFeature(dependencies: dependencies)
      }
      Scope(state: \.everyXDaysGoalCreation, action: \.everyXDaysGoalCreation) {
        EveryXDaysGoalCreationFeature(dependencies: dependencies)
      }
      Scope(state: \.weeksPeriodGoalCreation, action: \.weeksPeriodGoalCreation) {
        WeeksPeriodGoalCreationFeature(dependencies: dependencies)
      }
    }
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.cancelTapped):
        return .send(.delegate(.dismissed))
        
      case .view(.daysOfWeekTapped):
        state.goalTypeSelectionVisible = false
        state.destination = .daysOfWeekGoalCreation(
          DaysOfWeekGoalCreationFeature.State(sessionUnit: state.sessionUnit)
        )
        return .none
        
      case .view(.everyXDaysTapped):
        state.goalTypeSelectionVisible = false
        state.destination = .everyXDaysGoalCreation(
          EveryXDaysGoalCreationFeature.State(sessionUnit: state.sessionUnit)
        )
        return .none
        
      case .view(.weeksPeriodTapped):
        state.goalTypeSelectionVisible = false
        state.destination = .weeksPeriodGoalCreation(
          WeeksPeriodGoalCreationFeature.State(sessionUnit: state.sessionUnit)
        )
        return .none
        
      case ._internal:
        return .none
        
      case .delegate:
        return .none
        
      case let .destination(.presented(destinationAction)):
        switch destinationAction {
        case let .daysOfWeekGoalCreation(.delegate(delegateAction)):
          switch delegateAction {
          case .dismissed:
            return .send(.delegate(.dismissed))
          case let .goalCreated(weeksInterval, targets):
            let request = GoalCreationRequest.daysOfWeek(
              weeksInterval: weeksInterval,
              sundayGoal: targets[.sunday],
              mondayGoal: targets[.monday],
              tuesdayGoal: targets[.tuesday],
              wednesdayGoal: targets[.wednesday],
              thursdayGoal: targets[.thursday],
              fridayGoal: targets[.friday],
              saturdayGoal: targets[.saturday]
            )
            return .run { send in
              await send(.delegate(.goalCreated(request)))
              await send(.delegate(.dismissed))
            }
          }
          
        case let .everyXDaysGoalCreation(.delegate(delegateAction)):
          switch delegateAction {
          case .dismissed:
            return .send(.delegate(.dismissed))
          case let .goalCreated(daysInterval, target):
            let request = GoalCreationRequest.everyXDays(
              daysInterval: daysInterval,
              target: target
            )
            return .run { send in
              await send(.delegate(.goalCreated(request)))
              await send(.delegate(.dismissed))
            }
          }
          
        case let .weeksPeriodGoalCreation(.delegate(delegateAction)):
          switch delegateAction {
          case .dismissed:
            return .send(.delegate(.dismissed))
          case let .goalCreated(target):
            let request = GoalCreationRequest.weeksPeriod(target: target)
            return .run { send in
              await send(.delegate(.goalCreated(request)))
              await send(.delegate(.dismissed))
            }
          }
          
        default:
          return .none
        }
        
      case .destination(.dismiss):
        state.destination = nil
        state.goalTypeSelectionVisible = true
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination(dependencies: dependencies)
    }
  }
}