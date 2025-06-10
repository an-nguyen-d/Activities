import ComposableArchitecture
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_TagsListFeature

@Reducer
public struct ActivityGeneralTabFeature {
  
  @ObservableState
  public struct State: Equatable {
    public let activityID: ActivityModel.ID
    public var activity: ActivityModel?
    
    @Presents
    public var destination: Destination.State?
    
    public init(activityID: ActivityModel.ID) {
      self.activityID = activityID
    }
  }
  
  private enum CancelID {
    case activityObservation
  }
  
  public enum Action: Equatable {
    @CasePathable
    public enum ViewAction: Equatable {
      case willAppear
      case willDisappear
      case editNameTapped
      case addTagTapped
      case deleteTagTapped(ActivityTagModel)
    }
    
    @CasePathable
    public enum InternalAction: Equatable {
      case activityResponse(ActivityModel?)
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
  
  @Reducer
  public struct Destination {
    @CasePathable
    public enum State: Equatable {
      case tagsList(TagsListFeature.State)
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
        return .run { [activityID = state.activityID, databaseClient] send in
          do {
            let stream = try await databaseClient.observeActivity(.init(id: activityID))
            for try await activity in stream {
              await send(._internal(.activityResponse(activity)))
            }
          } catch {
            assertionFailure("Failed to observe activity: \(error)")
          }
        }
        .cancellable(id: CancelID.activityObservation)
        
      case .view(.willDisappear):
        return .cancel(id: CancelID.activityObservation)
        
      case .view(.editNameTapped):
        // TODO: Present edit name scene
        return .none
        
      case .view(.addTagTapped):
        state.destination = .tagsList(
          TagsListFeature.State(
            activityID: state.activityID,
            tagIDsToHide: Set() // TODO: Will be populated from observed tags
          )
        )
        return .none
        
      case .view(.deleteTagTapped):
        // TODO: Delete tag from activity
        return .none
        
      case ._internal(.activityResponse(let activity)):
        state.activity = activity
        
        // If activity is nil, dismiss the scene
        if activity == nil {
          return .send(.delegate(.dismissScene))
        }
        
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
