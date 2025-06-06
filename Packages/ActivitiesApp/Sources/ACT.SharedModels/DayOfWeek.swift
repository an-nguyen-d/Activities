import Foundation

public enum DayOfWeek: Int, CaseIterable, Sendable {
  case sunday = 1
  case monday = 2
  case tuesday = 3
  case wednesday = 4
  case thursday = 5
  case friday = 6
  case saturday = 7

  public static let daysPerWeek = 7

  public var name: String {
    switch self {
    case .sunday: return "Sunday"
    case .monday: return "Monday"
    case .tuesday: return "Tuesday"
    case .wednesday: return "Wednesday"
    case .thursday: return "Thursday"
    case .friday: return "Friday"
    case .saturday: return "Saturday"
    }
  }

  // Convenience for array indexing (0-based)
  public var index: Int {
    return rawValue - 1
  }

  // Create from array index
  public init?(index: Int) {
    self.init(rawValue: index + 1)
  }
}
