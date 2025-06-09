import ACT_DatabaseClient
import ACT_SharedModels
import ElixirShared
import GRDB
import Foundation

public enum DatabaseConfiguration {
  case inMemory
  case file(path: String)
}

private extension DatabaseConfiguration {
  var dbPath: String {
    switch self {
    case .inMemory:
      return ":memory:"
    case .file(let path):
      return path
    }
  }
}


extension DatabaseClient {

  public static func grdbValue(
    dateMaker: DateMaker,
    timeZone: TimeZone,
    configuration: DatabaseConfiguration
  ) throws -> Self {
    let dbQueue = try DatabaseQueue(path: configuration.dbPath)

    // Run migrations
    var migrator = DatabaseMigrator()
    migrator.registerMigration("1") { db in

      try db.create(table: ActivityRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("activityName", .text).notNull()
        t.column("sessionUnitType", .text).notNull() // "integer", "floating", "seconds"
        t.column("sessionUnitName", .text) // nullable - only for integer/floating
        t.column("currentStreakCount", .integer).notNull()
        t.column("lastGoalSuccessCheckCalendarDate", .text)
      }

      // Create app state table
      try db.create(table: AppStateRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("createDate", .datetime).notNull()
        t.column("createCalendarDate", .text).notNull()
        t.column("latestCalendarDateWithAllActivityStreaksEvaluated", .text)
      }

      // Create base goal table
      try db.create(table: GoalRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("activityId", .integer).notNull()
          .indexed()
          .references(ActivityRecord.databaseTableName, onDelete: .cascade)
        t.column("createDate", .datetime).notNull()
        t.column("effectiveCalendarDate", .text).notNull()
        t.column("goalType", .text).notNull()
      }

      // Create activity goal target table
      try db.create(table: ActivityGoalTargetRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("goalValue", .double).notNull()
        t.column("goalSuccessCriteria", .text).notNull()
      }

      // Create days_of_week_activity_goal table
      try db.create(table: DaysOfWeekActivityGoalRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("goalId", .integer).notNull()
          .references(GoalRecord.databaseTableName, onDelete: .cascade)
        t.column("weeksInterval", .integer).notNull()
      }

      // Create days_of_week_goal_target join table
      try db.create(table: DaysOfWeekGoalTargetRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("daysOfWeekGoalId", .integer).notNull()
          .references(DaysOfWeekActivityGoalRecord.databaseTableName, onDelete: .cascade)
        t.column("dayOfWeek", .integer).notNull()
        t.column("targetId", .integer).notNull()
          .references(ActivityGoalTargetRecord.databaseTableName, onDelete: .cascade)

        // Ensure we don't have duplicate entries for the same day
        t.uniqueKey(["daysOfWeekGoalId", "dayOfWeek"])

        // Ensure dayOfWeek matches our DayOfWeek enum values
        t.check(sql: "dayOfWeek >= 1 AND dayOfWeek <= 7")
      }

      // Create every_x_days_activity_goal table
      try db.create(table: EveryXDaysActivityGoalRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("goalId", .integer).notNull()
          .references(GoalRecord.databaseTableName, onDelete: .cascade)
        t.column("daysInterval", .integer).notNull()
        t.column("targetId", .integer).notNull()
          .references(ActivityGoalTargetRecord.databaseTableName, onDelete: .cascade)
      }

      // Create weeks_period_activity_goal table
      try db.create(table: WeeksPeriodActivityGoalRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("goalId", .integer).notNull()
          .references(GoalRecord.databaseTableName, onDelete: .cascade)
        t.column("targetId", .integer).notNull()
          .references(ActivityGoalTargetRecord.databaseTableName, onDelete: .cascade)
      }

      //

      try db.create(table: ActivitySessionRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("activityId", .integer).notNull()
          .indexed()
          .references(ActivityRecord.databaseTableName, onDelete: .cascade)
        t.column("value", .double).notNull()
        t.column("createDate", .datetime).notNull()
        t.column("completeDate", .datetime).notNull()
        t.column("completeCalendarDate", .text).notNull()
          .indexed() // Important for performance!
      }

      // Create composite index for efficient queries
      try db.create(index: "idx_activitySession_activity_date",
                    on: ActivitySessionRecord.databaseTableName,
                    columns: ["activityId", "completeCalendarDate"])

      try db.create(table: ActivityTagRecord.databaseTableName) { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("name", .text).notNull().unique()
        t.column("associatedColorHex", .text).notNull()
      }

      // Join table: Activity joins ActivityTag
      try db.create(table: ActivityJoinActivityTagRecord.databaseTableName) { t in
        t.column("activityId", .integer).notNull()
          .references(ActivityRecord.databaseTableName, onDelete: .cascade)
        t.column("activityTagId", .integer).notNull()
          .references(ActivityTagRecord.databaseTableName, onDelete: .cascade)
        t.primaryKey(["activityId", "activityTagId"])
      }

      // Indexes follow same pattern
      try db.create(index: "activityJoinActivityTag_activityId",
                    on: ActivityJoinActivityTagRecord.databaseTableName,
                    columns: ["activityId"])
      try db.create(index: "activityJoinActivityTag_activityTagId",
                    on: ActivityJoinActivityTagRecord.databaseTableName,
                    columns: ["activityTagId"])


    }



    try migrator.migrate(dbQueue)

    return .init(

      fetchOrCreateAppState: { _ in
        try await dbQueue.write { db in
          if let record = try AppStateRecord.fetchOne(db) {
            return GRDBMapper.MapAppState.toModel(from: record)
          } else {
            // Create default using dateMaker
            let now = dateMaker.date()
            let model = AppStateModel(
              id: 1,
              createDate: now,
              createCalendarDate: CalendarDate(from: now, timeZone: timeZone),
              latestCalendarDateWithAllActivityStreaksEvaluated: nil
            )

            var record = GRDBMapper.MapAppState.toRecord(from: model)
            try record.insert(db)

            return model
          }
        }
      },

      updateAppState: { request in

        try await dbQueue.write { db in
          // Fetch the app state (should always exist after fetchOrCreateAppState)
          guard var appStateRecord = try AppStateRecord.fetchOne(db) else {
            assertionFailure("App state should exist. Call fetchOrCreateAppState first.")
            return
          }

          // Update fields based on operations
          if case .update(let value) = request.latestCalendarDateWithAllActivityStreaksEvaluated {
            appStateRecord.latestCalendarDateWithAllActivityStreaksEvaluated = value?.value
          }

          // Save the updated record
          try appStateRecord.save(db)
        }

      },

      createActivity: { request in
        try await dbQueue.write { db in


          let (sessionUnitType, sessionUnitName): (ActivityRecord.SessionUnitType, String?) = {
            switch request.sessionUnit {
            case let .integer(unit):
              return (.integer, unit)
            case let .floating(unit):
              return (.floating, unit)
            case .seconds:
              return (.seconds, nil)
            }
          }()

          var record = ActivityRecord(
            id: request.id.rawValue,
            activityName: request.activityName,
            sessionUnitType: sessionUnitType,
            sessionUnitName: sessionUnitName,
            currentStreakCount: request.currentStreakCount,
            lastGoalSuccessCheckCalendarDate: request.lastGoalSuccessCheckCalendarDate?.value
          )
          try record.insert(db)

          let model = GRDBMapper.MapActivity.toModel(from: record)
          return model
        }
      },

      fetchActivity: { request in

        try await dbQueue.read { db in
          guard let activityRecord = try ActivityRecord
            .filter(Column("id") == request.id.rawValue)
            .fetchOne(db) else {
            return nil
          }

          return GRDBMapper.MapActivity.toModel(from: activityRecord)
        }

      },

      fetchActivitiesNeedingEvaluation: { request in
        try await dbQueue.read { db in
          let activities = try ActivityRecord
            .filter(
              sql: "lastGoalSuccessCheckCalendarDate < ? OR lastGoalSuccessCheckCalendarDate IS NULL",
              arguments: [request.evaluationDate.value]
            )
            .fetchAll(db)


          // Verify our algorithm invariant
          for activity in activities {
            if let lastChecked = activity.lastGoalSuccessCheckCalendarDate {
              let lastCheckedDate = CalendarDate(lastChecked)
              let daysDifference = request.evaluationDate.daysSince(lastCheckedDate)
              precondition(daysDifference <= 1, "Activity \(activity.id!) was last checked \(daysDifference) days ago, but our algorithm should only have 1 day gaps")
            }
          }

          // Convert to models
          return activities.map { record in
            GRDBMapper.MapActivity.toModel(from: record)
          }


        }
      },

      updateActivity: { request in

        try await dbQueue.write { db in
          // Fetch the existing record
          guard var activityRecord = try ActivityRecord
            .filter(Column("id") == request.id.rawValue)
            .fetchOne(db) else {
            assertionFailure("Trying to update non-existent activity with id \(request.id)")
            return
          }

          // Update fields based on operations
          switch request.currentStreakCount {
          case .skip:
            break // Don't update
          case .update(let value):
            activityRecord.currentStreakCount = value
          }

          switch request.lastGoalSuccessCheckCalendarDate {
          case .skip:
            break // Don't update
          case .update(let value):
            activityRecord.lastGoalSuccessCheckCalendarDate = value?.value
          }

          // Save the updated record
          try activityRecord.save(db)
        }

      },

      observeActivity: { request in
        AsyncThrowingStream { continuation in
          Task { @MainActor in
            let observation = ValueObservation
              .tracking { db in
                try ActivityRecord
                  .filter(Column("id") == request.id.rawValue)
                  .fetchOne(db)
              }
              .start(
                in: dbQueue,
                onError: { error in continuation.finish(throwing: error) },
                onChange: { record in
                  let model = record.map(GRDBMapper.MapActivity.toModel)
                  continuation.yield(model)
                }
              )

            continuation.onTermination = { _ in
              observation.cancel()
            }
          }
        }
      },

      observeActivitiesList: { request in
        AsyncThrowingStream { continuation in
          Task { @MainActor in
            let observation = ValueObservation
              .tracking { db -> [(activity: ActivityRecord, goal: any ActivityGoal.Modelling, sessions: [ActivitySessionRecord])] in
                let activities = try ActivityRecord.fetchAll(db)
                
                return try activities.compactMap { activity in
                  // Fetch latest effective goal for this activity using shared query helper
                  guard let goalRecord = try goalRecordsQuery(for: activity.id!)
                    .limit(1)
                    .fetchOne(db) else {
                    assertionFailure("Activity \(activity.id!) has no effective goal - this violates business logic assumption")
                    return nil // Skip this activity
                  }
                  
                  guard let effectiveGoal = try fetchGoalModel(from: goalRecord, db: db) else {
                    assertionFailure("Failed to parse goal for activity \(activity.id!)")
                    return nil // Skip this activity
                  }
                  
                  // Fetch all sessions for this activity (sorted by completeDate desc)
                  let allSessions = try ActivitySessionRecord
                    .filter(Column("activityId") == activity.id!)
                    .order(Column("completeDate").desc)
                    .fetchAll(db)
                  
                  return (activity, effectiveGoal, allSessions)
                }
              }
              .start(
                in: dbQueue,
                onError: { error in continuation.finish(throwing: error) },
                onChange: { results in
                  let models = results.map { result in
                    ActivityListItemModel(
                      activity: GRDBMapper.MapActivity.toModel(from: result.activity),
                      effectiveGoal: result.goal,
                      sessions: result.sessions.map(GRDBMapper.MapActivitySession.toModel)
                    )
                  }
                  continuation.yield(models)
                }
              )

            continuation.onTermination = { _ in
              observation.cancel()
            }
          }
        }
      },

      observeActivityGoals: { request in
        AsyncThrowingStream { continuation in
          Task { @MainActor in
            let observation = ValueObservation
              .tracking { db -> [any ActivityGoal.Modelling] in
                let goalRecords = try goalRecordsQuery(for: request.activityId.rawValue)
                  .fetchAll(db)
                
                return try goalRecords.compactMap { goalRecord in
                  try fetchGoalModel(from: goalRecord, db: db)
                }
              }
              .start(
                in: dbQueue,
                onError: { error in continuation.finish(throwing: error) },
                onChange: { goals in
                  continuation.yield(goals)
                }
              )

            continuation.onTermination = { _ in
              observation.cancel()
            }
          }
        }
      },

      // MARK: -

      createActivityTag: { request in
        try await dbQueue.write { db in
          var record = ActivityTagRecord(
            id: nil,
            name: request.name,
            associatedColorHex: request.associatedColorHex
          )
          try record.insert(db)
          return GRDBMapper.MapActivityTag.toModel(from: record)
        }
      },

      updateActivityTag: { request in
        try await dbQueue.write { db in
          guard var record = try ActivityTagRecord.fetchOne(db, key: request.id.rawValue) else {
            throw DatabaseClient.DatabaseError.recordNotFound
          }

          if case let .update(name) = request.name {
            record.name = name
          }

          if case let .update(colorHex) = request.associatedColorHex {
            record.associatedColorHex = colorHex
          }

          try record.update(db)
          return GRDBMapper.MapActivityTag.toModel(from: record)
        }
      },

      deleteActivityTag: { request in
        try await dbQueue.write { db in
          _ = try ActivityTagRecord.deleteOne(db, key: request.id.rawValue)
        }
      },

      linkActivityTag: { request in
        try await dbQueue.write { db in
          let join = ActivityJoinActivityTagRecord(
            activityId: request.activityId.rawValue,
            activityTagId: request.tagId.rawValue
          )
          try join.insert(db)
        }
      },

      unlinkActivityTag: { request in
        try await dbQueue.write { db in
          try db.execute(
            sql: """
                DELETE FROM \(ActivityJoinActivityTagRecord.databaseTableName)
                WHERE activityId = ? AND activityTagId = ?
                """,
            arguments: [request.activityId.rawValue, request.tagId.rawValue]
          )
        }
      },

      observeActivityTags: { request in
        AsyncThrowingStream { continuation in
          let task = Task { @MainActor in
            let observation: DatabaseCancellable

            if let activityId = request.activityId {
              // Observe tags for specific activity
              observation = ValueObservation
                .tracking { db in
                  try ActivityTagRecord
                    .joining(required: ActivityTagRecord
                      .hasMany(ActivityJoinActivityTagRecord.self)
                      .filter(Column("activityId") == activityId.rawValue)
                    )
                    .fetchAll(db)
                }
                .start(
                  in: dbQueue,
                  onError: { error in continuation.finish(throwing: error) },
                  onChange: { records in
                    let models = records.map(GRDBMapper.MapActivityTag.toModel)
                    continuation.yield(models)
                  }
                )
            } else {
              // Observe all tags
              observation = ValueObservation
                .tracking(ActivityTagRecord.fetchAll)
                .start(
                  in: dbQueue,
                  onError: { error in continuation.finish(throwing: error) },
                  onChange: { records in
                    let models = records.map(GRDBMapper.MapActivityTag.toModel)
                    continuation.yield(models)
                  }
                )
            }

            continuation.onTermination = { _ in
              observation.cancel()
            }
          }
        }
      },

      // MARK: -

      createGoalReplacingExisting: { request in

        try await dbQueue.write { db in
          let newGoal: (any ActivityGoal.Modelling)

          switch request.goalCreationType {
          case .everyXDays(let createRequest):
            newGoal = try createEveryXDaysGoal(db: db, request: createRequest)

          case .daysOfWeek(let createRequest):
            newGoal = try createDaysOfWeekGoal(db: db, request: createRequest)

          case .weeksPeriod(let createRequest):
            newGoal = try createWeeksPeriodGoal(db: db, request: createRequest)
          }
          
          // Then delete the existing goal
          try GoalRecord
            .filter(Column("id") == request.existingGoalIdToDelete.rawValue)
            .deleteAll(db)

          return newGoal
        }

      },

      createEveryXDaysGoal: { request in

        try await dbQueue.write { db in
          try createEveryXDaysGoal(
            db: db,
            request: request
          )
        }

      },

      createDaysOfWeekGoal: { request in

        try await dbQueue.write { db in
          try createDaysOfWeekGoal(
            db: db,
            request: request
          )
        }

      },

      createWeeksPeriodGoal: { request in

        try await dbQueue.write { db in
          try createWeeksPeriodGoal(
            db: db,
            request: request
          )
        }

      },

      fetchEffectiveGoal: { request in

        try await dbQueue.read { db in
          guard let goalRecord = try GoalRecord
            .filter(Column("activityId") == request.activityId.rawValue)
            .filter(Column("effectiveCalendarDate") <= request.calendarDate.value)
            .order(Column("effectiveCalendarDate").desc)
            .limit(1)
            .fetchOne(db) else {
            return nil
          }

          return try fetchGoalModel(from: goalRecord, db: db)
        }

      },

      fetchActivityGoal: { request in

        try await dbQueue.read { db in
          switch request.fetchType {
          case .matchingEffectiveCalendarDate(let effectiveCalendarDate):
            guard let goalRecord = try GoalRecord
              .filter(Column("activityId") == request.activityId.rawValue)
              .filter(Column("effectiveCalendarDate") == effectiveCalendarDate.value)
              .fetchOne(db) else {
              return nil
            }

            return try fetchGoalModel(from: goalRecord, db: db)
          }
        }

      },

      createSession: { request in

        try await dbQueue.write { db in
          // Create record from request (ID will be auto-generated)
          var record = ActivitySessionRecord(
            id: nil,
            activityId: request.activityId.rawValue,
            value: request.value,
            createDate: request.createDate,
            completeDate: request.completeDate,
            completeCalendarDate: request.completeCalendarDate.value
          )

          // Insert into database
          try record.insert(db)

          // Map to model and return
          return GRDBMapper.MapActivitySession.toModel(from: record)
        }

      },

      fetchSessionsTotalValue: { request in

        try await dbQueue.read { db in
          switch request.dateRange {
          case .singleDay(let date):
            // Option 1: SQL aggregation (more efficient)
            let total = try Double.fetchOne(db, sql: """
                SELECT COALESCE(SUM(value), 0) 
                FROM \(ActivitySessionRecord.databaseTableName)
                WHERE activityId = ? AND completeCalendarDate = ?
                """, arguments: [request.activityId.rawValue, date.value])
            return total ?? 0.0

          case .multipleDays(let start, let end):
            // Option 1: SQL aggregation (more efficient)
            let total = try Double.fetchOne(db, sql: """
                SELECT COALESCE(SUM(value), 0) 
                FROM \(ActivitySessionRecord.databaseTableName)
                WHERE activityId = ? 
                  AND completeCalendarDate >= ? 
                  AND completeCalendarDate <= ?
                """, arguments: [request.activityId.rawValue, start.value, end.value])
            return total ?? 0.0

          }
        }


      }




    )
  }

