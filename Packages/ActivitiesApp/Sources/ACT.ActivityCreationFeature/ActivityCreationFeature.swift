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

  public typealias Dependencies =
  HasDatabaseClient &
  HasDateMaker &
  HasTimeZone

  private let dependencies: Dependencies
  private var databaseClient: DatabaseClient { dependencies.databaseClient }
  private var date: () -> Date { dependencies.dateMaker.date }
  private var timeZone: TimeZone { dependencies.timeZone }

  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  @ObservableState
  public struct State: Equatable {
    public var activityName: String = ""
    public var selectedSessionUnit: SessionUnitType = .integer
    public var customUnitName: String = "Sessions"
    public var goalDescription: String? = nil
    
    // Store the goal creation data to create after activity
    public enum PendingGoal: Equatable, Sendable {
      case everyXDays(daysInterval: Int, target: DatabaseClient.CreateActivityGoalTarget.Request)
      case daysOfWeek(weeksInterval: Int, sundayGoal: DatabaseClient.CreateActivityGoalTarget.Request?, mondayGoal: DatabaseClient.CreateActivityGoalTarget.Request?, tuesdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?, wednesdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?, thursdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?, fridayGoal: DatabaseClient.CreateActivityGoalTarget.Request?, saturdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?)
      case weeksPeriod(target: DatabaseClient.CreateActivityGoalTarget.Request)
    }
    public var pendingGoal: PendingGoal?
    
    @Presents
    public var destination: Destination.State?

    public var isValid: Bool {
      // Activity name must not be empty
      guard !activityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return false
      }
      
      // For non-time units, unit name must not be empty
      switch selectedSessionUnit {
      case .integer, .floating:
        return !customUnitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      case .time:
        return true
      }
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
      case createActivityWithGoalResponse(Result<ActivityModel, DatabaseClient.DatabaseError>)
      case dismiss
    }

    public enum DelegateAction: Equatable {
      case dismissed
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
        case let .goalCreated(weeksInterval, targets):
          // Store pending goal
          state.pendingGoal = .daysOfWeek(
            weeksInterval: weeksInterval,
            sundayGoal: targets[.sunday],
            mondayGoal: targets[.monday],
            tuesdayGoal: targets[.tuesday],
            wednesdayGoal: targets[.wednesday],
            thursdayGoal: targets[.thursday],
            fridayGoal: targets[.friday],
            saturdayGoal: targets[.saturday]
          )
          
          // Create description
          let targetCount = targets.compactMap { $0 }.count
          state.goalDescription = GoalDescriptions.daysOfWeekSummaryDescription(
            targetCount: targetCount,
            weeksInterval: weeksInterval
          )
          state.destination = nil
          return .none
        }

      case let .everyXDaysGoalCreation(.delegate(delegateAction)):
        switch delegateAction {
        case .dismissed:
          state.destination = nil
          return .none
        case let .goalCreated(daysInterval, target):
          // Store pending goal
          state.pendingGoal = .everyXDays(daysInterval: daysInterval, target: target)
          
          // Create description
          state.goalDescription = GoalDescriptions.everyXDaysDescription(
            daysInterval: daysInterval,
            goalValue: target.goalValue,
            successCriteria: target.goalSuccessCriteria
          )
          state.destination = nil
          return .none
        }
      case let .weeksPeriodGoalCreation(.delegate(delegateAction)):
        switch delegateAction {
        case .dismissed:
          state.destination = nil
          return .none
        case let .goalCreated(targetRequest):
          // Store pending goal
          state.pendingGoal = .weeksPeriod(target: targetRequest)
          
          // Create description
          state.goalDescription = GoalDescriptions.weeksPeriodDescription(
            goalValue: targetRequest.goalValue,
            successCriteria: targetRequest.goalSuccessCriteria
          )
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
      // Validate state
      guard state.isValid else { return .none }
      
      // Ensure we have a pending goal
      guard let pendingGoal = state.pendingGoal else {
        assertionFailure("Save should not be enabled without a goal")
        return .none
      }
      
      // Create the session unit
      let sessionUnit: ActivityModel.SessionUnit
      switch state.selectedSessionUnit {
      case .integer:
        sessionUnit = .integer(state.customUnitName.trimmingCharacters(in: .whitespacesAndNewlines))
      case .floating:
        sessionUnit = .floating(state.customUnitName.trimmingCharacters(in: .whitespacesAndNewlines))
      case .time:
        sessionUnit = .seconds
      }
      
      // Create activity ID
      let activityId = ActivityModel.ID(rawValue: Int64.random(in: 1...Int64.max))
      
      // Create activity request
      let createActivityRequest = DatabaseClient.CreateActivity.Request(
        id: activityId,
        activityName: state.activityName.trimmingCharacters(in: .whitespacesAndNewlines),
        sessionUnit: sessionUnit,
        currentStreakCount: 0,
        lastGoalSuccessCheckCalendarDate: nil
      )
      
      // Get date and calendar date
      let now = date()
      let effectiveDate = CalendarDate(from: now, timeZone: timeZone)
      
      // Create goal request based on pending goal type
      let goalRequest: DatabaseClient.CreateActivityWithGoal.GoalRequest
      switch pendingGoal {
      case let .everyXDays(daysInterval, target):
        goalRequest = .everyXDays(
          .init(
            activityId: activityId,
            createDate: now,
            effectiveCalendarDate: effectiveDate,
            daysInterval: daysInterval,
            target: target
          )
        )
      case let .daysOfWeek(weeksInterval, sundayGoal, mondayGoal, tuesdayGoal, wednesdayGoal, thursdayGoal, fridayGoal, saturdayGoal):
        goalRequest = .daysOfWeek(
          .init(
            activityId: activityId,
            createDate: now,
            effectiveCalendarDate: effectiveDate,
            weeksInterval: weeksInterval,
            mondayGoal: mondayGoal,
            tuesdayGoal: tuesdayGoal,
            wednesdayGoal: wednesdayGoal,
            thursdayGoal: thursdayGoal,
            fridayGoal: fridayGoal,
            saturdayGoal: saturdayGoal,
            sundayGoal: sundayGoal
          )
        )
      case let .weeksPeriod(target):
        goalRequest = .weeksPeriod(
          .init(
            activityId: activityId,
            createDate: now,
            effectiveCalendarDate: effectiveDate,
            target: target
          )
        )
      }
      
      // Create the request for atomic creation
      let request = DatabaseClient.CreateActivityWithGoal.Request(
        activity: createActivityRequest,
        goal: goalRequest
      )
      
      return .run { [databaseClient] send in
        do {
          let activity = try await databaseClient.createActivityWithGoal(request)
          await send(._internal(.createActivityWithGoalResponse(.success(activity))))
        } catch {
          await send(._internal(.createActivityWithGoalResponse(.failure(error as! DatabaseClient.DatabaseError))))
        }
      }

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
        let sessionUnit: ActivityModel.SessionUnit
        switch state.selectedSessionUnit {
        case .integer:
          sessionUnit = .integer(state.customUnitName.isEmpty ? "sessions" : state.customUnitName)
        case .floating:
          sessionUnit = .floating(state.customUnitName.isEmpty ? "units" : state.customUnitName)
        case .time:
          sessionUnit = .seconds
        }

        switch goalAction {
        case .daysOfWeek:
          state.destination = .daysOfWeekGoalCreation(DaysOfWeekGoalCreationFeature.State(sessionUnit: sessionUnit))
        case .everyXDays:
          state.destination = .everyXDaysGoalCreation(EveryXDaysGoalCreationFeature.State(sessionUnit: sessionUnit))
        case .weeksPeriod:
          state.destination = .weeksPeriodGoalCreation(WeeksPeriodGoalCreationFeature.State(sessionUnit: sessionUnit))
        }
        return .none
      }
    }
  }

  private func coreInternal(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
    switch action {
    case .createActivityWithGoalResponse(.success):
      // Both activity and goal created successfully in a single transaction
      // Dismiss after a small delay to give user feedback that save was successful
      return .run { send in
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        await send(._internal(.dismiss))
      }
      
    case let .createActivityWithGoalResponse(.failure(error)):
      // TODO: Handle error - show alert
      print("Failed to create activity with goal: \(error)")
      return .none
      
    case .dismiss:
      // Tell the parent to dismiss this view
      return .send(.delegate(.dismissed))
    }
  }

}
