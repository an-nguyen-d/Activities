import ACT_GoalEvaluationClient
import ACT_SharedModels
import XCTest

// MARK: - Test Extensions

extension CalendarDate {
  static let knownSunday = CalendarDate("2025-06-01")  // Sunday
  static let knownMonday = CalendarDate("2025-06-02")   // Monday
}

// MARK: - Test Helpers

extension ActivitySessionModel {
  static func testSession(
    value: Double,
    completeCalendarDate: CalendarDate = .today()
  ) -> Self {
    let now = Date()
    return Self(
      id: .init(1),
      value: value,
      createDate: now,  // Not relevant for tests
      completeDate: now,  // Not relevant for tests
      completeCalendarDate: completeCalendarDate
    )
  }
}

extension EveryXDaysActivityGoalModel {
  static func testGoal(
    effectiveCalendarDate: CalendarDate = CalendarDate.today().addingDays(-365), // 1 year ago
    daysInterval: Int = 1,
    goalValue: Double,
    goalSuccessCriteria: GoalSuccessCriteria = .atLeast
  ) -> Self {
    return Self(
      id: .init(1),
      createDate: Date(),
      effectiveCalendarDate: effectiveCalendarDate,
      daysInterval: daysInterval,
      goalID: .init(1),
      goalValue: goalValue,
      goalSuccessCriteria: goalSuccessCriteria
    )
  }
}

extension DaysOfWeekActivityGoalModel {
  static func pausedGoal(
    effectiveCalendarDate: CalendarDate = CalendarDate.today().addingDays(-365), // 1 year ago
    weeksInterval: Int = 1
  ) -> Self {
    return Self(
      id: .init(1),
      createDate: Date(),
      effectiveCalendarDate: effectiveCalendarDate,
      weeksInterval: weeksInterval,
      mondayGoal: nil,
      tuesdayGoal: nil,
      wednesdayGoal: nil,
      thursdayGoal: nil,
      fridayGoal: nil,
      saturdayGoal: nil,
      sundayGoal: nil
    )
  }
  
  static func singleDayGoal(
    day: DayOfWeek,
    config: ActivityGoalTargetModel,
    effectiveCalendarDate: CalendarDate = CalendarDate.today().addingDays(-365), // 1 year ago
    weeksInterval: Int = 1
  ) -> Self {
    return Self(
      id: .init(1),
      createDate: Date(),
      effectiveCalendarDate: effectiveCalendarDate,
      weeksInterval: weeksInterval,
      mondayGoal: day == .monday ? config : nil,
      tuesdayGoal: day == .tuesday ? config : nil,
      wednesdayGoal: day == .wednesday ? config : nil,
      thursdayGoal: day == .thursday ? config : nil,
      fridayGoal: day == .friday ? config : nil,
      saturdayGoal: day == .saturday ? config : nil,
      sundayGoal: day == .sunday ? config : nil
    )
  }
  
  static func customGoal(
    effectiveCalendarDate: CalendarDate = CalendarDate.today().addingDays(-365), // 1 year ago
    weeksInterval: Int = 1,
    mondayGoal: ActivityGoalTargetModel? = nil,
    tuesdayGoal: ActivityGoalTargetModel? = nil,
    wednesdayGoal: ActivityGoalTargetModel? = nil,
    thursdayGoal: ActivityGoalTargetModel? = nil,
    fridayGoal: ActivityGoalTargetModel? = nil,
    saturdayGoal: ActivityGoalTargetModel? = nil,
    sundayGoal: ActivityGoalTargetModel? = nil
  ) -> Self {
    return Self(
      id: .init(1),
      createDate: Date(),
      effectiveCalendarDate: effectiveCalendarDate,
      weeksInterval: weeksInterval,
      mondayGoal: mondayGoal,
      tuesdayGoal: tuesdayGoal,
      wednesdayGoal: wednesdayGoal,
      thursdayGoal: thursdayGoal,
      fridayGoal: fridayGoal,
      saturdayGoal: saturdayGoal,
      sundayGoal: sundayGoal
    )
  }
}

