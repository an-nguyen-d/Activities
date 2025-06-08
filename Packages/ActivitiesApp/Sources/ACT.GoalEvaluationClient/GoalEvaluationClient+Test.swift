import Foundation
import ACT_SharedModels

extension GoalEvaluationClient {

  public static func previewValue() -> Self {
    liveValue()
  }

  public static func liveValue() -> Self {
    return .init(
      evaluateStatus: { request in
        precondition(request.goal.effectiveCalendarDate <= request.currentDate)

        // Get the target for this date (returns nil if should skip)
        guard let target = request.goal.getGoalTarget(for: request.evaluationDate) else {
          return .skip
        }

        // Evaluate using the criteria
        return target.goalSuccessCriteria.evaluate(
          totalValue: request.sessionsInGoalPeriodValueTotal,
          goalValue: target.goalValue,
          isEvaluatingInPast: request.evaluationDate < request.currentDate
        )
      }
    )
  }
}
