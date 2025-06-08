import Foundation
import GRDB

struct EveryXDaysActivityGoalRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "everyXDaysActivityGoalRecord"

  var id: Int64?
  var goalId: Int64
  var daysInterval: Int
  var targetId: Int64

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
