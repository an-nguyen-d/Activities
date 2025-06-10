import UIKit
import ACT_SharedModels

extension TagsCollection {
  
  @MainActor
  final class Manager: NSObject {
    
    // MARK: - Types
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Cell.Tag.Model>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell.Tag.Model>
    
    enum Section {
      case main
    }
    
    // MARK: - Properties
    
    private let collectionView: UICollectionView
    private lazy var dataSource: DataSource = createDataSource()
    
    var onTagSelected: ((String) -> Void)?
    
    // MARK: - Init
    
    init(collectionView: UICollectionView) {
      self.collectionView = collectionView
      super.init()
      setupCollectionView()
      loadDummyData()
    }
    
    // MARK: - Setup
    
    private func setupCollectionView() {
      collectionView.delegate = self
      collectionView.register(
        Cell.TagCell.self,
        forCellWithReuseIdentifier: String(describing: Cell.TagCell.self)
      )
    }
    
    private func createDataSource() -> DataSource {
      DataSource(
        collectionView: collectionView
      ) { collectionView, indexPath, model in
        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: String(describing: Cell.TagCell.self),
          for: indexPath
        ) as! Cell.TagCell
        
        cell.configure(with: model)
        return cell
      }
    }
    
    // MARK: - Public Methods
    
    func updateTags(_ tags: [Cell.Tag.Model]) {
      var snapshot = Snapshot()
      snapshot.appendSections([.main])
      snapshot.appendItems(tags, toSection: .main)
      dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Dummy Data
    
    private func loadDummyData() {
      let dummyTags = [
        Cell.Tag.Model(id: "1", name: "Work", colorHex: "e74c3c"),
        Cell.Tag.Model(id: "2", name: "Personal", colorHex: "3498db"),
        Cell.Tag.Model(id: "3", name: "Health & Fitness", colorHex: "2ecc71"),
        Cell.Tag.Model(id: "4", name: "Learning", colorHex: "f39c12"),
        Cell.Tag.Model(id: "5", name: "Side Project", colorHex: "9b59b6"),
        Cell.Tag.Model(id: "6", name: "Family", colorHex: "1abc9c"),
        Cell.Tag.Model(id: "7", name: "Finance", colorHex: "34495e"),
        Cell.Tag.Model(id: "8", name: "Travel", colorHex: "e67e22"),
        Cell.Tag.Model(id: "9", name: "Hobbies", colorHex: "d35400"),
        Cell.Tag.Model(id: "10", name: "Social", colorHex: "c0392b")
      ]
      
      updateTags(dummyTags)
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TagsCollection.Manager: UICollectionViewDelegateFlowLayout {
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = collectionView.bounds.width
    let height: CGFloat = 50
    return CGSize(width: width, height: height)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    guard let model = dataSource.itemIdentifier(for: indexPath) else { return }
    onTagSelected?(model.id)
  }
}