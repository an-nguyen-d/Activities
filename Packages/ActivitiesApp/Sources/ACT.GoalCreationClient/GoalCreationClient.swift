import Foundation
import ACT_SharedModels

public struct GoalCreationClient {

  public enum GoalType: Sendable {
    case everyXDays
    case daysOfWeek
    case weeksPeriod
  }

  public enum CalculateEffectiveCalendarDate {
    public struct Request: Sendable {
      public let goalType: GoalType
      public let currentCalendarDate: CalendarDate
      public let startingDayOfWeek: DayOfWeek
      
      public init(
        goalType: GoalType,
        currentCalendarDate: CalendarDate,
        startingDayOfWeek: DayOfWeek
      ) {
        self.goalType = goalType
        self.currentCalendarDate = currentCalendarDate
        self.startingDayOfWeek = startingDayOfWeek
      }
    }
    public typealias Response = CalendarDate
  }

  public var calculateEffectiveCalendarDate: @Sendable (CalculateEffectiveCalendarDate.Request) -> CalculateEffectiveCalendarDate.Response

  public init(
    calculateEffectiveCalendarDate: @Sendable @escaping (CalculateEffectiveCalendarDate.Request) -> CalculateEffectiveCalendarDate.Response
  ) {
    self.calculateEffectiveCalendarDate = calculateEffectiveCalendarDate
  }

}
