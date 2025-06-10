import Foundation
import Tagged

public struct ActivityGoalTargetModel: Sendable, Equatable {


  public typealias ID = Tagged<(Self, id: ()), Int64>
  public let id: ID

  /// Valid range: [0, ∞) - Can be 0 for "negative" goals (e.g., eat 0 snacks today)
  public let goalValue: Double
  public let goalSuccessCriteria: GoalSuccessCriteria

  public init?(
    id: ID,
    goalValue: Double,
    goalSuccessCriteria: GoalSuccessCriteria
  ) {
    guard goalValue >= 0 else { return nil }
    
    // Validate nonsensical combinations
    if goalValue == 0 {
      // Only "exactly 0" makes sense - "at least 0" is always true, "less than 0" is impossible
      guard goalSuccessCriteria == .exactly else { return nil }
    }
    
    self.id = id
    self.goalValue = goalValue
    self.goalSuccessCriteria = goalSuccessCriteria
  }
  
  /// Validates if a value and criteria combination makes sense
  public static func isValidCombination(value: Double, criteria: GoalSuccessCriteria) -> Bool {
    guard value >= 0 else { return false }
    
    if value == 0 {
      // Only "exactly 0" makes sense
      return criteria == .exactly
    }
    
    return true
  }
}
