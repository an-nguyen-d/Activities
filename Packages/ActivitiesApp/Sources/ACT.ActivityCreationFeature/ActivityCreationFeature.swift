import Foundation
import ComposableArchitecture
import ElixirShared
import ACT_SharedModels

@Reducer
public struct ActivityCreationFeature {
    
    public typealias Dependencies = Any
    
    private let dependencies: Dependencies
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }
    
    public enum Action: TCAFeatureAction, Equatable {
        public enum ViewAction: Equatable {
            case cancelButtonTapped
            case saveButtonTapped
        }
        
        public enum InternalAction: Equatable {
            
        }
        
        public enum DelegateAction: Equatable {
            case activityCreated(ActivityModel)
        }
        
        case view(ViewAction)
        case _internal(InternalAction)
        case delegate(DelegateAction)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            core(into: &state, action: action)
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
        }
    }
    
    private func coreView(into state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .cancelButtonTapped:
            return .none
            
        case .saveButtonTapped:
            return .none
        }
    }
    
    private func coreInternal(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
        switch action {
        }
    }
}