import Foundation
import ComposableArchitecture
import ElixirShared
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_DaysOfWeekGoalCreationFeature
import ACT_EveryXDaysGoalCreationFeature
import ACT_WeeksPeriodGoalCreationFeature

@Reducer
public struct ActivityCreationFeature {

  public typealias Dependencies = Any

  private let dependencies: Dependencies

  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  @ObservableState
  public struct State: Equatable {
    public var activityName: String = ""
    public var selectedSessionUnit: SessionUnitType = .integer
    public var customUnitName: String = "Sessions"
    public var goal: String? = nil
    
    @Presents
    public var destination: Destination.State?
    

    public var goalDescription: String {
      return goal ?? "No goal"
    }

    public var isValid: Bool {
      return !activityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public init() {}
  }
  
  public enum GoalSelectionAction: Equatable {
    case daysOfWeek
    case everyXDays
    case weeksPeriod
  }
  
  @Reducer
  public struct Destination {
    @CasePathable
    public enum State: Equatable {
      case daysOfWeekGoalCreation(DaysOfWeekGoalCreationFeature.State)
      case everyXDaysGoalCreation(EveryXDaysGoalCreationFeature.State)
      case weeksPeriodGoalCreation(WeeksPeriodGoalCreationFeature.State)
      
      public enum Alert: Equatable {
        case goalSelection
      }
      case alert(Alert)
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

  public enum Action: TCAFeatureAction, Equatable {
    public enum ViewAction: Equatable {
      case cancelButtonTapped
      case saveButtonTapped
      case activityNameChanged(String)
      case sessionUnitChanged(SessionUnitType)
      case customUnitNameChanged(String)
      case editGoalButtonTapped
      case didSelectAlertAction

      public enum Alert: Equatable {
        case goalSelection(GoalSelectionAction)
      }
      case alert(Alert)
    }

    public enum InternalAction: Equatable {

    }

    public enum DelegateAction: Equatable {
      case activityCreated(ActivityModel)
    }

    case view(ViewAction)
    case _internal(InternalAction)
    case delegate(DelegateAction)
    case destination(PresentationAction<Destination.Action>)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      core(into: &state, action: action)
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination(dependencies: dependencies)
    }
  }

  private func core(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case let .view(action):
      return coreView(into: &state, action: action)

    case let ._internal(action):
      return coreInternal(into: &state, action: action)

    case .delegate:
      return .none
      
    case let .destination(.presented(destinationAction)):
      switch destinationAction {
      case let .daysOfWeekGoalCreation(.delegate(delegateAction)):
        switch delegateAction {
        case .dismissed:
          state.destination = nil
          return .none
        case .goalCreated:
          state.destination = nil
          return .none
        }

      case let .everyXDaysGoalCreation(.delegate(delegateAction)):
        switch delegateAction {
        case .dismissed:
          state.destination = nil
          return .none
        case .goalCreated:
          state.destination = nil
          return .none
        }
      case let .weeksPeriodGoalCreation(.delegate(delegateAction)):
        switch delegateAction {
        case .dismissed:
          state.destination = nil
          return .none
        case let .goalCreated(targetRequest):
          // TODO: Store the target request and create the actual goal when saving the activity
          state.goal = "Weekly goal: \(targetRequest.goalSuccessCriteria.rawValue) \(Int(targetRequest.goalValue)) per week"
          state.destination = nil
          return .none
        }
      default:
        return .none
      }
      
    case .destination:
      return .none
    }
  }

  private func coreView(into state: inout State, action: Action.ViewAction) -> Effect<Action> {
    switch action {
    case .cancelButtonTapped:
      return .none

    case .saveButtonTapped:
      return .none

    case let .activityNameChanged(name):
      state.activityName = name
      return .none

    case let .sessionUnitChanged(unit):
      state.selectedSessionUnit = unit
      // Reset custom unit name when switching to time
      if unit == .time {
        state.customUnitName = ""
      } else if state.customUnitName.isEmpty {
        state.customUnitName = "Sessions"
      }
      return .none

    case let .customUnitNameChanged(name):
      state.customUnitName = name
      return .none

    case .editGoalButtonTapped:
      state.destination = .alert(.goalSelection)
      return .none

    case .didSelectAlertAction:
      state.destination = nil
      return .none

    case let .alert(action):
      switch action {
      case let .goalSelection(goalAction):
        switch goalAction {
        case .daysOfWeek:
          state.destination = .daysOfWeekGoalCreation(DaysOfWeekGoalCreationFeature.State())
        case .everyXDays:
          state.destination = .everyXDaysGoalCreation(EveryXDaysGoalCreationFeature.State())
        case .weeksPeriod:
          let sessionUnit: ActivityModel.SessionUnit
          switch state.selectedSessionUnit {
          case .integer:
            sessionUnit = .integer(state.customUnitName.isEmpty ? "sessions" : state.customUnitName)
          case .floating:
            sessionUnit = .floating(state.customUnitName.isEmpty ? "units" : state.customUnitName)
          case .time:
            sessionUnit = .seconds
          }
          state.destination = .weeksPeriodGoalCreation(WeeksPeriodGoalCreationFeature.State(sessionUnit: sessionUnit))
        }
        return .none
      }
    }
  }

  private func coreInternal(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
    switch action {
    }
  }

}
