import UIKit
import ACT_SharedUI
import ACT_SharedModels
import ElixirShared

extension TagsCollection.Cell {
  
  struct Tag {
    struct Model: Hashable {
      let id: ActivityTagModel.ID
      let name: String
      let colorHex: String
    }
  }
  
  final class TagCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let nameLabel = updateObject(UILabel()) {
      $0.font = .systemFont(ofSize: 17, weight: .medium)
      $0.textColor = .white
      $0.textAlignment = .left
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
      contentView.addSubviews(nameLabel)
      
      nameLabel.anchor(
        leading: contentView.leadingAnchor,
        trailing: contentView.trailingAnchor,
        insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
      )
      nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    // MARK: - Configuration
    
    func configure(with model: Tag.Model) {
      nameLabel.text = model.name
      
      let color = UIColor(hex: model.colorHex)
      contentView.backgroundColor = color
      nameLabel.textColor = color.contrastingColor()
    }
    
    override func prepareForReuse() {
      super.prepareForReuse()
      nameLabel.text = nil
      contentView.backgroundColor = .clear
    }
  }
}
