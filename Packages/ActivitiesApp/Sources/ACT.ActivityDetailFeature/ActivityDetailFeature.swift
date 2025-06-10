import ComposableArchitecture
import ACT_SharedModels
import ACT_ActivityGeneralTabFeature
import ACT_ActivityGoalsTabFeature
import ACT_ActivitySessionsTabFeature
import ACT_DatabaseClient

@Reducer
public struct ActivityDetailFeature {
  
  @ObservableState
  public struct State: Equatable {
    public let activityID: ActivityModel.ID
    public var generalTab: ActivityGeneralTabFeature.State
    public var goalsTab: ActivityGoalsTabFeature.State
    public var sessionsTab: ActivitySessionsTabFeature.State
    
    public init(activityID: ActivityModel.ID) {
      self.activityID = activityID
      self.generalTab = ActivityGeneralTabFeature.State(activityID: activityID)
      self.goalsTab = ActivityGoalsTabFeature.State(activityID: activityID)
      self.sessionsTab = ActivitySessionsTabFeature.State(activityID: activityID)
    }
  }
  
  public enum Action: Equatable {
    @CasePathable
    public enum ViewAction: Equatable {
      case willAppear
      case willDisappear
    }

    public enum DelegateAction: Equatable {
      case dismiss
    }

    case view(ViewAction)
    case delegate(DelegateAction)
    case generalTab(ActivityGeneralTabFeature.Action)
    case goalsTab(ActivityGoalsTabFeature.Action)
    case sessionsTab(ActivitySessionsTabFeature.Action)
  }
  
  public typealias Dependencies =
  ActivityGeneralTabFeature.Dependencies &
  HasDatabaseClient

  // Ensure Dependencies conforms to ActivityGeneralTabFeature.Dependencies
  // (which is also HasDatabaseClient)
  
  private let dependencies: Dependencies
  
  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.generalTab, action: \.generalTab) {
      ActivityGeneralTabFeature(dependencies: dependencies)
    }
    
    Scope(state: \.goalsTab, action: \.goalsTab) {
      ActivityGoalsTabFeature()
    }
    
    Scope(state: \.sessionsTab, action: \.sessionsTab) {
      ActivitySessionsTabFeature()
    }
    
    Reduce { state, action in
      switch action {
      case .view(.willAppear):
        return .none
        
      case .view(.willDisappear):
        return .none

      case .delegate:
        return .none

      case .generalTab(.delegate(.dismissScene)):
        // Activity was deleted, dismiss the entire detail view
        return .send(.delegate(.dismiss))
        
      case .generalTab:
        return .none
        
      case .goalsTab:
        return .none
        
      case .sessionsTab:
        return .none
      }
    }
  }
}
