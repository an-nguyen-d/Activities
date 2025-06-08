import Foundation

extension DatabaseClient {

  public static func previewValue() -> Self {
    testValue()
  }

  public static func testValue() -> Self {
    .init(
      fetchOrCreateAppState: { _ in fatalError() },
      updateAppState: { _ in fatalError() },
      createActivity: { _ in fatalError() },
      fetchActivity: { _ in fatalError() },
      fetchActivitiesNeedingEvaluation: { _ in fatalError() },
      updateActivity: { _ in fatalError() },
      observeActivity: { _ in 
        AsyncThrowingStream { continuation in
          continuation.finish()
        }
      },
      observeActivitiesList: { _ in
        AsyncThrowingStream { continuation in
          continuation.finish()
        }
      },
      createActivityTag: { _ in fatalError() },
      updateActivityTag: { _ in fatalError() },
      deleteActivityTag: { _ in fatalError() },
      linkActivityTag: { _ in fatalError() },
      unlinkActivityTag: { _ in fatalError() },
      observeActivityTags: { _ in fatalError() },
      createGoalReplacingExisting: { _ in fatalError() },
      createEveryXDaysGoal: { _ in fatalError() },
      createDaysOfWeekGoal: { _ in fatalError() },
      createWeeksPeriodGoal: { _ in fatalError() },
      fetchEffectiveGoal: { _ in fatalError() },
      fetchActivityGoal: { _ in fatalError() },
      createSession: { _ in fatalError() },
      fetchSessionsTotalValue: { _ in fatalError() }
    )
  }

}
