public protocol HasActivitiesStreakEvaluationClient {
  var activitiesStreakEvaluationClient: ActivitiesStreakEvaluationClient { get }
}

public extension HasActivitiesStreakEvaluationClient {
  var activitiesStreakEvaluationClient: ActivitiesStreakEvaluationClient {
    .previewValue()
  }
}
