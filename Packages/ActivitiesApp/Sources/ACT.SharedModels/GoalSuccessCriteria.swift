public enum GoalSuccessCriteria {
  case atLeast
  case exactly
  case lessThan
}

extension GoalSuccessCriteria {
  public func evaluate(
    totalValue: Double,
    goalValue: Double,
    isEvaluatingToday: Bool
  ) -> GoalStatus {
    switch self {
    case .atLeast:
      let metGoal = totalValue >= goalValue
      return metGoal ? .success : (isEvaluatingToday ? .incomplete : .failure)

    case .exactly:
      if totalValue == goalValue {
        return .success
      } else if totalValue < goalValue {
        return isEvaluatingToday ? .incomplete : .failure
      } else {
        return .failure  // Over the target
      }

    case .lessThan:
      if totalValue >= goalValue {
        return .failure  // At or over limit
      } else {
        return isEvaluatingToday ? .incomplete : .success
      }
    }
  }
}
