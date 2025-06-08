import Foundation
import GRDB

struct WeeksPeriodActivityGoalRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "weeksPeriodActivityGoalRecord"

  var id: Int64?
  var goalId: Int64
  var targetId: Int64

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
