import Foundation

public enum GoalDescriptions {
  
  /// Creates a human-readable description for an EveryXDays goal
  public static func everyXDaysDescription(
    daysInterval: Int,
    goalValue: Double,
    successCriteria: GoalSuccessCriteria
  ) -> String {
    let intervalText = daysInterval == 1 ? "day" : "\(daysInterval) days"
    return "\(successCriteria.rawValue) \(Int(goalValue)) every \(intervalText)"
  }
  
  /// Creates a human-readable description for a DaysOfWeek goal (summary version)
  public static func daysOfWeekSummaryDescription(
    targetCount: Int,
    weeksInterval: Int
  ) -> String {
    let intervalText = weeksInterval == 1 ? "week" : "\(weeksInterval) weeks"
    return "\(targetCount) days per \(intervalText)"
  }
  
  /// Creates a human-readable description for a WeeksPeriod goal
  public static func weeksPeriodDescription(
    goalValue: Double,
    successCriteria: GoalSuccessCriteria
  ) -> String {
    return "Weekly goal: \(successCriteria.rawValue) \(Int(goalValue)) per week"
  }
  
  /// Creates a description from any ActivityGoal model
  public static func description(for goal: ActivityGoalType) -> String {
    switch goal {
    case .everyXDays(let everyXDays):
      return everyXDaysDescription(
        daysInterval: everyXDays.daysInterval,
        goalValue: everyXDays.target.goalValue,
        successCriteria: everyXDays.target.goalSuccessCriteria
      )
      
    case .daysOfWeek(let daysOfWeek):
      let goals = [
        daysOfWeek.mondayGoal,
        daysOfWeek.tuesdayGoal,
        daysOfWeek.wednesdayGoal,
        daysOfWeek.thursdayGoal,
        daysOfWeek.fridayGoal,
        daysOfWeek.saturdayGoal,
        daysOfWeek.sundayGoal
      ]
      let targetCount = goals.compactMap { $0 }.count
      return daysOfWeekSummaryDescription(
        targetCount: targetCount,
        weeksInterval: daysOfWeek.weeksInterval
      )
      
    case .weeksPeriod(let weeksPeriod):
      return weeksPeriodDescription(
        goalValue: weeksPeriod.target.goalValue,
        successCriteria: weeksPeriod.target.goalSuccessCriteria
      )
    }
  }
  
  /// Gets the goal type name
  public static func goalTypeName(for goal: ActivityGoalType) -> String {
    switch goal {
    case .everyXDays:
      return "Every X Days"
    case .daysOfWeek:
      return "Days of Week"
    case .weeksPeriod:
      return "Weeks Period"
    }
  }
}