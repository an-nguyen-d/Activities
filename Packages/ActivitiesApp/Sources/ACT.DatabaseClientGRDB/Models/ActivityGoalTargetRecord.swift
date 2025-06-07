import Foundation
import GRDB

struct ActivityGoalTargetRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "activityGoalTargetRecord"

  var id: Int64?
  var goalValue: Double
  var goalSuccessCriteria: String

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
