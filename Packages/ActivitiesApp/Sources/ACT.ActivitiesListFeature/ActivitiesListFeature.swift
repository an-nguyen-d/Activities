import ElixirShared
import ComposableArchitecture
import Foundation
import ACT_ActivityCreationFeature

@Reducer
public struct ActivitiesListFeature {

  @ObservableState
  public struct State: Equatable {

    @Presents
    public var destination: Destination.State?

    public init() {

    }
  }

  public enum Action: TCAFeatureAction, Equatable {

    public enum ViewAction: Equatable {
      case addButtonTapped
    }

    public enum InternalAction: Equatable {

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
  Any

  private let dependencies: Dependencies

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
    case .addButtonTapped:
      state.destination = .activityCreation(.init())
      return .none
    }
  }

  // MARK: - InternalAction

  private func coreInternal(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
    switch action {

    }

    return .none
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
          case .activityCreated(let activity):
            // TODO: Handle activity created
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
