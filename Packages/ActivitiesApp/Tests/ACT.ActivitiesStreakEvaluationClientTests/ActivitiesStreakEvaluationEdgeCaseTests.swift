import XCTest
@testable import ACT_ActivitiesStreakEvaluationClient
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_GoalEvaluationClient
import ACT_DatabaseClientGRDB
import ElixirShared

final class ActivitiesStreakEvaluationEdgeCaseTests: XCTestCase {

  // MARK: - Properties

  var client: ActivitiesStreakEvaluationClient!
  var databaseClient: DatabaseClient!
  var timeZone: TimeZone!
  var currentTestCalendarDate: CalendarDate!

  // MARK: - Setup

  override func setUp() async throws {
    try await super.setUp()

    timeZone = TimeZone(identifier: "America/New_York")!
    currentTestCalendarDate = CalendarDate("2024-12-01")
    let dateMaker = DateMaker { [weak self] in
      guard let self = self else { return Date() }
      return self.currentTestCalendarDate.date(timeZone: self.timeZone)
    }

    databaseClient = try .grdbValue(
      dateMaker: dateMaker,
      timeZone: timeZone,
      configuration: .inMemory
    )

    client = ActivitiesStreakEvaluationClient(
      dateMaker: dateMaker,
      timeZone: timeZone,
      databaseClient: databaseClient,
      goalEvaluationClient: .liveValue()
    )

    _ = try await databaseClient.fetchOrCreateAppState(.init())
  }

  // MARK: - Helper Methods

  private func advanceToCalendarDate(_ calendarDate: CalendarDate) {
    currentTestCalendarDate = calendarDate
  }

  private func createActivity(
    id: Int64,
    currentStreakCount: Int = 0,
    lastCheckCalendarDate: CalendarDate? = nil
  ) async throws -> ActivityModel {
    let activity = try await databaseClient.createActivity(.init(
      id: ActivityModel.ID(rawValue: id),
      activityName: UUID().uuidString,
      sessionUnit: .seconds,
      currentStreakCount: currentStreakCount,
      lastGoalSuccessCheckCalendarDate: lastCheckCalendarDate
    ))
    return activity
  }

  private func createDailyGoal(
    for activityId: ActivityModel.ID,
    targetMinutes: Double,
    effectiveCalendarDate: CalendarDate
  ) async throws {
    _ = try await databaseClient.createEveryXDaysGoal(.init(
      activityId: activityId,
      createDate: effectiveCalendarDate.date(timeZone: timeZone),
      effectiveCalendarDate: effectiveCalendarDate,
      daysInterval: 1,
      target: DatabaseClient.CreateActivityGoalTarget.Request(
        goalValue: targetMinutes,
        goalSuccessCriteria: .atLeast
      )
    ))
  }

  private func createSession(
    activityId: ActivityModel.ID,
    minutes: Double,
    on calendarDate: CalendarDate
  ) async throws {
    let sessionDate = calendarDate.date(timeZone: timeZone)
    _ = try await databaseClient.createSession(.init(
      activityId: activityId,
      value: minutes,
      createDate: sessionDate,
      completeDate: sessionDate,
      completeCalendarDate: calendarDate
    ))
  }

  private func runStreakEvaluation() async throws {
    try await client.evaluateActivitiesStreaksUpToToday(.init())
  }

  private func fetchActivity(id: Int64) async throws -> ActivityModel? {
    return try await databaseClient.fetchActivity(.init(id: ActivityModel.ID(rawValue: id)))
  }

  // MARK: - Test: Year Boundary

