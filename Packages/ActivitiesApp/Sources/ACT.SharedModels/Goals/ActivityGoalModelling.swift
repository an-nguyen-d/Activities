import Foundation
import Tagged

public enum ActivityGoal {

  public typealias ID = Tagged<Self, Int64>

}

extension ActivityGoal {

  public protocol Modelling: Sendable {

    var id: ActivityGoal.ID { get }

    var createDate: Date { get }
    var effectiveCalendarDate: CalendarDate { get }

    /// Returns nil if should skip, otherwise the target to aim for on this date
    /// Precondition: calendarDate >= effectiveCalendarDate
    func getGoalTarget(for calendarDate: CalendarDate) -> ActivityGoalTargetModel?

    /// Returns true if we can evaluate the streak for the given evaluation date
    /// For daily goals: Can evaluate if evaluationCalendarDate < currentCalendarDate
    /// For period goals: Can evaluate if the period containing evaluationCalendarDate is complete
    func canEvaluateStreak(forEvaluationCalendarDate evaluationCalendarDate: CalendarDate, currentCalendarDate: CalendarDate) -> Bool

    /// Returns the date range where sessions count toward the goal target for the given evaluation date.
    ///
    /// - Note: This method returns a valid date range even for skip days (days where `getGoalTarget` returns nil).
    ///         Callers should check `getGoalTarget` first to determine if evaluation is needed.
    ///         The separation allows for consistent date range calculation regardless of skip patterns.
    ///
    /// - Precondition: evaluationCalendarDate >= effectiveCalendarDate
    func getSessionsDateRangeForTarget(evaluationCalendarDate: CalendarDate) -> CalendarDateRange

  }

}

