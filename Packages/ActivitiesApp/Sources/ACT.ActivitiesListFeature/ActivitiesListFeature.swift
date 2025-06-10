import ElixirShared
import ComposableArchitecture
import Foundation
import IdentifiedCollections
import ACT_ActivityCreationFeature
import ACT_CreateSessionFeature
import ACT_ActivityDetailFeature
import ACT_SharedModels
import ACT_DatabaseClient

@Reducer
public struct ActivitiesListFeature {

  @ObservableState
  public struct State: Equatable {
    public var activities: IdentifiedArrayOf<ActivityListItemModel> = []
    public var currentCalendarDate: CalendarDate
    
    @Presents
    public var destination: Destination.State?

    public init(currentCalendarDate: CalendarDate) {
      self.currentCalendarDate = currentCalendarDate
    }

  }
  
  private enum CancelID {
    case activitiesObservation
  }

  public enum Action: TCAFeatureAction, Equatable {

    public enum ViewAction: Equatable {
      case willAppear
      case willDisappear
      case addButtonTapped
      case quickLogTapped(activityId: ActivityModel.ID)
      case activityCellTapped(activityId: ActivityModel.ID)
      case activityLongPressed(activityId: ActivityModel.ID)
    }

    public enum InternalAction: Equatable {
      case activitiesListResponse([ActivityListItemModel])
    }

    public enum DelegateAction: Equatable {

    }

    case view(ViewAction)
    case _internal(InternalAction)
    case delegate(DelegateAction)
    case destination(PresentationAction<Destination.Action>)

  }

  @Reducer
  public struct Destination {

    @CasePathable
    public enum State: Equatable {
      case activityCreation(ActivityCreationFeature.State)
      case createSession(CreateSessionFeature.State)
      case activityDetail(ActivityDetailFeature.State)
    }

    @CasePathable
    public enum Action: Equatable {
      case activityCreation(ActivityCreationFeature.Action)
      case createSession(CreateSessionFeature.Action)
      case activityDetail(ActivityDetailFeature.Action)
    }

    let dependencies: Dependencies

    init(dependencies: Dependencies) {
      self.dependencies = dependencies
    }

    public var body : some Reducer<State, Action> {
      Scope(state: \.activityCreation, action: \.activityCreation) {
        ActivityCreationFeature(dependencies: dependencies)
      }
      Scope(state: \.createSession, action: \.createSession) {
        CreateSessionFeature(dependencies: dependencies)
      }
      Scope(state: \.activityDetail, action: \.activityDetail) {
        ActivityDetailFeature()
      }
    }

  }

  // MARK: - Dependencies

  public typealias Dependencies = 
    ActivityCreationFeature.Dependencies &
    CreateSessionFeature.Dependencies &
    HasDatabaseClient &
    HasDateMaker &
    HasTimeZone

  private let dependencies: Dependencies
  private var databaseClient: DatabaseClient { dependencies.databaseClient }

  // MARK: - Init

  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  // MARK: - Reducer

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
    case let .destination(action):
      return coreDestination(into: &state, action: action)
    }
  }

  private func coreView(into state: inout State, action: Action.ViewAction) -> Effect<Action> {
    switch action {
    case .willAppear:
      return .run { [databaseClient] send in
        do {
          let stream = try await databaseClient.observeActivitiesList(.init())
          for try await activities in stream {
            await send(._internal(.activitiesListResponse(activities)))
          }
        } catch {
          assertionFailure("Failed to observe activities: \(error)")
        }
      }
      .cancellable(id: CancelID.activitiesObservation)
      
    case .willDisappear:
      return .cancel(id: CancelID.activitiesObservation)
      
    case .addButtonTapped:
      state.destination = .activityCreation(.init())
      return .none
      
    case let .quickLogTapped(activityId: activityId):
      // Find the activity to determine if it's time-based
      guard let activityItem = state.activities[id: activityId] else {
        assertionFailure("Attempted to quick log for non-existent activity: \(activityId)")
        return .none
      }
      
      let activity = activityItem.activity
      let value: Double
      
      switch activity.sessionUnit {
      case .seconds:
        // For time activities, log 1 minute (60 seconds)
        value = 60
      case .integer:
        // For integer activities, log 1
        value = 1
      case .floating:
        // For floating activities, log 1.0
        value = 1.0
      }
      
      // Quick log value for activity
      
      let now = dependencies.dateMaker.date()
      let calendarDate = CalendarDate(
        from: now,
        timeZone: dependencies.timeZone
      )
      
      return .run { [databaseClient] _ in
        do {
          _ = try await databaseClient.createSession(
            .init(
              activityId: activityId,
              value: value,
              createDate: now,
              completeDate: now,
              completeCalendarDate: calendarDate
            )
          )
          
          // Quick log completed successfully
        } catch {
          assertionFailure("Failed to quick log: \(error)")
        }
      }
      
    case let .activityCellTapped(activityId: activityId):
      // Find the activity to get its unit type
      guard let activityItem = state.activities[id: activityId] else {
        assertionFailure("Attempted to create session for non-existent activity: \(activityId)")
        return .none
      }
      
      state.destination = .createSession(
        CreateSessionFeature.State(
          activityID: activityId,
          sessionUnit: activityItem.activity.sessionUnit
        )
      )
      return .none
      
    case let .activityLongPressed(activityId: activityId):
      state.destination = .activityDetail(
        ActivityDetailFeature.State(activityID: activityId)
      )
      return .none
    }
  }

  // MARK: - InternalAction

  private func coreInternal(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
    switch action {
    case let .activitiesListResponse(activities):
      state.activities = IdentifiedArray(uniqueElements: activities)
      // Update state with activities
      return .none
    }
  }

  // MARK: - DestinationAction

  private func coreDestination(into state: inout State, action: PresentationAction<Destination.Action>) -> Effect<Action> {
    switch action {
    case .dismiss:
      break

    case .presented(let action):
      switch action {
      case .activityCreation(let action):
        switch action {
        case .delegate(let delegateAction):
          switch delegateAction {
          case .dismissed:
            state.destination = nil
            return .none
          }
        default:
          return .none
        }
        
      case .createSession(let action):
        switch action {
        case .delegate(let delegateAction):
          switch delegateAction {
          case .dismissed:
            state.destination = nil
            return .none
          }
        default:
          return .none
        }
        
      case .activityDetail:
        return .none
      }

    }

    return .none
  }

}