extension WeeksPeriodActivityGoalModel {
  static func testGoal(
    effectiveCalendarDate: CalendarDate = CalendarDate.today().addingDays(-365).next(.monday), // 1 year ago
    goalValue: Double,
    goalSuccessCriteria: GoalSuccessCriteria = .atLeast
  ) -> Self {
    return Self(
      id: .init(1),
      createDate: Date(),
      effectiveCalendarDate: effectiveCalendarDate,
      goalID: .init(1),
      goalValue: goalValue,
      goalSuccessCriteria: goalSuccessCriteria
    )
  }
}

// MARK: - Tests

class GoalEvaluationClientTests: XCTestCase {
  
  let client = GoalEvaluationClient.liveValue()
  
  // MARK: - Paused Goal Tests (using DaysOfWeekActivityGoal with all nils)
  
  func test_givenDaysOfWeekActivityGoalWithAllNils_thenAlwaysReturnsSkip() {
    // Given - effectively a "paused" goal
    // Set effective date well before any test date (e.g., 30 days ago)
    let effectiveDate = CalendarDate.today().addingDays(-30)
    let pausedGoal = DaysOfWeekActivityGoalModel.pausedGoal(effectiveCalendarDate: effectiveDate)

    let startDate = CalendarDate.today()

    // Test 8 days to ensure we cover all weekdays and wrap around
    for dayOffset in 0..<(DayOfWeek.daysPerWeek + 1) {
      let evaluationDate = startDate.addingDays(dayOffset)
      let currentDate = startDate.addingDays(dayOffset)
      
      // When
      let request = GoalEvaluationClient.EvaluateStatus.Request(
        goal: pausedGoal,
        sessionsInGoalPeriodValueTotal: 0,  // No sessions
        evaluationDate: evaluationDate,
        currentDate: currentDate
      )
      
      // Then - should always be skip regardless of weekday
      XCTAssertEqual(
        client.evaluateStatus(request),
        .skip,
        "Day \(dayOffset) should skip but didn't"
      )
    }
    
    // Also test evaluating past dates from today's perspective
    let today = CalendarDate.today()
    for dayOffset in -DayOfWeek.daysPerWeek..<0 {
      let evaluationDate = today.addingDays(dayOffset)
      
      // When
      let request = GoalEvaluationClient.EvaluateStatus.Request(
        goal: pausedGoal,
        sessionsInGoalPeriodValueTotal: 0,
        evaluationDate: evaluationDate,
        currentDate: today
      )
      
      // Then - should still be skip for past dates
      XCTAssertEqual(
        client.evaluateStatus(request),
        .skip,
        "Past day \(dayOffset) should skip but didn't"
      )
    }
  }
  
  // MARK: - EveryXDaysActivityGoalModel Basic Evaluation Tests
  
  func test_givenEveryXDaysActivityGoalModel_whenNoSessionsToday_thenIncomplete() {
    // Given
    let dailyGoal = EveryXDaysActivityGoalModel.testGoal(goalValue: 1)
    let today = CalendarDate.today()
    
    // When
    let request = GoalEvaluationClient.EvaluateStatus.Request(
      goal: dailyGoal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: today,
      currentDate: today
    )
    
    // Then
    XCTAssertEqual(client.evaluateStatus(request), .incomplete)
  }
  
  func test_givenEveryXDaysActivityGoalModel_whenNoSessionsInPast_thenFailure() {
    // Given
    let dailyGoal = EveryXDaysActivityGoalModel.testGoal(goalValue: 1)
    let today = CalendarDate.today()
    let yesterday = today.addingDays(-1)
    
    // When
    let request = GoalEvaluationClient.EvaluateStatus.Request(
      goal: dailyGoal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: yesterday,
      currentDate: today
    )
    
    // Then
    XCTAssertEqual(client.evaluateStatus(request), .failure)
  }
  
