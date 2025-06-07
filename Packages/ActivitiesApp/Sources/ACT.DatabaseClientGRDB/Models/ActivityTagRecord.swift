import Foundation
import GRDB

struct ActivityTagRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "activityTagRecord"

  var id: Int64?
  var name: String
  var associatedColorHex: String // e.g., "#FF5733" or "FF5733"

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }
}
