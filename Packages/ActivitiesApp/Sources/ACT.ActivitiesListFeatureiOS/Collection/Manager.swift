import UIKit

extension ActivitiesCollection {

  final class Manager:
    NSObject,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDelegate
  {

    private let collectionView: UICollectionView
    private var cellModels: [Cell.Activity.Model] = [
      .init(),
      .init(),
      .init(),
      .init(),
      .init(),
      .init(),
      .init(),
      .init(),
      .init(),
      .init(),
      .init()
    ]

    init(collectionView: UICollectionView) {
      self.collectionView = collectionView
      super.init()
      collectionView.register(Cell.Activity.self)
      collectionView.dataSource = self
      collectionView.delegate = self
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      guard let superviewSize = collectionView.superview?.bounds.size else { return .zero }

      return .init(
        width: superviewSize.width,
        height: 100
      )
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      cellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell: Cell.Activity = collectionView.dequeueReusableCell(forIndexPath: indexPath)
      let cellModel = cellModels[indexPath.item]
      cell.configure(with: cellModel)
      return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

  }

}
