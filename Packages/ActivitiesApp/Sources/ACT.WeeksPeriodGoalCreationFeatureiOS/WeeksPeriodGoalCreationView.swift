import UIKit
import ElixirShared
import ACT_WeeksPeriodGoalCreationFeature
import ACT_SharedUI

final class WeeksPeriodGoalCreationView: BaseView {

  // MARK: - UI Elements
  
  private let scrollView = UIScrollView()
  private let contentStackView = UIStackView()
  
  private let titleLabel = updateObject(UILabel()) {
    $0.text = "Weekly Target"
    $0.font = .preferredFont(forTextStyle: .largeTitle)
    $0.textAlignment = .center
    $0.textColor = .label
  }
  
  private let instructionLabel = updateObject(UILabel()) {
    $0.text = "Set your weekly target for this activity"
    $0.font = .preferredFont(forTextStyle: .body)
    $0.textAlignment = .center
    $0.textColor = .secondaryLabel
    $0.numberOfLines = 0
  }
  
  let targetInputView = ActivityTargetInputView()
  
  let goalDescriptionLabel = updateObject(UILabel()) {
    $0.text = "No target"
    $0.font = .preferredFont(forTextStyle: .headline)
    $0.textAlignment = .center
    $0.textColor = .label
    $0.numberOfLines = 0
  }
  
  // MARK: - Setup
  
  override func setupView() {
    super.setupView()
    backgroundColor = .systemBackground
    
    // Setup scroll view to dismiss keyboard
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    tapGesture.cancelsTouchesInView = false
    addGestureRecognizer(tapGesture)
  }
  
  override func setupSubviews() {
    super.setupSubviews()
    
    // Configure target input view
    targetInputView.setTitle("Weekly Target")
    targetInputView.showClearButton = false // WeeksPeriod doesn't need clear button
    
    // Setup stack view
    contentStackView.axis = .vertical
    contentStackView.spacing = 24
    contentStackView.alignment = .fill
    
    contentStackView.addArrangedSubview(titleLabel)
    contentStackView.addArrangedSubview(instructionLabel)
    contentStackView.addArrangedSubview(targetInputView)
    contentStackView.addArrangedSubview(goalDescriptionLabel)
    
    // Add spacer to push content to top
    let spacerView = UIView()
    contentStackView.addArrangedSubview(spacerView)
    
    scrollView.addSubview(contentStackView)
    addSubview(scrollView)
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentStackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      // Scroll view
      scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      
      // Content stack view
      contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
      contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
      contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
      contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
      contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
    ])
  }
  
  @objc private func viewTapped() {
    endEditing(true)
  }
}