  /// Returns goal records for an activity, sorted by effectiveCalendarDate descending (latest first)
  private static func goalRecordsQuery(for activityId: Int64) -> QueryInterfaceRequest<GoalRecord> {
    return GoalRecord
      .filter(Column("activityId") == activityId)
      .order(Column("effectiveCalendarDate").desc)
  }

  private static func fetchGoalModel(from goalRecord: GoalRecord, db: Database) throws -> (any ActivityGoal.Modelling)? {
    switch goalRecord.goalType {
    case .everyXDays:
      guard let everyXDaysRecord = try EveryXDaysActivityGoalRecord
        .filter(Column("goalId") == goalRecord.id)
        .fetchOne(db) else {
        assertionFailure("EveryXDaysActivityGoalRecord should always exist for a goal with type .everyXDays")
        return nil
      }

      guard let targetRecord = try ActivityGoalTargetRecord
        .filter(Column("id") == everyXDaysRecord.targetId)
        .fetchOne(db) else {
        assertionFailure("ActivityGoalTargetRecord with id \(everyXDaysRecord.targetId) should always exist")
        return nil
      }

      return GRDBMapper.MapGoal.toEveryXDaysModel(
        from: goalRecord,
        everyXDaysRecord: everyXDaysRecord,
        targetRecord: targetRecord
      )

    case .daysOfWeek:
      guard let daysOfWeekRecord = try DaysOfWeekActivityGoalRecord
        .filter(Column("goalId") == goalRecord.id)
        .fetchOne(db) else {
        assertionFailure("DaysOfWeekActivityGoalRecord should always exist for a goal with type .daysOfWeek")
        return nil
      }

      let dayTargetRecords = try DaysOfWeekGoalTargetRecord
        .filter(Column("daysOfWeekGoalId") == daysOfWeekRecord.id)
        .fetchAll(db)

      guard !dayTargetRecords.isEmpty else {
        return GRDBMapper.MapGoal.toDaysOfWeekModel(
          from: goalRecord,
          daysOfWeekRecord: daysOfWeekRecord,
          daysOfWeekTargets: []
        )
      }

      let targetIds = dayTargetRecords.map { $0.targetId }
      let targetRecords = try ActivityGoalTargetRecord
        .filter(targetIds.contains(Column("id")))
        .fetchAll(db)

      let targetRecordById = Dictionary(uniqueKeysWithValues: targetRecords.map { ($0.id!, $0) })

      var daysOfWeekTargets: [(dayOfWeek: Int, target: ActivityGoalTargetRecord)] = []
      for dayTargetRecord in dayTargetRecords {
        guard let targetRecord = targetRecordById[dayTargetRecord.targetId] else {
          assertionFailure("ActivityGoalTargetRecord with id \(dayTargetRecord.targetId) should always exist")
          continue
        }
        daysOfWeekTargets.append((dayOfWeek: dayTargetRecord.dayOfWeek, target: targetRecord))
      }

      return GRDBMapper.MapGoal.toDaysOfWeekModel(
        from: goalRecord,
        daysOfWeekRecord: daysOfWeekRecord,
        daysOfWeekTargets: daysOfWeekTargets
      )

    case .weeksPeriod:
      guard let weeksPeriodRecord = try WeeksPeriodActivityGoalRecord
        .filter(Column("goalId") == goalRecord.id)
        .fetchOne(db) else {
        assertionFailure("WeeksPeriodActivityGoalRecord should always exist for a goal with type .weeksPeriod")
        return nil
      }

      guard let targetRecord = try ActivityGoalTargetRecord
        .filter(Column("id") == weeksPeriodRecord.targetId)
        .fetchOne(db) else {
        assertionFailure("ActivityGoalTargetRecord with id \(weeksPeriodRecord.targetId) should always exist")
        return nil
      }

      return GRDBMapper.MapGoal.toWeeksPeriodModel(
        from: goalRecord,
        weeksPeriodRecord: weeksPeriodRecord,
        targetRecord: targetRecord
      )
    }
  }

