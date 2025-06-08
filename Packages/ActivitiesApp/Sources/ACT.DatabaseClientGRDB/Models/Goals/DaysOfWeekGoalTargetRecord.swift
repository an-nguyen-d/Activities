import Foundation
import GRDB

struct DaysOfWeekGoalTargetRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "daysOfWeekGoalTargetRecord"

  var id: Int64?
  var daysOfWeekGoalId: Int64
  var dayOfWeek: Int  // 1 = Sunday, 2 = Monday, ..., 7 = Saturday (matches DayOfWeek.rawValue)
  var targetId: Int64


  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
