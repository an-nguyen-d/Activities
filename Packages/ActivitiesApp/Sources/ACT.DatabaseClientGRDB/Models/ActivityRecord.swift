import GRDB

struct ActivityRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "activityRecord"

  var id: Int64?

  var activityName: String

  enum SessionUnitType: String, Codable {
    case integer = "integer"
    case floating = "floating"
    case seconds = "seconds"
  }
  var sessionUnitType: SessionUnitType
  var sessionUnitName: String? // nil for seconds, "pills"/"ml"/etc for others

  var currentStreakCount: Int
  var lastGoalSuccessCheckCalendarDate: String?

  init(
    id: Int64?,
    activityName: String,
    sessionUnitType: SessionUnitType,
    sessionUnitName: String?,
    currentStreakCount: Int,
    lastGoalSuccessCheckCalendarDate: String?
  ) {
    self.id = id
    self.activityName = activityName
    self.sessionUnitType = sessionUnitType
    self.sessionUnitName = sessionUnitName
    self.currentStreakCount = currentStreakCount
    self.lastGoalSuccessCheckCalendarDate = lastGoalSuccessCheckCalendarDate
  }

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
