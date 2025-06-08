import XCTest
@testable import ACT_ActivitiesStreakEvaluationClient
import ACT_SharedModels
import ACT_DatabaseClient
import ACT_GoalEvaluationClient
import ACT_DatabaseClientGRDB
import ElixirShared

// MARK: - Test Extensions

extension CalendarDate {
  static let testValue = CalendarDate("2025-01-15")

  // Helper to convert CalendarDate to Date for createDate
  func toDate() -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter.date(from: value)!
  }
}

final class ActivitiesStreakEvaluationClientTests: XCTestCase {

  lazy var client = ActivitiesStreakEvaluationClient(
    dateMaker: .liveValue,
    timeZone: .autoupdatingCurrent,
    databaseClient: try! .grdbValue(
      dateMaker: .liveValue,
      timeZone: .autoupdatingCurrent,
      configuration: .inMemory
    ),
    goalEvaluationClient: .liveValue()
  )
  typealias Client = ActivitiesStreakEvaluationClient

  // MARK: - Test Helpers

  private func makeAppStateModel(
    id: AppStateModel.ID = 1,
    createCalendarDate: CalendarDate = .testValue,
    latestEvaluatedDate: CalendarDate? = nil
  ) -> AppStateModel {
    AppStateModel(
      id: id,
      createDate: createCalendarDate.toDate(),
      createCalendarDate: createCalendarDate,
      latestCalendarDateWithAllActivityStreaksEvaluated: latestEvaluatedDate
    )
  }

  // MARK: - determineStartingCalendarDateToEvaluate Tests

  func test_determineStartingCalendarDateToEvaluate_whenNoLatestEvaluatedDate_returnsCreateDate() {
    // Given
    let appState = makeAppStateModel()

    // When
    let startDate = Client.determineStartingCalendarDateToEvaluate(appStateModel: appState)

    // Then
    XCTAssertEqual(startDate, .testValue)
  }

  func test_determineStartingCalendarDateToEvaluate_whenLatestEvaluatedDateExists_returnsDayAfter() {
    // Given
    let baseDate = CalendarDate.testValue
    let latestEvaluatedDate = baseDate.addingDays(10)
    let appState = makeAppStateModel(latestEvaluatedDate: latestEvaluatedDate)

    // When
    let startDate = Client.determineStartingCalendarDateToEvaluate(appStateModel: appState)

    // Then
    let expectedStartDate = latestEvaluatedDate.addingDays(1)
    XCTAssertEqual(startDate, expectedStartDate)
  }

  // MARK: - determineEndingCalendarDateToEvaluate Tests

  func test_determineEndingCalendarDateToEvaluate_returnsYesterday() {
    let today = CalendarDate.testValue

    let endDate = Client.determineEndingCalendarDateToEvaluate(today: today)

    let expectedYesterday = today.addingDays(-1)
    XCTAssertEqual(endDate, expectedYesterday)
  }

  

}
