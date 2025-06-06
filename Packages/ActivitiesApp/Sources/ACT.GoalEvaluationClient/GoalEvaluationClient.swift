import Foundation
import ACT_SharedModels

public struct GoalEvaluationClient {

  public enum EvaluateStatus {
    public struct Request {

      /// The goal to evaluate. Must be effective (not from the future).
      /// Precondition: goal.effectiveCalendarDate <= currentDate
      /// Use goal selection logic to pick the correct goal before calling this function.
      public let goal: ActivityGoalProtocol

      /// Sessions filtered to the relevant evaluation period.
      /// For daily goals: sessions completed on evaluationDate only
      /// For period goals: sessions completed within the period containing evaluationDate
      public let sessionsInGoalPeriodValueTotal: Double

      public let evaluationDate: CalendarDate

      /// Today's actual date. Used to determine if evaluation is real-time vs retrospective.
      public let currentDate: CalendarDate

      public init(
        goal: ActivityGoalProtocol,
        sessionsInGoalPeriodValueTotal: Double,
        evaluationDate: CalendarDate,
        currentDate: CalendarDate
      ) {
        self.goal = goal
        self.sessionsInGoalPeriodValueTotal = sessionsInGoalPeriodValueTotal
        self.evaluationDate = evaluationDate
        self.currentDate = currentDate
      }
    }
    public typealias Response = GoalStatus
  }

  public var evaluateStatus: @Sendable (EvaluateStatus.Request) -> EvaluateStatus.Response

  public init(
    evaluateStatus: @Sendable @escaping (EvaluateStatus.Request) -> EvaluateStatus.Response
  ) {
    self.evaluateStatus = evaluateStatus
  }

}
