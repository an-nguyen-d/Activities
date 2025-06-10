import UIKit
import ElixirShared
import ACT_SharedUI

final class GoalCreationView: BaseView {
  
  // MARK: - UI Elements
  
  private let containerViewInternal = updateObject(UIView()) {
    $0.backgroundColor = .systemBackground
    $0.layer.cornerRadius = 12
  }
  
  let titleLabel = updateObject(UILabel()) {
    $0.font = .systemFont(ofSize: 20, weight: .semibold)
    $0.textColor = .label
    $0.textAlignment = .center
  }
  
  let messageLabel = updateObject(UILabel()) {
    $0.font = .systemFont(ofSize: 16)
    $0.textColor = .secondaryLabel
    $0.textAlignment = .center
    $0.numberOfLines = 0
  }
  
  private let stackView = updateObject(UIStackView()) {
    $0.axis = .vertical
    $0.spacing = 16
    $0.distribution = .fillEqually
  }
  
  let daysOfWeekButton = updateObject(BaseButton()) {
    $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    $0.backgroundColor = .systemBlue
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 8
  }
  
  let everyXDaysButton = updateObject(BaseButton()) {
    $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    $0.backgroundColor = .systemBlue
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 8
  }
  
  let weeksPeriodButton = updateObject(BaseButton()) {
    $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    $0.backgroundColor = .systemBlue
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 8
  }
  
  // MARK: - Properties
  
  var containerView: UIView { containerViewInternal }
  
  // MARK: - Setup
  
  override func setupView() {
    backgroundColor = UIColor.black.withAlphaComponent(0.5)
  }
  
  override func setupSubviews() {
    // Add buttons to stack
    stackView.addArrangedSubview(daysOfWeekButton)
    stackView.addArrangedSubview(everyXDaysButton)
    stackView.addArrangedSubview(weeksPeriodButton)
    
    // Add subviews
    containerViewInternal.addSubviews(titleLabel, messageLabel, stackView)
    addSubview(containerViewInternal)
    
    // Layout
    containerViewInternal.centerIn(self)
    
    // Manual constraints for greater/less than
    containerViewInternal.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 40).isActive = true
    containerViewInternal.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40).isActive = true
    containerViewInternal.widthAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
    
    titleLabel.anchor(
      .top(containerViewInternal.topAnchor, constant: 24),
      .leading(containerViewInternal.leadingAnchor, constant: 24),
      .trailing(containerViewInternal.trailingAnchor, constant: -24)
    )
    
    messageLabel.anchor(
      .top(titleLabel.bottomAnchor, constant: 8),
      .leading(containerViewInternal.leadingAnchor, constant: 24),
      .trailing(containerViewInternal.trailingAnchor, constant: -24)
    )
    
    stackView.anchor(
      .top(messageLabel.bottomAnchor, constant: 32),
      .leading(containerViewInternal.leadingAnchor, constant: 24),
      .trailing(containerViewInternal.trailingAnchor, constant: -24),
      .bottom(containerViewInternal.bottomAnchor, constant: -24),
      .height(180) // 3 buttons * 50 + 2 spaces * 16
    )
    
    // Button heights
    daysOfWeekButton.anchor(.height(50))
    everyXDaysButton.anchor(.height(50))
    weeksPeriodButton.anchor(.height(50))
  }
  
}
