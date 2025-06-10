import ComposableArchitecture
import ACT_SharedModels

@Reducer
public struct ActivityDetailFeature {
  
  @ObservableState
  public struct State: Equatable {
    public let activityID: ActivityModel.ID
    
    public init(activityID: ActivityModel.ID) {
      self.activityID = activityID
    }
  }
  
  public enum Action: Equatable {
    @CasePathable
    public enum ViewAction: Equatable {
      case willAppear
      case willDisappear
    }
    
    case view(ViewAction)
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.willAppear):
        return .none
        
      case .view(.willDisappear):
        return .none
      }
    }
  }
}