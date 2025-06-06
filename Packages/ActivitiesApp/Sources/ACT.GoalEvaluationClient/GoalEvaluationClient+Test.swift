import Foundation
import ACT_SharedModels

extension GoalEvaluationClient {

  public static func previewValue() -> Self {
    testValue()
  }

  public static func testValue() -> Self {
    return .init(
      evaluateStatus: { request in
        precondition(request.goal.effectiveCalendarDate <= request.currentDate)

        // Get the target for this date (returns nil if should skip)
        guard let target = request.goal.targetForDate(request.evaluationDate) else {
          return .skip
        }

        // Determine if we're evaluating "today"
        let isToday = request.goal.isEvaluatingToday(
          evaluationDate: request.evaluationDate,
          currentDate: request.currentDate
        )

        // Evaluate using the criteria
        return target.goalSuccessCriteria.evaluate(
          totalValue: request.sessionsInGoalPeriodValueTotal,
          goalValue: target.goalValue,
          isEvaluatingToday: isToday
        )
      }
    )
  }
}
