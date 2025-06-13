import Foundation

public enum GoalDescriptions {
  
  /// Creates a human-readable description for an EveryXDays goal
  public static func everyXDaysDescription(
    daysInterval: Int,
    goalValue: Double,
    successCriteria: GoalSuccessCriteria,
    sessionUnit: ActivityModel.SessionUnit? = nil
  ) -> String {
    let intervalText = daysInterval == 1 ? "day" : "\(daysInterval) days"
    let formattedValue: String
    if let sessionUnit = sessionUnit {
      formattedValue = ValueFormatting.formatValue(goalValue, for: sessionUnit)
    } else {
      // Fallback: show decimals only if needed
      formattedValue = goalValue.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(goalValue)) : String(goalValue)
    }
    return "\(successCriteria.rawValue) \(formattedValue) every \(intervalText)"
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
    successCriteria: GoalSuccessCriteria,
    sessionUnit: ActivityModel.SessionUnit? = nil
  ) -> String {
    let formattedValue: String
    if let sessionUnit = sessionUnit {
      formattedValue = ValueFormatting.formatValue(goalValue, for: sessionUnit)
    } else {
      // Fallback: show decimals only if needed
      formattedValue = goalValue.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(goalValue)) : String(goalValue)
    }
    return "Weekly goal: \(successCriteria.rawValue) \(formattedValue) per week"
  }
  
  /// Creates a description from any ActivityGoal model
  public static func description(for goal: ActivityGoalType, sessionUnit: ActivityModel.SessionUnit? = nil) -> String {
    switch goal {
    case .everyXDays(let everyXDays):
      return everyXDaysDescription(
        daysInterval: everyXDays.daysInterval,
        goalValue: everyXDays.target.goalValue,
        successCriteria: everyXDays.target.goalSuccessCriteria,
        sessionUnit: sessionUnit
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
        successCriteria: weeksPeriod.target.goalSuccessCriteria,
        sessionUnit: sessionUnit
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