  private static func createWeeksPeriodGoal(
    db: Database,
    request: CreateWeeksPeriodGoal.Request
  ) throws -> CreateWeeksPeriodGoal.Response {
    // 1. Insert the target
    var targetRecord = ActivityGoalTargetRecord(
      id: nil,
      goalValue: request.target.goalValue,
      goalSuccessCriteria: request.target.goalSuccessCriteria.rawValue
    )
    try targetRecord.insert(db)
    let targetId = targetRecord.id!

    // 2. Insert the base goal record
    var goalRecord = GoalRecord(
      id: nil,
      activityId: request.activityId.rawValue,
      createDate: request.createDate,
      effectiveCalendarDate: request.effectiveCalendarDate.value,
      goalType: .weeksPeriod
    )
    try goalRecord.insert(db)
    let goalId = goalRecord.id!

    // 3. Insert the weeks period specific record
    var weeksPeriodRecord = WeeksPeriodActivityGoalRecord(
      id: nil,
      goalId: goalId,
      targetId: targetId
    )
    try weeksPeriodRecord.save(db)

    // 4. Map to model and return
    return GRDBMapper.MapGoal.toWeeksPeriodModel(
      from: goalRecord,
      weeksPeriodRecord: weeksPeriodRecord,
      targetRecord: targetRecord
    )!

  }

