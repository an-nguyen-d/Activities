import XCTest
@testable import ACT_GoalCreationClient
import ACT_SharedModels

final class GoalCreationClientTests: XCTestCase {

  let client = GoalCreationClient.liveValue()

  func test_calculateEffectiveCalendarDate_everyXDays_returnsCurrentDate() {
    let currentDate = CalendarDate("2024-06-05") // Wednesday

    let result = client.calculateEffectiveCalendarDate(.init(
      goalType: .everyXDays,
      currentCalendarDate: currentDate,
      startingDayOfWeek: .monday
    ))

    XCTAssertEqual(result, currentDate)
  }

  func test_calculateEffectiveCalendarDate_daysOfWeek_returnsCurrentDate() {
    let currentDate = CalendarDate("2024-06-05") // Wednesday

    let result = client.calculateEffectiveCalendarDate(.init(
      goalType: .daysOfWeek,
      currentCalendarDate: currentDate,
      startingDayOfWeek: .monday
    ))

    XCTAssertEqual(result, currentDate)
  }

  func test_calculateEffectiveCalendarDate_weeksPeriod_snapsToMonday() {
    // Test data: date -> expected Monday
    let testCases: [(String, String, String)] = [
      ("2024-06-03", "2024-06-03", "Monday returns itself"),
      ("2024-06-04", "2024-06-03", "Tuesday returns previous Monday"),
      ("2024-06-05", "2024-06-03", "Wednesday returns previous Monday"),
      ("2024-06-06", "2024-06-03", "Thursday returns previous Monday"),
      ("2024-06-07", "2024-06-03", "Friday returns previous Monday"),
      ("2024-06-08", "2024-06-03", "Saturday returns previous Monday"),
      ("2024-06-09", "2024-06-03", "Sunday returns previous Monday"),
    ]

    for (input, expected, description) in testCases {
      let result = client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: CalendarDate(input),
        startingDayOfWeek: .monday
      ))

      XCTAssertEqual(result, CalendarDate(expected), description)
    }
  }

  func test_calculateEffectiveCalendarDate_weeksPeriod_30DayMarch() {
    let startDate = CalendarDate("2024-06-01") // Saturday

    for dayOffset in 0..<30 {
      let currentDate = startDate.addingDays(dayOffset)
      let result = client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: currentDate,
        startingDayOfWeek: .monday
      ))

      // Verify it's always a Monday
      XCTAssertEqual(result.dayOfWeek(), .monday, "Result for \(currentDate.value) should be Monday")

      // Verify it's never in the future
      XCTAssertLessThanOrEqual(result, currentDate, "Result should not be in future for \(currentDate.value)")

      // Verify it's within the last 6 days
      let daysSince = currentDate.daysSince(result)
      XCTAssertLessThanOrEqual(daysSince, 6, "Should be within 6 days for \(currentDate.value)")
      XCTAssertGreaterThanOrEqual(daysSince, 0, "Should not be negative for \(currentDate.value)")
    }
  }

  func test_calculateEffectiveCalendarDate_weeksPeriod_yearBoundary() {
    // Dec 31, 2024 (Tuesday) should snap to Dec 30, 2024 (Monday)
    XCTAssertEqual(
      client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: CalendarDate("2024-12-31"),
        startingDayOfWeek: .monday
      )),
      CalendarDate("2024-12-30")
    )

    // Jan 1, 2025 (Wednesday) should snap to Dec 30, 2024 (Monday)
    XCTAssertEqual(
      client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: CalendarDate("2025-01-01"),
        startingDayOfWeek: .monday
      )),
      CalendarDate("2024-12-30")
    )
  }

  func test_calculateEffectiveCalendarDate_weeksPeriod_30DayMarch_improved() {
    let startDate = CalendarDate("2024-06-01") // Saturday

    for dayOffset in 0..<30 {
      let currentDate = startDate.addingDays(dayOffset)
      let result = client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: currentDate,
        startingDayOfWeek: .monday
      ))

      // Explicitly test it matches the expected computation
      let expected = currentDate.getCurrentOrPrevious(dayOfWeek: .monday)
      XCTAssertEqual(result, expected, "Failed for date: \(currentDate.value)")
    }
  }

  func test_calculateEffectiveCalendarDate_weeksPeriod_differentStartingDays() {
    let testDate = CalendarDate("2024-06-05") // Wednesday

    // Test with Sunday as starting day
    XCTAssertEqual(
      client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: testDate,
        startingDayOfWeek: .sunday
      )),
      CalendarDate("2024-06-02") // Previous Sunday
    )

    // Test with Thursday as starting day
    XCTAssertEqual(
      client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: testDate,
        startingDayOfWeek: .thursday
      )),
      CalendarDate("2024-05-30") // Previous Thursday
    )

    // Test when current day IS the starting day
    XCTAssertEqual(
      client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: testDate,
        startingDayOfWeek: .wednesday
      )),
      testDate // Should return itself
    )
  }

  func test_calculateEffectiveCalendarDate_weeksPeriod_leapYearBoundary() {
    // Feb 29, 2024 (Thursday) → Feb 26, 2024 (Monday)
    XCTAssertEqual(
      client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: CalendarDate("2024-02-29"),
        startingDayOfWeek: .monday
      )),
      CalendarDate("2024-02-26")
    )

    // March 1, 2024 (Friday) → Feb 26, 2024 (Monday) - crosses leap day
    XCTAssertEqual(
      client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: CalendarDate("2024-03-01"),
        startingDayOfWeek: .monday
      )),
      CalendarDate("2024-02-26")
    )

    // Test non-leap year for comparison: Feb 28, 2023 (Tuesday) → Feb 27, 2023 (Monday)
    XCTAssertEqual(
      client.calculateEffectiveCalendarDate(.init(
        goalType: .weeksPeriod,
        currentCalendarDate: CalendarDate("2023-02-28"),
        startingDayOfWeek: .monday
      )),
      CalendarDate("2023-02-27")
    )
  }
}
