import Foundation
import ComposableArchitecture
import ElixirShared
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_SharedUI

@Reducer
public struct WeeksPeriodGoalCreationFeature {

  @Reducer
  public struct Destination {
    public enum State: Equatable {
      case timePicker(TimePickerFeature.State)
    }
    
    public enum Action: Equatable {
      case timePicker(TimePickerFeature.Action)
    }
    
    public var body: some Reducer<State, Action> {
      Scope(state: \.timePicker, action: \.timePicker) {
        TimePickerFeature()
      }
    }
  }

  public typealias Dependencies = Any

  private let dependencies: Dependencies

  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  @ObservableState
  public struct State: Equatable {
    // Store individual pieces of state
    public var targetValue: Double?
    public var targetValueString: String = "" // For better float input UX
    public var successCriteria: GoalSuccessCriteria?
    public var sessionUnit: ActivityModel.SessionUnit
    
    @Presents public var destination: Destination.State?
    
    public var isValid: Bool {
      guard let value = targetValue, let criteria = successCriteria else {
        return false
      }
      return ActivityGoalTargetModel.isValidCombination(value: value, criteria: criteria)
    }
    
    // Computed property to help UI show validation feedback
    public var validationMessage: String? {
      guard let value = targetValue, let criteria = successCriteria else {
        return nil
      }
      
      if value == 0 && criteria != .exactly {
        return "For a goal of 0, only 'Exactly' makes sense"
      }
      
      return nil
    }
    
    // Goal description logic will be moved to VC

    public init(sessionUnit: ActivityModel.SessionUnit) {
      self.sessionUnit = sessionUnit
    }
  }

  public enum Action: TCAFeatureAction, Equatable {
    public enum ViewAction: Equatable {
      case cancelButtonTapped
      case saveButtonTapped
      case targetValueChanged(Double?)
      case targetValueStringChanged(String)
      case targetSuccessCriteriaChanged(GoalSuccessCriteria?)
      case clearTargetTapped
      case timeEditTapped
    }

    public enum InternalAction: Equatable {

    }

    public enum DelegateAction: Equatable {
      case goalCreated(DatabaseClient.CreateActivityGoalTarget.Request)
      case dismissed
    }

    case view(ViewAction)
    case _internal(InternalAction)
    case delegate(DelegateAction)
    case destination(PresentationAction<Destination.Action>)
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
      
    case let .destination(.presented(.timePicker(.delegate(.timeSaved(seconds))))):
      state.targetValue = seconds
      state.destination = nil
      return .none
      
    case .destination(.presented(.timePicker(.cancelButtonTapped))):
      state.destination = nil
      return .none
      
    case .destination:
      return .none
    }
  }

  private func coreView(into state: inout State, action: Action.ViewAction) -> Effect<Action> {
    switch action {
    case .cancelButtonTapped:
      return .send(.delegate(.dismissed))

    case .saveButtonTapped:
      // Create the target request from the current state
      guard let value = state.targetValue, 
            let criteria = state.successCriteria else {
        return .none
      }
      
      let targetRequest = DatabaseClient.CreateActivityGoalTarget.Request(
        goalValue: value,
        goalSuccessCriteria: criteria
      )
      
      return .send(.delegate(.goalCreated(targetRequest)))
      
    case let .targetValueChanged(value):
      state.targetValue = value
      if let value = value {
        // Update string representation based on unit type
        switch state.sessionUnit {
        case .integer:
          state.targetValueString = "\(Int(value))"
        case .floating:
          state.targetValueString = "\(value)"
        case .seconds:
          state.targetValueString = "" // Time uses picker, not text field
        }
      } else {
        state.targetValueString = ""
      }
      return .none
      
    case let .targetValueStringChanged(string):
      state.targetValueString = string
      // Only update numeric value if string is valid
      if !string.isEmpty {
        if let value = Double(string) {
          state.targetValue = value
        }
      } else {
        state.targetValue = nil
      }
      return .none
      
    case let .targetSuccessCriteriaChanged(criteria):
      state.successCriteria = criteria
      return .none
      
    case .clearTargetTapped:
      state.targetValue = nil
      state.targetValueString = ""
      state.successCriteria = nil
      return .none
      
    case .timeEditTapped:
      state.destination = .timePicker(TimePickerFeature.State(
        initialTimeInSeconds: state.targetValue ?? 0
      ))
      return .none
    }
  }
  private func coreInternal(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
    switch action {
    }
  }
}