  private static func createDaysOfWeekGoal(
    db: Database,
    request: CreateDaysOfWeekGoal.Request
  ) throws -> CreateDaysOfWeekGoal.Response {
    // 1. Insert the base goal record
    var goalRecord = GoalRecord(
      id: nil,
      activityId: request.activityId.rawValue,
      createDate: request.createDate,
      effectiveCalendarDate: request.effectiveCalendarDate.value,
      goalType: .daysOfWeek
    )
    try goalRecord.save(db)
    let goalId = goalRecord.id!

    // 2. Insert the days of week specific record
    var daysOfWeekRecord = DaysOfWeekActivityGoalRecord(
      id: nil,
      goalId: goalId,
      weeksInterval: request.weeksInterval
    )
    try daysOfWeekRecord.save(db)
    let daysOfWeekId = daysOfWeekRecord.id!

    // 3. Insert targets and join records for each day that has a goal
    var daysOfWeekTargets: [(dayOfWeek: Int, target: ActivityGoalTargetRecord)] = []

    let daysAndGoals: [(DayOfWeek, DatabaseClient.CreateActivityGoalTarget.Request?)] = [
      (.sunday, request.sundayGoal),
      (.monday, request.mondayGoal),
      (.tuesday, request.tuesdayGoal),
      (.wednesday, request.wednesdayGoal),
      (.thursday, request.thursdayGoal),
      (.friday, request.fridayGoal),
      (.saturday, request.saturdayGoal)
    ]

    for (dayOfWeek, goalTarget) in daysAndGoals {
      guard let goalTarget = goalTarget else { continue }

      // Insert target
      var targetRecord = ActivityGoalTargetRecord(
        id: nil,
        goalValue: goalTarget.goalValue,
        goalSuccessCriteria: goalTarget.goalSuccessCriteria.rawValue
      )
      try targetRecord.save(db)
      let targetId = targetRecord.id!

      // Insert join record
      var joinRecord = DaysOfWeekGoalTargetRecord(
        id: nil,
        daysOfWeekGoalId: daysOfWeekId,
        dayOfWeek: dayOfWeek.rawValue,
        targetId: targetId
      )
      try joinRecord.save(db)

      daysOfWeekTargets.append((dayOfWeek.rawValue, targetRecord))
    }

    // 4. Map to model and return
    return GRDBMapper.MapGoal.toDaysOfWeekModel(
      from: goalRecord,
      daysOfWeekRecord: daysOfWeekRecord,
      daysOfWeekTargets: daysOfWeekTargets
    )

  }

