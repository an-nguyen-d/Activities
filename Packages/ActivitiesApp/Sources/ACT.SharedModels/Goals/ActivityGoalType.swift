import Foundation

/// Enum representing all possible activity goal types
/// This provides type-safe storage and automatic Equatable conformance
public enum ActivityGoalType: Equatable {
  case everyXDays(EveryXDaysActivityGoalModel)
  case daysOfWeek(DaysOfWeekActivityGoalModel)
  case weeksPeriod(WeeksPeriodActivityGoalModel)
}

extension ActivityGoalType: ActivityGoal.Modelling {
  public var id: ActivityGoal.ID {
    switch self {
    case .everyXDays(let model): return model.id
    case .daysOfWeek(let model): return model.id
    case .weeksPeriod(let model): return model.id
    }
  }
  
  public var createDate: Date {
    switch self {
    case .everyXDays(let model): return model.createDate
    case .daysOfWeek(let model): return model.createDate
    case .weeksPeriod(let model): return model.createDate
    }
  }
  
  public var effectiveCalendarDate: CalendarDate {
    switch self {
    case .everyXDays(let model): return model.effectiveCalendarDate
    case .daysOfWeek(let model): return model.effectiveCalendarDate
    case .weeksPeriod(let model): return model.effectiveCalendarDate
    }
  }
  
  public func getGoalTarget(for calendarDate: CalendarDate) -> ActivityGoalTargetModel? {
    switch self {
    case .everyXDays(let model): return model.getGoalTarget(for: calendarDate)
    case .daysOfWeek(let model): return model.getGoalTarget(for: calendarDate)
    case .weeksPeriod(let model): return model.getGoalTarget(for: calendarDate)
    }
  }
  
  public func canEvaluateStreak(forEvaluationCalendarDate evaluationCalendarDate: CalendarDate, currentCalendarDate: CalendarDate) -> Bool {
    switch self {
    case .everyXDays(let model): 
      return model.canEvaluateStreak(forEvaluationCalendarDate: evaluationCalendarDate, currentCalendarDate: currentCalendarDate)
    case .daysOfWeek(let model): 
      return model.canEvaluateStreak(forEvaluationCalendarDate: evaluationCalendarDate, currentCalendarDate: currentCalendarDate)
    case .weeksPeriod(let model): 
      return model.canEvaluateStreak(forEvaluationCalendarDate: evaluationCalendarDate, currentCalendarDate: currentCalendarDate)
    }
  }
  
  public func getSessionsDateRangeForTarget(onCalendarDate: CalendarDate) -> CalendarDateRange {
    switch self {
    case .everyXDays(let model): return model.getSessionsDateRangeForTarget(onCalendarDate: onCalendarDate)
    case .daysOfWeek(let model): return model.getSessionsDateRangeForTarget(onCalendarDate: onCalendarDate)
    case .weeksPeriod(let model): return model.getSessionsDateRangeForTarget(onCalendarDate: onCalendarDate)
    }
  }
}