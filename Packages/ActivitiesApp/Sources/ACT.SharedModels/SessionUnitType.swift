public enum SessionUnitType: Sendable, Equatable, CaseIterable {
  case integer
  case floating
  case time

  public var displayName: String {
    switch self {
    case .integer: return "Integer"
    case .floating: return "Floating"
    case .time: return "Time"
    }
  }
}