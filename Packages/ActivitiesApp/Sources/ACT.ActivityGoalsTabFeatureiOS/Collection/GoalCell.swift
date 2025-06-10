import UIKit
import ACT_SharedUI
import ElixirShared

extension GoalsCollection.Cell {
  
  struct Goal {
    struct Model: Hashable {
      let id: String
      let effectiveDate: String
      let description: String
      let goalType: String
    }
  }
  
  final class GoalCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let containerView = updateObject(UIView()) {
      $0.backgroundColor = UIColor.white.withAlphaComponent(0.05)
      $0.layer.cornerRadius = 12
      $0.layer.borderWidth = 1
      $0.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
    }
    
    private let stackView = updateObject(UIStackView()) {
      $0.axis = .vertical
      $0.spacing = 8
      $0.alignment = .leading
    }
    
    private let goalTypeLabel = updateObject(UILabel()) {
      $0.font = .systemFont(ofSize: 12, weight: .medium)
      $0.textColor = .peterRiver
    }
    
    private let effectiveDateLabel = updateObject(UILabel()) {
      $0.font = .systemFont(ofSize: 14, weight: .regular)
      $0.textColor = .secondaryLabel
    }
    
    private let descriptionLabel = updateObject(UILabel()) {
      $0.font = .systemFont(ofSize: 16, weight: .medium)
      $0.textColor = .View.Text.primary
      $0.numberOfLines = 0
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
      contentView.addSubviews(containerView)
      containerView.addSubviews(stackView)
      
      stackView.addArrangedSubview(goalTypeLabel)
      stackView.addArrangedSubview(effectiveDateLabel)
      stackView.addArrangedSubview(descriptionLabel)
      
      containerView.fillView(contentView, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
      stackView.fillView(containerView, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    // MARK: - Configuration
    
    func configure(with model: Goal.Model) {
      goalTypeLabel.text = model.goalType.uppercased()
      effectiveDateLabel.text = model.effectiveDate
      descriptionLabel.text = model.description
    }
    
    override func prepareForReuse() {
      super.prepareForReuse()
      goalTypeLabel.text = nil
      effectiveDateLabel.text = nil
      descriptionLabel.text = nil
    }
  }
}