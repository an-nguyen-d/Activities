import UIKit
import ElixirShared
import ACT_EveryXDaysGoalCreationFeature

final class EveryXDaysGoalCreationView: BaseView {

  // MARK: - UI Elements
  
  private let titleLabel = updateObject(UILabel()) {
    $0.text = "Every X Days Goal Creation"
    $0.font = .preferredFont(forTextStyle: .largeTitle)
    $0.textAlignment = .center
    $0.textColor = .white
  }
  
  // MARK: - Setup
  
  override func setupView() {
    super.setupView()
    backgroundColor = .systemGreen // GREEN background for testing
  }
  
  override func setupSubviews() {
    super.setupSubviews()
    
    addSubviews(titleLabel)
    
    titleLabel.centerIn(self)
  }
}