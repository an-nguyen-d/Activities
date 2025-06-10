import Foundation
import Tagged

/// A goal that evaluates success based on accumulating a target value over a weekly period.
/// 
/// Unlike daily goals (DaysOfWeek, EveryXDays), this goal type accumulates all sessions
/// within a week-long period and evaluates success at the end of the week.
/// 
/// Example: "Complete at least 150 minutes of meditation per week"
/// - The user can complete this in any pattern: 5x30min, 7x21min, 1x150min, etc.
/// - All sessions from Monday-Sunday count toward the weekly target
/// - Success is evaluated only on Sunday when the week is complete
public struct WeeksPeriodActivityGoalModel: Equatable {

  public let id: ActivityGoal.ID

  public let createDate: Date

  /// Always a Monday - the start of the period
  public let effectiveCalendarDate: CalendarDate

  /// The target to achieve over the entire week period (e.g., 150 minutes, 5 sessions, etc.)
  public let target: ActivityGoalTargetModel

  public init(
    id: ActivityGoal.ID,
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    target: ActivityGoalTargetModel
  ) {
    self.id = id
    self.createDate = createDate
    self.effectiveCalendarDate = effectiveCalendarDate
    self.target = target
  }

}

extension WeeksPeriodActivityGoalModel: ActivityGoal.Modelling {
  public func getGoalTarget(for calendarDate: CalendarDate) -> ActivityGoalTargetModel? {
    precondition(calendarDate >= effectiveCalendarDate, "Cannot evaluate goal before its effective date")

    // WeeksPeriod always evaluates (never skips)
    return target
  }

  private func calculatePeriodBounds(for calendarDate: CalendarDate) -> (start: CalendarDate, end: CalendarDate) {
    let daysSinceStart = calendarDate.daysSince(effectiveCalendarDate)
    let periodNumber = daysSinceStart / DayOfWeek.daysPerWeek
    let periodStartMonday = effectiveCalendarDate.addingDays(periodNumber * DayOfWeek.daysPerWeek)
    let periodEndSunday = periodStartMonday.addingDays(DayOfWeek.daysPerWeek - 1)
    return (periodStartMonday, periodEndSunday)
  }

  public func getSessionsDateRangeForTarget(onCalendarDate: CalendarDate) -> CalendarDateRange {
    let (periodStart, periodEnd) = calculatePeriodBounds(for: onCalendarDate)
    return .multipleDays(start: periodStart, end: periodEnd)
  }

  public func canEvaluateStreak(
    forEvaluationCalendarDate evaluationCalendarDate: CalendarDate,
    currentCalendarDate: CalendarDate
  ) -> Bool {
    precondition(evaluationCalendarDate >= effectiveCalendarDate, "Cannot evaluate goal before its effective date")
    let (_, periodEndSunday) = calculatePeriodBounds(for: evaluationCalendarDate)

    // Only evaluate on the last day of the period (Sunday) AND when the period is complete
    return evaluationCalendarDate == periodEndSunday && currentCalendarDate > periodEndSunday
  }


}
