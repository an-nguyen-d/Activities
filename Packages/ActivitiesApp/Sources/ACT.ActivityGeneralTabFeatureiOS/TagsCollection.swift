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
    var onDeleteTapped: ((Int) -> Void)?

    init(collectionView: UICollectionView) {
      self.collectionView = collectionView
      super.init()

      collectionView.register(Cell.Tag.self)
      setupDataSource()
      setupCollectionView()

      // Load dummy data for testing
      loadDummyData()
    }

    private func setupDataSource() {
      dataSource = UICollectionViewDiffableDataSource<Section, Cell.Tag.Model>(
        collectionView: collectionView
      ) { [weak self] collectionView, indexPath, model in
        let cell: Cell.Tag = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.configure(with: model)

        // Set up delete button handler
        cell.deleteButton.onTapHandler = { [weak self] in
          self?.onDeleteTapped?(indexPath.item)
        }

        return cell
      }
    }

    private func setupCollectionView() {
      collectionView.delegate = self
    }

    private func loadDummyData() {
      // Dummy data with various name lengths for testing autosizing
      let dummyTags = [
        Cell.Tag.Model(name: "Work", colorHex: "e74c3c"),
        Cell.Tag.Model(name: "Personal Development", colorHex: "3498db"),
        Cell.Tag.Model(name: "Health", colorHex: "2ecc71"),
        Cell.Tag.Model(name: "Fitness & Exercise", colorHex: "f39c12"),
        Cell.Tag.Model(name: "AI", colorHex: "9b59b6"),
        Cell.Tag.Model(name: "Reading", colorHex: "1abc9c"),
        Cell.Tag.Model(name: "Meditation & Mindfulness", colorHex: "34495e"),
        Cell.Tag.Model(name: "Code", colorHex: "e67e22"),
        Cell.Tag.Model(name: "Family Time Activities", colorHex: "16a085"),
        Cell.Tag.Model(name: "Art", colorHex: "d35400")
      ]

      var snapshot = NSDiffableDataSourceSnapshot<Section, Cell.Tag.Model>()
      snapshot.appendSections([.main])
      snapshot.appendItems(dummyTags)
      dataSource.apply(snapshot, animatingDifferences: false)
    }

    func updateTags(_ tags: [ActivityTagModel]) {
      let models = tags.map { tag in
        Cell.Tag.Model(name: tag.name, colorHex: tag.associatedColorHex)
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
