public enum GoalSuccessCriteria: String, Sendable {
  case atLeast
  case exactly
  case lessThan
}

extension GoalSuccessCriteria {
  public func evaluate(
    totalValue: Double,
    goalValue: Double,
    isEvaluatingInPast: Bool
  ) -> GoalStatus {
    switch self {
    case .atLeast:
      let metGoal = totalValue >= goalValue
      return metGoal ? .success : (isEvaluatingInPast ? .failure : .incomplete)

    case .exactly:
      if totalValue == goalValue {
        return .success
      } else if totalValue < goalValue {
        return isEvaluatingInPast ? .failure : .incomplete  // Inverted!
      } else {
        return .failure  // Over the target
      }

    case .lessThan:
      if totalValue >= goalValue {
        return .failure  // At or over limit
      } else {
        return isEvaluatingInPast ? .success : .incomplete  // Inverted!
      }
    }
  }
}