  private static func createEveryXDaysGoal(
    db: Database,
    request: CreateEveryXDaysGoal.Request
  ) throws -> CreateEveryXDaysGoal.Response {
    // 1. Insert the target
    var targetRecord = ActivityGoalTargetRecord(
      id: nil,
      goalValue: request.target.goalValue,
      goalSuccessCriteria: request.target.goalSuccessCriteria.rawValue
    )
    try targetRecord.save(db)
    let targetId = targetRecord.id!

    // 2. Insert the base goal record
    var goalRecord = GoalRecord(
      id: nil,
      activityId: request.activityId.rawValue,
      createDate: request.createDate,
      effectiveCalendarDate: request.effectiveCalendarDate.value,
      goalType: .everyXDays
    )
    try goalRecord.save(db)
    let goalId = goalRecord.id!

    // 3. Insert the every x days specific record
    var everyXDaysRecord = EveryXDaysActivityGoalRecord(
      id: nil,
      goalId: goalId,
      daysInterval: request.daysInterval,
      targetId: targetId
    )
    try everyXDaysRecord.save(db)

    // 4. Map to model and return
    return GRDBMapper.MapGoal.toEveryXDaysModel(
      from: goalRecord,
      everyXDaysRecord: everyXDaysRecord,
      targetRecord: targetRecord
    )!
  }

}