  func test_givenEveryXDaysActivityGoalModel_whenAddingSessions_thenTransitionsToSuccess() {
    // Given
    let goalValue: Double = 10
    let goal = EveryXDaysActivityGoalModel.testGoal(goalValue: goalValue)
    let today = CalendarDate.today()
    
    // Assert incomplete with no sessions
    let request1 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request1), .incomplete)
    
    // Add enough to meet goal, assert success
    let request2 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: goalValue,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request2), .success)
    
    // Add more, assert still success
    let request3 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: goalValue * 2,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request3), .success)
  }
  
  // MARK: - EveryXDaysActivityGoalModel Interval Tests
  
  func test_givenEveryXDaysActivityGoalModel_whenInterval2_thenCorrectStatesAcrossDays() {
    // Given - goal every 2 days
    let day1 = CalendarDate.today()
    let day2 = day1.addingDays(1)
    let day3 = day1.addingDays(2)
    let day4 = day1.addingDays(3)
    
    let goal = EveryXDaysActivityGoalModel(
      id: .init(1),
      createDate: Date(),
      effectiveCalendarDate: day1,
      daysInterval: 2,
      goalID: .init(1),
      goalValue: 10,
      goalSuccessCriteria: .atLeast
    )
    
    // Day 1 - scheduled day (interval day 0), starts incomplete
    let request1 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: day1,
      currentDate: day1
    )
    XCTAssertEqual(client.evaluateStatus(request1), .incomplete)
    
    // Day 1 - add sessions, becomes success
    let request2 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 15,
      evaluationDate: day1,
      currentDate: day1
    )
    XCTAssertEqual(client.evaluateStatus(request2), .success)
    
    // Day 2 - not scheduled (interval day 1), should skip
    let request3 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: day2,
      currentDate: day2
    )
    XCTAssertEqual(client.evaluateStatus(request3), .skip)
    
    // Day 3 - scheduled day (interval day 2), incomplete with no sessions
    let request4 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: day3,
      currentDate: day3
    )
    XCTAssertEqual(client.evaluateStatus(request4), .incomplete)
    
    // Day 4 - evaluating Day 3 from Day 4 (past incomplete = failure)
    let request5 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: day3,
      currentDate: day4
    )
    XCTAssertEqual(client.evaluateStatus(request5), .failure)
  }
  
  // MARK: - Goal Success Criteria Tests
  
  func test_givenEveryXDaysActivityGoalModel_whenExactlyCriteria_thenOnlyExactValueSucceeds() {
    // Given - goal requiring exactly 30 minutes
    let goalValue: Double = 30
    let goal = EveryXDaysActivityGoalModel.testGoal(
      goalValue: goalValue,
      goalSuccessCriteria: .exactly
    )
    let today = CalendarDate.today()
    
    // With no sessions - incomplete
    let request1 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request1), .incomplete)
    
    // Add less than goal - still incomplete
    let request2 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 20,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request2), .incomplete)
    
    // Add to reach exact goal - success!
    let request3 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 30,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request3), .success)
    
    // Add more - failure, went over!
    let request4 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 40,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request4), .failure)
  }
  
  func test_givenEveryXDaysActivityGoalModel_whenLessThanCriteriaToday_thenIncompleteUntilOver() {
    // Given - goal to watch less than 20 minutes TV
    let goalValue: Double = 20
    let goal = EveryXDaysActivityGoalModel.testGoal(
      goalValue: goalValue,
      goalSuccessCriteria: .lessThan
    )
    let today = CalendarDate.today()
    
    // With no sessions - incomplete (not success yet!)
    let request1 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request1), .incomplete)
    
    // Watch less than limit - still incomplete (could still go over)
    let request2 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 10,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request2), .incomplete)
    
    // Reach the limit - failure!
    let request3 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 20,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request3), .failure)
    
    // Go over - still failure
    let request4 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 30,
      evaluationDate: today,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request4), .failure)
  }
  
  func test_givenEveryXDaysActivityGoalModel_whenLessThanCriteriaPastDate_thenSuccessOrFailure() {
    // Given - goal to watch less than 20 minutes TV
    let goalValue: Double = 20
    let yesterday = CalendarDate.today().addingDays(-1)
    let today = CalendarDate.today()

    // Create goal with effective date before yesterday
    let goal = EveryXDaysActivityGoalModel.testGoal(
      effectiveCalendarDate: yesterday.addingDays(-7), // A week before yesterday
      goalValue: goalValue,
      goalSuccessCriteria: .lessThan
    )

    // 0 minutes yesterday - success! (proved restraint)
    let request1 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: yesterday,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request1), .success)
    
    // Less than limit yesterday - success!
    let request2 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 10,
      evaluationDate: yesterday,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request2), .success)
    
    // At limit yesterday - failure
    let request3 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: goalValue,
      evaluationDate: yesterday,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request3), .failure)
    
    // Over limit yesterday - failure
    let request4 = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 30,
      evaluationDate: yesterday,
      currentDate: today
    )
    XCTAssertEqual(client.evaluateStatus(request4), .failure)
  }
  
  // MARK: - DaysOfWeekActivityGoal Tests
  
  func test_givenDaysOfWeekActivityGoal_whenOnlyOneDayConfigured_thenEvaluatesOnlyThatDay() {
    let goalConfig = ActivityGoalTargetModel(id: 1, goalValue: 10, goalSuccessCriteria: .atLeast)!

    // Create all 7 single-day goals
    let singleDayGoals = (0..<DayOfWeek.daysPerWeek).map { targetDay in
      DaysOfWeekActivityGoalModel(
        id: .init(1),
        createDate: Date(),
        effectiveCalendarDate: .knownSunday,
        weeksInterval: 1,
        mondayGoal: targetDay == 1 ? goalConfig : nil,
        tuesdayGoal: targetDay == 2 ? goalConfig : nil,
        wednesdayGoal: targetDay == 3 ? goalConfig : nil,
        thursdayGoal: targetDay == 4 ? goalConfig : nil,
        fridayGoal: targetDay == 5 ? goalConfig : nil,
        saturdayGoal: targetDay == 6 ? goalConfig : nil,
        sundayGoal: targetDay == 0 ? goalConfig : nil
      )
    }
    
    // Walk through 8 days once, testing all goals on each day
    for dayOffset in 0..<(DayOfWeek.daysPerWeek + 1) {
      let evaluationDate = CalendarDate.knownSunday.addingDays(dayOffset)
      let currentDayIndex = dayOffset % DayOfWeek.daysPerWeek
      let currentDayName = DayOfWeek.allCases[currentDayIndex].name
      
      // Test each single-day goal on this day
      for (goalDayIndex, goal) in singleDayGoals.enumerated() {
        let goalDayName = DayOfWeek.allCases[goalDayIndex].name
        
        // Test with no sessions
        let request = GoalEvaluationClient.EvaluateStatus.Request(
          goal: goal,
          sessionsInGoalPeriodValueTotal: 0,
          evaluationDate: evaluationDate,
          currentDate: evaluationDate
        )
        let status = client.evaluateStatus(request)
        
        if currentDayIndex == goalDayIndex {
          // This is the goal's configured day
          XCTAssertEqual(
            status,
            .incomplete,
            "Day \(dayOffset): \(goalDayName)-only goal should evaluate as incomplete on \(currentDayName)"
          )
          
          // Also verify success with sessions
          let requestWithSessions = GoalEvaluationClient.EvaluateStatus.Request(
            goal: goal,
            sessionsInGoalPeriodValueTotal: 10,
            evaluationDate: evaluationDate,
            currentDate: evaluationDate
          )
          XCTAssertEqual(
            client.evaluateStatus(requestWithSessions),
            .success,
            "Day \(dayOffset): \(goalDayName)-only goal should succeed on \(currentDayName) with sessions"
          )
        } else {
          // Not the goal's day - should skip
          XCTAssertEqual(
            status,
            .skip,
            "Day \(dayOffset): \(goalDayName)-only goal should skip on \(currentDayName)"
          )
        }
      }
    }
  }
  
  func test_givenDaysOfWeekActivityGoal_whenVariousConfigurations_thenEvaluatesCorrectly() {
    // Define all possible configurations we want to test
    struct TestCase {
      let name: String
      let config: ActivityGoalTargetModel?
      let totalValue: Double
      let expectedToday: GoalStatus
      let expectedYesterday: GoalStatus
    }
    
    let testCases = [
      // No goal
      TestCase(
        name: "no goal",
        config: nil,
        totalValue: 0,
        expectedToday: .skip,
        expectedYesterday: .skip
      ),
      
      // atLeast tests
      TestCase(
        name: "atLeast 10 - under (5)",
        config: ActivityGoalTargetModel(id: 1, goalValue: 10, goalSuccessCriteria: .atLeast)!,
        totalValue: 5,
        expectedToday: .incomplete,
        expectedYesterday: .failure
      ),
      TestCase(
        name: "atLeast 10 - exact (10)",
        config: ActivityGoalTargetModel(id: 2, goalValue: 10, goalSuccessCriteria: .atLeast)!,
        totalValue: 10,
        expectedToday: .success,
        expectedYesterday: .success
      ),
      TestCase(
        name: "atLeast 10 - over (15)",
        config: ActivityGoalTargetModel(id: 3, goalValue: 10, goalSuccessCriteria: .atLeast)!,
        totalValue: 15,
        expectedToday: .success,
        expectedYesterday: .success
      ),
      
      // exactly tests
      TestCase(
        name: "exactly 10 - under (5)",
        config: ActivityGoalTargetModel(id: 4, goalValue: 10, goalSuccessCriteria: .exactly)!,
        totalValue: 5,
        expectedToday: .incomplete,
        expectedYesterday: .failure
      ),
      TestCase(
        name: "exactly 10 - exact (10)",
        config: ActivityGoalTargetModel(id: 5, goalValue: 10, goalSuccessCriteria: .exactly)!,
        totalValue: 10,
        expectedToday: .success,
        expectedYesterday: .success
      ),
      TestCase(
        name: "exactly 10 - over (15)",
        config: ActivityGoalTargetModel(id: 6, goalValue: 10, goalSuccessCriteria: .exactly)!,
        totalValue: 15,
        expectedToday: .failure,
        expectedYesterday: .failure
      ),
      
      // lessThan tests
      TestCase(
        name: "lessThan 10 - under (5)",
        config: ActivityGoalTargetModel(id: 7, goalValue: 10, goalSuccessCriteria: .lessThan)!,
        totalValue: 5,
        expectedToday: .incomplete,
        expectedYesterday: .success
      ),
      TestCase(
        name: "lessThan 10 - exact (10)",
        config: ActivityGoalTargetModel(id: 8, goalValue: 10, goalSuccessCriteria: .lessThan)!,
        totalValue: 10,
        expectedToday: .failure,
        expectedYesterday: .failure
      ),
      TestCase(
        name: "lessThan 10 - over (15)",
        config: ActivityGoalTargetModel(id: 9, goalValue: 10, goalSuccessCriteria: .lessThan)!,
        totalValue: 15,
        expectedToday: .failure,
        expectedYesterday: .failure
      )
    ]
    
    // Test each configuration on each day of the week
    for day in DayOfWeek.allCases {
      let evaluationDate = CalendarDate.knownSunday.addingDays(day.index)
      
      // Set a base effective date that's before all our test dates
      // This ensures the precondition (goal.effectiveCalendarDate <= currentDate) passes
      let goalEffectiveDate = CalendarDate.knownSunday.addingDays(-7) // One week before our test dates
      
      for testCase in testCases {
        // Create goal with explicit effective date
        let goal: DaysOfWeekActivityGoalModel
        if let config = testCase.config {
          goal = DaysOfWeekActivityGoalModel.singleDayGoal(
            day: day,
            config: config,
            effectiveCalendarDate: goalEffectiveDate
          )
        } else {
          goal = DaysOfWeekActivityGoalModel.pausedGoal(effectiveCalendarDate: goalEffectiveDate)
        }
        
        // Test evaluating "today"
        let todayRequest = GoalEvaluationClient.EvaluateStatus.Request(
          goal: goal,
          sessionsInGoalPeriodValueTotal: testCase.totalValue,
          evaluationDate: evaluationDate,
          currentDate: evaluationDate
        )
        XCTAssertEqual(
          client.evaluateStatus(todayRequest),
          testCase.expectedToday,
          "\(day.name) - \(testCase.name) - evaluating today"
        )
        
        // Test evaluating "yesterday" (from tomorrow's perspective)
        let tomorrow = evaluationDate.addingDays(1)
        let yesterdayRequest = GoalEvaluationClient.EvaluateStatus.Request(
          goal: goal,
          sessionsInGoalPeriodValueTotal: testCase.totalValue,
          evaluationDate: evaluationDate,
          currentDate: tomorrow
        )
        XCTAssertEqual(
          client.evaluateStatus(yesterdayRequest),
          testCase.expectedYesterday,
          "\(day.name) - \(testCase.name) - evaluating from tomorrow"
        )
      }
    }
  }
  
  // MARK: - DaysOfWeekActivityGoal weeksInterval Tests
  
  func test_givenDaysOfWeekActivityGoal_whenWeeksInterval2_thenEvaluatesEveryOtherWeek() {
    // Given - Sunday-only goal that repeats every 2 weeks
    let goalConfig = ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast)!

    let goal = DaysOfWeekActivityGoalModel.singleDayGoal(
      day: .sunday,
      config: goalConfig,
      effectiveCalendarDate: .knownMonday.addingWeeks(-1),
      weeksInterval: 2
    )
    
    // Walk through 4 weeks to see the pattern repeat
    for dayOffset in 0..<(4 * DayOfWeek.daysPerWeek) {
      let evaluationDate = CalendarDate.knownSunday.addingDays(dayOffset)
      let weekNumber = dayOffset / DayOfWeek.daysPerWeek
      let isActiveWeek = (weekNumber % 2) == 0
      let isSunday = (dayOffset % DayOfWeek.daysPerWeek) == 0
      
      // When
      let request = GoalEvaluationClient.EvaluateStatus.Request(
        goal: goal,
        sessionsInGoalPeriodValueTotal: 0,
        evaluationDate: evaluationDate,
        currentDate: evaluationDate
      )
      let status = client.evaluateStatus(request)
      
      // Then
      if isActiveWeek && isSunday {
        XCTAssertEqual(
          status,
          .incomplete,
          "Week \(weekNumber) day \(dayOffset) should evaluate (Sunday of active week)"
        )
        
        // Also verify it can succeed with sessions
        let requestWithSessions = GoalEvaluationClient.EvaluateStatus.Request(
          goal: goal,
          sessionsInGoalPeriodValueTotal: 30,
          evaluationDate: evaluationDate,
          currentDate: evaluationDate
        )
        XCTAssertEqual(
          client.evaluateStatus(requestWithSessions),
          .success,
          "Week \(weekNumber) day \(dayOffset) should succeed with sessions"
        )
      } else {
        XCTAssertEqual(
          status,
          .skip,
          "Week \(weekNumber) day \(dayOffset) should skip"
        )
      }
    }
  }
  
  // MARK: - WeeksPeriodActivityGoalModel Tests
  
  func test_givenWeeksPeriodActivityGoalModel_whenMidWeekWithNoSessions_thenIncomplete() {
    // Given - weekly goal of 100 minutes
    let goal = WeeksPeriodActivityGoalModel.testGoal(goalValue: 100)
    
    // When - evaluating mid-week with no sessions
    let wednesday = CalendarDate.knownMonday.addingDays(2)
    let request = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: 0,
      evaluationDate: wednesday,
      currentDate: wednesday
    )
    
    // Then - should be incomplete (NOT failure like daily goals would be)
    XCTAssertEqual(
      client.evaluateStatus(request),
      .incomplete,
      "Mid-week with no sessions should be incomplete, not failure"
    )
  }
  
  func test_givenWeeksPeriodActivityGoalModel_whenPeriodEnds_thenEvaluatesSuccessOrFailure() {
    // Given - weekly goal of 100 minutes
    let goalValue: Double = 100
    let goal = WeeksPeriodActivityGoalModel.testGoal(goalValue: goalValue)
    
    let sunday = CalendarDate.knownMonday.next(.sunday)
    let nextMonday = CalendarDate.knownMonday.next(.monday)
    
    // When evaluating Sunday from next Monday with insufficient sessions
    let failureRequest = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: goalValue / 2,  // Only half the goal
      evaluationDate: sunday,
      currentDate: nextMonday
    )
    XCTAssertEqual(
      client.evaluateStatus(failureRequest),
      .failure,
      "Should fail when week ends with insufficient activity"
    )
    
    // When evaluating Sunday from next Monday with sufficient sessions
    let successRequest = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: goalValue,  // Exactly the goal
      evaluationDate: sunday,
      currentDate: nextMonday
    )
    XCTAssertEqual(
      client.evaluateStatus(successRequest),
      .success,
      "Should succeed when week ends with sufficient activity"
    )
  }
  
  func test_givenWeeksPeriodActivityGoalModel_whenVariousCriteria_thenStateTransitionsCorrectly() {
    // Given - three goals with different criteria, all targeting the same value
    let goalValue: Double = 100
    
    let atLeastGoal = WeeksPeriodActivityGoalModel.testGoal(
      goalValue: goalValue,
      goalSuccessCriteria: .atLeast
    )
    let exactlyGoal = WeeksPeriodActivityGoalModel.testGoal(
      goalValue: goalValue,
      goalSuccessCriteria: .exactly
    )
    let lessThanGoal = WeeksPeriodActivityGoalModel.testGoal(
      goalValue: goalValue,
      goalSuccessCriteria: .lessThan
    )
    
    let monday = CalendarDate.knownMonday
    let wednesday = monday.next(.wednesday)
    let friday = monday.next(.friday)
    
    // Test 1: Start of week with no sessions - all should be incomplete
    for (goal, criteriaName) in [(atLeastGoal, "atLeast"), (exactlyGoal, "exactly"), (lessThanGoal, "lessThan")] {
      let request = GoalEvaluationClient.EvaluateStatus.Request(
        goal: goal,
        sessionsInGoalPeriodValueTotal: 0,
        evaluationDate: monday,
        currentDate: monday
      )
      XCTAssertEqual(
        client.evaluateStatus(request),
        .incomplete,
        "\(criteriaName) should start incomplete with no sessions"
      )
    }
    
    // Test 2: Mid-week after reaching exactly the goal
    let totalAtGoal = goalValue
    
    // atLeast: should be success
    XCTAssertEqual(
      client.evaluateStatus(GoalEvaluationClient.EvaluateStatus.Request(
        goal: atLeastGoal,
        sessionsInGoalPeriodValueTotal: totalAtGoal,
        evaluationDate: wednesday,
        currentDate: wednesday
      )),
      .success,
      "atLeast should be success when meeting goal"
    )
    
    // exactly: should be success
    XCTAssertEqual(
      client.evaluateStatus(GoalEvaluationClient.EvaluateStatus.Request(
        goal: exactlyGoal,
        sessionsInGoalPeriodValueTotal: totalAtGoal,
        evaluationDate: wednesday,
        currentDate: wednesday
      )),
      .success,
      "exactly should be success when meeting goal exactly"
    )
    
    // lessThan: should be failure (hit the limit)
    XCTAssertEqual(
      client.evaluateStatus(GoalEvaluationClient.EvaluateStatus.Request(
        goal: lessThanGoal,
        sessionsInGoalPeriodValueTotal: totalAtGoal,
        evaluationDate: wednesday,
        currentDate: wednesday
      )),
      .failure,
      "lessThan should be failure when reaching the limit"
    )
    
    // Test 3: Later in week after exceeding the goal
    let totalOverGoal = goalValue + 20  // 20% over goal
    
    // atLeast: should remain success
    XCTAssertEqual(
      client.evaluateStatus(GoalEvaluationClient.EvaluateStatus.Request(
        goal: atLeastGoal,
        sessionsInGoalPeriodValueTotal: totalOverGoal,
        evaluationDate: friday,
        currentDate: friday
      )),
      .success,
      "atLeast should remain success when exceeding goal"
    )
    
    // exactly: should now be failure
    XCTAssertEqual(
      client.evaluateStatus(GoalEvaluationClient.EvaluateStatus.Request(
        goal: exactlyGoal,
        sessionsInGoalPeriodValueTotal: totalOverGoal,
        evaluationDate: friday,
        currentDate: friday
      )),
      .failure,
      "exactly should be failure when exceeding goal"
    )
    
    // lessThan: should remain failure
    XCTAssertEqual(
      client.evaluateStatus(GoalEvaluationClient.EvaluateStatus.Request(
        goal: lessThanGoal,
        sessionsInGoalPeriodValueTotal: totalOverGoal,
        evaluationDate: friday,
        currentDate: friday
      )),
      .failure,
      "lessThan should remain failure when over limit"
    )
  }
  
  func test_givenWeeksPeriodActivityGoalModel_whenSessionsAcrossMultipleDays_thenAccumulatesCorrectly() {
    // Given - weekly goal of 100 minutes
    let goalValue: Double = 100
    let goal = WeeksPeriodActivityGoalModel.testGoal(goalValue: goalValue)
    
    // Total across the week equals exactly goalValue
    let totalValue = goalValue
    
    let friday = CalendarDate.knownMonday.next(.friday)
    
    // When evaluating on Friday with accumulated sessions
    let request = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: totalValue,
      evaluationDate: friday,
      currentDate: friday
    )
    
    // Then should show success (accumulated to goal)
    XCTAssertEqual(
      client.evaluateStatus(request),
      .success,
      "Should accumulate sessions across multiple days to reach goal"
    )
  }
  
  // MARK: - Session Calendar Date Filtering Tests
  
  func test_givenEveryXDaysActivityGoalModel_whenSessionsFromDifferentDays_thenOnlyCountsEvaluationDateSessions() {
    // Given - daily goal of 10 minutes
    let goalValue: Double = 10
    let goal = EveryXDaysActivityGoalModel.testGoal(goalValue: goalValue)
    
    let today = CalendarDate.today()
    let yesterday = today.addingDays(-1)
    let tomorrow = today.addingDays(1)
    
    // Sessions from different days
    let yesterdaySession = ActivitySessionModel.testSession(value: 5, completeCalendarDate: yesterday)
    let todaySession = ActivitySessionModel.testSession(value: 5, completeCalendarDate: today)
    let tomorrowSession = ActivitySessionModel.testSession(value: 5, completeCalendarDate: tomorrow)
    
    // When evaluating today - caller should only sum today's sessions
    let correctlyFilteredTotal = todaySession.value  // Just 5
    let incorrectlyFilteredTotal = yesterdaySession.value + todaySession.value + tomorrowSession.value  // 15
    
    // This is what the caller SHOULD do
    let correctRequest = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: correctlyFilteredTotal,
      evaluationDate: today,
      currentDate: today
    )
    
    // Then - with correct filtering, should be incomplete (5 < 10)
    XCTAssertEqual(
      client.evaluateStatus(correctRequest),
      .incomplete,
      "With correct filtering, should only count today's 5 minutes"
    )
    
    // This demonstrates what happens if caller doesn't filter
    let incorrectRequest = GoalEvaluationClient.EvaluateStatus.Request(
      goal: goal,
      sessionsInGoalPeriodValueTotal: incorrectlyFilteredTotal,
      evaluationDate: today,
      currentDate: today
    )
    
    // With incorrect filtering, would show success (15 > 10)
    XCTAssertEqual(
      client.evaluateStatus(incorrectRequest),
      .success,
      "Without filtering, would incorrectly count all sessions"
    )
  }
  
}


