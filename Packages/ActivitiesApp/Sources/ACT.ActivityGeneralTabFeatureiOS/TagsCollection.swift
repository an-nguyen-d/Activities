import UIKit
import ElixirShared
import ACT_SharedModels
import ACT_SharedUI

enum TagsCollection {
  enum Cell {
  }
}

// MARK: - Tag Cell
extension TagsCollection.Cell {

  final class Tag: BaseCollectionCell {

    struct Model: Hashable, Sendable {
      let id: ActivityTagModel.ID
      let name: String
      let colorHex: String
    }

    private let containerView = updateObject(UIView()) {
      $0.layer.cornerRadius = 16
    }

    private let nameLabel = updateObject(UILabel()) {
      $0.font = .systemFont(ofSize: 14, weight: .regular)
      $0.textColor = .white
    }

    let deleteButton = updateObject(BaseButton()) {
      $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
      $0.tintColor = .white
    }

    override func setupView() {
      super.setupView()
      contentView.backgroundColor = .clear
    }

    override func setupSubviews() {
      super.setupSubviews()

      contentView.addSubviews(containerView)
      containerView.addSubviews(nameLabel, deleteButton)

      containerView.anchor(
        top: contentView.topAnchor,
        leading: contentView.leadingAnchor,
        bottom: contentView.bottomAnchor,
        trailing: contentView.trailingAnchor
      )

      nameLabel.anchor(
        leading: containerView.leadingAnchor,
        insets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
      )
      nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

      deleteButton.anchor(
        leading: nameLabel.trailingAnchor,
        trailing: containerView.trailingAnchor,
        insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
        width: 20,
        height: 20
      )
      deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

      containerView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }

    func configure(with model: Model) {
      nameLabel.text = model.name
      containerView.backgroundColor = UIColor(hex: model.colorHex)
    }
  }
}

// MARK: - Collection Manager
extension TagsCollection {

  @MainActor
  final class Manager: NSObject {

    enum Section: Hashable {
      case main
    }

    private let collectionView: UICollectionView
    private var dataSource: UICollectionViewDiffableDataSource<Section, Cell.Tag.Model>!

    // Closure to handle delete button taps
    var onDeleteTapped: ((ActivityTagModel.ID) -> Void)?

    init(collectionView: UICollectionView) {
      self.collectionView = collectionView
      super.init()

      collectionView.register(Cell.Tag.self)
      setupDataSource()
      setupCollectionView()
    }

    private func setupDataSource() {
      dataSource = UICollectionViewDiffableDataSource<Section, Cell.Tag.Model>(
        collectionView: collectionView
      ) { [weak self] collectionView, indexPath, model in
        let cell: Cell.Tag = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: model)

        // Set up delete button handler
        cell.deleteButton.onTapHandler = { [weak self] in
          self?.onDeleteTapped?(model.id)
        }

        return cell
      }
    }

    private func setupCollectionView() {
      collectionView.delegate = self
    }

    func updateTags(_ tags: [ActivityTagModel]) {
      let models = tags.map { tag in
        Cell.Tag.Model(id: tag.id, name: tag.name, colorHex: tag.associatedColorHex)
      }

      var snapshot = NSDiffableDataSourceSnapshot<Section, Cell.Tag.Model>()
      snapshot.appendSections([.main])
      snapshot.appendItems(models)
      dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TagsCollection.Manager: UICollectionViewDelegateFlowLayout {
  // Using automatic sizing - cells will size themselves based on content
}
