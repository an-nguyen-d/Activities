public protocol HasGoalCreationClient {
  var goalCreationClient: GoalCreationClient { get }
}

public extension HasGoalCreationClient {
  var goalCreationClient: GoalCreationClient {
    .previewValue()
  }
}
