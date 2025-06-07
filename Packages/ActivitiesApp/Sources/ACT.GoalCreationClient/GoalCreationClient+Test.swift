import Foundation
import ACT_SharedModels

extension GoalCreationClient {

  public static func previewValue() -> Self {
    testValue()
  }

  public static func testValue() -> Self {
    fatalError()
  }

  public static func liveValue() -> Self {
    Self(
      calculateEffectiveCalendarDate: { request in
        switch request.goalType {
        case .everyXDays, .daysOfWeek:
          return request.currentCalendarDate

        case .weeksPeriod:
          return request.currentCalendarDate.getCurrentOrPrevious(
            dayOfWeek: request.startingDayOfWeek
          )

        }
      }
    )
  }

}
