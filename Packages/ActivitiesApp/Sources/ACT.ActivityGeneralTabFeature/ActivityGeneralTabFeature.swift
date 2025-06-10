import ComposableArchitecture
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_TagsListFeature
import IdentifiedCollections

@Reducer
public struct ActivityGeneralTabFeature {
  
  @ObservableState
  public struct State: Equatable {
    public let activityID: ActivityModel.ID
    public var activity: ActivityModel?
    public var tags: IdentifiedArrayOf<ActivityTagModel> = []
    
    @Presents
    public var destination: Destination.State?
    
    public init(activityID: ActivityModel.ID) {
      self.activityID = activityID
    }
  }
  
  private enum CancelID {
    case activityObservation
    case tagsObservation
  }
  
  public enum Action: Equatable {
    @CasePathable
    public enum ViewAction: Equatable {
      case willAppear
      case willDisappear
      case editNameTapped
      case addTagTapped
      case deleteTagTapped(ActivityTagModel)
      case deleteActivityTapped
      case didSelectAlertAction
      
      public enum Alert: Equatable {
        case deleteActivity(DeleteActivityAction)
      }
      case alert(Alert)
    }
    
    @CasePathable
    public enum InternalAction: Equatable {
      case activityResponse(ActivityModel?)
      case tagsResponse([ActivityTagModel])
    }
    
    @CasePathable 
    public enum DelegateAction: Equatable {
      case dismissScene
    }
    
    case view(ViewAction)
    case _internal(InternalAction)
    case delegate(DelegateAction)
    case destination(PresentationAction<Destination.Action>)
  }
  
  public enum DeleteActivityAction: Equatable {
    case confirm
  }
  
  @Reducer
  public struct Destination {
    @CasePathable
    public enum State: Equatable {
      case tagsList(TagsListFeature.State)
      
      public enum Alert: Equatable {
        case deleteActivity
      }
      case alert(Alert)
    }
    
    @CasePathable
    public enum Action: Equatable {
      case tagsList(TagsListFeature.Action)
    }
    
    let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
      self.dependencies = dependencies
    }
    
    public var body: some Reducer<State, Action> {
      Scope(state: \.tagsList, action: \.tagsList) {
        TagsListFeature(dependencies: dependencies)
      }
    }
  }
  
  public typealias Dependencies = HasDatabaseClient
  
  private let dependencies: Dependencies
  private var databaseClient: DatabaseClient { dependencies.databaseClient }
  
  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.willAppear):
        return .merge(
          // Observe activity
          .run { [activityID = state.activityID, databaseClient] send in
            do {
              let stream = try await databaseClient.observeActivity(.init(id: activityID))
              for try await activity in stream {
                await send(._internal(.activityResponse(activity)))
              }
            } catch {
              assertionFailure("Failed to observe activity: \(error)")
            }
          }
          .cancellable(id: CancelID.activityObservation),
          
          // Observe tags for this activity
          .run { [activityID = state.activityID, databaseClient] send in
            do {
              let stream = try await databaseClient.observeActivityTags(.init(activityId: activityID))
              for try await tags in stream {
                await send(._internal(.tagsResponse(tags)))
              }
            } catch {
              assertionFailure("Failed to observe tags: \(error)")
            }
          }
          .cancellable(id: CancelID.tagsObservation)
        )
        
      case .view(.willDisappear):
        return .concatenate(
          .cancel(id: CancelID.activityObservation),
          .cancel(id: CancelID.tagsObservation)
        )
        
      case .view(.editNameTapped):
        // TODO: Present edit name scene
        return .none
        
      case .view(.addTagTapped):
        state.destination = .tagsList(
          TagsListFeature.State(
            activityID: state.activityID,
            tagIDsToHide: Set(state.tags.map(\.id))
          )
        )
        return .none
        
      case let .view(.deleteTagTapped(tag)):
        return .run { [databaseClient, activityID = state.activityID] _ in
          do {
            try await databaseClient.unlinkActivityTag(
              .init(
                activityId: activityID,
                tagId: tag.id
              )
            )
          } catch {
            assertionFailure("Failed to unlink tag: \(error)")
          }
        }
        
      case .view(.deleteActivityTapped):
        state.destination = .alert(.deleteActivity)
        return .none
        
      case .view(.didSelectAlertAction):
        state.destination = nil
        return .none
        
      case .view(.alert(.deleteActivity(.confirm))):
        state.destination = nil
        return .run { [databaseClient, activityID = state.activityID] send in
          do {
            try await databaseClient.deleteActivity(.init(id: activityID))
            // Send delegate action to notify parent that activity was deleted
            await send(.delegate(.dismissScene))
          } catch {
            assertionFailure("Failed to delete activity: \(error)")
          }
        }
        
      case .view(.alert):
        return .none
        
      case ._internal(.activityResponse(let activity)):
        state.activity = activity
        
        // If activity is nil, dismiss the scene
        if activity == nil {
          return .send(.delegate(.dismissScene))
        }
        
        return .none
        
      case let ._internal(.tagsResponse(tags)):
        state.tags = IdentifiedArray(uniqueElements: tags)
        return .none
        
      case .delegate:
        // Delegate actions are handled by parent
        return .none
        
      case .destination(.presented(.tagsList(.delegate(.dismissed)))):
        state.destination = nil
        return .none
        
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination(dependencies: dependencies)
    }
  }
}
