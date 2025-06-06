import Foundation

public struct EveryXDaysActivityGoal {
  public let createDate: Date

  /// The date this goal becomes effective and is used for success evaluations
  public let effectiveCalendarDate: CalendarDate

  /// Valid range: [1, ∞) - Must be at least 1 (1 = daily, 2 = every other day, etc.)
  public let daysInterval: Int

  public let target: ActivityGoalTarget

  public init(
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    daysInterval: Int,
    target: ActivityGoalTarget
  ) {
    self.createDate = createDate
    self.effectiveCalendarDate = effectiveCalendarDate
    self.daysInterval = daysInterval
    self.target = target
  }

  // Convenience init for backward compatibility
  public init(
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    daysInterval: Int,
    goalValue: Double,
    goalSuccessCriteria: GoalSuccessCriteria
  ) {
    self.init(
      createDate: createDate,
      effectiveCalendarDate: effectiveCalendarDate,
      daysInterval: daysInterval,
      target: ActivityGoalTarget(goalValue: goalValue, goalSuccessCriteria: goalSuccessCriteria)
    )
  }

}

extension EveryXDaysActivityGoal: ActivityGoalProtocol {
  public func targetForDate(_ date: CalendarDate) -> ActivityGoalTarget? {
    let daysSinceStart = date.daysSince(effectiveCalendarDate)

    // If not divisible by interval, it's a skip day
    if daysSinceStart % daysInterval != 0 {
      return nil
    }

    return target
  }

  public func isEvaluatingToday(evaluationDate: CalendarDate, currentDate: CalendarDate) -> Bool {
    return evaluationDate == currentDate
  }
}
