import XCTest
import GRDB
@testable import ACT_DatabaseClientGRDB
import ACT_DatabaseClient
import ACT_SharedModels

// MARK: - Base Test Case

class DatabaseClientTestCase: XCTestCase {
  var client: DatabaseClient!
  
  override func setUp() async throws {
    try await super.setUp()
    client = try! .grdbValue(
      dateMaker: .liveValue,
      timeZone: .autoupdatingCurrent,
      configuration: .inMemory
    )
  }
  
  override func tearDown() async throws {
    client = nil
    try await super.tearDown()
  }
  
  // MARK: - Helper Methods
  
  /// Creates an activity with default values
  func createTestActivity(
    id: Int64 = 1,
    currentStreakCount: Int = 0,
    lastGoalSuccessCheckCalendarDate: CalendarDate? = nil
  ) async throws -> ActivityModel {
    try await client.createActivity(.init(
      id: .init(rawValue: id),
      activityName: UUID().uuidString,
      sessionUnit: .seconds,
      currentStreakCount: currentStreakCount,
      lastGoalSuccessCheckCalendarDate: lastGoalSuccessCheckCalendarDate
    ))
  }
  
  /// Creates a sequence of dates starting from the given date
  func makeDates(start: CalendarDate, count: Int) -> [CalendarDate] {
    (0..<count).map { start.addingDays($0) }
  }
  
  /// Creates sessions with the given values on the specified dates
  func createSessions(
    activityId: ActivityModel.ID,
    values: [Double],
    dates: [CalendarDate]
  ) async throws {
    precondition(values.count == dates.count, "Values and dates must have same count")
    
    for (value, date) in zip(values, dates) {
      _ = try await client.createSession(.init(
        activityId: activityId,
        value: value,
        createDate: TestDateMaker.testDate(from: date),
        completeDate: TestDateMaker.testDate(from: date),
        completeCalendarDate: date
      ))
    }
  }
  
  /// Creates a single session
  func createSession(
    activityId: ActivityModel.ID,
    value: Double,
    date: CalendarDate
  ) async throws {
    try await createSessions(activityId: activityId, values: [value], dates: [date])
  }
  
  // Note: ActivityGoalTargetModel IDs should be unique within the database.
  // In tests, we use sequential IDs (1, 2, 3...) for clarity.
}

// MARK: - Activity Evaluation Tests

final class FetchActivitiesNeedingEvaluationTests: DatabaseClientTestCase {
  
  func test_filtersCorrectly() async throws {
    let evaluationDate = CalendarDate("2025-01-04")
    let previousDay = evaluationDate.addingDays(-1)
    
    // Insert test data
    _ = try await createTestActivity(id: 1, lastGoalSuccessCheckCalendarDate: previousDay) // Needs evaluation
    _ = try await createTestActivity(id: 2, lastGoalSuccessCheckCalendarDate: nil) // Never checked - needs evaluation
    _ = try await createTestActivity(id: 3, lastGoalSuccessCheckCalendarDate: evaluationDate) // Already checked - skip
    
    // Test
    let activities = try await client.fetchActivitiesNeedingEvaluation(.init(evaluationDate: evaluationDate))
    
    // Assert - should get activities 1 and 2, not 3
    let activityIDs = activities.map(\.id.rawValue).sorted()
    XCTAssertEqual(activityIDs, [1, 2])
  }
  
  func test_whenNoActivities_returnsEmpty() async throws {
    let activities = try await client.fetchActivitiesNeedingEvaluation(.init(
      evaluationDate: CalendarDate("2025-01-04")
    ))
    
    XCTAssertEqual(activities.map(\.id), [])
  }
  
  func test_whenAllActivitiesUpToDate_returnsEmpty() async throws {
    let evaluationDate = CalendarDate("2025-01-04")
    
    // All activities already checked for this date
    _ = try await createTestActivity(id: 1, lastGoalSuccessCheckCalendarDate: evaluationDate)
    _ = try await createTestActivity(id: 2, lastGoalSuccessCheckCalendarDate: evaluationDate)
    
    let activities = try await client.fetchActivitiesNeedingEvaluation(.init(
      evaluationDate: evaluationDate
    ))
    
    XCTAssertEqual(activities.map(\.id), [])
  }
}

// MARK: - Fetch Effective Goal Tests

final class FetchEffectiveGoalTests: DatabaseClientTestCase {
  
