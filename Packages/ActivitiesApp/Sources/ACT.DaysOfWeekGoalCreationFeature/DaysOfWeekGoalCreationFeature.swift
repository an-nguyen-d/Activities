import Foundation
import ComposableArchitecture
import ElixirShared
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_SharedUI

@Reducer
public struct DaysOfWeekGoalCreationFeature {

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
    public var weeksInterval: Int = 1
    
    // Target for each day of the week
    public var mondayTarget: DayTarget = DayTarget()
    public var tuesdayTarget: DayTarget = DayTarget()
    public var wednesdayTarget: DayTarget = DayTarget()
    public var thursdayTarget: DayTarget = DayTarget()
    public var fridayTarget: DayTarget = DayTarget()
    public var saturdayTarget: DayTarget = DayTarget()
    public var sundayTarget: DayTarget = DayTarget()
    
    public var sessionUnit: ActivityModel.SessionUnit
    
    @Presents public var destination: Destination.State?
    
    // State for tracking which day's time picker is being edited
    public var editingDay: DayOfWeek?
    
    public struct DayTarget: Equatable {
      public var targetValue: Double?
      public var targetValueString: String = ""
      public var successCriteria: GoalSuccessCriteria?
      
      public init() {}
    }
    
    public func getTarget(for day: DayOfWeek) -> DayTarget {
      switch day {
      case .monday: return mondayTarget
      case .tuesday: return tuesdayTarget
      case .wednesday: return wednesdayTarget
      case .thursday: return thursdayTarget
      case .friday: return fridayTarget
      case .saturday: return saturdayTarget
      case .sunday: return sundayTarget
      }
    }
    
    public mutating func setTarget(for day: DayOfWeek, target: DayTarget) {
      switch day {
      case .monday: mondayTarget = target
      case .tuesday: tuesdayTarget = target
      case .wednesday: wednesdayTarget = target
      case .thursday: thursdayTarget = target
      case .friday: fridayTarget = target
      case .saturday: saturdayTarget = target
      case .sunday: sundayTarget = target
      }
    }
    
    public init(sessionUnit: ActivityModel.SessionUnit) {
      self.sessionUnit = sessionUnit
    }
  }

  public enum Action: TCAFeatureAction, Equatable {
    public enum ViewAction: Equatable {
      case cancelButtonTapped
      case saveButtonTapped
      case weeksIntervalChanged(Int)
      case dayTargetValueChanged(DayOfWeek, Double?)
      case dayTargetValueStringChanged(DayOfWeek, String)
      case dayTargetSuccessCriteriaChanged(DayOfWeek, GoalSuccessCriteria?)
      case dayTargetClearTapped(DayOfWeek)
      case dayTimeEditTapped(DayOfWeek)
    }

    public enum InternalAction: Equatable {

    }

    public enum DelegateAction: Equatable {
      case goalCreated(weeksInterval: Int, targets: [DayOfWeek: DatabaseClient.CreateActivityGoalTarget.Request])
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
      guard let editingDay = state.editingDay else { return .none }
      var target = state.getTarget(for: editingDay)
      target.targetValue = seconds
      state.setTarget(for: editingDay, target: target)
      state.destination = nil
      state.editingDay = nil
      return .none
      
    case .destination(.presented(.timePicker(.cancelButtonTapped))):
      state.destination = nil
      state.editingDay = nil
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
      // Create targets for days that have values and criteria
      var targets: [DayOfWeek: DatabaseClient.CreateActivityGoalTarget.Request] = [:]
      
      for day in DayOfWeek.allCases {
        let target = state.getTarget(for: day)
        if let value = target.targetValue, let criteria = target.successCriteria {
          targets[day] = DatabaseClient.CreateActivityGoalTarget.Request(
            goalValue: value,
            goalSuccessCriteria: criteria
          )
        }
      }
      
      return .send(.delegate(.goalCreated(
        weeksInterval: state.weeksInterval,
        targets: targets
      )))
      
    case let .weeksIntervalChanged(interval):
      state.weeksInterval = max(1, interval)
      return .none
      
    case let .dayTargetValueChanged(day, value):
      var target = state.getTarget(for: day)
      target.targetValue = value
      if let value = value {
        // Update string representation based on unit type
        switch state.sessionUnit {
        case .integer:
          target.targetValueString = "\(Int(value))"
        case .floating:
          target.targetValueString = "\(value)"
        case .seconds:
          target.targetValueString = "" // Time uses picker, not text field
        }
      } else {
        target.targetValueString = ""
      }
      state.setTarget(for: day, target: target)
      return .none
      
    case let .dayTargetValueStringChanged(day, string):
      var target = state.getTarget(for: day)
      target.targetValueString = string
      // Only update numeric value if string is valid
      if !string.isEmpty {
        if let value = Double(string) {
          target.targetValue = value
        }
      } else {
        target.targetValue = nil
      }
      state.setTarget(for: day, target: target)
      return .none
      
    case let .dayTargetSuccessCriteriaChanged(day, criteria):
      var target = state.getTarget(for: day)
      target.successCriteria = criteria
      state.setTarget(for: day, target: target)
      return .none
      
    case let .dayTargetClearTapped(day):
      var target = state.getTarget(for: day)
      target.targetValue = nil
      target.targetValueString = ""
      target.successCriteria = nil
      state.setTarget(for: day, target: target)
      return .none
      
    case let .dayTimeEditTapped(day):
      let target = state.getTarget(for: day)
      state.editingDay = day
      state.destination = .timePicker(TimePickerFeature.State(
        initialTimeInSeconds: target.targetValue ?? 0
      ))
      return .none
    }
  }

  private func coreInternal(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
    switch action {
    }
  }
}
