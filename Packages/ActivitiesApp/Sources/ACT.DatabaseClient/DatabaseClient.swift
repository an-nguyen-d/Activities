import Foundation
import ElixirShared
import ACT_SharedModels

public struct DatabaseClient: Sendable {

  public enum DatabaseError: Error {
    case recordNotFound
  }

  public enum CreateActivityGoalTarget {
    public struct Request: Sendable, Equatable {
      public let goalValue: Double
      public let goalSuccessCriteria: GoalSuccessCriteria
      
      public init(
        goalValue: Double,
        goalSuccessCriteria: GoalSuccessCriteria
      ) {
        self.goalValue = goalValue
        self.goalSuccessCriteria = goalSuccessCriteria
      }
    }
  }

  // MARK: - AppState

  public enum FetchOrCreateAppState {
    public struct Request {
      public init() {}
    }
    public typealias Response = AppStateModel
  }
  public var fetchOrCreateAppState: @Sendable (FetchOrCreateAppState.Request) async throws -> FetchOrCreateAppState.Response

  public enum UpdateAppState {
    public struct Request: Sendable {
      public let latestCalendarDateWithAllActivityStreaksEvaluated: UpdateValueOperation<CalendarDate?>

      public init(
        latestCalendarDateWithAllActivityStreaksEvaluated: UpdateValueOperation<CalendarDate?> = .skip
      ) {
        self.latestCalendarDateWithAllActivityStreaksEvaluated = latestCalendarDateWithAllActivityStreaksEvaluated
      }
    }
    public typealias Response = Void
  }
  /// Updates the app state's fields based on the update operations provided
  public var updateAppState: @Sendable (UpdateAppState.Request) async throws -> UpdateAppState.Response

  // MARK: - Activity

  public enum CreateActivityWithGoal {
    public enum GoalRequest: Sendable {
      case everyXDays(CreateEveryXDaysGoal.Request)
      case daysOfWeek(CreateDaysOfWeekGoal.Request)
      case weeksPeriod(CreateWeeksPeriodGoal.Request)
    }
    
    public struct Request: Sendable {
      public let activity: CreateActivity.Request
      public let goal: GoalRequest
      
      public init(
        activity: CreateActivity.Request,
        goal: GoalRequest
      ) {
        self.activity = activity
        self.goal = goal
      }
    }
    public typealias Response = ActivityModel
  }
  public var createActivityWithGoal: @Sendable (CreateActivityWithGoal.Request) async throws -> CreateActivityWithGoal.Response

  public enum CreateActivity {
    public struct Request: Sendable {
      public let id: ActivityModel.ID
      public let activityName: String
      public let sessionUnit: ActivityModel.SessionUnit
      public let currentStreakCount: Int
      public let lastGoalSuccessCheckCalendarDate: CalendarDate?

      public init(id: ActivityModel.ID, activityName: String, sessionUnit: ActivityModel.SessionUnit, currentStreakCount: Int, lastGoalSuccessCheckCalendarDate: CalendarDate?) {
        self.id = id
        self.activityName = activityName
        self.sessionUnit = sessionUnit
        self.currentStreakCount = currentStreakCount
        self.lastGoalSuccessCheckCalendarDate = lastGoalSuccessCheckCalendarDate
      }
    }
    public typealias Response = ActivityModel
  }
  public var createActivity: @Sendable (CreateActivity.Request) async throws -> CreateActivity.Response

  public enum FetchActivity {
    public struct Request: Sendable {
      public let id: ActivityModel.ID

      public init(id: ActivityModel.ID) {
        self.id = id
      }
    }
    public typealias Response = ActivityModel?
  }
  public var fetchActivity: @Sendable (FetchActivity.Request) async throws -> FetchActivity.Response

  public enum FetchActivitiesNeedingEvaluation {
    public struct Request: Sendable {
      public let evaluationDate: CalendarDate
      public init(evaluationDate: CalendarDate) {
        self.evaluationDate = evaluationDate
      }
    }
    public typealias Response = [ActivityModel]
  }
  public var fetchActivitiesNeedingEvaluation: @Sendable (FetchActivitiesNeedingEvaluation.Request) async throws -> FetchActivitiesNeedingEvaluation.Response

