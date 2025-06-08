import UIKit
import ElixirShared
import ACT_WeeksPeriodGoalCreationFeature

final class WeeksPeriodGoalCreationView: BaseView {

  // MARK: - UI Elements
  
  private let titleLabel = updateObject(UILabel()) {
    $0.text = "Weeks Period Goal Creation"
    $0.font = .preferredFont(forTextStyle: .largeTitle)
    $0.textAlignment = .center
    $0.textColor = .white
  }
  
  // MARK: - Setup
  
  override func setupView() {
    super.setupView()
    backgroundColor = .systemBlue // BLUE background for testing
  }
  
  override func setupSubviews() {
    super.setupSubviews()
    
    addSubviews(titleLabel)
    
    titleLabel.centerIn(self)
  }
}