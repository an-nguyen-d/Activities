public protocol HasDatabaseClient {
  var databaseClient: DatabaseClient { get }
}

public extension HasDatabaseClient {
  var databaseClient: DatabaseClient {
    .previewValue()
  }
}
