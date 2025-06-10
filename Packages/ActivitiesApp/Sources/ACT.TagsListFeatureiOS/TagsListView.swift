import UIKit
import ACT_SharedUI
import ACT_SharedModels
import ElixirShared

final class TagsListView: BaseView {
  
  // MARK: - Properties
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 1
    layout.minimumInteritemSpacing = 0
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .black
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }()
  
  // MARK: - Setup
  
  override func setupView() {
    super.setupView()
    backgroundColor = .black
  }
  
  override func setupSubviews() {
    super.setupSubviews()
    
    addSubviews(collectionView)
    
    collectionView.fillView(self)
  }
}