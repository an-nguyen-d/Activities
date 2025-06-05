import UIKit
import ComposableArchitecture
import ElixirShared
import ACT_ActivitiesListFeatureOld

public final class CreateActivityFeatureVC: BaseViewController {

  public typealias Module = CreateActivityFeature
  private typealias View = CreateActivityFeatureView
  
  private let contentView = View()
  
  @UIBindable
  var store: StoreOf<Module>

  public init(store: StoreOf<Module>) {
    self.store = store
    super.init()
  }

  public override func loadView() {
    view = contentView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    observeStore()
    bindView()
    bindRouting()
  }

  private func bindRouting() {

  }

  private func observeStore() {
    observe { [weak self] in
      guard let self else { return }


    }
  }

  private func bindView() {
    contentView.dismissButton.onTapHandler = { [weak self] in
      self?.store.send(.view(.dismissButtonTapped))
      self?.dismiss(animated: true)
    }
  }

  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

public final class CreateActivityFeatureView: BaseView {

  let dismissButton = updateObject(BaseButton()) {
    $0.setTitle("Dismiss", for: [])
    $0.setTitleColor(.white, for: [])
  }

  public override func setupView() {
    super.setupView()

    backgroundColor = .black
  }

  public override func setupSubviews() {
    addSubviews(
      dismissButton
    )

    dismissButton.fillView(self)
  }

}

public final class ActivitiesListFeatureVC: BaseViewController {

  public typealias Module = ActivitiesListFeature
  private typealias View = ActivitiesListFeatureView
  private typealias State = Module.State
  private typealias ViewAction = Module.Action.ViewAction

  private let contentView = View()
  private var router: Router!

  private var viewStore: Store<State, ViewAction>

  public init(store: StoreOf<Module>) {
    self.viewStore = store.scope(
      state: \.self,
      action: \.view
    )

    super.init()
    self.router = Router(
      viewController: self,
      store: store
    )
  }

  public override func loadView() {
    view = contentView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    observeStore()
    bindView()
  }

  private func observeStore() {
    observe { [weak self] in
      guard let self else { return }

      contentView.counterLabel.text = "\(viewStore.count)"

      switch viewStore.destination {
      case .createActivity:
        view.backgroundColor = .red
      case nil:
        view.backgroundColor = .black
      }
    }
  }

  private func bindView() {
    contentView.decrementButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.decrementButtonTapped)

    }

    contentView.incrementButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.incrementButtonTapped)
    }
  }

  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

public final class ActivitiesListFeatureView: BaseView {

  let counterLabel = updateObject(UILabel()) {
    $0.textColor = .white
    $0.font = .systemFont(ofSize: 36)
  }

  let decrementButton = updateObject(BaseButton()) {
    $0.setTitle("+", for: [])
    $0.setTitleColor(.white, for: [])
  }

  let incrementButton = updateObject(BaseButton()) {
    $0.setTitle("+", for: [])
    $0.setTitleColor(.white, for: [])
  }

  public override func setupView() {
    super.setupView()

    backgroundColor = .black
  }

  public override func setupSubviews() {
    super.setupSubviews()

    addSubviews(
      counterLabel,
      decrementButton,
      incrementButton
    )

    counterLabel.fillHorizontally(self)
    counterLabel.anchor(
      .top(topAnchor, constant: 36)
    )

    decrementButton.centerXTo(centerXAnchor)
    decrementButton.anchor(
      .top(counterLabel.bottomAnchor, constant: 16)
    )

    incrementButton.centerXTo(centerXAnchor)
    incrementButton.anchor(
      .top(decrementButton.bottomAnchor, constant: 16)
    )
  }

}