  func test_whenNoGoalExists_returnsNil() async throws {
    let activity = try await createTestActivity()
    
    let goal = try await client.fetchEffectiveGoal(.init(
      activityId: activity.id,
      calendarDate: CalendarDate("2025-01-04")
    ))
    
    XCTAssertNil(goal)
  }
  
  func test_whenSingleGoalExists_returnsIt() async throws {
    let activity = try await createTestActivity()
    
    // Create a goal
    _ = try await client.createEveryXDaysGoal(.init(
      activityId: activity.id,
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-01"),
      daysInterval: 2,
      target: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast)
    ))
    
    // Fetch goal on or after effective date
    let goal = try await client.fetchEffectiveGoal(.init(
      activityId: activity.id,
      calendarDate: CalendarDate("2025-01-15")
    ))
    
    let everyXDaysGoal = goal as? EveryXDaysActivityGoalModel
    XCTAssertNotNil(everyXDaysGoal)
    XCTAssertEqual(everyXDaysGoal?.daysInterval, 2)
    XCTAssertEqual(everyXDaysGoal?.target.goalValue, 30)
    XCTAssertEqual(everyXDaysGoal?.target.goalSuccessCriteria, .atLeast)
  }
  
  func test_whenMultipleGoalsExist_returnsMostRecent() async throws {
    let activity = try await createTestActivity()
    
    // Create three goals with different effective dates
    _ = try await client.createEveryXDaysGoal(.init(
      activityId: activity.id,
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-01"),
      daysInterval: 1,
      target: ActivityGoalTargetModel(id: 1, goalValue: 10, goalSuccessCriteria: .atLeast)
    ))
    
    _ = try await client.createEveryXDaysGoal(.init(
      activityId: activity.id,
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-02-01"),
      daysInterval: 2,
      target: ActivityGoalTargetModel(id: 2, goalValue: 20, goalSuccessCriteria: .exactly)
    ))
    
    _ = try await client.createEveryXDaysGoal(.init(
      activityId: activity.id,
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-03-01"),
      daysInterval: 3,
      target: ActivityGoalTargetModel(id: 3, goalValue: 30, goalSuccessCriteria: .lessThan)
    ))
    
    // Query for Feb 15 - should get the Feb 1 goal
    let goal = try await client.fetchEffectiveGoal(.init(
      activityId: activity.id,
      calendarDate: CalendarDate("2025-02-15")
    ))
    
    let everyXDaysGoal = goal as? EveryXDaysActivityGoalModel
    XCTAssertNotNil(everyXDaysGoal)
    XCTAssertEqual(everyXDaysGoal?.daysInterval, 2)
    XCTAssertEqual(everyXDaysGoal?.target.goalValue, 20)
    XCTAssertEqual(everyXDaysGoal?.effectiveCalendarDate.value, "2025-02-01")
  }
  
  func test_whenQueryingBeforeFirstGoal_returnsNil() async throws {
    let activity = try await createTestActivity()
    
    // Create goal starting Feb 1
    _ = try await client.createEveryXDaysGoal(.init(
      activityId: activity.id,
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-02-01"),
      daysInterval: 1,
      target: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast)
    ))
    
    // Query for Jan 15 - before the goal
    let goal = try await client.fetchEffectiveGoal(.init(
      activityId: activity.id,
      calendarDate: CalendarDate("2025-01-15")
    ))
    
    XCTAssertNil(goal)
  }
  
  func test_daysOfWeekGoal() async throws {
    let activity = try await createTestActivity()
    
    // Create DaysOfWeek goal with targets for Mon/Wed/Fri
    _ = try await client.createDaysOfWeekGoal(.init(
      activityId: activity.id,
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-01"),
      weeksInterval: 1,
      mondayGoal: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast),
      tuesdayGoal: nil,
      wednesdayGoal: ActivityGoalTargetModel(id: 2, goalValue: 45, goalSuccessCriteria: .exactly),
      thursdayGoal: nil,
      fridayGoal: ActivityGoalTargetModel(id: 3, goalValue: 60, goalSuccessCriteria: .lessThan),
      saturdayGoal: nil,
      sundayGoal: nil
    ))
    
    // Fetch goal
    let goal = try await client.fetchEffectiveGoal(.init(
      activityId: activity.id,
      calendarDate: CalendarDate("2025-01-15")
    ))
    
    let daysOfWeekGoal = goal as? DaysOfWeekActivityGoalModel
    XCTAssertNotNil(daysOfWeekGoal)
    XCTAssertEqual(daysOfWeekGoal?.weeksInterval, 1)
    
    // Check specific days
    XCTAssertEqual(daysOfWeekGoal?.mondayGoal?.goalValue, 30)
    XCTAssertEqual(daysOfWeekGoal?.mondayGoal?.goalSuccessCriteria, .atLeast)
    XCTAssertNil(daysOfWeekGoal?.tuesdayGoal)
    XCTAssertEqual(daysOfWeekGoal?.wednesdayGoal?.goalValue, 45)
    XCTAssertEqual(daysOfWeekGoal?.wednesdayGoal?.goalSuccessCriteria, .exactly)
    XCTAssertEqual(daysOfWeekGoal?.fridayGoal?.goalValue, 60)
    XCTAssertEqual(daysOfWeekGoal?.fridayGoal?.goalSuccessCriteria, .lessThan)
  }
  
  func test_weeksPeriodGoal() async throws {
    let activity = try await createTestActivity()
    
    // Create WeeksPeriod goal
    _ = try await client.createWeeksPeriodGoal(.init(
      activityId: activity.id,
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // A Monday
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    ))
    
    // Fetch goal
    let goal = try await client.fetchEffectiveGoal(.init(
      activityId: activity.id,
      calendarDate: CalendarDate("2025-01-20")
    ))
    
    let weeksPeriodGoal = goal as? WeeksPeriodActivityGoalModel
    XCTAssertNotNil(weeksPeriodGoal)
    XCTAssertEqual(weeksPeriodGoal?.target.goalValue, 150)
    XCTAssertEqual(weeksPeriodGoal?.target.goalSuccessCriteria, .atLeast)
    XCTAssertEqual(weeksPeriodGoal?.effectiveCalendarDate.value, "2025-01-06")
  }
}

