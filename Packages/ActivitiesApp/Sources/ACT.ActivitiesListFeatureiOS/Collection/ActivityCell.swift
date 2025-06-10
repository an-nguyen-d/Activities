import Foundation
import ElixirShared
import ACT_SharedUI
import ACT_SharedModels

enum ActivitiesCollection {

  enum Cell {

  }

}

// Namespace for all things related to our collection
extension ActivitiesCollection.Cell {

  final class Activity: BaseCollectionCell {

    struct Model: Hashable {
      let id: ActivityModel.ID
      let activityName: String
      let goalStatusText: String
      let lastCompletedText: String
      let lastCompletedDate: Date? // Store the actual date for timer updates
      let streakNumber: String
      let streakColor: UIColor
      let progressPercentage: Double // 0.0 to 1.0
      
      // Source data hash for cache validation (includes calendar date)
      let sourceDataHash: Int
    }
    
    var onQuickLogTapped: ((ActivityModel.ID) -> Void)?

    let streakVSeparatorView = updateObject(UIView()) {
      $0.backgroundColor = .View.separator
    }

    let logQuickActionButton = updateObject(BaseButton()) {
      $0.touchAreaInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
      $0.backgroundColor = .peterRiver
      $0.layer.cornerRadius = 4
      $0.setImage(.init(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: [])
      $0.tintColor = .View.Background.primary
    }

    let nameLabel = updateObject(UILabel()) {
      $0.textColor = .View.Text.primary
      $0.font = .systemFont(ofSize: 14, weight: .bold)
      $0.textAlignment = .left
      $0.text = "Meditate"
    }

    let goalStatusLabel = updateObject(UILabel()) {
      $0.textColor = .View.Text.primary
      $0.font = .systemFont(ofSize: 12, weight: .regular)
      $0.textAlignment = .left
      $0.text = "0 / 1 Sessions (-1)"
    }

    let lastCompleteLabel = updateObject(UILabel()) {
      $0.textColor = .View.Text.primary
      $0.font = .systemFont(ofSize: 12, weight: .regular)
      $0.textAlignment = .left
      $0.text = "Last completed: Yesterday"
    }

    let streakCountLabel = updateObject(UILabel()) {
      $0.textColor = .View.Text.primary
      $0.font = .systemFont(ofSize: 24, weight: .bold)
      $0.textAlignment = .right
      $0.text = "34"
    }

    let goalProgressView = updateObject(SimpleProgressView()) {
      $0.progress = 0.3
      $0.foregroundView.backgroundColor = .peterRiver
      $0.backgroundColor = .white.withAlphaComponent(0.2)
    }

    let bottomHSeparatorView = updateObject(UIView()) {
      $0.backgroundColor = .View.separator
    }

    override func setupView() {
      super.setupView()

      contentView.backgroundColor = .clear
      backgroundColor = .clear
    }

    override func setupSubviews() {
      super.setupSubviews()

      contentView.addSubviews(
        streakCountLabel,
        streakVSeparatorView,
        nameLabel,
        goalStatusLabel,
        lastCompleteLabel,
        goalProgressView,

        bottomHSeparatorView,
        logQuickActionButton
      )

      streakCountLabel.centerYTo(contentView.centerYAnchor)
      streakCountLabel.anchor(
        .leading(contentView.leadingAnchor, constant: 8)
//        .top(nameLabel.topAnchor)
      )

      streakVSeparatorView.fillVertically(contentView)
      streakVSeparatorView.anchor(
        .leading(contentView.leadingAnchor, constant: 44),
        .width(1)
      )

      nameLabel.anchor(
        .leading(streakVSeparatorView.trailingAnchor, constant: 8),
        .top(contentView.topAnchor, constant: 12)
      )

      goalStatusLabel.anchor(
        .leading(nameLabel.leadingAnchor, constant: 0),
        .top(nameLabel.bottomAnchor, constant: 4)
      )

      lastCompleteLabel.anchor(
        .leading(nameLabel.leadingAnchor, constant: 0),
        .top(goalStatusLabel.bottomAnchor, constant: 4)
      )

      goalProgressView.anchor(
        .leading(nameLabel.leadingAnchor, constant: 0),
        .trailing(logQuickActionButton.leadingAnchor, constant: -16),
        .top(lastCompleteLabel.bottomAnchor, constant: 10),
        .height(6)
      )

      bottomHSeparatorView.fillHorizontally(contentView, padding: 16)
      bottomHSeparatorView.anchor(
        .bottom(contentView.bottomAnchor, constant: 0),
        .height(1)
      )

      logQuickActionButton.centerYTo(contentView.centerYAnchor)
      logQuickActionButton.anchor(
        .trailing(contentView.trailingAnchor, constant: -8),
        .width(28),
        .height(28)
      )

    }

    private var currentModelId: ActivityModel.ID?
    
    func configure(with model: Model) {
      nameLabel.text = model.activityName
      goalStatusLabel.text = model.goalStatusText
      lastCompleteLabel.text = model.lastCompletedText
      streakCountLabel.text = model.streakNumber
      streakCountLabel.textColor = model.streakColor
      goalProgressView.progress = model.progressPercentage
      
      // Store the model ID and set up button handler
      currentModelId = model.id
      logQuickActionButton.onTapHandler = { [weak self] in
        guard let self = self, let activityId = self.currentModelId else { return }
        self.onQuickLogTapped?(activityId)
      }
    }

  }


}

import SwiftUI

struct ActivityCell_Preview: PreviewProvider {
  static var previews: some View {
    BaseViewRepresentable(view: ActivitiesCollection.Cell.Activity())
      .frame(width: 393, height: 55)
      .previewLayout(.fixed(width: 393, height: 55))
      .previewDisplayName("iPhone 14 Pro")
  }
}
