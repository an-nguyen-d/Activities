import ElixirShared
import ComposableArchitecture
import Foundation
import IdentifiedCollections
import ACT_ActivityCreationFeature
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
    
    public init() {
      // Default to today - will be properly set by parent
      self.currentCalendarDate = CalendarDate("2024-01-01")
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
    }

    @CasePathable
    public enum Action: Equatable {
      case activityCreation(ActivityCreationFeature.Action)
    }

    let dependencies: Dependencies

    init(dependencies: Dependencies) {
      self.dependencies = dependencies
    }

    public var body : some Reducer<State, Action> {
      Scope(state: \.activityCreation, action: \.activityCreation) {
        ActivityCreationFeature(dependencies: dependencies)
      }
    }

  }

  // MARK: - Dependencies

  public typealias Dependencies = 
    ActivityCreationFeature.Dependencies &
    HasDatabaseClient

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
            print("📊 Received \(activities.count) activities")
            await send(._internal(.activitiesListResponse(activities)))
          }
        } catch {
          print("❌ Error observing activities: \(error)")
        }
      }
      .cancellable(id: CancelID.activitiesObservation)
      
    case .willDisappear:
      return .cancel(id: CancelID.activitiesObservation)
      
    case .addButtonTapped:
      state.destination = .activityCreation(.init())
      return .none
    }
  }

  // MARK: - InternalAction

  private func coreInternal(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
    switch action {
    case let .activitiesListResponse(activities):
      state.activities = IdentifiedArray(uniqueElements: activities)
      print("✅ Updated state with \(activities.count) activities")
      for activity in activities {
        print("  - \(activity.activity.activityName): streak \(activity.activity.currentStreakCount), sessions: \(activity.sessions.count)")
      }
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
      }

    }

    return .none
  }

}
