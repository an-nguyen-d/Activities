import Foundation
import GRDB

// MARK: - ActivitySessionRecord

struct ActivitySessionRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "activitySessionRecord"

  var id: Int64?
  var activityId: Int64
  var value: Double
  var createDate: Date
  var completeDate: Date
  var completeCalendarDate: String

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
