import UIKit
import ElixirShared
import ComposableArchitecture
import ACT_ActivitiesListFeature

public final class ActivitiesListVC: BaseViewController {

  // MARK: - Typealiases

  public typealias Module = ActivitiesListFeature
  public typealias Dependencies = Module.Dependencies

  private typealias View = ActivitiesListView
  private typealias Router = ActivitiesListRouter
  private typealias State = Module.State
  private typealias ViewAction = Module.Action.ViewAction

  // MARK: - Properties

  private let contentView = View()
  private var router: Router!
  private var viewStore: Store<State, ViewAction>

  private var collectionManager: ActivitiesCollection.Manager!

  // MARK: - Init

  public init(
    store: StoreOf<Module>,
    dependencies: Dependencies
  ) {
    self.viewStore = store.scope(
      state: \.self,
      action: \.view
    )
    super.init()
    self.router = Router(
      viewController: self,
      store: store,
      dependencies: dependencies
    )
  }

  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View

  public override func loadView() {
    view = contentView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    collectionManager = .init(
      collectionView: contentView.collectionView
    )

    observeStore()
    bindView()
  }

  private func observeStore() {
    observe { [weak self] in
      guard let self else { return }

      // Observe viewStore to update view
    }
  }

  private func bindView() {
    // Binding the view to send actions into viewStore
  }

}

import SwiftUI

struct VC_Preview: PreviewProvider {

  struct Dependencies {

  }

  static let dependencies = Dependencies()

  static var previews: some View {
    BaseVCRepresentable(
      vc: ActivitiesListVC(
        store: .init(
          initialState: ActivitiesListFeature.State(),
          reducer: {
            ActivitiesListFeature(
              dependencies: self.dependencies
            )
          }
        ),
        dependencies: self.dependencies
      )
    )
    .previewDevice("iPhone 14 Pro")
    .previewDisplayName("iPhone 14 Pro")

  }
}
