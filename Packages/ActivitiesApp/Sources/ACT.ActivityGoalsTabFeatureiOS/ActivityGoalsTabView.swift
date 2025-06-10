import UIKit
import ElixirShared
import ACT_SharedUI

final class ActivityGoalsTabView: BaseView {
  
  // MARK: - UI Elements
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 16
    layout.scrollDirection = .vertical
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    return collectionView
  }()
  
  let createGoalButton = updateObject(BaseButton()) {
    $0.setTitle("Create Goal", for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .peterRiver
    $0.layer.cornerRadius = 25
  }
  
  // MARK: - Setup
  
  override func setupView() {
    super.setupView()
    backgroundColor = .View.Background.primary
  }
  
  override func setupSubviews() {
    super.setupSubviews()
    
    addSubviews(collectionView, createGoalButton)
    
    // Collection view fills the view
    collectionView.fillView(self)
    
    // Create goal button floats at the bottom
    createGoalButton.anchor(
      bottom: safeAreaLayoutGuide.bottomAnchor,
      insets: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20),
      height: 50
    )
    createGoalButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    createGoalButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
    
    // Adjust collection view content insets to make room for button
    collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 90, right: 0)
    collectionView.scrollIndicatorInsets = collectionView.contentInset
  }
}