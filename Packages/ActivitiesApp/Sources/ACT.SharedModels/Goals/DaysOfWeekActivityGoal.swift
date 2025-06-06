import Foundation

public struct DaysOfWeekActivityGoal {
  public let createDate: Date
  public let effectiveCalendarDate: CalendarDate

  /// How often this weekly pattern repeats (1 = every week, 2 = every other week, etc.)
  public let weeksInterval: Int

  public let mondayGoal: ActivityGoalTarget?
  public let tuesdayGoal: ActivityGoalTarget?
  public let wednesdayGoal: ActivityGoalTarget?
  public let thursdayGoal: ActivityGoalTarget?
  public let fridayGoal: ActivityGoalTarget?
  public let saturdayGoal: ActivityGoalTarget?
  public let sundayGoal: ActivityGoalTarget?

  public init(
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    weeksInterval: Int,
    mondayGoal: ActivityGoalTarget?,
    tuesdayGoal: ActivityGoalTarget?,
    wednesdayGoal: ActivityGoalTarget?,
    thursdayGoal: ActivityGoalTarget?,
    fridayGoal: ActivityGoalTarget?,
    saturdayGoal: ActivityGoalTarget?,
    sundayGoal: ActivityGoalTarget?
  ) {
    self.createDate = createDate
    self.effectiveCalendarDate = effectiveCalendarDate
    self.weeksInterval = weeksInterval
    self.mondayGoal = mondayGoal
    self.tuesdayGoal = tuesdayGoal
    self.wednesdayGoal = wednesdayGoal
    self.thursdayGoal = thursdayGoal
    self.fridayGoal = fridayGoal
    self.saturdayGoal = saturdayGoal
    self.sundayGoal = sundayGoal
  }
}

extension DaysOfWeekActivityGoal {
  public func goal(for dayOfWeek: DayOfWeek) -> ActivityGoalTarget? {
    switch dayOfWeek {
    case .sunday: return sundayGoal
    case .monday: return mondayGoal
    case .tuesday: return tuesdayGoal
    case .wednesday: return wednesdayGoal
    case .thursday: return thursdayGoal
    case .friday: return fridayGoal
    case .saturday: return saturdayGoal
    }
  }
}

extension DaysOfWeekActivityGoal: ActivityGoalProtocol {
  public func targetForDate(_ date: CalendarDate) -> ActivityGoalTarget? {
    // Check if we're in an active week based on weeksInterval
    let daysSinceStart = date.daysSince(effectiveCalendarDate)
    let weeksSinceStart = daysSinceStart / DayOfWeek.daysPerWeek
    let isActiveWeek = (weeksSinceStart % weeksInterval) == 0

    // If not an active week, skip
    if !isActiveWeek {
      return nil
    }

    // Check the day of week
    let dayOfWeek = date.dayOfWeek()
    return goal(for: dayOfWeek)
  }

  public func isEvaluatingToday(evaluationDate: CalendarDate, currentDate: CalendarDate) -> Bool {
    return evaluationDate == currentDate
  }
}
