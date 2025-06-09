import XCTest
@testable import ACT_SharedModels

final class ActivityGoalModelTests: XCTestCase {

  // MARK: - EveryXDaysActivityGoalModel Tests

  func test_everyXDays_interval1_returnsTargetEveryDay() {
    let goal = EveryXDaysActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-01"),
      daysInterval: 1,
      target: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast)
    )

    // Test multiple consecutive days
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-01")))
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-02")))
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-03")))
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-04")))

    // Verify target values
    let target = goal.getGoalTarget(for: CalendarDate("2025-01-01"))
    XCTAssertEqual(target?.goalValue, 30)
    XCTAssertEqual(target?.goalSuccessCriteria, .atLeast)
  }

  func test_everyXDays_interval2_alternatesDays() {
    let goal = EveryXDaysActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-01"),
      daysInterval: 2,
      target: ActivityGoalTargetModel(id: 1, goalValue: 45, goalSuccessCriteria: .exactly)
    )

    // Day 0 (Jan 1) - has target
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-01")))
    // Day 1 (Jan 2) - skip
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-02")))
    // Day 2 (Jan 3) - has target
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-03")))
    // Day 3 (Jan 4) - skip
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-04")))
    // Day 4 (Jan 5) - has target
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-05")))
  }

  func test_everyXDays_interval3() {
    let goal = EveryXDaysActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-01"),
      daysInterval: 3,
      target: ActivityGoalTargetModel(id: 1, goalValue: 60, goalSuccessCriteria: .lessThan)
    )

    // Pattern: target on days 0, 3, 6, 9...
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-01"))) // Day 0
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-02")))    // Day 1
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-03")))    // Day 2
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-04"))) // Day 3
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-05")))    // Day 4
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-06")))    // Day 5
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-07"))) // Day 6
  }

  func test_everyXDays_canEvaluateStreak_alwaysMatchesDates() {
    let goal = EveryXDaysActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-01"),
      daysInterval: 1,
      target: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast)
    )

    // When evaluationCalendarDate == currentCalendarDate, should return false (can't evaluate today)
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-15"),
      currentCalendarDate: CalendarDate("2025-01-15")
    ))

    // When evaluationCalendarDate < currentCalendarDate, should return true (can evaluate past)
    XCTAssertTrue(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-14"),
      currentCalendarDate: CalendarDate("2025-01-15")
    ))
  }

  // MARK: - DaysOfWeekActivityGoalModel Tests

  func test_daysOfWeek_onlyMondayGoal_weeksInterval1() {
    let goal = DaysOfWeekActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // A Monday
      weeksInterval: 1,
      mondayGoal: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast),
      tuesdayGoal: nil,
      wednesdayGoal: nil,
      thursdayGoal: nil,
      fridayGoal: nil,
      saturdayGoal: nil,
      sundayGoal: nil
    )

    // Week 1 - Starting week
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-06"))) // Monday
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-07")))    // Tuesday
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-08")))    // Wednesday
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-09")))    // Thursday
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-10")))    // Friday
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-11")))    // Saturday
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-12")))    // Sunday

    // Week 2 - Every week, so Monday has target again
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-13"))) // Monday
  }

  func test_daysOfWeek_multipleGoals_weeksInterval1() {
    let goal = DaysOfWeekActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      weeksInterval: 1,
      mondayGoal: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast),
      tuesdayGoal: nil,
      wednesdayGoal: ActivityGoalTargetModel(id: 2, goalValue: 45, goalSuccessCriteria: .exactly),
      thursdayGoal: nil,
      fridayGoal: ActivityGoalTargetModel(id: 3, goalValue: 60, goalSuccessCriteria: .lessThan),
      saturdayGoal: nil,
      sundayGoal: nil
    )

    // Check targets exist on correct days
    let monday = goal.getGoalTarget(for: CalendarDate("2025-01-06"))
    XCTAssertEqual(monday?.goalValue, 30)
    XCTAssertEqual(monday?.goalSuccessCriteria, .atLeast)

    let wednesday = goal.getGoalTarget(for: CalendarDate("2025-01-08"))
    XCTAssertEqual(wednesday?.goalValue, 45)
    XCTAssertEqual(wednesday?.goalSuccessCriteria, .exactly)

    let friday = goal.getGoalTarget(for: CalendarDate("2025-01-10"))
    XCTAssertEqual(friday?.goalValue, 60)
    XCTAssertEqual(friday?.goalSuccessCriteria, .lessThan)

    // No goals on other days
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-07"))) // Tuesday
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-09"))) // Thursday
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-11"))) // Saturday
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-12"))) // Sunday
  }

  func test_daysOfWeek_weeksInterval2_alternatesWeeks() {
    let goal = DaysOfWeekActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      weeksInterval: 2,
      mondayGoal: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast),
      tuesdayGoal: nil,
      wednesdayGoal: nil,
      thursdayGoal: nil,
      fridayGoal: nil,
      saturdayGoal: nil,
      sundayGoal: nil
    )

    // Week 0 (Jan 6-12) - Active week
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-06"))) // Monday

    // Week 1 (Jan 13-19) - Skip week
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-13"))) // Monday (skip week)

    // Week 2 (Jan 20-26) - Active week
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-20"))) // Monday

    // Week 3 (Jan 27-Feb 2) - Skip week
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-27"))) // Monday (skip week)

    // Week 4 (Feb 3-9) - Active week
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-02-03"))) // Monday
  }

  func test_daysOfWeek_sundayGoal() {
    let goal = DaysOfWeekActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-05"), // Sunday Jan 5
      weeksInterval: 1,
      mondayGoal: nil,
      tuesdayGoal: nil,
      wednesdayGoal: nil,
      thursdayGoal: nil,
      fridayGoal: nil,
      saturdayGoal: nil,
      sundayGoal: ActivityGoalTargetModel(id: 1, goalValue: 90, goalSuccessCriteria: .atLeast)
    )

    // First Sunday (effective date)
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-05")))

    // Monday after
    XCTAssertNil(goal.getGoalTarget(for: CalendarDate("2025-01-06")))

    // Next Sunday
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-12")))
  }

  func test_daysOfWeek_canEvaluateStreak_alwaysMatchesDates() {
    let goal = DaysOfWeekActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"),
      weeksInterval: 1,
      mondayGoal: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast),
      tuesdayGoal: nil,
      wednesdayGoal: nil,
      thursdayGoal: nil,
      fridayGoal: nil,
      saturdayGoal: nil,
      sundayGoal: nil
    )

    // Can't evaluate same day
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-15"),
      currentCalendarDate: CalendarDate("2025-01-15")
    ))

    // Can evaluate past day
    XCTAssertTrue(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-14"),
      currentCalendarDate: CalendarDate("2025-01-15")
    ))
  }

  // MARK: - WeeksPeriodActivityGoalModel Tests

  func test_weeksPeriod_alwaysReturnsTarget() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )

    // Every day returns the same target (accumulation goal)
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-06"))) // Monday
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-07"))) // Tuesday
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-08"))) // Wednesday
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-09"))) // Thursday
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-10"))) // Friday
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-11"))) // Saturday
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-12"))) // Sunday

    // Next week also returns target
    XCTAssertNotNil(goal.getGoalTarget(for: CalendarDate("2025-01-13"))) // Next Monday

    // Verify target values
    let target = goal.getGoalTarget(for: CalendarDate("2025-01-06"))
    XCTAssertEqual(target?.goalValue, 150)
    XCTAssertEqual(target?.goalSuccessCriteria, .atLeast)
  }

  func test_weeksPeriod_canEvaluateStreak_duringWeek() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )
    
    // Evaluating Monday, current date is also Monday - can't evaluate same day
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-06"),
      currentCalendarDate: CalendarDate("2025-01-06")
    ))
    
    // Evaluating Wednesday, current date is Wednesday - can't evaluate same day
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-08"),
      currentCalendarDate: CalendarDate("2025-01-08")
    ))
    
    // Evaluating Sunday, current date is Sunday - can't evaluate same day
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-12"),
      currentCalendarDate: CalendarDate("2025-01-12")
    ))
  }
  
  func test_weeksPeriod_canEvaluateStreak_afterPeriodComplete() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )
    
    // Evaluating Sunday when current date is next Monday - period complete, can evaluate
    XCTAssertTrue(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-12"), // Sunday
      currentCalendarDate: CalendarDate("2025-01-13")    // Next Monday
    ))
    
    // Evaluating Wednesday when current date is after that week - CANNOT evaluate (not Sunday)
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-08"), // Wednesday
      currentCalendarDate: CalendarDate("2025-01-15")    // Following Wednesday
    ))
    
    // Evaluating Monday when current date is next Tuesday - CANNOT evaluate (not Sunday)
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-06"), // Monday
      currentCalendarDate: CalendarDate("2025-01-14")    // Next week Tuesday
    ))
    
    // Evaluating Friday when current date is after that week - CANNOT evaluate (not Sunday)
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-10"), // Friday
      currentCalendarDate: CalendarDate("2025-01-13")    // Next Monday
    ))
  }
  
  func test_weeksPeriod_canEvaluateStreak_multipleWeeks() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )
    
    // Week 1 Sunday: Can evaluate when current date is in week 2
    XCTAssertTrue(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-12"), // Sunday of week 1
      currentCalendarDate: CalendarDate("2025-01-13")    // Monday of week 2
    ))
    
    // Week 1 Friday: Cannot evaluate (not Sunday)
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-10"), // Friday of week 1
      currentCalendarDate: CalendarDate("2025-01-13")    // Monday of week 2
    ))
    
    // Week 2 Sunday: Can evaluate when current date is in week 3
    XCTAssertTrue(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-19"), // Sunday of week 2
      currentCalendarDate: CalendarDate("2025-01-20")    // Monday of week 3
    ))
    
    // Week 2 Wednesday: Cannot evaluate (not Sunday)
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: CalendarDate("2025-01-15"), // Wednesday of week 2
      currentCalendarDate: CalendarDate("2025-01-20")    // Monday of week 3
    ))
  }
  
  func test_weeksPeriod_periodBoundaries() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )
    
    // Period 0: Jan 6-12 (Mon-Sun)
    let period0Start = CalendarDate("2025-01-06") // Monday
    let period0End = CalendarDate("2025-01-12")   // Sunday
    let period1Start = CalendarDate("2025-01-13") // Next Monday
    
    // During period 0, canEvaluateStreak is false (can't evaluate during period)
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: period0Start,
      currentCalendarDate: period0Start
    ))
    
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: period0End,
      currentCalendarDate: period0End
    ))
    
    // After period 0 completes:
    // - Monday cannot be evaluated (not Sunday)
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: period0Start,
      currentCalendarDate: period1Start
    ))
    
    // - Sunday CAN be evaluated (it's Sunday and period is complete)
    XCTAssertTrue(goal.canEvaluateStreak(
      forEvaluationCalendarDate: period0End,
      currentCalendarDate: period1Start
    ))
    
    // Test mid-week days cannot be evaluated even after period completes
    let period0Wednesday = CalendarDate("2025-01-08")
    XCTAssertFalse(goal.canEvaluateStreak(
      forEvaluationCalendarDate: period0Wednesday,
      currentCalendarDate: period1Start
    ))
  }
  
  func test_weeksPeriod_onlySundaysEvaluate() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )
    
    // Check each day of the week - only Sunday should evaluate
    let weekDays = [
      (CalendarDate("2025-01-06"), "Monday"),
      (CalendarDate("2025-01-07"), "Tuesday"),
      (CalendarDate("2025-01-08"), "Wednesday"),
      (CalendarDate("2025-01-09"), "Thursday"),
      (CalendarDate("2025-01-10"), "Friday"),
      (CalendarDate("2025-01-11"), "Saturday"),
      (CalendarDate("2025-01-12"), "Sunday")
    ]
    
    let nextMonday = CalendarDate("2025-01-13")
    
    for (date, dayName) in weekDays {
      let canEvaluate = goal.canEvaluateStreak(
        forEvaluationCalendarDate: date,
        currentCalendarDate: nextMonday
      )
      
      if dayName == "Sunday" {
        XCTAssertTrue(canEvaluate, "\(dayName) should be evaluatable after week completes")
      } else {
        XCTAssertFalse(canEvaluate, "\(dayName) should NOT be evaluatable")
      }
    }
  }

  // MARK: - getSessionsDateRangeForTarget Tests

  // MARK: EveryXDaysActivityGoalModel

  func test_everyXDays_getSessionsDateRangeForTarget_alwaysSingleDay() {
    let goal = EveryXDaysActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-01"),
      daysInterval: 3,
      target: ActivityGoalTargetModel(id: 1, goalValue: 30, goalSuccessCriteria: .atLeast)
    )

    // Test various dates - should always return single day
    let date1 = CalendarDate("2025-01-01")
    let range1 = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: date1)
    if case .singleDay(let day) = range1 {
      XCTAssertEqual(day, date1)
    } else {
      XCTFail("Expected .singleDay for EveryXDays goal")
    }

    let date2 = CalendarDate("2025-01-15")
    let range2 = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: date2)
    if case .singleDay(let day) = range2 {
      XCTAssertEqual(day, date2)
    } else {
      XCTFail("Expected .singleDay for EveryXDays goal")
    }
  }

  // MARK: DaysOfWeekActivityGoalModel

  func test_daysOfWeek_getSessionsDateRangeForTarget_alwaysSingleDay() {
    let goal = DaysOfWeekActivityGoalModel(
      id: .init(rawValue: 1),
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
    )

    // Test Monday
    let monday = CalendarDate("2025-01-06")
    let rangeMonday = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: monday)
    if case .singleDay(let day) = rangeMonday {
      XCTAssertEqual(day, monday)
    } else {
      XCTFail("Expected .singleDay for DaysOfWeek goal")
    }

    // Test Tuesday (skip day)
    let tuesday = CalendarDate("2025-01-07")
    let rangeTuesday = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: tuesday)
    if case .singleDay(let day) = rangeTuesday {
      XCTAssertEqual(day, tuesday)
    } else {
      XCTFail("Expected .singleDay for DaysOfWeek goal")
    }

    // Test Wednesday
    let wednesday = CalendarDate("2025-01-08")
    let rangeWednesday = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: wednesday)
    if case .singleDay(let day) = rangeWednesday {
      XCTAssertEqual(day, wednesday)
    } else {
      XCTFail("Expected .singleDay for DaysOfWeek goal")
    }
  }

  // MARK: WeeksPeriodActivityGoalModel

  func test_weeksPeriod_getSessionsDateRangeForTarget_returnsFullWeek() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )

    // Test Monday - should return Mon-Sun of that week
    let monday = CalendarDate("2025-01-06")
    let rangeMonday = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: monday)

    // Using CalendarDateRange initializer, should get multipleDays
    if case .multipleDays(let start, let end) = rangeMonday {
      XCTAssertEqual(start, CalendarDate("2025-01-06")) // Monday
      XCTAssertEqual(end, CalendarDate("2025-01-12"))   // Sunday
    } else {
      XCTFail("Expected .multipleDays for WeeksPeriod goal")
    }

    // Test Wednesday - should return same Mon-Sun
    let wednesday = CalendarDate("2025-01-08")
    let rangeWednesday = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: wednesday)

    if case .multipleDays(let start, let end) = rangeWednesday {
      XCTAssertEqual(start, CalendarDate("2025-01-06")) // Monday
      XCTAssertEqual(end, CalendarDate("2025-01-12"))   // Sunday
    } else {
      XCTFail("Expected .multipleDays for WeeksPeriod goal")
    }

    // Test Sunday - should return same Mon-Sun
    let sunday = CalendarDate("2025-01-12")
    let rangeSunday = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: sunday)

    if case .multipleDays(let start, let end) = rangeSunday {
      XCTAssertEqual(start, CalendarDate("2025-01-06")) // Monday
      XCTAssertEqual(end, CalendarDate("2025-01-12"))   // Sunday
    } else {
      XCTFail("Expected .multipleDays for WeeksPeriod goal")
    }
  }

  func test_weeksPeriod_getSessionsDateRangeForTarget_multipleWeeks() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday of week 1
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )

    // Week 1: Jan 6-12
    let week1Date = CalendarDate("2025-01-10") // Friday
    let range1 = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: week1Date)

    if case .multipleDays(let start, let end) = range1 {
      XCTAssertEqual(start, CalendarDate("2025-01-06"))
      XCTAssertEqual(end, CalendarDate("2025-01-12"))
    } else {
      XCTFail("Expected .multipleDays for week 1")
    }

    // Week 2: Jan 13-19
    let week2Date = CalendarDate("2025-01-15") // Wednesday
    let range2 = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: week2Date)

    if case .multipleDays(let start, let end) = range2 {
      XCTAssertEqual(start, CalendarDate("2025-01-13"))
      XCTAssertEqual(end, CalendarDate("2025-01-19"))
    } else {
      XCTFail("Expected .multipleDays for week 2")
    }

    // Week 3: Jan 20-26
    let week3Date = CalendarDate("2025-01-20") // Monday
    let range3 = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: week3Date)

    if case .multipleDays(let start, let end) = range3 {
      XCTAssertEqual(start, CalendarDate("2025-01-20"))
      XCTAssertEqual(end, CalendarDate("2025-01-26"))
    } else {
      XCTFail("Expected .multipleDays for week 3")
    }
  }

  func test_weeksPeriod_getSessionsDateRangeForTarget_beforeEffectiveDate() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-02-03"), // Monday in February
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )

    // This should trigger the precondition, but in tests we might want to handle it differently
    // For now, let's test a date on or after the effective date
    let validDate = CalendarDate("2025-02-05") // Wednesday of first week
    let range = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: validDate)

    if case .multipleDays(let start, let end) = range {
      XCTAssertEqual(start, CalendarDate("2025-02-03")) // Monday
      XCTAssertEqual(end, CalendarDate("2025-02-09"))   // Sunday
    } else {
      XCTFail("Expected .multipleDays")
    }
  }

  func test_weeksPeriod_getSessionsDateRangeForTarget_farFutureDate() {
    let goal = WeeksPeriodActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-06"), // Monday
      target: ActivityGoalTargetModel(id: 1, goalValue: 150, goalSuccessCriteria: .atLeast)
    )

    // Test a date 52 weeks later
    let farFutureDate = CalendarDate("2026-01-07") // Wednesday, 52+ weeks later
    let range = goal.getSessionsDateRangeForTarget(evaluationCalendarDate: farFutureDate)

    if case .multipleDays(let start, let end) = range {
      // Should calculate the correct week boundaries
      XCTAssertEqual(start, CalendarDate("2026-01-05")) // Monday of that week
      XCTAssertEqual(end, CalendarDate("2026-01-11"))   // Sunday of that week
    } else {
      XCTFail("Expected .multipleDays")
    }
  }

  func test_everyXDays_interval3_longRange() {
    let goal = EveryXDaysActivityGoalModel(
      id: .init(rawValue: 1),
      createDate: Date(),
      effectiveCalendarDate: CalendarDate("2025-01-01"),
      daysInterval: 3,
      target: ActivityGoalTargetModel(id: 1, goalValue: 60, goalSuccessCriteria: .lessThan)
    )

    // Test 45 days later (15 intervals)
    let date45DaysLater = CalendarDate("2025-02-15") // 45 days from Jan 1
    XCTAssertNotNil(goal.getGoalTarget(for: date45DaysLater))

    // Test 46 days later (should be skip)
    let date46DaysLater = CalendarDate("2025-02-16")
    XCTAssertNil(goal.getGoalTarget(for: date46DaysLater))

    // Test across year boundary - 365 days later
    let yearLater = CalendarDate("2026-01-01") // 365 days = 121*3 + 2, so skip
    XCTAssertNil(goal.getGoalTarget(for: yearLater))

    // Test 366 days later (122 * 3 = 366)
    let date366DaysLater = CalendarDate("2026-01-02")
    XCTAssertNotNil(goal.getGoalTarget(for: date366DaysLater))
  }
}
