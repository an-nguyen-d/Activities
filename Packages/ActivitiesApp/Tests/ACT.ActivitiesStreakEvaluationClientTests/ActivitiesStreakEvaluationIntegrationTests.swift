import XCTest
@testable import ACT_ActivitiesStreakEvaluationClient
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_GoalEvaluationClient
import ACT_DatabaseClientGRDB
import ElixirShared

final class ActivitiesStreakEvaluationIntegrationTests: XCTestCase {

  // MARK: - Properties

  var client: ActivitiesStreakEvaluationClient!
  var databaseClient: DatabaseClient!
  var timeZone: TimeZone!
  var currentTestCalendarDate: CalendarDate!

  // MARK: - Setup

  override func setUp() async throws {
    try await super.setUp()

    timeZone = TimeZone(identifier: "America/New_York")!

    // Start tests on Dec 1, 2024 (Sunday)
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

    // Initialize app state
    _ = try await databaseClient.fetchOrCreateAppState(.init())
  }

  // MARK: - Test Helpers

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
      target: .init(
        id: .init(rawValue: Int64.random(in: 1...10000)),
        goalValue: targetMinutes,
        goalSuccessCriteria: .atLeast
      )
    ))
  }

  private func createEveryXDaysGoal(
    for activityId: ActivityModel.ID,
    targetMinutes: Double,
    everyXDays: Int,
    effectiveCalendarDate: CalendarDate
  ) async throws {
    _ = try await databaseClient.createEveryXDaysGoal(.init(
      activityId: activityId,
      createDate: effectiveCalendarDate.date(timeZone: timeZone),
      effectiveCalendarDate: effectiveCalendarDate,
      daysInterval: everyXDays,
      target: .init(
        id: .init(rawValue: Int64.random(in: 1...10000)),
        goalValue: targetMinutes,
        goalSuccessCriteria: .atLeast
      )
    ))
  }

  private func createWeeklyGoal(
    for activityId: ActivityModel.ID,
    targetMinutes: Double,
    effectiveCalendarDate: CalendarDate
  ) async throws {
    let effectiveMondayCalendarDate = effectiveCalendarDate.getCurrentOrPrevious(dayOfWeek: .monday)
    _ = try await databaseClient.createWeeksPeriodGoal(.init(
      activityId: activityId,
      createDate: effectiveMondayCalendarDate.date(timeZone: timeZone),
      effectiveCalendarDate: effectiveMondayCalendarDate,
      target: .init(
        id: .init(rawValue: Int64.random(in: 1...10000)),
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
    let activities = try await databaseClient.fetchActivitiesNeedingEvaluation(.init(
      evaluationDate: currentTestCalendarDate
    ))
    return activities.first { $0.id.rawValue == id }
  }

  // MARK: - Test: Simple Daily Meditation Journey

  func test_dailyMeditationJourney_twoWeeks() async throws {
    // User starts meditation habit on Dec 1
    let meditation = try await createActivity(
      id: 1,
      currentStreakCount: 0,
      lastCheckCalendarDate: nil
    )

    try await createDailyGoal(
      for: meditation.id,
      targetMinutes: 10,
      effectiveCalendarDate: CalendarDate("2024-12-01")
    )

    // Day-by-day journey
    let meditationPattern: [(String, Double?)] = [
      ("2024-12-01", 15.0),  // Sun: Success (15 min)
      ("2024-12-02", 12.0),  // Mon: Success (12 min)
      ("2024-12-03", 0.0),   // Tue: Skip (0 min)
      ("2024-12-04", 20.0),  // Wed: Success (20 min)
      ("2024-12-05", 8.0),   // Thu: Fail (8 min, below 10)
      ("2024-12-06", 11.0),  // Fri: Success (11 min)
      ("2024-12-07", 10.0),  // Sat: Success (10 min)
      ("2024-12-08", 25.0),  // Sun: Success (25 min)
      ("2024-12-09", nil),   // Mon: No session
      ("2024-12-10", 10.0),  // Tue: Success (10 min)
      ("2024-12-11", 15.0),  // Wed: Success (15 min)
      ("2024-12-12", 5.0),   // Thu: Fail (5 min)
      ("2024-12-13", 30.0),  // Fri: Success (30 min)
      ("2024-12-14", 20.0),  // Sat: Success (20 min)
    ]

    var expectedStreaks: [Int] = []
    var currentStreak = 0

    for (dateString, minutes) in meditationPattern {
      let calendarDate = CalendarDate(dateString)

      // Add session if minutes provided
      if let minutes = minutes, minutes > 0 {
        try await createSession(
          activityId: meditation.id,
          minutes: minutes,
          on: calendarDate
        )
      }

      // Calculate expected streak
      if let minutes = minutes, minutes >= 10 {
        currentStreak += 1
      } else {
        currentStreak = 0
      }
      expectedStreaks.append(currentStreak)

      // Advance time and run evaluation
      advanceToCalendarDate(calendarDate.addingDays(1))
      try await runStreakEvaluation()

      // Verify streak
      let updatedActivity = try await fetchActivity(id: 1)
      XCTAssertEqual(
        updatedActivity?.currentStreakCount,
        currentStreak,
        "Streak mismatch on \(dateString): expected \(currentStreak)"
      )
    }

    // Final assertions
    let finalActivity = try await fetchActivity(id: 1)
    XCTAssertEqual(finalActivity?.currentStreakCount, 2) // Last two days were successful
    XCTAssertEqual(finalActivity?.lastGoalSuccessCheckCalendarDate, CalendarDate("2024-12-14"))
  }

  // MARK: - Test: Goal Change Mid-Journey

  func test_goalChange_fromDailyToEveryOtherDay() async throws {
    // User starts with daily exercise goal
    let exercise = try await createActivity(
      id: 2,
      currentStreakCount: 0
    )

    try await createDailyGoal(
      for: exercise.id,
      targetMinutes: 30,
      effectiveCalendarDate: CalendarDate("2024-12-01")
    )

    // Week 1: Daily goal
    for day in 1...7 {
      let dayString = String(format: "%02d", day)
      let calendarDate = CalendarDate("2024-12-\(dayString)")

      // Exercise every day for first week
      try await createSession(
        activityId: exercise.id,
        minutes: 35,
        on: calendarDate
      )

      advanceToCalendarDate(calendarDate.addingDays(1))
      try await runStreakEvaluation()
    }

    // Verify week 1 streak
    var activity = try await fetchActivity(id: 2)
    XCTAssertEqual(activity?.currentStreakCount, 7)

    // Change to every-other-day goal on Dec 8
    try await createEveryXDaysGoal(
      for: exercise.id,
      targetMinutes: 30,
      everyXDays: 2,
      effectiveCalendarDate: CalendarDate("2024-12-08")
    )

    // Week 2: Every-other-day goal
    for day in 8...14 {
      let dayString = String(format: "%02d", day)
      let calendarDate = CalendarDate("2024-12-\(dayString)")

      // Exercise on even days only
      if day % 2 == 0 {
        try await createSession(
          activityId: exercise.id,
          minutes: 40,
          on: calendarDate
        )
      }

      advanceToCalendarDate(calendarDate.addingDays(1))
      try await runStreakEvaluation()
    }

    // Final verification
    activity = try await fetchActivity(id: 2)
    XCTAssertEqual(activity?.currentStreakCount, 11) // 7 from week 1 + 4 from week 2
  }

  // MARK: - Test: Multiple Activities with Different Goal Types

  func test_multipleActivities_differentGoalTypes() async throws {
    // Setup 3 activities with different goal types

    // 1. Reading: Daily goal
    let reading = try await createActivity(id: 3)
    try await createDailyGoal(
      for: reading.id,
      targetMinutes: 20,
      effectiveCalendarDate: CalendarDate("2024-12-01")
    )

    // 2. Running: Every 3 days
    let running = try await createActivity(id: 4)
    try await createEveryXDaysGoal(
      for: running.id,
      targetMinutes: 30,
      everyXDays: 3,
      effectiveCalendarDate: CalendarDate("2024-12-01")
    )

    // 3. Weekly planning: Weekly goal (120 min/week)
    let planning = try await createActivity(id: 5)
    try await createWeeklyGoal(
      for: planning.id,
      targetMinutes: 120,
      effectiveCalendarDate: CalendarDate("2024-12-02") // Monday
    )

    // Simulate 2 weeks
    for day in 1...14 {
      let dayString = String(format: "%02d", day)
      let calendarDate = CalendarDate("2024-12-\(dayString)")

      // Reading: Daily, skip weekends
      let isWeekend = calendarDate.dayOfWeek() == .saturday || calendarDate.dayOfWeek() == .sunday
      if !isWeekend {
        try await createSession(
          activityId: reading.id,
          minutes: 25,
          on: calendarDate
        )
      }

      // Running: Every 3 days (1, 4, 7, 10, 13)
      if [1, 4, 7, 10, 13].contains(day) {
        try await createSession(
          activityId: running.id,
          minutes: 35,
          on: calendarDate
        )
      }

      // Planning: Big session on Sundays
      if calendarDate.dayOfWeek() == .sunday {
        try await createSession(
          activityId: planning.id,
          minutes: 130,
          on: calendarDate
        )
      }

      advanceToCalendarDate(calendarDate.addingDays(1))
      try await runStreakEvaluation()
    }

    // Final verifications
    let finalReading = try await fetchActivity(id: 3)
    let finalRunning = try await fetchActivity(id: 4)
    let finalPlanning = try await fetchActivity(id: 5)

    // Reading: Should have broken on first weekend
    XCTAssertEqual(finalReading?.currentStreakCount, 0) // Thu, Fri, Mon, Tue of week 2

    // Running: Perfect streak on every-3-days
    XCTAssertEqual(finalRunning?.currentStreakCount, 5) // All 5 sessions

    // Planning: 2 successful weeks
    XCTAssertEqual(finalPlanning?.currentStreakCount, 1)
  }

  // MARK: - Test: Week Boundary Edge Cases

  func test_weeklyGoal_boundaryConditions() async throws {
    // Create activity with weekly goal starting on a Thursday
    let activity = try await createActivity(id: 6)

    // Create goal on Thursday Dec 5 - should snap to Monday Dec 2
    try await createWeeklyGoal(
      for: activity.id,
      targetMinutes: 180, // 3 hours per week
      effectiveCalendarDate: CalendarDate("2024-12-05") // Thursday
    )

    // Add sessions throughout the week
    try await createSession(activityId: activity.id, minutes: 60, on: CalendarDate("2024-12-02")) // Mon
    try await createSession(activityId: activity.id, minutes: 70, on: CalendarDate("2024-12-04")) // Wed
    try await createSession(activityId: activity.id, minutes: 55, on: CalendarDate("2024-12-07")) // Sat

    // Advance to Sunday and evaluate
    advanceToCalendarDate(CalendarDate("2024-12-09")) // Monday of next week
    try await runStreakEvaluation()

    let result = try await fetchActivity(id: 6)
    XCTAssertEqual(result?.currentStreakCount, 1) // 185 minutes >= 180 target

    // Next week: Just under target
    try await createSession(activityId: activity.id, minutes: 90, on: CalendarDate("2024-12-10")) // Tue
    try await createSession(activityId: activity.id, minutes: 85, on: CalendarDate("2024-12-12")) // Thu
    // Total: 175 < 180

    advanceToCalendarDate(CalendarDate("2024-12-16")) // Monday of week 3
    try await runStreakEvaluation()

    let finalResult = try await fetchActivity(id: 6)
    XCTAssertEqual(finalResult?.currentStreakCount, 0) // Streak broken
  }

  // MARK: - Test: No Activities

  func test_noActivities_handlesGracefully() async throws {
    // Just run evaluation with no activities
    try await runStreakEvaluation()

    // Should complete without error
    let appState = try await databaseClient.fetchOrCreateAppState(.init())
    XCTAssertNil(appState.latestCalendarDateWithAllActivityStreaksEvaluated)

  }
}
