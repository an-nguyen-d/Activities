import Foundation
import Tagged

public struct ActivitySessionModel: Sendable {

  public typealias ID = Tagged<(Self, id: ()), Int64>
  public let id: ID
  public let value: Double
  public let createDate: Date
  public let completeDate: Date
  public let completeCalendarDate: CalendarDate

  public init(id: ID, value: Double, createDate: Date, completeDate: Date, completeCalendarDate: CalendarDate) {
    precondition(value >= 0, "ActivitySessionValue must be non-negative")
    self.id = id
    self.value = value
    self.createDate = createDate
    self.completeDate = completeDate
    self.completeCalendarDate = completeCalendarDate
  }
}
