import Foundation
import GRDB

struct GoalRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "goalRecord"

  enum GoalType: String, Codable, DatabaseValueConvertible {
    case daysOfWeek
    case everyXDays
    case weeksPeriod
  }

  var id: Int64?
  var activityId: Int64
  var createDate: Date
  var effectiveCalendarDate: String
  var goalType: GoalType

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