  func test_yearBoundary_streakContinues() async throws {
    // Create activity with existing streak at end of year
    let activity = try await createActivity(
      id: 101,
      currentStreakCount: 10,
      lastCheckCalendarDate: CalendarDate("2024-12-28")
    )

    try await createDailyGoal(
      for: activity.id,
      targetMinutes: 30,
      effectiveCalendarDate: CalendarDate("2024-12-01")
    )

    // Add sessions crossing year boundary
    let dates = [
      "2024-12-29",
      "2024-12-30",
      "2024-12-31",
      "2025-01-01",
      "2025-01-02",
      "2025-01-03"
    ]

    for dateString in dates {
      let calendarDate = CalendarDate(dateString)
      try await createSession(
        activityId: activity.id,
        minutes: 35,
        on: calendarDate
      )

      advanceToCalendarDate(calendarDate.addingDays(1))
      try await runStreakEvaluation()
    }

    let finalActivity = try await fetchActivity(id: 101)
    XCTAssertEqual(finalActivity?.currentStreakCount, 16) // 10 + 6 days
    XCTAssertEqual(finalActivity?.lastGoalSuccessCheckCalendarDate, CalendarDate("2025-01-03"))
  }

  // MARK: - Test: Leap Year

  func test_leapYear_february29() async throws {
    // Start earlier to build up the streak naturally
    currentTestCalendarDate = CalendarDate("2024-02-22")

    // Make sure app state is set up correctly
    try await databaseClient.updateAppState(.init(
      latestCalendarDateWithAllActivityStreaksEvaluated: .update(CalendarDate("2024-02-21"))
    ))

    let activity = try await createActivity(
      id: 102,
      currentStreakCount: 0,
      lastCheckCalendarDate: nil
    )

    try await createDailyGoal(
      for: activity.id,
      targetMinutes: 20,
      effectiveCalendarDate: CalendarDate("2024-02-01")
    )

    // Build up 5-day streak first (Feb 22-26)
    for day in 22...26 {
      let calendarDate = CalendarDate("2024-02-\(day)")

      try await createSession(
        activityId: activity.id,
        minutes: 25,
        on: calendarDate
      )

      advanceToCalendarDate(calendarDate.addingDays(1))
      try await runStreakEvaluation()
    }

    // Now test the leap year dates
    let dates = ["2024-02-27", "2024-02-28", "2024-02-29", "2024-03-01"]

    for dateString in dates {
      let calendarDate = CalendarDate(dateString)

      try await createSession(
        activityId: activity.id,
        minutes: 25,
        on: calendarDate
      )

      advanceToCalendarDate(calendarDate.addingDays(1))

      try await runStreakEvaluation()
    }

    let finalActivity = try await fetchActivity(id: 102)
    XCTAssertEqual(finalActivity?.currentStreakCount, 9) // 5 + 4 days
  }

  // MARK: - Test: Activity Without Goal

  func test_activityWithoutGoal_onlyUpdatesLastCheckDate() async throws {
    let activity = try await createActivity(
      id: 103,
      currentStreakCount: 7,
      lastCheckCalendarDate: CalendarDate("2024-11-30") // Changed to Nov 30 (yesterday from Dec 1)
    )

    // Don't create any goal

    // Add some sessions anyway
    for day in 1...5 {
      let dayString = String(format: "%02d", day)
      let calendarDate = CalendarDate("2024-12-\(dayString)")
      try await createSession(
        activityId: activity.id,
        minutes: 30,
        on: calendarDate
      )
    }

    // Advance and evaluate
    advanceToCalendarDate(CalendarDate("2024-12-06"))
    try await runStreakEvaluation()

    let finalActivity = try await fetchActivity(id: 103)
    XCTAssertEqual(finalActivity?.currentStreakCount, 7) // Unchanged
    XCTAssertEqual(finalActivity?.lastGoalSuccessCheckCalendarDate, CalendarDate("2024-12-05"))
  }

  // MARK: - Test: Goal Collision