extension EveryXDaysActivityGoalModel {

  init(
    id: ActivityGoal.ID,
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    daysInterval: Int,
    goalID: ActivityGoalTargetModel.ID,
    goalValue: Double,
    goalSuccessCriteria: GoalSuccessCriteria
  ) {
    self.init(
      id: id,
      createDate: createDate,
      effectiveCalendarDate: effectiveCalendarDate,
      daysInterval: daysInterval,
      target: ActivityGoalTargetModel(
        id: goalID,
        goalValue: goalValue,
        goalSuccessCriteria: goalSuccessCriteria
      )!
    )
  }

}

extension WeeksPeriodActivityGoalModel {

  public init(
    id: ActivityGoal.ID,
    createDate: Date,
    effectiveCalendarDate: CalendarDate,
    goalID: ActivityGoalTargetModel.ID,
    goalValue: Double,
    goalSuccessCriteria: GoalSuccessCriteria
  ) {
    assert(effectiveCalendarDate.dayOfWeek() == Global.startingDayOfWeek)

    self.init(
      id: id,
      createDate: createDate,
      effectiveCalendarDate: effectiveCalendarDate,
      target: ActivityGoalTargetModel(
        id: goalID,
        goalValue: goalValue,
        goalSuccessCriteria: goalSuccessCriteria
      )!
    )
  }

}
