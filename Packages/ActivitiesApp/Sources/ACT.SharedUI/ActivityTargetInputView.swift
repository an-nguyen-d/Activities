import UIKit
import ElixirShared
import XCTestDynamicOverlay
import ACT_SharedModels

public final class ActivityTargetInputView: BaseView {
  
  // MARK: - Public Properties
  
  public var unitType: SessionUnitType = .integer {
    didSet { updateForUnitType() }
  }
  
  public var showClearButton: Bool = false {
    didSet { clearButton.isHidden = !showClearButton }
  }
  
  
  // MARK: - Completion Handlers
  
  public var onTargetValueChanged: ((Double?) -> Void)?
  public var onTargetTextChanged: ((String) -> Void)? // For better float input UX
  public var onSuccessCriteriaChanged: ((GoalSuccessCriteria?) -> Void)?
  public var onClearTapped: (() -> Void)?
  public var onTimeEditTapped: (() -> Void)?
  
  // MARK: - Private UI Components
  
  private let titleLabel = updateObject(UILabel()) {
    $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    $0.textColor = .label
  }
  
  private let successCriteriaSegmentedControl = updateObject(UISegmentedControl(items: ["At Least", "Exactly", "Less Than"])) {
    $0.selectedSegmentIndex = UISegmentedControl.noSegment // No default selection
  }
  