  func test_goalCollision_weeksPeriodReplacesEveryXDays() async throws {
    // Create activity with EveryXDays goal starting Monday
    let activity = try await createActivity(id: 104)

    // Create EveryXDays goal on Monday Dec 2
    try await createDailyGoal(
      for: activity.id,
      targetMinutes: 30,
      effectiveCalendarDate: CalendarDate("2024-12-02") // Monday
    )

    // Add sessions for a few days
    for day in 2...5 {
      let dayString = String(format: "%02d", day)
      let calendarDate = CalendarDate("2024-12-\(dayString)")
      try await createSession(
        activityId: activity.id,
        minutes: 35,
        on: calendarDate
      )

      advanceToCalendarDate(calendarDate.addingDays(1))
      try await runStreakEvaluation()
    }

    var currentActivity = try await fetchActivity(id: 104)
    XCTAssertEqual(currentActivity?.currentStreakCount, 4)

    // On Friday, create WeeksPeriod goal (should delete the EveryXDays goal)
    advanceToCalendarDate(CalendarDate("2024-12-06")) // Friday

    // First check for collision
    let existingGoal = try await databaseClient.fetchActivityGoal(.init(
      activityId: activity.id,
      fetchType: .matchingEffectiveCalendarDate(CalendarDate("2024-12-02")) // Monday
    ))

    XCTAssertNotNil(existingGoal, "Should find existing goal with Monday effective date")

    // Create new goal replacing the old one
    if let existingGoal = existingGoal {
      _ = try await databaseClient.createGoalReplacingExisting(.init(
        goalCreationType: .weeksPeriod(.init(
          activityId: activity.id,
          createDate: CalendarDate("2024-12-06").date(timeZone: timeZone),
          effectiveCalendarDate: CalendarDate("2024-12-02"), // Snaps to Monday
          target: DatabaseClient.CreateActivityGoalTarget.Request(
            goalValue: 180, // 3 hours per week
            goalSuccessCriteria: .atLeast
          )
        )),
        existingGoalIdToDelete: existingGoal.id
      ))
    }

    // Continue with weekly pattern
    try await createSession(activityId: activity.id, minutes: 60, on: CalendarDate("2024-12-06")) // Fri
    try await createSession(activityId: activity.id, minutes: 70, on: CalendarDate("2024-12-07")) // Sat
    try await createSession(activityId: activity.id, minutes: 65, on: CalendarDate("2024-12-08")) // Sun

    // Advance to next Monday to evaluate the week
    advanceToCalendarDate(CalendarDate("2024-12-09"))
    try await runStreakEvaluation()

    currentActivity = try await fetchActivity(id: 104)
    // Total for week: 35+35+35+35+60+70+65 = 335 minutes > 180 target
    XCTAssertEqual(currentActivity?.currentStreakCount, 5) // 4 daily + 1 weekly
  }

  // MARK: - Test: Multiple Sessions Same Day

  func test_multipleSessionsSameDay_sumsCorrectly() async throws {
    let activity = try await createActivity(id: 105)

    try await createDailyGoal(
      for: activity.id,
      targetMinutes: 60,
      effectiveCalendarDate: CalendarDate("2024-12-01")
    )

    // Day 1: Multiple small sessions that sum to success
    let day1 = CalendarDate("2024-12-01")
    try await createSession(activityId: activity.id, minutes: 20, on: day1)
    try await createSession(activityId: activity.id, minutes: 25, on: day1)
    try await createSession(activityId: activity.id, minutes: 20, on: day1)
    // Total: 65 minutes

    // Day 2: Multiple sessions that don't reach goal
    let day2 = CalendarDate("2024-12-02")
    try await createSession(activityId: activity.id, minutes: 15, on: day2)
    try await createSession(activityId: activity.id, minutes: 10, on: day2)
    try await createSession(activityId: activity.id, minutes: 20, on: day2)
    // Total: 45 minutes

    advanceToCalendarDate(CalendarDate("2024-12-03"))
    try await runStreakEvaluation()

    let finalActivity = try await fetchActivity(id: 105)
    XCTAssertEqual(finalActivity?.currentStreakCount, 0) // Day 2 broke the streak
  }

  // MARK: - Test: Days of Week Goal