  public enum UpdateActivity {
    public struct Request: Sendable {
      public let id: ActivityModel.ID
      public let currentStreakCount: UpdateValueOperation<Int>
      public let lastGoalSuccessCheckCalendarDate: UpdateValueOperation<CalendarDate?>

      public init(
        id: ActivityModel.ID,
        currentStreakCount: UpdateValueOperation<Int> = .skip,
        lastGoalSuccessCheckCalendarDate: UpdateValueOperation<CalendarDate?> = .skip
      ) {
        self.id = id
        self.currentStreakCount = currentStreakCount
        self.lastGoalSuccessCheckCalendarDate = lastGoalSuccessCheckCalendarDate
      }
    }
    public typealias Response = Void
  }

  /// Updates an activity's fields based on the update operations provided
  public var updateActivity: @Sendable (UpdateActivity.Request) async throws -> UpdateActivity.Response

  public enum DeleteActivity {
    public struct Request: Sendable {
      public let id: ActivityModel.ID
      public init(id: ActivityModel.ID) {
        self.id = id
      }
    }
    public typealias Response = Void
  }
  /// Deletes an activity and all associated data (goals, sessions, tag links)
  public var deleteActivity: @Sendable (DeleteActivity.Request) async throws -> DeleteActivity.Response

  // MARK: - Activity Tag Operations

  public enum CreateActivityTag {
    public struct Request: Sendable {
      public let name: String
      public let associatedColorHex: String

      public init(name: String, associatedColorHex: String) {
        self.name = name
        self.associatedColorHex = associatedColorHex
      }
    }
    public typealias Response = ActivityTagModel
  }
  public var createActivityTag: @Sendable (CreateActivityTag.Request) async throws -> CreateActivityTag.Response

  public enum UpdateActivityTag {
    public struct Request: Sendable {
      public let id: ActivityTagModel.ID
      public let name: UpdateValueOperation<String>
      public let associatedColorHex: UpdateValueOperation<String>

      public init(
        id: ActivityTagModel.ID,
        name: UpdateValueOperation<String> = .skip,
        associatedColorHex: UpdateValueOperation<String> = .skip
      ) {
        self.id = id
        self.name = name
        self.associatedColorHex = associatedColorHex
      }
    }
    public typealias Response = ActivityTagModel
  }
  public var updateActivityTag: @Sendable (UpdateActivityTag.Request) async throws -> UpdateActivityTag.Response

  public enum DeleteActivityTag {
    public struct Request: Sendable {
      public let id: ActivityTagModel.ID

      public init(id: ActivityTagModel.ID) {
        self.id = id
      }
    }
    public typealias Response = Void
  }
  public var deleteActivityTag: @Sendable (DeleteActivityTag.Request) async throws -> DeleteActivityTag.Response

  public enum LinkActivityTag {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      public let tagId: ActivityTagModel.ID

