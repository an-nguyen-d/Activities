import UIKit

extension GoalsCollection {
  
  @MainActor
  final class Manager: NSObject {
    
    // MARK: - Types
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Cell.Goal.Model>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell.Goal.Model>
    
    enum Section {
      case main
    }
    
    // MARK: - Properties
    
    private let collectionView: UICollectionView
    private lazy var dataSource: DataSource = createDataSource()
    
    // MARK: - Init
    
    init(collectionView: UICollectionView) {
      self.collectionView = collectionView
      super.init()
      setupCollectionView()
    }
    
    // MARK: - Setup
    
    private func setupCollectionView() {
      collectionView.delegate = self
      collectionView.register(
        Cell.GoalCell.self,
        forCellWithReuseIdentifier: String(describing: Cell.GoalCell.self)
      )
    }
    
    private func createDataSource() -> DataSource {
      DataSource(
        collectionView: collectionView
      ) { collectionView, indexPath, model in
        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: String(describing: Cell.GoalCell.self),
          for: indexPath
        ) as! Cell.GoalCell
        
        cell.configure(with: model)
        return cell
      }
    }
    
    // MARK: - Public Methods
    
    func updateGoals(_ goals: [Cell.Goal.Model]) {
      var snapshot = Snapshot()
      snapshot.appendSections([.main])
      snapshot.appendItems(goals, toSection: .main)
      dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GoalsCollection.Manager: UICollectionViewDelegateFlowLayout {
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = collectionView.bounds.width - 32 // 16pt padding on each side
    let height: CGFloat = 100 // Fixed height for goal cells
    return CGSize(width: width, height: height)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return 16
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }
}