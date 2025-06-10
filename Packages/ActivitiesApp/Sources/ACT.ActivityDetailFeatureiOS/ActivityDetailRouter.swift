import UIKit
import ComposableArchitecture
import ACT_ActivityDetailFeature
import ACT_SharedModels

public enum ActivityDetailRouter {
  
  @MainActor
  public static func makeActivityDetailVC(
    activityID: ActivityModel.ID
  ) -> UIViewController {
    let store = Store(
      initialState: ActivityDetailFeature.State(activityID: activityID),
      reducer: { ActivityDetailFeature() }
    )
    
    return ActivityDetailVC(store: store)
  }
}