      public init(activityId: ActivityModel.ID, tagId: ActivityTagModel.ID) {
        self.activityId = activityId
        self.tagId = tagId
      }
    }
    public typealias Response = Void
  }
  public var linkActivityTag: @Sendable (LinkActivityTag.Request) async throws -> LinkActivityTag.Response

  public enum UnlinkActivityTag {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      public let tagId: ActivityTagModel.ID

      public init(activityId: ActivityModel.ID, tagId: ActivityTagModel.ID) {
        self.activityId = activityId
        self.tagId = tagId
      }
    }
    public typealias Response = Void
  }
  public var unlinkActivityTag: @Sendable (UnlinkActivityTag.Request) async throws -> UnlinkActivityTag.Response

  public enum ObserveActivityTags {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID?

      public init(activityId: ActivityModel.ID? = nil) {
        self.activityId = activityId
      }
    }
    public typealias Response = AsyncThrowingStream<[ActivityTagModel], Error>
  }
  public var observeActivityTags: @Sendable (ObserveActivityTags.Request) async throws -> ObserveActivityTags.Response

  public enum ObserveActivity {
    public struct Request: Sendable {
      public let id: ActivityModel.ID
      
      public init(id: ActivityModel.ID) {
        self.id = id
      }
    }
    public typealias Response = AsyncThrowingStream<ActivityModel?, Error>
  }
  public var observeActivity: @Sendable (ObserveActivity.Request) async throws -> ObserveActivity.Response


  public enum ObserveActivitiesList {
    public struct Request: Sendable {
      public init() {}
    }
    public typealias Response = AsyncThrowingStream<[ActivityListItemModel], Error>
  }
  public var observeActivitiesList: @Sendable (ObserveActivitiesList.Request) async throws -> ObserveActivitiesList.Response

  public enum ObserveActivityGoals {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      
      public init(activityId: ActivityModel.ID) {
        self.activityId = activityId
      }
    }
    public typealias Response = AsyncThrowingStream<[any ActivityGoal.Modelling], Error>
  }
  public var observeActivityGoals: @Sendable (ObserveActivityGoals.Request) async throws -> ObserveActivityGoals.Response

  // MARK: - Goal

  public enum CreateGoalReplacingExisting {
    public enum GoalCreationType: Sendable {
      case everyXDays(CreateEveryXDaysGoal.Request)
      case daysOfWeek(CreateDaysOfWeekGoal.Request)
      case weeksPeriod(CreateWeeksPeriodGoal.Request)
    }

    public struct Request: Sendable {
      public let goalCreationType: GoalCreationType
      public let existingGoalIdToDelete: ActivityGoal.ID
      public init(goalCreationType: GoalCreationType, existingGoalIdToDelete: ActivityGoal.ID) {
        self.goalCreationType = goalCreationType
        self.existingGoalIdToDelete = existingGoalIdToDelete
      }
    }
    public typealias Response = any ActivityGoal.Modelling
  }
  public var createGoalReplacingExisting: @Sendable (CreateGoalReplacingExisting.Request) async throws -> CreateGoalReplacingExisting.Response

  public enum CreateEveryXDaysGoal {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      public let createDate: Date
      public let effectiveCalendarDate: CalendarDate
      public let daysInterval: Int
      public let target: DatabaseClient.CreateActivityGoalTarget.Request

      public init(
        activityId: ActivityModel.ID,
        createDate: Date,
        effectiveCalendarDate: CalendarDate,
        daysInterval: Int,
        target: DatabaseClient.CreateActivityGoalTarget.Request
      ) {
        self.activityId = activityId
        self.createDate = createDate
        self.effectiveCalendarDate = effectiveCalendarDate
        self.daysInterval = daysInterval
        self.target = target
      }
    }
    public typealias Response = EveryXDaysActivityGoalModel
  }
  public var createEveryXDaysGoal: @Sendable (CreateEveryXDaysGoal.Request) async throws -> CreateEveryXDaysGoal.Response

  public enum CreateDaysOfWeekGoal {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      public let createDate: Date
      public let effectiveCalendarDate: CalendarDate
      public let weeksInterval: Int
      public let mondayGoal: DatabaseClient.CreateActivityGoalTarget.Request?
      public let tuesdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?
      public let wednesdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?
      public let thursdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?
      public let fridayGoal: DatabaseClient.CreateActivityGoalTarget.Request?
      public let saturdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?
      public let sundayGoal: DatabaseClient.CreateActivityGoalTarget.Request?

      public init(
        activityId: ActivityModel.ID,
        createDate: Date,
        effectiveCalendarDate: CalendarDate,
        weeksInterval: Int,
        mondayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
        tuesdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
        wednesdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
        thursdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
        fridayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
        saturdayGoal: DatabaseClient.CreateActivityGoalTarget.Request?,
        sundayGoal: DatabaseClient.CreateActivityGoalTarget.Request?
      ) {
        self.activityId = activityId
        self.createDate = createDate
        self.effectiveCalendarDate = effectiveCalendarDate
        self.weeksInterval = weeksInterval
        self.mondayGoal = mondayGoal
        self.tuesdayGoal = tuesdayGoal
        self.wednesdayGoal = wednesdayGoal
        self.thursdayGoal = thursdayGoal
        self.fridayGoal = fridayGoal
        self.saturdayGoal = saturdayGoal
        self.sundayGoal = sundayGoal
      }
    }
    public typealias Response = DaysOfWeekActivityGoalModel
  }
  public var createDaysOfWeekGoal: @Sendable (CreateDaysOfWeekGoal.Request) async throws -> CreateDaysOfWeekGoal.Response

  public enum CreateWeeksPeriodGoal {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      public let createDate: Date
      public let effectiveCalendarDate: CalendarDate
      public let target: DatabaseClient.CreateActivityGoalTarget.Request

      public init(
        activityId: ActivityModel.ID,
        createDate: Date,
        effectiveCalendarDate: CalendarDate,
        target: DatabaseClient.CreateActivityGoalTarget.Request
      ) {
        self.activityId = activityId
        self.createDate = createDate
        self.effectiveCalendarDate = effectiveCalendarDate
        self.target = target
      }
    }
    public typealias Response = WeeksPeriodActivityGoalModel
  }
  public var createWeeksPeriodGoal: @Sendable (CreateWeeksPeriodGoal.Request) async throws -> CreateWeeksPeriodGoal.Response

  public enum FetchEffectiveGoal {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      public let calendarDate: CalendarDate
      public init(activityId: ActivityModel.ID, calendarDate: CalendarDate) {
        self.activityId = activityId
        self.calendarDate = calendarDate
      }
    }
    public typealias Response = (any ActivityGoal.Modelling)?
  }
  /// Fetches the goal that is effective for an activity on a specific date.
  /// Returns the most recent goal where effectiveCalendarDate <= calendarDate.
  public var fetchEffectiveGoal: @Sendable (FetchEffectiveGoal.Request) async throws -> FetchEffectiveGoal.Response

  public enum DeleteGoal {
    public struct Request: Sendable {
      public let id: ActivityGoal.ID
      public init(id: ActivityGoal.ID) {
        self.id = id
      }
    }
    public typealias Response = Void
  }
  /// Deletes a goal and all associated ActivityGoalTargetRecords
  public var deleteGoal: @Sendable (DeleteGoal.Request) async throws -> DeleteGoal.Response

  public enum FetchActivityGoal {
    public enum FetchType: Sendable {
      case matchingEffectiveCalendarDate(CalendarDate)
    }

    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      public let fetchType: FetchType
      public init(activityId: ActivityModel.ID, fetchType: FetchType) {
        self.activityId = activityId
        self.fetchType = fetchType
      }
    }
    public typealias Response = (any ActivityGoal.Modelling)?
  }
  public var fetchActivityGoal: @Sendable (FetchActivityGoal.Request) async throws -> FetchActivityGoal.Response

  // MARK: - Session

  public enum CreateSession {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      public let value: Double
      public let createDate: Date
      public let completeDate: Date
      public let completeCalendarDate: CalendarDate

      public init(
        activityId: ActivityModel.ID,
        value: Double,
        createDate: Date,
        completeDate: Date,
        completeCalendarDate: CalendarDate
      ) {
        self.activityId = activityId
        self.value = value
        self.createDate = createDate
        self.completeDate = completeDate
        self.completeCalendarDate = completeCalendarDate
      }
    }
    
    public typealias Response = ActivitySessionModel
  }
  public var createSession: @Sendable (CreateSession.Request) async throws -> CreateSession.Response

  public enum FetchSessionsTotalValue {
    public struct Request: Sendable {
      public let activityId: ActivityModel.ID
      public let dateRange: CalendarDateRange

      public init(
        activityId: ActivityModel.ID,
        dateRange: CalendarDateRange
      ) {
        self.activityId = activityId
        self.dateRange = dateRange
      }
    }
    public typealias Response = Double
  }
  public var fetchSessionsTotalValue: @Sendable (FetchSessionsTotalValue.Request) async throws -> FetchSessionsTotalValue.Response

  public init(
    fetchOrCreateAppState: @escaping @Sendable (FetchOrCreateAppState.Request) async throws -> FetchOrCreateAppState.Response,
    updateAppState: @Sendable @escaping (UpdateAppState.Request) async throws -> UpdateAppState.Response,

    createActivityWithGoal: @Sendable @escaping (CreateActivityWithGoal.Request) async throws -> CreateActivityWithGoal.Response,
    createActivity: @Sendable @escaping (CreateActivity.Request) async throws -> CreateActivity.Response,
    fetchActivity: @Sendable @escaping (FetchActivity.Request) async throws -> FetchActivity.Response,
    fetchActivitiesNeedingEvaluation: @Sendable @escaping (FetchActivitiesNeedingEvaluation.Request) async throws -> FetchActivitiesNeedingEvaluation.Response,
    updateActivity: @Sendable @escaping (UpdateActivity.Request) async throws -> UpdateActivity.Response,
    deleteActivity: @Sendable @escaping (DeleteActivity.Request) async throws -> DeleteActivity.Response,
    observeActivity: @Sendable @escaping (ObserveActivity.Request) async throws -> ObserveActivity.Response,
    observeActivitiesList: @Sendable @escaping (ObserveActivitiesList.Request) async throws -> ObserveActivitiesList.Response,
    observeActivityGoals: @Sendable @escaping (ObserveActivityGoals.Request) async throws -> ObserveActivityGoals.Response,

    createActivityTag: @Sendable @escaping (CreateActivityTag.Request) async throws -> CreateActivityTag.Response,
    updateActivityTag: @Sendable @escaping (UpdateActivityTag.Request) async throws -> UpdateActivityTag.Response,
    deleteActivityTag: @Sendable @escaping (DeleteActivityTag.Request) async throws -> DeleteActivityTag.Response,
    linkActivityTag: @Sendable @escaping (LinkActivityTag.Request) async throws -> LinkActivityTag.Response,
    unlinkActivityTag: @Sendable @escaping (UnlinkActivityTag.Request) async throws -> UnlinkActivityTag.Response,
    observeActivityTags: @Sendable @escaping (ObserveActivityTags.Request) async throws -> ObserveActivityTags.Response,

    createGoalReplacingExisting: @Sendable @escaping (CreateGoalReplacingExisting.Request) async throws -> CreateGoalReplacingExisting.Response,
    createEveryXDaysGoal: @Sendable @escaping (CreateEveryXDaysGoal.Request) async throws -> CreateEveryXDaysGoal.Response,
    createDaysOfWeekGoal: @Sendable @escaping (CreateDaysOfWeekGoal.Request) async throws -> CreateDaysOfWeekGoal.Response,
    createWeeksPeriodGoal: @Sendable @escaping (CreateWeeksPeriodGoal.Request) async throws -> CreateWeeksPeriodGoal.Response,
    fetchEffectiveGoal: @Sendable @escaping (FetchEffectiveGoal.Request) async throws -> FetchEffectiveGoal.Response,
    deleteGoal: @Sendable @escaping (DeleteGoal.Request) async throws -> DeleteGoal.Response,
    fetchActivityGoal: @Sendable @escaping (FetchActivityGoal.Request) async throws -> FetchActivityGoal.Response,

    createSession: @Sendable @escaping (CreateSession.Request) async throws -> CreateSession.Response,
    fetchSessionsTotalValue: @Sendable @escaping (FetchSessionsTotalValue.Request) async throws -> FetchSessionsTotalValue.Response
  ) {
    self.fetchOrCreateAppState = fetchOrCreateAppState
    self.updateAppState = updateAppState

    self.createActivityWithGoal = createActivityWithGoal
    self.createActivity = createActivity
    self.fetchActivity = fetchActivity
    self.fetchActivitiesNeedingEvaluation = fetchActivitiesNeedingEvaluation
    self.updateActivity = updateActivity
    self.deleteActivity = deleteActivity
    self.observeActivity = observeActivity
    self.observeActivitiesList = observeActivitiesList
    self.observeActivityGoals = observeActivityGoals

    self.createActivityTag = createActivityTag
    self.updateActivityTag = updateActivityTag
    self.deleteActivityTag = deleteActivityTag
    self.linkActivityTag = linkActivityTag
    self.unlinkActivityTag = unlinkActivityTag
    self.observeActivityTags = observeActivityTags

    self.createGoalReplacingExisting = createGoalReplacingExisting
    self.createEveryXDaysGoal = createEveryXDaysGoal
    self.createDaysOfWeekGoal = createDaysOfWeekGoal
    self.createWeeksPeriodGoal = createWeeksPeriodGoal
    self.fetchEffectiveGoal = fetchEffectiveGoal
    self.deleteGoal = deleteGoal
    self.fetchActivityGoal = fetchActivityGoal

    self.createSession = createSession
    self.fetchSessionsTotalValue = fetchSessionsTotalValue
  }

}
