import Foundation

public struct ActivityGoalTarget {
  /// Valid range: [0, ∞) - Can be 0 for "negative" goals (e.g., eat 0 snacks today)
  public let goalValue: Double
  public let goalSuccessCriteria: GoalSuccessCriteria

  public init(goalValue: Double, goalSuccessCriteria: GoalSuccessCriteria) {
    assert(goalValue >= 0)
    self.goalValue = goalValue
    self.goalSuccessCriteria = goalSuccessCriteria
  }
}
