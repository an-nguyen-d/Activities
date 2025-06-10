import Foundation
import ComposableArchitecture

@Reducer
public struct TimePickerFeature {
  
  @ObservableState
  public struct State: Equatable {
    public var hours: Int
    public var minutes: Int
    public var seconds: Int
    
    public var totalSeconds: Double {
      Double(hours * 3600 + minutes * 60 + seconds)
    }
    
    public init(initialTimeInSeconds: Double) {
      let totalSeconds = Int(initialTimeInSeconds)
      self.hours = totalSeconds / 3600
      self.minutes = (totalSeconds % 3600) / 60
      self.seconds = totalSeconds % 60
    }
  }
  
  public enum Action: Equatable {
    case hoursChanged(Int)
    case minutesChanged(Int)
    case secondsChanged(Int)
    case saveButtonTapped
    case cancelButtonTapped
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
      case timeSaved(seconds: Double)
    }
  }
  
  public init() {}
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .hoursChanged(hours):
        state.hours = max(0, hours)
        return .none
        
      case let .minutesChanged(minutes):
        state.minutes = max(0, min(59, minutes))
        return .none
        
      case let .secondsChanged(seconds):
        state.seconds = max(0, min(59, seconds))
        return .none
        
      case .saveButtonTapped:
        return .send(.delegate(.timeSaved(seconds: state.totalSeconds)))
        
      case .cancelButtonTapped:
        // Just dismiss without saving
        return .none
        
      case .delegate:
        return .none
      }
    }
  }
}