import UIKit
import ElixirShared
import ACT_SharedModels
import ACT_SharedUI

final class ActivityGeneralTabView: BaseView {
    
    // MARK: - UI Elements
    
    private let scrollView = updateObject(UIScrollView()) { _ in
        // Default scroll view configuration
    }
    
    private let contentView = updateObject(UIView()) { _ in
        // Default content view configuration
    }
    
    private let stackView = updateObject(UIStackView()) {
        $0.axis = .vertical
        $0.spacing = 24
    }
    
    // Activity Name Section
    private let activityNameLabel = updateObject(UILabel()) {
        $0.text = "ACTIVITY NAME"
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .secondaryLabel
    }
    
    private let nameValueLabel = updateObject(UILabel()) {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .View.Text.primary
    }
    
    let editNameButton = updateObject(BaseButton()) {
        $0.setTitle("Edit", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.setTitleColor(.peterRiver, for: .normal)
    }
    
    private lazy var nameStackView = updateObject(UIStackView(arrangedSubviews: [nameValueLabel, editNameButton])) {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
    }
    
    // Unit Section
    private let unitSectionLabel = updateObject(UILabel()) {
        $0.text = "UNIT TYPE"
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .secondaryLabel
    }
    
    private let unitDescriptionLabel = updateObject(UILabel()) {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .View.Text.primary
        $0.numberOfLines = 0
    }
    
    // Tags Section
    private let tagsSectionLabel = updateObject(UILabel()) {
        $0.text = "TAGS"
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .secondaryLabel
    }
    
    let addTagButton = updateObject(BaseButton()) {
        $0.setTitle("Add Tag", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.setTitleColor(.peterRiver, for: .normal)
    }
    
    private lazy var tagsHeaderStackView = updateObject(UIStackView(arrangedSubviews: [tagsSectionLabel, addTagButton])) {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
    }
    
    let tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - Setup
    
    override func setupView() {
        super.setupView()
        backgroundColor = .View.Background.primary
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubviews(scrollView)
        
        scrollView.addSubviews(contentView)
        
        contentView.addSubviews(stackView)
        
        stackView.addArrangedSubview(activityNameLabel)
        stackView.addArrangedSubview(nameStackView)
        stackView.addArrangedSubview(unitSectionLabel)
        stackView.addArrangedSubview(unitDescriptionLabel)
        stackView.addArrangedSubview(tagsHeaderStackView)
        stackView.addArrangedSubview(tagsCollectionView)
        
        scrollView.fillView(self)
        contentView.fillView(scrollView)
        
        let stackInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            insets: stackInsets
        )
        
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        tagsCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
    }
    
    // MARK: - Public Methods
    
    func configure(activity: ActivityModel) {
        nameValueLabel.text = activity.activityName
        unitDescriptionLabel.text = unitDescription(for: activity.sessionUnit)
    }
    
    private func unitDescription(for unit: ActivityModel.SessionUnit) -> String {
        switch unit {
        case .integer(let unitName):
            return "Sessions tracked as whole numbers (e.g., 1, 2, 3 \(unitName))"
        case .floating(let unitName):
            return "Sessions tracked with decimal precision (e.g., 1.5, 2.25 \(unitName))"
        case .seconds:
            return "Sessions tracked by duration in time"
        }
    }
}