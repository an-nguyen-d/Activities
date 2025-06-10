import ComposableArchitecture
import ACT_SharedModels
import ACT_DatabaseClient
import Tagged

@Reducer
public struct TagsListFeature {
  
  @ObservableState
  public struct State: Equatable {
    public let activityID: ActivityModel.ID
    public let tagIDsToHide: Set<ActivityTagModel.ID>
    
    public init(
      activityID: ActivityModel.ID,
      tagIDsToHide: Set<ActivityTagModel.ID> = []
    ) {
      self.activityID = activityID
      self.tagIDsToHide = tagIDsToHide
    }
  }
  
  public enum Action: Equatable {
    @CasePathable
    public enum ViewAction: Equatable {
      case willAppear
      case willDisappear
    }
    
    @CasePathable
    public enum DelegateAction: Equatable {
      case dismissed
    }
    
    case view(ViewAction)
    case delegate(DelegateAction)
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
        // TODO: Implement tags observation
        return .none
        
      case .view(.willDisappear):
        // TODO: Cancel observations
        return .none
        
      case .delegate:
        // Delegate actions are handled by parent
        return .none
      }
    }
  }
}