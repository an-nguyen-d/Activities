import Foundation
import ComposableArchitecture
import ElixirShared

@Reducer
public struct ActivitiesListFeature {

  @ObservableState
  public struct State: Equatable {
    public var count = 0

    @Presents
    public var destination: Destination.State?

    public init() {

    }
  }

  public enum Action: TCAFeatureAction, Equatable {

    public enum ViewAction: Equatable {
      case decrementButtonTapped
      case incrementButtonTapped
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
      case createActivity(CreateActivityFeature.State)
    }

    @CasePathable
    public enum Action: Equatable {
      case createActivity(CreateActivityFeature.Action)
    }

    public var body : some Reducer<State, Action> {
      Scope(state: \.createActivity, action: \.createActivity) {
        CreateActivityFeature()
      }
    }

  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      core(into: &state, action: action)
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
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
    case .decrementButtonTapped:
      state.count -= 1
      return .none

    case .incrementButtonTapped:
      state.count += 1

      if state.count == 5 {
        state.destination = .createActivity(
          .init()
        )
      }

      return .none

    }
    return .none
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
      case let .createActivity(.delegate(action)):
        switch action {
        case .squareCounter:
          state.count *= state.count

        }

      case .createActivity:
        break

      }

    }

    return .none
  }

  public init() {

  }




}

@Reducer
public struct CreateActivityFeature {

  @ObservableState
  public struct State: Equatable {
    public var isOn = false
    public init() {

    }
  }

  public enum Action: TCAFeatureAction, Equatable {

    public enum ViewAction: Equatable {
      case dismissButtonTapped
    }

    public enum InternalAction: Equatable {

    }

    public enum DelegateAction: Equatable {
      case squareCounter
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

    }

    @CasePathable
    public enum Action: Equatable {

    }

    public var body : some Reducer<State, Action> {
      EmptyReducer()
    }

  }

  public var body: some Reducer<State, Action> {

    Reduce { state, action in
      switch action {
      case let .view(action):
        switch action {
        case .dismissButtonTapped:
          return .send(.delegate(.squareCounter))

        }

      default:
        return .none

      }


    }
  }

}


// swiftlint:enable cyclomatic_complexity function_body_length
