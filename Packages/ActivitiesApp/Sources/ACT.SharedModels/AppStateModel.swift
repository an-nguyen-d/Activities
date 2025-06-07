import Foundation
import Tagged

public struct AppStateModel: Sendable {

  public typealias ID = Tagged<(Self, id: ()), Int64>
  public let id: ID

  public let createDate: Date
  public let createCalendarDate: CalendarDate
  public var latestCalendarDateWithAllActivityStreaksEvaluated: CalendarDate?

  public init(
    id: ID,
    createDate: Date,
    createCalendarDate: CalendarDate,
    latestCalendarDateWithAllActivityStreaksEvaluated: CalendarDate? = nil
  ) {
    self.id = id
    self.createDate = createDate
    self.createCalendarDate = createCalendarDate
    self.latestCalendarDateWithAllActivityStreaksEvaluated = latestCalendarDateWithAllActivityStreaksEvaluated
  }

}
