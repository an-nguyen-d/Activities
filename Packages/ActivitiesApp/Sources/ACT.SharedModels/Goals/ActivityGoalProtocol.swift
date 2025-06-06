public protocol ActivityGoalProtocol {
  var effectiveCalendarDate: CalendarDate { get }
  
  // Returns nil if should skip, otherwise the target to evaluate
  func targetForDate(_ date: CalendarDate) -> ActivityGoalTarget?

  // For period-based goals that need both dates
  func isEvaluatingToday(evaluationDate: CalendarDate, currentDate: CalendarDate) -> Bool
}
