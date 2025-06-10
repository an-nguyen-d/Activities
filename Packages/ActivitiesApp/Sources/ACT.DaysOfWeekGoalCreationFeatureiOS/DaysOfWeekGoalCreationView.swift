import UIKit
import ElixirShared
import ACT_DaysOfWeekGoalCreationFeature

final class DaysOfWeekGoalCreationView: BaseView {

  // MARK: - UI Elements
  
  private let titleLabel = updateObject(UILabel()) {
    $0.text = "Days of Week Goal Creation"
    $0.font = .preferredFont(forTextStyle: .largeTitle)
    $0.textAlignment = .center
    $0.textColor = .white
  }
  
  // MARK: - Setup
  
  override func setupView() {
    super.setupView()
    backgroundColor = .systemRed // RED background for testing
  }
  
  override func setupSubviews() {
    super.setupSubviews()
    
    addSubviews(titleLabel)
    
    titleLabel.centerIn(self)
  }
}