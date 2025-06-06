import Foundation

public struct WeeksPeriodActivityGoal {
  public let createDate: Date

  /// Always a Monday - the start of the period
  public let effectiveCalendarDate: CalendarDate

  public let target: ActivityGoalTarget

  public init(
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    target: ActivityGoalTarget
  ) {
    self.createDate = createDate
    self.effectiveCalendarDate = effectiveCalendarDate
    self.target = target
  }

  // Convenience init
  public init(
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    goalValue: Double,
    goalSuccessCriteria: GoalSuccessCriteria
  ) {
    self.init(
      createDate: createDate,
      effectiveCalendarDate: effectiveCalendarDate,
      target: ActivityGoalTarget(goalValue: goalValue, goalSuccessCriteria: goalSuccessCriteria)
    )
  }
}

extension WeeksPeriodActivityGoal: ActivityGoalProtocol {
  public func targetForDate(_ date: CalendarDate) -> ActivityGoalTarget? {
    // WeeksPeriod always evaluates (never skips)
    return target
  }

  public func isEvaluatingToday(evaluationDate: CalendarDate, currentDate: CalendarDate) -> Bool {
    // Calculate which period (week) the evaluation date falls in
    let daysSinceStart = evaluationDate.daysSince(effectiveCalendarDate)
    let periodNumber = daysSinceStart / DayOfWeek.daysPerWeek
    let periodStartMonday = effectiveCalendarDate.addingDays(periodNumber * DayOfWeek.daysPerWeek)
    let periodEndSunday = periodStartMonday.addingDays(DayOfWeek.daysPerWeek - 1)

    // We're "evaluating today" if the period isn't complete yet
    let isPeriodComplete = currentDate > periodEndSunday
    return !isPeriodComplete
  }
}
