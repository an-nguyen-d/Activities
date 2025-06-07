import Foundation
import GRDB

struct AppStateRecord: Codable, FetchableRecord, MutablePersistableRecord {
  static let databaseTableName = "appStateRecord"

  var id: Int64?
  var createDate: Date
  var createCalendarDate: String
  var latestCalendarDateWithAllActivityStreaksEvaluated: String?

  mutating func didInsert(_ inserted: InsertionSuccess) {
    id = inserted.rowID
  }

}

