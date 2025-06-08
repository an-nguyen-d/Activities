import Foundation
import GRDB

struct ActivityJoinActivityTagRecord: Codable, FetchableRecord, PersistableRecord {
  static let databaseTableName = "activityJoinActivityTagRecord"

  var activityId: Int64
  var activityTagId: Int64
}