  func test_daysOfWeekGoal_complexPattern() async throws {
    let activity = try await createActivity(id: 106)

    // Goal: Mon/Wed/Fri - 45 minutes each
    _ = try await databaseClient.createDaysOfWeekGoal(.init(
      activityId: activity.id,
      createDate: CalendarDate("2024-12-01").date(timeZone: timeZone),
      effectiveCalendarDate: CalendarDate("2024-12-01"),
      weeksInterval: 1,
      mondayGoal: DatabaseClient.CreateActivityGoalTarget.Request(
        goalValue: 45,
        goalSuccessCriteria: .atLeast
      ),
      tuesdayGoal: nil,
      wednesdayGoal: DatabaseClient.CreateActivityGoalTarget.Request(
        goalValue: 45,
        goalSuccessCriteria: .atLeast
      ),
      thursdayGoal: nil,
      fridayGoal: DatabaseClient.CreateActivityGoalTarget.Request(
        goalValue: 45,
        goalSuccessCriteria: .atLeast
      ),
      saturdayGoal: nil,
      sundayGoal: nil
    ))

    // Week 1 (Dec 2-8)
    try await createSession(activityId: activity.id, minutes: 50, on: CalendarDate("2024-12-02")) // Mon ✓
    try await createSession(activityId: activity.id, minutes: 30, on: CalendarDate("2024-12-04")) // Wed ✗
    try await createSession(activityId: activity.id, minutes: 60, on: CalendarDate("2024-12-06")) // Fri ✓

    // Evaluate after each day
    for day in 2...8 {
      let dayString = String(format: "%02d", day)
      advanceToCalendarDate(CalendarDate("2024-12-\(dayString)"))
      try await runStreakEvaluation()
    }

    var currentActivity = try await fetchActivity(id: 106)
    XCTAssertEqual(currentActivity?.currentStreakCount, 1) // Wed failure broke streak

    // Week 2 - perfect week
    try await createSession(activityId: activity.id, minutes: 50, on: CalendarDate("2024-12-09"))  // Mon ✓
    try await createSession(activityId: activity.id, minutes: 55, on: CalendarDate("2024-12-11")) // Wed ✓
    try await createSession(activityId: activity.id, minutes: 48, on: CalendarDate("2024-12-13")) // Fri ✓

    for day in 9...15 {
      let dayString = String(format: "%02d", day)
      advanceToCalendarDate(CalendarDate("2024-12-\(dayString)"))
      try await runStreakEvaluation()
    }

    currentActivity = try await fetchActivity(id: 106)
    XCTAssertEqual(currentActivity?.currentStreakCount, 4) // Mon, Wed, Fri all successful
  }

  // MARK: - Test: Catch Up After Missing Days

  func test_catchUpAfterMissingDays_evaluatesSequentially() async throws {
    // Create activity that was last checked 5 days ago
    let activity = try await createActivity(
      id: 107,
      currentStreakCount: 10,
      lastCheckCalendarDate: CalendarDate("2024-11-25")
    )

    try await createDailyGoal(
      for: activity.id,
      targetMinutes: 20,
      effectiveCalendarDate: CalendarDate("2024-10-01")
    )

    // Update app state to match
    try await databaseClient.updateAppState(.init(
      latestCalendarDateWithAllActivityStreaksEvaluated: .update(CalendarDate("2024-11-25"))
    ))

    // Add sessions for some days
    try await createSession(activityId: activity.id, minutes: 25, on: CalendarDate("2024-11-26"))
    try await createSession(activityId: activity.id, minutes: 25, on: CalendarDate("2024-11-27"))
    // Skip Nov 28
    try await createSession(activityId: activity.id, minutes: 25, on: CalendarDate("2024-11-29"))
    try await createSession(activityId: activity.id, minutes: 25, on: CalendarDate("2024-11-30"))

    // Run evaluation - it should process Nov 26-30 sequentially
    advanceToCalendarDate(CalendarDate("2024-12-01"))
    try await runStreakEvaluation()

    let finalActivity = try await fetchActivity(id: 107)
    XCTAssertEqual(finalActivity?.currentStreakCount, 2) // Broken on Nov 28
    XCTAssertEqual(finalActivity?.lastGoalSuccessCheckCalendarDate, CalendarDate("2024-11-30"))

    // Verify app state updated
    let appState = try await databaseClient.fetchOrCreateAppState(.init())
    XCTAssertEqual(
      appState.latestCalendarDateWithAllActivityStreaksEvaluated,
      CalendarDate("2024-11-30")
    )
  }
}
