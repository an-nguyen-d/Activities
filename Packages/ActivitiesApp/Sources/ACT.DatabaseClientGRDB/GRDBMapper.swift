import Foundation
import ACT_SharedModels

enum GRDBMapper {

  enum MapAppState {
    static func toModel(from record: AppStateRecord) -> AppStateModel {
      AppStateModel(
        id: .init(rawValue: record.id!),
        createDate: record.createDate,
        createCalendarDate: CalendarDate(record.createCalendarDate),
        latestCalendarDateWithAllActivityStreaksEvaluated: record.latestCalendarDateWithAllActivityStreaksEvaluated.map(CalendarDate.init)
      )
    }

    static func toRecord(from model: AppStateModel) -> AppStateRecord {
      AppStateRecord(
        id: model.id.rawValue,
        createDate: model.createDate,
        createCalendarDate: model.createCalendarDate.value,
        latestCalendarDateWithAllActivityStreaksEvaluated: model.latestCalendarDateWithAllActivityStreaksEvaluated?.value
      )
    }
  }

  enum MapActivity {
    static func toRecord(from model: ActivityModel) -> ActivityRecord {
      let (unitType, unitName): (ActivityRecord.SessionUnitType, String?) = {
        switch model.sessionUnit {
        case .integer(let name):
          return (.integer, name)
        case .floating(let name):
          return (.floating, name)
        case .seconds:
          return (.seconds, nil)
        }
      }()

      return ActivityRecord(
        id: model.id.rawValue,
        activityName: model.activityName,
        sessionUnitType: unitType,
        sessionUnitName: unitName,
        currentStreakCount: model.currentStreakCount,
        lastGoalSuccessCheckCalendarDate: model.lastGoalSuccessCheckCalendarDate?.value
      )
    }
    
    static func toModel(from record: ActivityRecord) -> ActivityModel {
      let sessionUnit: ActivityModel.SessionUnit = {
        switch record.sessionUnitType {
        case .integer:
          return .integer(record.sessionUnitName ?? "sessions") // fallback
        case .floating:
          return .floating(record.sessionUnitName ?? "units") // fallback
        case .seconds:
          return .seconds
        }
      }()

      return ActivityModel(
        id: .init(rawValue: record.id!),
        activityName: record.activityName,
        sessionUnit: sessionUnit,
        currentStreakCount: record.currentStreakCount,
        lastGoalSuccessCheckCalendarDate: record.lastGoalSuccessCheckCalendarDate.map(CalendarDate.init)
      )
    }
  }


}


extension GRDBMapper {
  enum MapActivitySession {
    static func toModel(from record: ActivitySessionRecord) -> ActivitySessionModel {
      ActivitySessionModel(
        id: .init(record.id!),
        value: record.value,
        createDate: record.createDate,
        completeDate: record.completeDate,
        completeCalendarDate: CalendarDate(record.completeCalendarDate)
      )
    }

    static func toRecord(from model: ActivitySessionModel, activityId: Int64) -> ActivitySessionRecord {
      ActivitySessionRecord(
        id: model.id.rawValue,
        activityId: activityId,
        value: model.value,
        createDate: model.createDate,
        completeDate: model.completeDate,
        completeCalendarDate: model.completeCalendarDate.value
      )
    }
  }
}

extension GRDBMapper {
  enum MapActivityGoalTarget {
    static func toModel(from record: ActivityGoalTargetRecord) -> ActivityGoalTargetModel? {
      guard let goalSuccessCriteria = GoalSuccessCriteria(rawValue: record.goalSuccessCriteria) else {
        assertionFailure("Invalid goalSuccessCriteria value '\(record.goalSuccessCriteria)' in database. Valid values are: atLeast, exactly, lessThan")
        return nil
      }
      
      return ActivityGoalTargetModel(
        id: .init(record.id!),
        goalValue: record.goalValue,
        goalSuccessCriteria: goalSuccessCriteria
      )
    }
    
