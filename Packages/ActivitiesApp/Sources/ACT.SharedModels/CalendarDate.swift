import Foundation

public struct CalendarDate: Equatable, Comparable, Sendable {
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
}
