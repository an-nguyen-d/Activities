import Foundation

public enum CalendarDateRange: Sendable {
  case singleDay(CalendarDate)
  case multipleDays(start: CalendarDate, end: CalendarDate)
  
  public init(start: CalendarDate, end: CalendarDate) {
    precondition(start <= end, "Invalid date range: start (\(start.value)) must not be after end (\(end.value))")
    
    if start == end {
      self = .singleDay(start)
    } else {
      self = .multipleDays(start: start, end: end)
    }
  }
  
  public var start: CalendarDate {
    switch self {
    case .singleDay(let date):
      return date
    case .multipleDays(let start, _):
      return start
    }
  }
  
  public var end: CalendarDate {
    switch self {
    case .singleDay(let date):
      return date
    case .multipleDays(_, let end):
      return end
    }
  }
}

public struct CalendarDate: Equatable, Comparable, Sendable, Hashable {
  public let value: String

  private static let format = "yyyy-MM-dd"

  // Singleton formatter for parsing/formatting (uses UTC)
  private static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)  // UTC
    return formatter
  }()

  // Singleton UTC calendar to match formatter's timezone
  private static let utcCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
  }()

  public init(_ value: String) {
    self.value = value
  }

  // Only today() needs timezone awareness
  public static func today(timeZone: TimeZone = .autoupdatingCurrent) -> CalendarDate {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = timeZone
    return CalendarDate(formatter.string(from: Date()))
  }

  public init(from date: Date, timeZone: TimeZone = .autoupdatingCurrent) {
    let formatter = DateFormatter()
    formatter.dateFormat = Self.format
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = timeZone
    self.init(formatter.string(from: date))
  }

  public func addingDays(_ days: Int) -> CalendarDate {
    guard
      let date = Self.formatter.date(from: value),
      let newDate = Self.utcCalendar.date(byAdding: .day, value: days, to: date)
    else {
      fatalError("Invalid date format")
    }

    return CalendarDate(Self.formatter.string(from: newDate))
  }

  public static func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
    guard
      let lhsDate = formatter.date(from: lhs.value),
      let rhsDate = formatter.date(from: rhs.value)
    else {
      fatalError("Invalid date format for comparison")
    }

    return lhsDate < rhsDate
  }

  public func daysSince(_ other: CalendarDate) -> Int {
    guard
      let thisDate = Self.formatter.date(from: self.value),
      let otherDate = Self.formatter.date(from: other.value)
    else {
      fatalError("Invalid date format")
    }

    let components = Self.utcCalendar.dateComponents([.day], from: otherDate, to: thisDate)
    return components.day ?? 0
  }

  public func dayOfWeek() -> DayOfWeek {
    guard let date = Self.formatter.date(from: value) else {
      fatalError("Invalid date format")
    }

    let components = Self.utcCalendar.dateComponents([.weekday], from: date)

    guard let weekday = components.weekday,
          let dayOfWeek = DayOfWeek(rawValue: weekday) else {
      fatalError("Invalid weekday component")
    }

    return dayOfWeek
  }

  public func addingWeeks(_ weeks: Int) -> CalendarDate {
    return addingDays(weeks * DayOfWeek.daysPerWeek)
  }

  /// Returns the next occurrence of the specified day of week
  public func next(_ targetDay: DayOfWeek) -> CalendarDate {
    let currentDay = self.dayOfWeek()
    let daysToAdd = (targetDay.rawValue - currentDay.rawValue + DayOfWeek.daysPerWeek) % DayOfWeek.daysPerWeek

    // If it's 0, we're on that day, so go to next week's occurrence
    return daysToAdd == 0 ? addingWeeks(1) : addingDays(daysToAdd)
  }

  public func nextDay() -> CalendarDate {
      addingDays(1)
  }

}

extension CalendarDate {
  /// Returns the current date if it matches the target day, otherwise returns the most recent occurrence.
  /// - Parameter dayOfWeek: The target day of week to find
  /// - Returns: Self if already on target day, otherwise the most recent occurrence in the past
  public func getCurrentOrPrevious(dayOfWeek targetDay: DayOfWeek) -> CalendarDate {
    let currentDay = self.dayOfWeek()

    if currentDay == targetDay {
      return self
    }

    // Calculate days to go back to reach the target day
    var daysBack = currentDay.rawValue - targetDay.rawValue
    if daysBack < 0 {
      daysBack += DayOfWeek.daysPerWeek
    }

    return addingDays(-daysBack)
  }
}
extension CalendarDate {
  public func date(timeZone: TimeZone = .autoupdatingCurrent) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = Self.format
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = timeZone

    guard let date = formatter.date(from: value) else {
      fatalError("Invalid date format: \(value)")
    }

    return date
  }
  
  /// Returns the start of the week containing this date
  /// - Parameter firstWeekday: The day that starts the week (default: Monday)
  /// - Returns: The CalendarDate representing the start of the week
  public func startOfWeek(firstWeekday: DayOfWeek = .monday) -> CalendarDate {
    let currentDay = self.dayOfWeek()
    
    // Calculate days to go back to reach the first weekday
    var daysBack = currentDay.rawValue - firstWeekday.rawValue
    if daysBack < 0 {
      daysBack += DayOfWeek.daysPerWeek
    }
    
    return addingDays(-daysBack)
  }
}
