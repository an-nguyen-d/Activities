import Foundation
import Tagged

public struct EveryXDaysActivityGoalModel {

  public let id: ActivityGoal.ID

  public let createDate: Date

  /// The date this goal becomes effective and is used for success evaluations
  public let effectiveCalendarDate: CalendarDate

  /// Valid range: [1, ∞) - Must be at least 1 (1 = daily, 2 = every other day, etc.)
  /// Precondition: daysInterval >= 1
  public let daysInterval: Int

  public let target: ActivityGoalTargetModel

  public init(
    id: ActivityGoal.ID,
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    daysInterval: Int,
    target: ActivityGoalTargetModel
  ) {
    precondition(daysInterval >= 1)

    self.id = id
    self.createDate = createDate
    self.effectiveCalendarDate = effectiveCalendarDate
    self.daysInterval = daysInterval
    self.target = target
  }

  // Convenience init for backward compatibility
  public init(
    id: ActivityGoal.ID,
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    daysInterval: Int,
    goalID: ActivityGoalTargetModel.ID,
    goalValue: Double,
    goalSuccessCriteria: GoalSuccessCriteria
  ) {
    self.init(
      id: id,
      createDate: createDate,
      effectiveCalendarDate: effectiveCalendarDate,
      daysInterval: daysInterval,
      target: ActivityGoalTargetModel(
        id: goalID,
        goalValue: goalValue,
        goalSuccessCriteria: goalSuccessCriteria
      )
    )
  }

}

extension EveryXDaysActivityGoalModel: ActivityGoal.Modelling {
  public func getGoalTarget(for calendarDate: CalendarDate) -> ActivityGoalTargetModel? {
    precondition(calendarDate >= effectiveCalendarDate, "Cannot evaluate goal before its effective date")

    let daysSinceStart = calendarDate.daysSince(effectiveCalendarDate)

    // If not divisible by interval, it's a skip day
    if daysSinceStart % daysInterval != 0 {
      return nil
    }

    return target
  }

  public func canEvaluateStreak(forEvaluationCalendarDate evaluationCalendarDate: CalendarDate, currentCalendarDate: CalendarDate) -> Bool {
    return evaluationCalendarDate < currentCalendarDate
  }
  public func getSessionsDateRangeForTarget(evaluationCalendarDate: CalendarDate) -> CalendarDateRange {
    precondition(evaluationCalendarDate >= effectiveCalendarDate, "Cannot evaluate goal before its effective date")
    return .singleDay(evaluationCalendarDate)
  }
}
