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
      numberStepper
    )
    
    numberInputContainer.fillHorizontally(contentView, padding: 20)
    numberInputContainer.anchor(
      .top(titleLabel.bottomAnchor, constant: 40),
      .height(120)
    )
    
    numberTextField.centerIn(numberInputContainer)
    numberTextField.anchor(
      .width(200),
      .height(80)
    )
    
    numberStepper.anchor(
      .top(numberTextField.bottomAnchor, constant: 12)
    )
    numberStepper.centerXTo(numberTextField.centerXAnchor)
    
    // Time input setup
    timeInputContainer.addSubviews(timeStackView)
    
    timeInputContainer.fillHorizontally(contentView, padding: 20)
    timeInputContainer.anchor(
      .top(titleLabel.bottomAnchor, constant: 40),
      .height(260)
    )
    
    timeStackView.anchor(
      .leading(timeInputContainer.leadingAnchor),
      .trailing(timeInputContainer.trailingAnchor),
      .top(timeInputContainer.topAnchor),
      .bottom(timeInputContainer.bottomAnchor)
    )
    
    // Setup picker containers
    [hoursPickerContainer, minutesPickerContainer, secondsPickerContainer].forEach {
      timeStackView.addArrangedSubview($0)
    }
    
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
  
  func configureForUnit(_ unit: ActivityModel.SessionUnit) {
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
  }
}