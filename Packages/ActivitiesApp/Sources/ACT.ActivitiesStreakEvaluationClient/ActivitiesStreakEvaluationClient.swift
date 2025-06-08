import Foundation
import ACT_SharedModels

public struct ActivitiesStreakEvaluationClient {

  public enum EvaluateActivitiesStreaksUpToToday {
    public struct Request {
      public init() {

      }
    }
    public typealias Response = Void
  }
  public var evaluateActivitiesStreaksUpToToday: @Sendable (EvaluateActivitiesStreaksUpToToday.Request) async throws -> EvaluateActivitiesStreaksUpToToday.Response

  public init(
    evaluateActivitiesStreaksUpToToday: @Sendable @escaping (EvaluateActivitiesStreaksUpToToday.Request) -> EvaluateActivitiesStreaksUpToToday.Response
  ) {
    self.evaluateActivitiesStreaksUpToToday = evaluateActivitiesStreaksUpToToday
  }


  static func determineStartingCalendarDateToEvaluate(appStateModel: AppStateModel) -> CalendarDate {
    if let latestEvaluatedDate = appStateModel.latestCalendarDateWithAllActivityStreaksEvaluated {
      return latestEvaluatedDate.addingDays(1)
    } else {
      return appStateModel.createCalendarDate
    }
  }

  static func determineEndingCalendarDateToEvaluate(today: CalendarDate) -> CalendarDate { 
    return today.addingDays(-1)
  }

}
