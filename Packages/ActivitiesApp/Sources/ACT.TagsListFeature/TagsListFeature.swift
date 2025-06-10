import ComposableArchitecture
import ACT_SharedModels
import ACT_DatabaseClient
import Tagged
import IdentifiedCollections

@Reducer
public struct TagsListFeature {

  @ObservableState
  public struct State: Equatable {
    public let activityID: ActivityModel.ID
    public let tagIDsToHide: Set<ActivityTagModel.ID>
    public var tags: IdentifiedArrayOf<ActivityTagModel> = []

    @Presents
    public var destination: Destination.State?

    public init(
      activityID: ActivityModel.ID,
      tagIDsToHide: Set<ActivityTagModel.ID> = []
    ) {
      self.activityID = activityID
      self.tagIDsToHide = tagIDsToHide
    }
  }

  private enum CancelID {
    case tagsObservation
  }

  public enum Action: Equatable {
    @CasePathable
    public enum ViewAction: Equatable {
      case willAppear
      case willDisappear
      case createButtonTapped
      case didSelectAlertAction
      case tagSelected(ActivityTagModel.ID)

      public enum Alert: Equatable {
        case createTag(CreateTagAction)
      }
      case alert(Alert)
    }

    @CasePathable
    public enum InternalAction: Equatable {
      case tagsResponse([ActivityTagModel])
    }

    @CasePathable
    public enum DelegateAction: Equatable {
      case dismissed
    }

    case view(ViewAction)
    case _internal(InternalAction)
    case delegate(DelegateAction)
    case destination(PresentationAction<Destination.Action>)
  }

  public enum CreateTagAction: Equatable {
    case confirm(name: String, colorHex: String)
  }

  @Reducer
  public struct Destination {
    @CasePathable
    public enum State: Equatable {
      public enum Alert: Equatable {
        case createTag
      }
      case alert(Alert)
    }

    @CasePathable
    public enum Action: Equatable {
      // No actions needed for alert destination
    }

    public var body: some Reducer<State, Action> {
      EmptyReducer()
    }
  }

  public typealias Dependencies = HasDatabaseClient

  private let dependencies: Dependencies
  private var databaseClient: DatabaseClient { dependencies.databaseClient }

  public init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.willAppear):
        return .run { [databaseClient] send in
          do {
            let stream = try await databaseClient.observeActivityTags(.init())
            for try await tags in stream {
              await send(._internal(.tagsResponse(tags)))
            }
          } catch {
            assertionFailure("Failed to observe tags: \(error)")
          }
        }
        .cancellable(id: CancelID.tagsObservation)

      case .view(.willDisappear):
        return .cancel(id: CancelID.tagsObservation)

      case .view(.createButtonTapped):
        state.destination = .alert(.createTag)
        return .none

      case .view(.didSelectAlertAction):
        state.destination = nil
        return .none

      case let .view(.alert(.createTag(.confirm(name, colorHex)))):
        // Validate tag name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
          assertionFailure("Tag name cannot be empty")
          return .none
        }

        // Validate color hex (exactly 6 characters, no #)
        let trimmedHex = colorHex.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedHex.count == 6,
              trimmedHex.allSatisfy({ $0.isHexDigit }) else {
          assertionFailure("Color hex must be exactly 6 hex characters without #")
          return .none
        }

        // Create the tag in database
        state.destination = nil

        return .run { [databaseClient] _ in
          do {
            _ = try await databaseClient.createActivityTag(
              .init(
                name: trimmedName,
                associatedColorHex: trimmedHex
              )
            )
            print("Successfully created tag: \(trimmedName) with color: \(trimmedHex)")
          } catch {
            assertionFailure("Failed to create tag: \(error)")
          }
        }

      case .view(.alert):
        return .none

      case let .view(.tagSelected(tagID)):
        // Link the selected tag to the activity
        return .run { [databaseClient, activityID = state.activityID] send in
          do {
            try await databaseClient.linkActivityTag(
              .init(
                activityId: activityID,
                tagId: tagID
              )
            )
            // Dismiss after successful linking
            await send(.delegate(.dismissed))
          } catch {
            assertionFailure("Failed to link tag: \(error)")
          }
        }

      case .view:
        return .none

      case let ._internal(.tagsResponse(allTags)):
        // Filter out tags that should be hidden
        let visibleTags = allTags.filter { !state.tagIDsToHide.contains($0.id) }
        state.tags = IdentifiedArray(uniqueElements: visibleTags)
        return .none

      case ._internal:
        return .none

      case .delegate:
        // Delegate actions are handled by parent
        return .none

      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
  }
}