  private let clearButton = updateObject(UIButton(type: .system)) {
    $0.setTitle("Clear", for: .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    $0.isHidden = true // Hidden by default
  }
  
  // Value input views
  private let integerTextField = updateObject(UITextField()) {
    $0.borderStyle = .roundedRect
    $0.keyboardType = .numberPad
    $0.placeholder = "0"
  }
  
  private let integerStepper = updateObject(UIStepper()) {
    $0.minimumValue = 0
    $0.maximumValue = 9999
    $0.stepValue = 1
  }
  
  private let floatingTextField = updateObject(UITextField()) {
    $0.borderStyle = .roundedRect
    $0.keyboardType = .numbersAndPunctuation
    $0.placeholder = "0.0"
  }
  
  private let floatingStepper = updateObject(UIStepper()) {
    $0.minimumValue = 0
    $0.maximumValue = 9999
    $0.stepValue = 1.0
  }
  
  private let timeLabel = updateObject(UILabel()) {
    $0.text = "00:00:00"
    $0.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
    $0.textColor = .label
  }
  
  private let timeEditButton = updateObject(UIButton(type: .system)) {
    $0.setTitle("Edit", for: .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
  }
  
  private let stackView = updateObject(UIStackView()) {
    $0.axis = .vertical
    $0.spacing = 12
    $0.alignment = .fill
  }
  
  private let valueInputStackView = updateObject(UIStackView()) {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let integerStackView = updateObject(UIStackView()) {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.alignment = .center
  }
  
  private let floatingStackView = updateObject(UIStackView()) {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.alignment = .center
  }
  
  private let timeStackView = updateObject(UIStackView()) {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.alignment = .center
  }
  
  // MARK: - Setup
  
  public override func setupView() {
    super.setupView()
    
    // Add target actions
    successCriteriaSegmentedControl.addTarget(self, action: #selector(successCriteriaChanged), for: .valueChanged)
    clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
    
    integerTextField.addTarget(self, action: #selector(integerTextFieldChanged), for: .editingChanged)
    integerStepper.addTarget(self, action: #selector(integerStepperChanged), for: .valueChanged)
    
    floatingTextField.addTarget(self, action: #selector(floatingTextFieldChanged), for: .editingChanged)
    floatingStepper.addTarget(self, action: #selector(floatingStepperChanged), for: .valueChanged)
    
    timeEditButton.addTarget(self, action: #selector(timeEditTapped), for: .touchUpInside)
  }
  
  public override func setupSubviews() {
    super.setupSubviews()
    
    // Add to stack views
    integerStackView.addArrangedSubview(integerTextField)
    integerStackView.addArrangedSubview(integerStepper)
    
    floatingStackView.addArrangedSubview(floatingTextField)
    floatingStackView.addArrangedSubview(floatingStepper)
    
    timeStackView.addArrangedSubview(timeLabel)
    timeStackView.addArrangedSubview(timeEditButton)
    
    valueInputStackView.addArrangedSubview(integerStackView)
    valueInputStackView.addArrangedSubview(floatingStackView)
    valueInputStackView.addArrangedSubview(timeStackView)
    
    let headerStackView = updateObject(UIStackView()) {
      $0.axis = .horizontal
      $0.alignment = .center
    }
    headerStackView.addArrangedSubview(titleLabel)
    headerStackView.addArrangedSubview(UIView()) // Spacer
    headerStackView.addArrangedSubview(clearButton)
    
    stackView.addArrangedSubview(headerStackView)
    stackView.addArrangedSubview(successCriteriaSegmentedControl)
    stackView.addArrangedSubview(valueInputStackView)
    
    addSubview(stackView)
    
    // Setup constraints
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      integerTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
      floatingTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
    ])
    
    updateForUnitType()
  }
  
  // MARK: - Public Methods
  
  public func setTitle(_ title: String) {
    titleLabel.text = title
  }
  
  // MARK: - Private Methods
  
  private func updateForUnitType() {
    integerStackView.isHidden = unitType != .integer
    floatingStackView.isHidden = unitType != .floating
    timeStackView.isHidden = unitType != .time
  }
  
  public func setValue(_ value: Double?) {
    guard let value = value else {
      // Clear value inputs
      integerTextField.text = ""
      integerStepper.value = 0
      floatingTextField.text = ""
      floatingStepper.value = 0
      timeLabel.text = TimeFormatting.formatTimeDescriptionWithPlaceholder(seconds: nil)
      return
    }
    
    switch unitType {
    case .integer:
      let intValue = Int(value)
      integerTextField.text = "\(intValue)"
      integerStepper.value = value
    case .floating:
      // Don't reformat float text if user is typing
      if !floatingTextField.isFirstResponder {
        floatingTextField.text = "\(value)"
      }
      floatingStepper.value = value
    case .time:
      timeLabel.text = TimeFormatting.formatTimeDescriptionWithPlaceholder(seconds: value)
    }
  }
  
  public func setSuccessCriteria(_ criteria: GoalSuccessCriteria?) {
    guard let criteria = criteria else {
      successCriteriaSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
      return
    }
    
    switch criteria {
    case .atLeast:
      successCriteriaSegmentedControl.selectedSegmentIndex = 0
    case .exactly:
      successCriteriaSegmentedControl.selectedSegmentIndex = 1
    case .lessThan:
      successCriteriaSegmentedControl.selectedSegmentIndex = 2
    }
  }
  
  private func getCurrentSuccessCriteria() -> GoalSuccessCriteria? {
    switch successCriteriaSegmentedControl.selectedSegmentIndex {
    case 0: return .atLeast
    case 1: return .exactly
    case 2: return .lessThan
    default: return nil
    }
  }
  
  private func getCurrentValue() -> Double? {
    switch unitType {
    case .integer:
      guard let text = integerTextField.text, !text.isEmpty else { return nil }
      return Double(text)
    case .floating:
      guard let text = floatingTextField.text, !text.isEmpty else { return nil }
      return Double(text)
    case .time:
      // For time, the value should be updated externally via the target property
      // We don't track it internally since it's edited via a modal
      return nil
    }
  }
  
  // MARK: - Actions
  
  @objc private func successCriteriaChanged() {
    let criteria = getCurrentSuccessCriteria()
    onSuccessCriteriaChanged?(criteria)
  }
  
  @objc private func clearTapped() {
    successCriteriaSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
    integerTextField.text = ""
    integerStepper.value = 0
    floatingTextField.text = ""
    floatingStepper.value = 0
    timeLabel.text = TimeFormatting.formatTimeDescriptionWithPlaceholder(seconds: nil)
    onClearTapped?()
  }
  
  @objc private func integerTextFieldChanged() {
    if let text = integerTextField.text, let value = Double(text) {
      integerStepper.value = value
    }
    let currentValue = getCurrentValue()
    onTargetValueChanged?(currentValue)
  }
  
  @objc private func integerStepperChanged() {
    let value = Int(integerStepper.value)
    integerTextField.text = "\(value)"
    let currentValue = getCurrentValue()
    onTargetValueChanged?(currentValue)
  }
  
  @objc private func floatingTextFieldChanged() {
    let text = floatingTextField.text ?? ""
    
    // Notify about text change for better UX
    if unitType == .floating {
      onTargetTextChanged?(text)
    }
    
    // Update stepper only if valid number
    if let value = Double(text) {
      floatingStepper.value = value
      onTargetValueChanged?(value)
    } else if text.isEmpty {
      onTargetValueChanged?(nil)
    }
  }
  
  @objc private func floatingStepperChanged() {
    floatingTextField.text = "\(floatingStepper.value)"
    let currentValue = getCurrentValue()
    onTargetValueChanged?(currentValue)
  }
  
  @objc private func timeEditTapped() {
    onTimeEditTapped?()
  }
}