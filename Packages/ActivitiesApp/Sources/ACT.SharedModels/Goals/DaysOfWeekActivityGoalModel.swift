import Foundation
import Tagged

public struct DaysOfWeekActivityGoalModel {

  public let id: ActivityGoal.ID

  public let createDate: Date
  public let effectiveCalendarDate: CalendarDate

  /// How often this weekly pattern repeats (1 = every week, 2 = every other week, etc.)
  /// Precondition: weeksInterval >= 1
  public let weeksInterval: Int

  public let mondayGoal: ActivityGoalTargetModel?
  public let tuesdayGoal: ActivityGoalTargetModel?
  public let wednesdayGoal: ActivityGoalTargetModel?
  public let thursdayGoal: ActivityGoalTargetModel?
  public let fridayGoal: ActivityGoalTargetModel?
  public let saturdayGoal: ActivityGoalTargetModel?
  public let sundayGoal: ActivityGoalTargetModel?

  public init(
    id: ActivityGoal.ID,
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    weeksInterval: Int,
    mondayGoal: ActivityGoalTargetModel?,
    tuesdayGoal: ActivityGoalTargetModel?,
    wednesdayGoal: ActivityGoalTargetModel?,
    thursdayGoal: ActivityGoalTargetModel?,
    fridayGoal: ActivityGoalTargetModel?,
    saturdayGoal: ActivityGoalTargetModel?,
    sundayGoal: ActivityGoalTargetModel?
  ) {
    precondition(weeksInterval >= 1)

    self.id = id
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

extension DaysOfWeekActivityGoalModel {
  public func goal(for dayOfWeek: DayOfWeek) -> ActivityGoalTargetModel? {
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

extension DaysOfWeekActivityGoalModel: ActivityGoal.Modelling {
  public func getGoalTarget(for calendarDate: CalendarDate) -> ActivityGoalTargetModel? {
    precondition(calendarDate >= effectiveCalendarDate, "Cannot evaluate goal before its effective date")

    // Check if we're in an active week based on weeksInterval
    let daysSinceStart = calendarDate.daysSince(effectiveCalendarDate)
    let weeksSinceStart = daysSinceStart / DayOfWeek.daysPerWeek
    let isActiveWeek = (weeksSinceStart % weeksInterval) == 0

    // If not an active week, skip
    if !isActiveWeek {
      return nil
    }

    // Check the day of week
    let dayOfWeek = calendarDate.dayOfWeek()
    return goal(for: dayOfWeek)
  }

  public func canEvaluateStreak(forEvaluationCalendarDate evaluationCalendarDate: CalendarDate, currentCalendarDate: CalendarDate) -> Bool {
    return evaluationCalendarDate < currentCalendarDate
  }
  public func getSessionsDateRangeForTarget(onCalendarDate: CalendarDate) -> CalendarDateRange {
    precondition(onCalendarDate >= effectiveCalendarDate, "Cannot evaluate goal before its effective date")
    return .singleDay(onCalendarDate)
  }
}
