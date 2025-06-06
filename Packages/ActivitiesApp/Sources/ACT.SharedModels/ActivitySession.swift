import Foundation

public struct ActivitySession {
  public let value: Double
  public let createDate: Date
  public let completeDate: Date
  public let completeCalendarDate: CalendarDate

  public init(
    value: Double,
    createDate: Date,
    completeDate: Date,
    completeCalendarDate: CalendarDate
  ) {
    self.value = value
    self.createDate = createDate
    self.completeDate = completeDate
    self.completeCalendarDate = completeCalendarDate
  }
}
