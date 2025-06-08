import Foundation
import GRDB

struct DaysOfWeekActivityGoalRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "daysOfWeekActivityGoalRecord"

  var id: Int64?
  var goalId: Int64
  var weeksInterval: Int

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
