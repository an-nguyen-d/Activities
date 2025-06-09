import Foundation
import Tagged

public struct WeeksPeriodActivityGoalModel {

  public let id: ActivityGoal.ID

  public let createDate: Date

  /// Always a Monday - the start of the period
  public let effectiveCalendarDate: CalendarDate

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

  public func getSessionsDateRangeForTarget(evaluationCalendarDate: CalendarDate) -> CalendarDateRange {
    let (periodStart, periodEnd) = calculatePeriodBounds(for: evaluationCalendarDate)
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
