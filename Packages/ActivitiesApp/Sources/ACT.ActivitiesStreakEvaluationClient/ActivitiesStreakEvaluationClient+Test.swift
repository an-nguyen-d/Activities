import Foundation
import ElixirShared
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_GoalEvaluationClient

private actor ActivitiesStreakEvaluationClientStorage {
  static let shared = ActivitiesStreakEvaluationClientStorage()

  private var client: ActivitiesStreakEvaluationClient?

  func getOrCreate(
    dateMaker: DateMaker,
    timeZone: TimeZone,
    databaseClient: DatabaseClient,
    goalEvaluationClient: GoalEvaluationClient
  ) -> ActivitiesStreakEvaluationClient {
    if let existing = client {
      return existing
    }

    let new = ActivitiesStreakEvaluationClient.init(
      dateMaker: dateMaker,
      timeZone: timeZone,
      databaseClient: databaseClient,
      goalEvaluationClient: goalEvaluationClient
    )
    client = new
    return new
  }

  func reset() {
    client = nil
  }
}

extension ActivitiesStreakEvaluationClient {
  public static func liveValue(
    dateMaker: DateMaker,
    timeZone: TimeZone,
    databaseClient: DatabaseClient,
    goalEvaluationClient: GoalEvaluationClient
  ) async -> ActivitiesStreakEvaluationClient {
    await ActivitiesStreakEvaluationClientStorage.shared.getOrCreate(
      dateMaker: dateMaker,
      timeZone: timeZone,
      databaseClient: databaseClient,
      goalEvaluationClient: goalEvaluationClient
    )
  }
}

extension ActivitiesStreakEvaluationClient {

  public static func previewValue() -> Self {
    testValue()
  }

  public static func testValue() -> Self {
    fatalError()
  }

  init(
    dateMaker: DateMaker,
    timeZone: TimeZone,
    databaseClient: DatabaseClient,
    goalEvaluationClient: GoalEvaluationClient
  ) {

    let coordinator = SingleExecutionCoordinator()


    self.evaluateActivitiesStreaksUpToToday = { req in
      try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
          Task(priority: .high) {
            do {
              let didExecute = try await coordinator.executeIfNotRunning {

                // 1. Get current date
                let todayCalendarDate = CalendarDate(from: dateMaker.date(), timeZone: timeZone)

                // 2. Fetch app state to determine where we left off
                let appState = try await databaseClient.fetchOrCreateAppState(.init())

                // 3. Determine date range to evaluate
                let startCheckCalendarDate = Self.determineStartingCalendarDateToEvaluate(appStateModel: appState)
                let endCheckCalendarDate = Self.determineEndingCalendarDateToEvaluate(today: todayCalendarDate)

                // 4. Early exit if no dates to evaluate (start > end means we're caught up)
                guard startCheckCalendarDate <= endCheckCalendarDate else { return }

                // 5. March forward from startCheckCalendarDate to endCheckCalendarDate
                var currentCheckCalendarDate = startCheckCalendarDate
                while currentCheckCalendarDate <= endCheckCalendarDate {
                  // 6. Fetch all activities that need evaluation for this date
                  let activities = try await databaseClient.fetchActivitiesNeedingEvaluation(.init(
                    evaluationDate: currentCheckCalendarDate
                  ))

                  // 7. For each activity:
                  for activity in activities {
                    // Helper to update just the lastGoalSuccessCheckCalendarDate
                    @Sendable func updateLastCheckDate(for checkDate: CalendarDate) async throws {
                      try await databaseClient.updateActivity(.init(
                        id: activity.id,
                        lastGoalSuccessCheckCalendarDate: .update(checkDate)
                      ))
                    }

                    // Fetch the effective goal for this activity on this date
                    let effectiveGoal = try await databaseClient.fetchEffectiveGoal(.init(
                      activityId: activity.id,
                      calendarDate: currentCheckCalendarDate
                    ))

                    // If no goal exists, just update the date and continue
                    guard let goal = effectiveGoal else {
                      try await updateLastCheckDate(for: currentCheckCalendarDate)
                      continue
                    }

                    // Check if there's a target for this date (might be a skip day)
                    guard goal.getGoalTarget(for: currentCheckCalendarDate) != nil else {
                      // It's a skip day - update date but don't change streak
                      try await updateLastCheckDate(for: currentCheckCalendarDate)
                      continue
                    }

                    // Check if we can evaluate the streak for this date
                    guard goal.canEvaluateStreak(
                      forEvaluationCalendarDate: currentCheckCalendarDate,
                      currentCalendarDate: todayCalendarDate
                    ) else {
                      // Can't evaluate yet (e.g., mid-period) - update date but don't change streak
                      try await updateLastCheckDate(for: currentCheckCalendarDate)
                      continue
                    }

                    // Get the date range where sessions count toward this goal's target
                    let sessionsDateRange = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: currentCheckCalendarDate)

                    // Fetch sessions total value for the date range
                    let sessionsTotal = try await databaseClient.fetchSessionsTotalValue(.init(
                      activityId: activity.id,
                      dateRange: sessionsDateRange
                    ))

                    // Evaluate if goal was met
                    let status = goalEvaluationClient.evaluateStatus(.init(
                      goal: goal,
                      sessionsInGoalPeriodValueTotal: sessionsTotal,
                      evaluationDate: currentCheckCalendarDate,
                      currentDate: todayCalendarDate
                    ))

                    // Calculate new streak count
                    let newStreakCount = Self.calculateNewStreakCount(
                      currentStreakCount: activity.currentStreakCount,
                      evaluationStatus: status
                    )

                    // Update activity with new streak and date
                    try await databaseClient.updateActivity(.init(
                      id: activity.id,
                      currentStreakCount: .update(newStreakCount),
                      lastGoalSuccessCheckCalendarDate: .update(currentCheckCalendarDate)
                    ))
                  }

                  // 8. After all activities for this date are evaluated,
                  try await databaseClient.updateAppState(.init(
                    latestCalendarDateWithAllActivityStreaksEvaluated: .update(currentCheckCalendarDate)
                  ))

                  // 9. Move to next date
                  currentCheckCalendarDate = currentCheckCalendarDate.nextDay()
                }
              }


              // Skip if evaluation already in progress

              continuation.resume()
            } catch {
              continuation.resume(throwing: error)
            }
          }
        }
      }

    }
  }

  private static func calculateNewStreakCount(
    currentStreakCount: Int,
    evaluationStatus: GoalStatus
  ) -> Int {
    switch evaluationStatus {
    case .success:
      return currentStreakCount + 1
    case .failure:
      return 0  // Reset streak
    case .incomplete:
      // Shouldn't happen if canEvaluateStreak is working correctly
      assertionFailure("Got incomplete status when canEvaluateStreak returned true")
      return currentStreakCount
    case .skip:
      // Shouldn't happen - we already checked for nil target
      assertionFailure("Got skip status when target was non-nil")
      return currentStreakCount
    }
  }

}