    static func toRecord(from model: ActivityGoalTargetModel) -> ActivityGoalTargetRecord {
      return ActivityGoalTargetRecord(
        id: model.id.rawValue,
        goalValue: model.goalValue,
        goalSuccessCriteria: model.goalSuccessCriteria.rawValue
      )
    }
  }
}

extension GRDBMapper {

  enum MapGoal {

    static func toEveryXDaysModel(
      from goalRecord: GoalRecord,
      everyXDaysRecord: EveryXDaysActivityGoalRecord,
      targetRecord: ActivityGoalTargetRecord
    ) -> EveryXDaysActivityGoalModel? {
      guard let target = MapActivityGoalTarget.toModel(from: targetRecord) else {
        return nil
      }
      
      return EveryXDaysActivityGoalModel(
        id: .init(goalRecord.id!),
        createDate: goalRecord.createDate,
        effectiveCalendarDate: CalendarDate(goalRecord.effectiveCalendarDate),
        daysInterval: everyXDaysRecord.daysInterval,
        target: target
      )
    }

    static func toDaysOfWeekModel(
      from goalRecord: GoalRecord,
      daysOfWeekRecord: DaysOfWeekActivityGoalRecord,
      daysOfWeekTargets: [(dayOfWeek: Int, target: ActivityGoalTargetRecord)]
    ) -> DaysOfWeekActivityGoalModel {
      // Build a map of dayOfWeek to target
      var targetsByDay: [Int: ActivityGoalTargetModel] = [:]

      for (dayOfWeek, targetRecord) in daysOfWeekTargets {
        if let target = MapActivityGoalTarget.toModel(from: targetRecord) {
          targetsByDay[dayOfWeek] = target
        }
      }

      // Map to each day using DayOfWeek enum values
      return DaysOfWeekActivityGoalModel(
        id: .init(goalRecord.id!),
        createDate: goalRecord.createDate,
        effectiveCalendarDate: CalendarDate(goalRecord.effectiveCalendarDate),
        weeksInterval: daysOfWeekRecord.weeksInterval,
        mondayGoal: targetsByDay[DayOfWeek.monday.rawValue],
        tuesdayGoal: targetsByDay[DayOfWeek.tuesday.rawValue],
        wednesdayGoal: targetsByDay[DayOfWeek.wednesday.rawValue],
        thursdayGoal: targetsByDay[DayOfWeek.thursday.rawValue],
        fridayGoal: targetsByDay[DayOfWeek.friday.rawValue],
        saturdayGoal: targetsByDay[DayOfWeek.saturday.rawValue],
        sundayGoal: targetsByDay[DayOfWeek.sunday.rawValue]
      )
    }

    static func toWeeksPeriodModel(
      from goalRecord: GoalRecord,
      weeksPeriodRecord: WeeksPeriodActivityGoalRecord,
      targetRecord: ActivityGoalTargetRecord
    ) -> WeeksPeriodActivityGoalModel? {
      guard let target = MapActivityGoalTarget.toModel(from: targetRecord) else {
        return nil
      }
      
      return WeeksPeriodActivityGoalModel(
        id: .init(goalRecord.id!),
        createDate: goalRecord.createDate,
        effectiveCalendarDate: CalendarDate(goalRecord.effectiveCalendarDate),
        target: target
      )
    }
  }
}


extension GRDBMapper {
  enum MapActivityTag {
    static func toRecord(from model: ActivityTagModel) -> ActivityTagRecord {
      return ActivityTagRecord(
        id: model.id.rawValue,
        name: model.name,
        associatedColorHex: model.associatedColorHex
      )
    }

    static func toModel(from record: ActivityTagRecord) -> ActivityTagModel {
      return ActivityTagModel(
        id: .init(rawValue: record.id!),
        name: record.name,
        associatedColorHex: record.associatedColorHex
      )
    }
  }
}
