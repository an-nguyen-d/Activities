import ElixirShared
import ComposableArchitecture
import Foundation
import ACT_SharedModels
import ACT_DatabaseClient

@Reducer
public struct CreateSessionFeature {
  
  @ObservableState
  public struct State: Equatable, Sendable {
    public let activityID: ActivityModel.ID
    public let sessionUnit: ActivityModel.SessionUnit
    public let commonValues: [Float]
    
    // Value tracking based on unit type
    public var integerValue: Int = 1
    public var floatingValue: Double = 1.0
    public var timeHours: Int = 0
    public var timeMinutes: Int = 1
    public var timeSeconds: Int = 0
    
    // Computed value for database
    public var value: Double {
      switch sessionUnit {
      case .integer:
        return Double(integerValue)
      case .floating:
        return floatingValue
      case .seconds:
        return Double((timeHours * 3600) + (timeMinutes * 60) + timeSeconds)
      }
    }
    
    // Validation
    public var isValid: Bool {
      value > 0
    }
    
    // Human-readable label
    public var valueLabel: String {
      switch sessionUnit {
      case .integer(let unitName):
        return "\(integerValue) \(unitName) completed"
      case .floating(let unitName):
        return String(format: "%.1f %@ completed", floatingValue, unitName)
      case .seconds:
        let totalSeconds = Int(value)
        return "\(TimeFormatting.formatTimeDescription(seconds: Double(totalSeconds))) completed"
      }
    }
    
    public init(
      activityID: ActivityModel.ID,
      sessionUnit: ActivityModel.SessionUnit,
      commonValues: [Float]
    ) {
      self.activityID = activityID
      self.sessionUnit = sessionUnit
      self.commonValues = commonValues
    }
  }
  
  public enum Action: TCAFeatureAction, Equatable {
    
    public enum ViewAction: Equatable {
      case integerValueChanged(Int)
      case floatingValueChanged(Double)
      case timeHoursChanged(Int)
      case timeMinutesChanged(Int)
      case timeSecondsChanged(Int)
      case confirmButtonTapped
      case cancelButtonTapped
    }
    
    public enum InternalAction: Equatable {
      case createSessionSuccess
      case createSessionFailure
    }
    
    public enum DelegateAction: Equatable {
      case dismissed
    }
    
    case view(ViewAction)
    case _internal(InternalAction)
    case delegate(DelegateAction)
  }
  
  // MARK: - Dependencies
  
  public typealias Dependencies = 
    HasDatabaseClient &
    HasDateMaker &
    HasTimeZone
  
  private let dependencies: Dependencies
  private var databaseClient: DatabaseClient { dependencies.databaseClient }
  
  // MARK: - Init
  
  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Reducer
  
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
    case let .integerValueChanged(value):
      state.integerValue = max(1, value)
      return .none
      
    case let .floatingValueChanged(value):
      state.floatingValue = max(0.1, value)
      return .none
      
    case let .timeHoursChanged(hours):
      state.timeHours = max(0, min(23, hours))
      return .none
      
    case let .timeMinutesChanged(minutes):
      state.timeMinutes = max(0, min(59, minutes))
      return .none
      
    case let .timeSecondsChanged(seconds):
      state.timeSeconds = max(0, min(59, seconds))
      return .none
      
    case .confirmButtonTapped:
      guard state.isValid else {
        assertionFailure("Confirm button should be disabled when invalid")
        return .none
      }
      
      let now = dependencies.dateMaker.date()
      let calendarDate = CalendarDate(
        from: now,
        timeZone: dependencies.timeZone
      )
      
      let activityID = state.activityID
      let value = state.value
      
      return .run { [databaseClient] send in
        do {
          _ = try await databaseClient.createSession(
            .init(
              activityId: activityID,
              value: value,
              createDate: now,
              completeDate: now,
              completeCalendarDate: calendarDate
            )
          )
          await send(._internal(.createSessionSuccess))
        } catch {
          assertionFailure("Failed to create session: \(error)")
          await send(._internal(.createSessionFailure))
        }
      }
      
    case .cancelButtonTapped:
      return .send(.delegate(.dismissed))
    }
  }
  
  // MARK: - InternalAction
  
  private func coreInternal(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
    switch action {
    case .createSessionSuccess:
      return .send(.delegate(.dismissed))
      
    case .createSessionFailure:
      // Error already logged in action
      return .none
    }
  }
}