import Foundation
import Tagged

public struct ActivityModel: Sendable, Equatable {

  public typealias ID = Tagged<(Self, id: ()), Int64>

  public enum SessionUnit: Sendable, Equatable {
    case integer(String)
    case floating(String)
    case seconds
  }

  public let id: ID
  public var activityName: String
  public var sessionUnit: SessionUnit
  public var currentStreakCount: Int
  public var lastGoalSuccessCheckCalendarDate: CalendarDate?

  public init(
    id: ID,
    activityName: String,
    sessionUnit: SessionUnit,
    currentStreakCount: Int,
    lastGoalSuccessCheckCalendarDate: CalendarDate? = nil
  ) {
    self.id = id
    self.activityName = activityName
    self.sessionUnit = sessionUnit
    self.currentStreakCount = currentStreakCount
    self.lastGoalSuccessCheckCalendarDate = lastGoalSuccessCheckCalendarDate
  }
}
