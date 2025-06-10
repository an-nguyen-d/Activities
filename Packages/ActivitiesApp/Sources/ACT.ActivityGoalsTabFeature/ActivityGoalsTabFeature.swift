import Foundation
import ComposableArchitecture
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_GoalCreationFeature
import ElixirShared

@Reducer
public struct ActivityGoalsTabFeature {
  
  @ObservableState
  public struct State: Equatable {
    public let activityID: ActivityModel.ID
    public var goals: [ActivityGoalType] = []
    
    // Activity details needed for goal creation
    public var activitySessionUnit: ActivityModel.SessionUnit?
    
    @Presents
    public var destination: Destination.State?
    
    public init(activityID: ActivityModel.ID) {
      self.activityID = activityID
    }
  }
  
  // MARK: - Destination
  
  @Reducer
  public struct Destination {
    @CasePathable
    public enum State: Equatable {
      case goalCreation(GoalCreationFeature.State)
    }
    
    @CasePathable
    public enum Action: Equatable {
      case goalCreation(GoalCreationFeature.Action)
    }
    
    let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
      self.dependencies = dependencies
    }
    
    public var body: some Reducer<State, Action> {
      Scope(state: \.goalCreation, action: \.goalCreation) {
        GoalCreationFeature(dependencies: dependencies)
      }
    }
  }
  
  public enum Action: Equatable {
    @CasePathable
    public enum ViewAction: Equatable {
      case willAppear
      case willDisappear
      case createGoalTapped
    }
    
    public enum InternalAction: Equatable {
      case observeGoalsResponse(Result<[ActivityGoalType], DatabaseClient.DatabaseError>)
      case observeActivityResponse(Result<ActivityModel, DatabaseClient.DatabaseError>)
      case createGoalResponse(Result<ActivityGoalType, DatabaseClient.DatabaseError>)
    }
    
    case view(ViewAction)
    case _internal(InternalAction)
    case destination(PresentationAction<Destination.Action>)
  }
  
  public typealias Dependencies = HasDatabaseClient & HasDateMaker & HasTimeZone
  
  private let dependencies: Dependencies
  private var databaseClient: DatabaseClient { dependencies.databaseClient }
  private var date: () -> Date { dependencies.dateMaker.date }
  private var timeZone: TimeZone { dependencies.timeZone }
  
  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.willAppear):
        return .merge(
          // Observe goals
          .run { [activityID = state.activityID, databaseClient] send in
            do {
              let response = try await databaseClient.observeActivityGoals(.init(activityId: activityID))
              for try await goals in response {
                await send(._internal(.observeGoalsResponse(.success(goals))))
              }
            } catch {
              await send(._internal(.observeGoalsResponse(.failure(error as! DatabaseClient.DatabaseError))))
            }
          },
          // Fetch activity details for session unit
          .run { [activityID = state.activityID, databaseClient] send in
            do {
              let activity = try await databaseClient.fetchActivity(.init(id: activityID))
              if let activity = activity {
                await send(._internal(.observeActivityResponse(.success(activity))))
              } else {
                await send(._internal(.observeActivityResponse(.failure(.recordNotFound))))
              }
            } catch {
              await send(._internal(.observeActivityResponse(.failure(error as! DatabaseClient.DatabaseError))))
            }
          }
        )
        
      case .view(.willDisappear):
        return .none
        
      case .view(.createGoalTapped):
        guard let sessionUnit = state.activitySessionUnit else {
          // We need the session unit to show goal creation
          return .none
        }
        state.destination = .goalCreation(GoalCreationFeature.State(sessionUnit: sessionUnit))
        return .none
        
      case let ._internal(.observeGoalsResponse(.success(goals))):
        state.goals = goals
        return .none
        
      case let ._internal(.observeGoalsResponse(.failure(error))):
        // TODO: Handle error
        print("Failed to observe goals: \(error)")
        return .none
        
      case let ._internal(.observeActivityResponse(.success(activity))):
        state.activitySessionUnit = activity.sessionUnit
        return .none
        
      case let ._internal(.observeActivityResponse(.failure(error))):
        // TODO: Handle error
        print("Failed to read activity: \(error)")
        return .none
        
      case ._internal(.createGoalResponse(.success)):
        // Goal created successfully, it will appear via observation
        return .none
        
      case let ._internal(.createGoalResponse(.failure(error))):
        // TODO: Handle error
        print("Failed to create goal: \(error)")
        return .none
        
      case let .destination(.presented(.goalCreation(.delegate(delegateAction)))):
        switch delegateAction {
        case .dismissed:
          state.destination = nil
          return .none
          
        case let .goalCreated(goalRequest):
          // Get date and calendar date
          let now = date()
          let effectiveDate = CalendarDate(from: now, timeZone: timeZone)
          
          state.destination = nil
          
          // Create goal based on type
          return .run { [activityID = state.activityID, databaseClient] send in
            do {
              let goal: ActivityGoalType
              switch goalRequest {
              case let .everyXDays(daysInterval, target):
                let everyXDaysGoal = try await databaseClient.createEveryXDaysGoal(
                  .init(
                    activityId: activityID,
                    createDate: now,
                    effectiveCalendarDate: effectiveDate,
                    daysInterval: daysInterval,
                    target: target
                  )
                )
                goal = .everyXDays(everyXDaysGoal)
                
              case let .daysOfWeek(weeksInterval, sundayGoal, mondayGoal, tuesdayGoal, wednesdayGoal, thursdayGoal, fridayGoal, saturdayGoal):
                let daysOfWeekGoal = try await databaseClient.createDaysOfWeekGoal(
                  .init(
                    activityId: activityID,
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
                goal = .daysOfWeek(daysOfWeekGoal)
                
              case let .weeksPeriod(target):
                let weeksPeriodGoal = try await databaseClient.createWeeksPeriodGoal(
                  .init(
                    activityId: activityID,
                    createDate: now,
                    effectiveCalendarDate: effectiveDate,
                    target: target
                  )
                )
                goal = .weeksPeriod(weeksPeriodGoal)
              }
              
              await send(._internal(.createGoalResponse(.success(goal))))
            } catch {
              await send(._internal(.createGoalResponse(.failure(error as! DatabaseClient.DatabaseError))))
            }
          }
        }
        
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination(dependencies: dependencies)
    }
  }
}
