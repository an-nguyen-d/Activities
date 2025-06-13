import UIKit
import ElixirShared
import ACT_SharedUI
import ACT_SharedModels

public final class CreateSessionView: BaseView {
  
  // MARK: - Common UI Elements
  
  let scrollView = UIScrollView()
  let contentView = UIView()
  
  let titleLabel = updateObject(UILabel()) {
    $0.textColor = .View.Text.primary
    $0.font = .systemFont(ofSize: 24, weight: .bold)
    $0.textAlignment = .center
    $0.text = "Log Session"
  }
  
  let valueLabelContainer = updateObject(UIView()) {
    $0.backgroundColor = UIColor(white: 0.1, alpha: 1)
    $0.layer.cornerRadius = 12
  }
  
  let valueLabel = updateObject(UILabel()) {
    $0.textColor = .View.Text.primary
    $0.font = .systemFont(ofSize: 18, weight: .medium)
    $0.textAlignment = .center
    $0.text = "1 session completed"
  }
  
  let confirmButton = updateObject(BaseButton()) {
    $0.setTitle("Log Session", for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    $0.backgroundColor = .peterRiver
    $0.layer.cornerRadius = 12
    $0.setTitleColor(.white, for: .normal)
    $0.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
  }
  
  let cancelButton = updateObject(BaseButton()) {
    $0.setTitle("Cancel", for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
  }
  
  // MARK: - Integer/Float Input
  
  let numberInputContainer = UIView()
  
  let numberTextField = updateObject(UITextField()) {
    $0.textColor = .View.Text.primary
    $0.font = .systemFont(ofSize: 48, weight: .bold)
    $0.textAlignment = .center
    $0.keyboardType = .decimalPad
    $0.text = "1"
    $0.backgroundColor = UIColor(white: 0.1, alpha: 1)
    $0.layer.cornerRadius = 12
  }
  
  let numberStepper = updateObject(UIStepper()) {
    $0.minimumValue = 1
    $0.maximumValue = 999
    $0.value = 1
    $0.stepValue = 1
  }
  
  // Common values quick selection for number input
  let numberCommonValuesScrollView = updateObject(UIScrollView()) {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
  }
  
  let numberCommonValuesStackView = updateObject(UIStackView()) {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.alignment = .center
    $0.distribution = .fill // Changed to fill for proper button sizing
  }
  
  // Common values quick selection for time input
  let timeCommonValuesScrollView = updateObject(UIScrollView()) {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
  }
  
  let timeCommonValuesStackView = updateObject(UIStackView()) {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.alignment = .center
    $0.distribution = .fill // Changed to fill for consistency
  }
  
  // Common values passed from state
  private var commonValues: [Float] = []
  var commonValueButtons: [BaseButton] = []
  
  // MARK: - Time Input
  
  let timeInputContainer = UIView()
  
  let timeStackView = updateObject(UIStackView()) {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.spacing = 16
  }
  
  let hoursPickerContainer = UIView()
  let hoursLabel = updateObject(UILabel()) {
    $0.text = "Hours"
    $0.textColor = UIColor(white: 0.6, alpha: 1)
    $0.font = .systemFont(ofSize: 14)
    $0.textAlignment = .center
  }
  let hoursPicker = UIPickerView()
  
  let minutesPickerContainer = UIView()
  let minutesLabel = updateObject(UILabel()) {
    $0.text = "Minutes"
    $0.textColor = UIColor(white: 0.6, alpha: 1)
    $0.font = .systemFont(ofSize: 14)
    $0.textAlignment = .center
  }
  let minutesPicker = UIPickerView()
  
  let secondsPickerContainer = UIView()
  let secondsLabel = updateObject(UILabel()) {
    $0.text = "Seconds"
    $0.textColor = UIColor(white: 0.6, alpha: 1)
    $0.font = .systemFont(ofSize: 14)
    $0.textAlignment = .center
  }
  let secondsPicker = UIPickerView()
  
  // MARK: - Setup
  
  public override func setupView() {
    super.setupView()
    backgroundColor = .View.Background.primary
  }
  
  public override func setupSubviews() {
    super.setupSubviews()
    
    addSubviews(scrollView)
    scrollView.addSubviews(contentView)
    
    scrollView.anchor(
      .leading(leadingAnchor),
      .trailing(trailingAnchor),
      .top(topAnchor),
      .bottom(bottomAnchor)
    )
    
    contentView.anchor(
      .leading(scrollView.leadingAnchor),
      .trailing(scrollView.trailingAnchor),
      .top(scrollView.topAnchor),
      .bottom(scrollView.bottomAnchor)
    )
    contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    
    // Common elements
    contentView.addSubviews(
      titleLabel,
      valueLabelContainer,
      confirmButton,
      cancelButton
    )
    
    titleLabel.fillHorizontally(contentView, padding: 20)
    titleLabel.anchor(
      .top(contentView.topAnchor, constant: 20)
    )
    
    // Input containers (both added, visibility controlled by VC)
    contentView.addSubviews(
      numberInputContainer,
      timeInputContainer
    )
    
    // Number input setup
    numberInputContainer.addSubviews(
      numberTextField,
      numberStepper,
      numberCommonValuesScrollView
    )
    
    numberInputContainer.fillHorizontally(contentView, padding: 20)
    numberInputContainer.anchor(
      .top(titleLabel.bottomAnchor, constant: 40),
      .height(180) // Increased height to accommodate common values
    )
    
    numberTextField.centerXTo(numberInputContainer.centerXAnchor)
    numberTextField.anchor(
      .top(numberInputContainer.topAnchor),
      .width(200),
      .height(80)
    )
    
    numberStepper.anchor(
      .top(numberTextField.bottomAnchor, constant: 12)
    )
    numberStepper.centerXTo(numberTextField.centerXAnchor)
    
    // Number common values scrollview setup
    numberCommonValuesScrollView.anchor(
      .leading(numberInputContainer.leadingAnchor),
      .trailing(numberInputContainer.trailingAnchor),
      .top(numberStepper.bottomAnchor, constant: 16),
      .height(40)
    )
    
    numberCommonValuesScrollView.addSubviews(numberCommonValuesStackView)
    // Use content layout guide for horizontal scrolling
    numberCommonValuesStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      numberCommonValuesStackView.leadingAnchor.constraint(equalTo: numberCommonValuesScrollView.contentLayoutGuide.leadingAnchor),
      numberCommonValuesStackView.trailingAnchor.constraint(equalTo: numberCommonValuesScrollView.contentLayoutGuide.trailingAnchor),
      numberCommonValuesStackView.topAnchor.constraint(equalTo: numberCommonValuesScrollView.contentLayoutGuide.topAnchor),
      numberCommonValuesStackView.bottomAnchor.constraint(equalTo: numberCommonValuesScrollView.contentLayoutGuide.bottomAnchor),
      numberCommonValuesStackView.heightAnchor.constraint(equalTo: numberCommonValuesScrollView.frameLayoutGuide.heightAnchor)
    ])
    
    // Time input setup
    timeInputContainer.addSubviews(timeStackView, timeCommonValuesScrollView)
    
    timeInputContainer.fillHorizontally(contentView, padding: 20)
    timeInputContainer.anchor(
      .top(titleLabel.bottomAnchor, constant: 40),
      .height(320) // 260 for pickers + 16 spacing + 40 for common values + 4 padding
    )
    
    // timeStackView is already positioned correctly, no need to re-anchor here
    
    // Setup picker containers
    [hoursPickerContainer, minutesPickerContainer, secondsPickerContainer].forEach {
      timeStackView.addArrangedSubview($0)
    }
    
    // Position time stack view first
    timeStackView.anchor(
      .leading(timeInputContainer.leadingAnchor),
      .trailing(timeInputContainer.trailingAnchor),
      .top(timeInputContainer.topAnchor),
      .height(260) // Fixed height for pickers
    )
    
    // Position common values below time pickers
    timeCommonValuesScrollView.anchor(
      .leading(timeInputContainer.leadingAnchor),
      .trailing(timeInputContainer.trailingAnchor),
      .top(timeStackView.bottomAnchor, constant: 16),
      .height(40)
    )
    
    // Setup time common values stack view
    timeCommonValuesScrollView.addSubviews(timeCommonValuesStackView)
    // Use content layout guide for horizontal scrolling
    timeCommonValuesStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      timeCommonValuesStackView.leadingAnchor.constraint(equalTo: timeCommonValuesScrollView.contentLayoutGuide.leadingAnchor),
      timeCommonValuesStackView.trailingAnchor.constraint(equalTo: timeCommonValuesScrollView.contentLayoutGuide.trailingAnchor),
      timeCommonValuesStackView.topAnchor.constraint(equalTo: timeCommonValuesScrollView.contentLayoutGuide.topAnchor),
      timeCommonValuesStackView.bottomAnchor.constraint(equalTo: timeCommonValuesScrollView.contentLayoutGuide.bottomAnchor),
      timeCommonValuesStackView.heightAnchor.constraint(equalTo: timeCommonValuesScrollView.frameLayoutGuide.heightAnchor)
    ])
    
    // Hours picker
    hoursPickerContainer.addSubviews(hoursLabel, hoursPicker)
    hoursLabel.fillHorizontally(hoursPickerContainer)
    hoursLabel.anchor(
      .top(hoursPickerContainer.topAnchor),
      .height(20)
    )
    hoursPicker.fillHorizontally(hoursPickerContainer)
    hoursPicker.anchor(
      .top(hoursLabel.bottomAnchor, constant: 4),
      .bottom(hoursPickerContainer.bottomAnchor)
    )
    
    // Minutes picker
    minutesPickerContainer.addSubviews(minutesLabel, minutesPicker)
    minutesLabel.fillHorizontally(minutesPickerContainer)
    minutesLabel.anchor(
      .top(minutesPickerContainer.topAnchor),
      .height(20)
    )
    minutesPicker.fillHorizontally(minutesPickerContainer)
    minutesPicker.anchor(
      .top(minutesLabel.bottomAnchor, constant: 4),
      .bottom(minutesPickerContainer.bottomAnchor)
    )
    
    // Seconds picker
    secondsPickerContainer.addSubviews(secondsLabel, secondsPicker)
    secondsLabel.fillHorizontally(secondsPickerContainer)
    secondsLabel.anchor(
      .top(secondsPickerContainer.topAnchor),
      .height(20)
    )
    secondsPicker.fillHorizontally(secondsPickerContainer)
    secondsPicker.anchor(
      .top(secondsLabel.bottomAnchor, constant: 4),
      .bottom(secondsPickerContainer.bottomAnchor)
    )
    
    // Value label - positioned after time input container since it's the larger one
    valueLabelContainer.addSubviews(valueLabel)
    valueLabelContainer.fillHorizontally(contentView, padding: 20)
    valueLabelContainer.anchor(
      .top(timeInputContainer.bottomAnchor, constant: 40),
      .height(60)
    )
    
    valueLabel.anchor(
      .leading(valueLabelContainer.leadingAnchor, constant: 16),
      .trailing(valueLabelContainer.trailingAnchor, constant: -16),
      .top(valueLabelContainer.topAnchor, constant: 16),
      .bottom(valueLabelContainer.bottomAnchor, constant: -16)
    )
    
    // Buttons
    confirmButton.fillHorizontally(contentView, padding: 20)
    confirmButton.anchor(
      .top(valueLabelContainer.bottomAnchor, constant: 40),
      .height(50)
    )
    
    cancelButton.anchor(
      .top(confirmButton.bottomAnchor, constant: 12),
      .bottom(contentView.bottomAnchor, constant: -20)
    )
    cancelButton.centerXTo(contentView.centerXAnchor)
  }
  
  func configureForUnit(_ unit: ActivityModel.SessionUnit, commonValues: [Float]) {
    self.commonValues = commonValues
    
    switch unit {
    case .integer, .floating:
      numberInputContainer.isHidden = false
      timeInputContainer.isHidden = true
      
      if case .floating = unit {
        numberTextField.keyboardType = .decimalPad
        numberStepper.stepValue = 0.1
      } else {
        numberTextField.keyboardType = .numberPad
        numberStepper.stepValue = 1
      }
      
    case .seconds:
      numberInputContainer.isHidden = true
      timeInputContainer.isHidden = false
    }
    
    // Update common value buttons for the unit type
    setupCommonValueButtons(for: unit)
  }
  
  private func setupCommonValueButtons(for unit: ActivityModel.SessionUnit? = nil) {
    // Clear existing buttons
    commonValueButtons.forEach { $0.removeFromSuperview() }
    commonValueButtons.removeAll()
    
    // Determine which stack view to use
    let stackView: UIStackView
    switch unit {
    case .integer, .floating:
      stackView = numberCommonValuesStackView
    case .seconds:
      stackView = timeCommonValuesStackView
    case .none:
      return // No unit specified, don't create buttons
    }
    
    // Create buttons for each common value
    for value in commonValues {
      let button = updateObject(BaseButton()) {
        // Format the title based on unit type
        let title: String
        switch unit {
        case .integer:
          title = String(Int(value))
        case .floating:
          title = ValueFormatting.formatValue(Double(value), for: unit!)
        case .seconds:
          title = TimeFormatting.formatTimeDescription(seconds: Double(value))
        case .none:
          title = "" // Won't reach here due to guard above
        }
        
        $0.setTitle(title, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        $0.layer.cornerRadius = 16
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        $0.tag = Int(value * 100) // Store value as tag (multiplied to preserve decimals)
        // Ensure button has intrinsic content size
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
      }
      
      commonValueButtons.append(button)
      stackView.addArrangedSubview(button)
    }
  }
}
