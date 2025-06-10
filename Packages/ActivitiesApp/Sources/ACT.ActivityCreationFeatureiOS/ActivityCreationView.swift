import UIKit
import ElixirShared
import ACT_ActivityCreationFeature
import ACT_SharedModels

final class ActivityCreationView: BaseView {

  // MARK: - UI Elements

  private let scrollView = updateObject(UIScrollView()) { _ in
    // Default scroll view configuration
  }

  private let contentView = updateObject(UIView()) { _ in
    // Default content view configuration
  }

  private let stackView = updateObject(UIStackView()) {
    $0.axis = .vertical
    $0.spacing = 24
  }

  // Activity Name Section
  private let activityNameLabel = updateObject(UILabel()) {
    $0.text = "Activity Name"
    $0.font = .preferredFont(forTextStyle: .headline)
  }

  let activityNameTextField = updateObject(UITextField()) {
    $0.borderStyle = .roundedRect
    $0.placeholder = "Enter activity name"
    $0.autocapitalizationType = .words
    $0.returnKeyType = .next
  }

  // Unit Selection Section
  private let unitSectionLabel = updateObject(UILabel()) {
    $0.text = "Unit Type"
    $0.font = .preferredFont(forTextStyle: .headline)
  }

  let unitSegmentedControl = updateObject(UISegmentedControl(items: SessionUnitType.allCases.map(\.displayName))) {
    $0.selectedSegmentIndex = 0 // Default to integer
  }

  // Custom Unit Section
  private let customUnitLabel = updateObject(UILabel()) {
    $0.text = "Unit Name"
    $0.font = .preferredFont(forTextStyle: .headline)
  }

  let customUnitTextField = updateObject(UITextField()) {
    $0.borderStyle = .roundedRect
    $0.placeholder = "Sessions"
    $0.text = "Sessions"
    $0.returnKeyType = .done
  }

  // Goal Section
  private let goalSectionLabel = updateObject(UILabel()) {
    $0.text = "Goal"
    $0.font = .preferredFont(forTextStyle: .headline)
  }

  let goalDescriptionLabel = updateObject(UILabel()) {
    $0.text = "No goal"
    $0.font = .preferredFont(forTextStyle: .body)
    $0.textColor = .secondaryLabel
    $0.numberOfLines = 0
  }

  let editGoalButton = updateObject(BaseButton()) {
    $0.setTitle("Edit Goal", for: .normal)
    $0.backgroundColor = .systemBlue
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 8
    $0.titleLabel?.font = .preferredFont(forTextStyle: .body)
  }

  private lazy var goalStackView = updateObject(UIStackView(arrangedSubviews: [goalDescriptionLabel, editGoalButton])) {
    $0.axis = .horizontal
    $0.spacing = 12
    $0.alignment = .center
  }

  // MARK: - Setup

  override func setupView() {
    super.setupView()
    backgroundColor = .systemBackground
  }

  override func setupSubviews() {
    super.setupSubviews()

    addSubviews(scrollView)
    
    scrollView.addSubviews(contentView)
    
    contentView.addSubviews(stackView)
    
    stackView.addArrangedSubview(activityNameLabel)
    stackView.addArrangedSubview(activityNameTextField)
    stackView.addArrangedSubview(unitSectionLabel)
    stackView.addArrangedSubview(unitSegmentedControl)
    stackView.addArrangedSubview(customUnitLabel)
    stackView.addArrangedSubview(customUnitTextField)
    stackView.addArrangedSubview(goalSectionLabel)
    stackView.addArrangedSubview(goalStackView)

    scrollView.fillView(self)
    contentView.fillView(scrollView)

    let stackInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    stackView.anchor(
      top: contentView.topAnchor,
      leading: contentView.leadingAnchor,
      bottom: contentView.bottomAnchor,
      trailing: contentView.trailingAnchor,
      insets: stackInsets
    )

    contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true


    editGoalButton.anchor(height: 44)
    editGoalButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
  }

  // MARK: - Public Methods

  func updateCustomUnitVisibility(isVisible: Bool) {
    customUnitLabel.isHidden = !isVisible
    customUnitTextField.isHidden = !isVisible
  }

  func updateGoalDescription(_ description: String) {
    goalDescriptionLabel.text = description
  }
}
