import Foundation
import Tagged

public struct ActivityGoalTargetModel: Sendable {


  public typealias ID = Tagged<(Self, id: ()), Int64>
  public let id: ID

  /// Valid range: [0, ∞) - Can be 0 for "negative" goals (e.g., eat 0 snacks today)
  public let goalValue: Double
  public let goalSuccessCriteria: GoalSuccessCriteria

  public init(
    id: ID,
    goalValue: Double,
    goalSuccessCriteria: GoalSuccessCriteria
  ) {
    assert(goalValue >= 0)
    self.id = id
    self.goalValue = goalValue
    self.goalSuccessCriteria = goalSuccessCriteria
  }
}
