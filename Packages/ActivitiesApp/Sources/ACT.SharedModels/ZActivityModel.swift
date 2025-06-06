/*
import Foundation
import Tagged

public struct ActivityModel {

  public typealias ID = Tagged<(Self, id: ()), String>
  public let id: ID

  public let name: String
  public let createDate: Date

  public var goalSuccessStreakCount: Int

  // Relationships

  // 1 to many
  public var goals: [ActivityGoalModel]

  // 1 to many
  public var sessions: [ActivitySessionModel]

  // Many to many
  public var tags: [ActivityTagModel]

}


public struct ActivityGoalModel {

  public typealias ID = Tagged<(Self, id: ()), String>
  public let id: ID

  public let createDate: Date

  // This is stored as something like 2025-3-23, instead of a Date object to emphasize that it starts on a given day of the year
  public let effectiveDateString: String

  public let goalValue: CGFloat

  public enum GoalSuccessCriteria {
    case lessThan
    case equalTo
    case greaterThanOrEqualTo
  }
  public let goalSuccessCriteria: GoalSuccessCriteria

  public enum UnitType {
    case custom(String)
    case time
  }
  public let unitType: UnitType

}

public struct ActivitySessionModel {

  public typealias ID = Tagged<(Self, id: ()), String>
  public let id: ID

  public let createDate: Date

  // Usually the same as `createDate` as you can only log it when you've finished an activity
  // For time activities, you can subtract from completeDate, the amountCompleted as seconds to find the activity start time
  // This is the time in the real world it was completed, with exact seconds, etc
  public let completeDate: Date

  // This is how we filter down which sessions count towards a given goal
  public let effectiveCompleteDateString: String

  public let amountCompleted: CGFloat

}

public struct ActivityTagModel {

  public typealias ID = Tagged<(Self, id: ()), String>
  public let id: ID

  public let name: String
  public let createDate: Date

}

/*
 Scheduling types for goals I want to support:
 - DaysOfTheWeek, ex:
  - Do every M + W + F
  - Do every M every 2 weeks
  - This should be able to be define a very particular schedule for example, do it on Wednesday from 4AM to 5AM, but on Thursday from 2PM to 3PM, etc. So we store a separate for each of them, not just one day for every day. Also the goal can be split too, for example, do at least 5 minutes on wednesday, do at least 15 minutes on Thursday
 - CumulativeWeekly, ex:
  - Meditate at least 5 minutes this week cumulatively
  - Watch less than 1 hour of TV this week cumulatively
 - Every X days, ex:
  - Do laundry every 4 days

 I also want to support reminders to tell me about when it's approaching time to complete an activity, for example:
 - Do Red Light Therapy at 11AM every day.
 I want to have 2 separate times available to be set for an activity. Both of them are optional. For example, start time
 for Red Light THerapy is 11AM, and then end time is at 11:30AM. I want to be able to "stack" up notifications.
 A practical example here is:
 - Remind me 30 minutes before it starts
 - Remind me 10 minutes before it starts
 - Remind me when it starts
 - Remind me when it ends

 Or maybe a separate activity like
 - Go to the gym on M - F. Start time is at 12PM and end time is as 1PM
 - Remind me 30 min before it starts
 - Remind me 10 min before it end
 - Remind me when it ends

 Basically notifications:
 - For the start time, I can opt in to multiple trigger points, and the end point as well
 - I will also support "post" notifications, for example:
 - 1 hour after brushing teeth, send me a notification
 This is same thing, opt in, 30 min after, 1 hour after, multiple choices

 From user perspective:
 - I can create somewhat complex schedules when needed but most of the time I won't need to so the UI/UX is optimized for this, exposing complexity if needed.
 - I just want it to work, scheduling notifications doesn't need to be specific per day of the week if it's that goal type, I just want to know if i set 30 minutes before, that whenever the start time is, it sends it 30 minutes before


 */
*/
