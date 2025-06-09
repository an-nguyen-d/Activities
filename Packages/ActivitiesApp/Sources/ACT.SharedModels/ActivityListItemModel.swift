import Foundation
import Tagged

/// Composite model combining activity + goal + sessions data for list display
public struct ActivityListItemModel: Sendable, Equatable, Identifiable {
  public var id: ActivityModel.ID { activity.id }
  
  public let activity: ActivityModel
  public let effectiveGoal: any ActivityGoal.Modelling
  public let sessions: [ActivitySessionModel]
  
  public init(
    activity: ActivityModel,
    effectiveGoal: any ActivityGoal.Modelling,
    sessions: [ActivitySessionModel]
  ) {
    self.activity = activity
    self.effectiveGoal = effectiveGoal
    self.sessions = sessions
  }
  
  public static func == (lhs: ActivityListItemModel, rhs: ActivityListItemModel) -> Bool {
    lhs.activity == rhs.activity &&
    lhs.sessions == rhs.sessions &&
    lhs.effectiveGoal.id == rhs.effectiveGoal.id
  }
}