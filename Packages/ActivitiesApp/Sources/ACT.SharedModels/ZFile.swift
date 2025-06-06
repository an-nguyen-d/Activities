//
//  File.swift
//  ActivitiesApp
//
//  Created by An Nguyen on 6/5/25.
//

import Foundation
/*

struct EvaluateActivityGoalSuccessWorker {

//  public static func liveValue(
//
//  ) -> Self {
//
//  }




  func evaluateActivityGoalSuccessesIfNeeded() {
    // From database, grab all the activities. For each goal we want to grab their current goal + all the sessions on that date...



  }



}


struct ActivityGoalCriteria {
  let value: Int

  enum SuccessCriteria {
    case lessThan
    case equalTo
    case greaterThanOrEqualTo
  }
  let successCriteria: SuccessCriteria
}

struct ActivityScheduleTime {
  var startTime: Date?
  var endTime: Date?
}

struct ActivityGoalSchedule {
  let goalCriteria: ActivityGoalCriteria
  let scheduleTime: ActivityScheduleTime
}


struct DaysOfWeekSchedule: GoalScheduleProtocol {

  let mondayGoalCriteria: ActivityGoalSchedule?
  let tuesdayGoalCriteria: ActivityGoalSchedule?
  let wednesdayGoalCriteria: ActivityGoalSchedule?
  let thursdayGoalCriteria: ActivityGoalSchedule?
  let fridayGoalCriteria: ActivityGoalSchedule?
  let saturdayGoalCriteria: ActivityGoalSchedule?
  let sundayGoalCriteria: ActivityGoalSchedule?

  // 1 = every week
  let repeatInterval: Int

  let createDate: Date

  // What day of the week we start it. Usually same as createDate but doesnt contain time information like hours, minutes, seconds, etc
  let effectiveDateString: String

  func getEffectiveGoalSchedule(forEffectiveDate effectiveDateString: String) -> ActivityGoalSchedule? {
    // Based on what DOTY the effectiveDateString is on, we return that corresponding goalSchedule from above, which might be nil
  }

}

//

struct CumulativeWeeklySchedule: GoalScheduleProtocol {

  // 1 = every week, 2 = it sums up over 2 weeks
  let repeatInterval: Int

  let createDate: Date

  let goalCriteria: ActivityGoalSchedule
  let effectiveDateString: String

  func getEffectiveGoalSchedule(forEffectiveDate effectiveDateString: String) -> ActivityGoalSchedule? {
    return goalCriteria
  }

}

struct EveryXDaysSchedule: GoalScheduleProtocol {

  let intervalDays: Int
  let goalCriteria: ActivityGoalSchedule
  let effectiveDateString: String

  func getEffectiveGoalSchedule(forEffectiveDate effectiveDateString: String) -> ActivityGoalSchedule? {
    // this returns nil depending on effectiveDateString, if it's not a date in which the interval days returns 0 remainder when divided into
  }

}

protocol GoalScheduleProtocol {

  func getEffectiveGoalSchedule(forEffectiveDate effectiveDateString: String) -> ActivityGoalSchedule?
  var effectiveDateString: String { get }

}
*/