// MARK: - Fetch Sessions Total Value Tests

final class FetchSessionsTotalValueTests: DatabaseClientTestCase {
  private var activity: ActivityModel!
  
  override func setUp() async throws {
    try await super.setUp()
    activity = try await createTestActivity()
  }
  
  override func tearDown() async throws {
    activity = nil
    try await super.tearDown()
  }
  
  // MARK: - Single Day Tests
  
  func test_singleDay_withMultipleSessions_returnsSum() async throws {
    let targetDate = CalendarDate("2025-01-04")
    
    try await createSessions(
      activityId: activity.id,
      values: [10.5, 20.3],
      dates: [targetDate, targetDate]
    )
    
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: activity.id,
      dateRange: .singleDay(targetDate)
    ))
    
    XCTAssertEqual(total, 30.8, accuracy: 0.001)
  }
  
  func test_singleDay_noSessions_returnsZero() async throws {
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: activity.id,
      dateRange: .singleDay(CalendarDate("2025-01-04"))
    ))
    
    XCTAssertEqual(total, 0.0)
  }
  
  func test_singleDay_differentActivity_returnsZero() async throws {
    let otherActivity = try await createTestActivity(id: 2)
    let targetDate = CalendarDate("2025-01-04")
    
    try await createSession(activityId: activity.id, value: 25.0, date: targetDate)
    
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: otherActivity.id,
      dateRange: .singleDay(targetDate)
    ))
    
    XCTAssertEqual(total, 0.0)
  }
  
  // MARK: - Multiple Days Tests
  
  func test_multipleDays_fullWeek_returnsSum() async throws {
    let monday = CalendarDate("2025-01-06")
    let weekDates = makeDates(start: monday, count: 7)
    let values = [10.0, 15.0, 20.0, 5.0, 12.5, 7.5, 30.0] // Total: 100
    
    try await createSessions(activityId: activity.id, values: values, dates: weekDates)
    
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: activity.id,
      dateRange: .multipleDays(start: weekDates.first!, end: weekDates.last!)
    ))
    
    XCTAssertEqual(total, 100.0)
  }
  
  func test_multipleDays_arbitrarySpan_returnsSum() async throws {
    let startDate = CalendarDate("2025-01-10")
    let dates = makeDates(start: startDate, count: 10)
    let values = Array(repeating: 5.5, count: 10) // 10 days × 5.5 = 55
    
    try await createSessions(activityId: activity.id, values: values, dates: dates)
    
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: activity.id,
      dateRange: .multipleDays(start: dates.first!, end: dates.last!)
    ))
    
    XCTAssertEqual(total, 55.0)
  }
  
  func test_multipleDays_sparseSessions_returnsSum() async throws {
    let startDate = CalendarDate("2025-01-01")
    let allDates = makeDates(start: startDate, count: 30)
    
    // Only create sessions on every 5th day
    let sparseDates = stride(from: 0, to: allDates.count, by: 5).map { allDates[$0] }
    let values = Array(repeating: 10.0, count: sparseDates.count)
    
    try await createSessions(activityId: activity.id, values: values, dates: sparseDates)
    
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: activity.id,
      dateRange: .multipleDays(start: allDates.first!, end: allDates.last!)
    ))
    
    XCTAssertEqual(total, Double(sparseDates.count) * 10.0)
  }
  
  func test_multipleDays_boundaryInclusive() async throws {
    let start = CalendarDate("2025-01-06")
    let end = CalendarDate("2025-01-08")
    
    try await createSessions(
      activityId: activity.id,
      values: [10.0, 20.0],
      dates: [start, end]
    )
    
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: activity.id,
      dateRange: .multipleDays(start: start, end: end)
    ))
    
    XCTAssertEqual(total, 30.0)
  }
  
  func test_multipleDays_excludesOutsideRange() async throws {
    let rangeStart = CalendarDate("2025-01-06")
    let rangeEnd = CalendarDate("2025-01-08")
    let beforeRange = CalendarDate("2025-01-05")
    let afterRange = CalendarDate("2025-01-09")
    
    try await createSessions(
      activityId: activity.id,
      values: [100.0, 15.0, 200.0],
      dates: [beforeRange, rangeStart, afterRange]
    )
    
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: activity.id,
      dateRange: .multipleDays(start: rangeStart, end: rangeEnd)
    ))
    
    XCTAssertEqual(total, 15.0)
  }
  
  func test_multipleDays_sameDayRange_behavesLikeSingleDay() async throws {
    let date = CalendarDate("2025-01-06")
    
    try await createSession(activityId: activity.id, value: 25.0, date: date)
    
    let dateRange = CalendarDateRange(start: date, end: date)
    
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: activity.id,
      dateRange: dateRange
    ))
    
    XCTAssertEqual(total, 25.0)
    
    // Verify it was converted to singleDay
    if case .singleDay(let singleDate) = dateRange {
      XCTAssertEqual(singleDate, date)
    } else {
      XCTFail("Expected dateRange to be .singleDay")
    }
  }
  
  // MARK: - Edge Cases
  
  func test_handlesDecimalsPrecisely() async throws {
    let date = CalendarDate("2025-01-06")
    
    try await createSessions(
      activityId: activity.id,
      values: [0.1, 0.2, 0.3],
      dates: [date, date, date]
    )
    
    let total = try await client.fetchSessionsTotalValue(.init(
      activityId: activity.id,
      dateRange: .singleDay(date)
    ))
    
    XCTAssertEqual(total, 0.6, accuracy: 0.0001)
  }
  
  func test_emptyDatabase_returnsZero() async throws {
    // Fresh activity with no sessions
    let freshActivity = try await createTestActivity(id: 99)
    
    let singleDayTotal = try await client.fetchSessionsTotalValue(.init(
      activityId: freshActivity.id,
      dateRange: .singleDay(CalendarDate("2025-01-01"))
    ))
    
    let multiDayTotal = try await client.fetchSessionsTotalValue(.init(
      activityId: freshActivity.id,
      dateRange: .multipleDays(
        start: CalendarDate("2025-01-01"),
        end: CalendarDate("2025-01-31")
      )
    ))
    
    XCTAssertEqual(singleDayTotal, 0.0)
    XCTAssertEqual(multiDayTotal, 0.0)
  }
}

// MARK: - Test Date Maker

enum TestDateMaker {
  /// Returns a fixed test date for consistent testing
  /// Default: January 1, 2025 at noon UTC
  static func testDate(
    year: Int = 2025,
    month: Int = 1,
    day: Int = 1,
    hour: Int = 12,
    minute: Int = 0,
    second: Int = 0
  ) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = second
    components.timeZone = TimeZone(secondsFromGMT: 0)
    
    let calendar = Calendar(identifier: .gregorian)
    return calendar.date(from: components)!
  }
  
  /// Convenience for creating a test date from a CalendarDate
  static func testDate(from calendarDate: CalendarDate) -> Date {
    let components = calendarDate.value.split(separator: "-").compactMap { Int($0) }
    return testDate(year: components[0], month: components[1], day: components[2])
  }
}
