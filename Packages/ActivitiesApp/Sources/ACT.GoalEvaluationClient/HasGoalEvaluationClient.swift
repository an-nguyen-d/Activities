public protocol HasGoalEvaluationClient {
  var goalEvaluationClient: GoalEvaluationClient { get }
}

public extension HasGoalEvaluationClient {
  var goalEvaluationClient: GoalEvaluationClient {
    .previewValue()
  }
}
