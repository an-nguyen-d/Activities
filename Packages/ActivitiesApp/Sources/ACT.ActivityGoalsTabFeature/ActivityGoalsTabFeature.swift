import ComposableArchitecture
import ACT_SharedModels
import ACT_DatabaseClient

@Reducer
public struct ActivityGoalsTabFeature {
  
  @ObservableState
  public struct State: Equatable {
    public let activityID: ActivityModel.ID
    public var goals: [ActivityGoalType] = []
    
    public init(activityID: ActivityModel.ID) {
      self.activityID = activityID
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
    }
    
    case view(ViewAction)
    case _internal(InternalAction)
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
            let response = try await databaseClient.observeActivityGoals(.init(activityId: activityID))
            for try await goals in response {
              await send(._internal(.observeGoalsResponse(.success(goals))))
            }
          } catch {
            await send(._internal(.observeGoalsResponse(.failure(error as! DatabaseClient.DatabaseError))))
          }
        }
        
      case .view(.willDisappear):
        return .none
        
      case .view(.createGoalTapped):
        // TODO: Handle goal creation
        return .none
        
      case let ._internal(.observeGoalsResponse(.success(goals))):
        state.goals = goals
        return .none
        
      case let ._internal(.observeGoalsResponse(.failure(error))):
        // TODO: Handle error
        print("Failed to observe goals: \(error)")
        return .none
      }
    }
  }
}
