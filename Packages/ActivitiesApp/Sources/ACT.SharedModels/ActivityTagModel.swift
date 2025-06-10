import Foundation
import Tagged

public struct ActivityTagModel: Sendable, Equatable, Identifiable {
  public typealias ID = Tagged<(Self, id: ()), Int64>

  public let id: ID
  public var name: String
  public var associatedColorHex: String

  public init(
    id: ID,
    name: String,
    associatedColorHex: String
  ) {
    self.id = id
    self.name = name
    self.associatedColorHex = associatedColorHex
  }
}
