import UIKit

/// A reusable component that combines labels, a text field, and a stepper for interval selection
public final class IntervalStepperView: UIView {
  
  // MARK: - Properties
  
  public var value: Int = 1 {
    didSet {
      textField.text = "\(value)"
      stepper.value = Double(value)
      onValueChanged?(value)
    }
  }
  
  public var minimumValue: Int = 1 {
    didSet {
      stepper.minimumValue = Double(minimumValue)
    }
  }
  
  public var maximumValue: Int = 100 {
    didSet {
      stepper.maximumValue = Double(maximumValue)
    }
  }
  
  public var prefixText: String = "Every" {
    didSet {
      prefixLabel.text = prefixText
    }
  }
  
  public var suffixText: String = "days" {
    didSet {
      suffixLabel.text = suffixText
    }
  }
  
  // MARK: - Completion Handlers
  
  public var onValueChanged: ((Int) -> Void)?
  
  // MARK: - UI Components
  
  private let containerStackView = UIStackView()
  private let labelsStackView = UIStackView()
  private let prefixLabel = UILabel()
  private let textField = UITextField()
  private let suffixLabel = UILabel()
  private let stepper = UIStepper()
  
  // MARK: - Initialization
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    setupConstraints()
    setupActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupUI() {
    // Container stack view (vertical)
    containerStackView.axis = .vertical
    containerStackView.spacing = 12
    containerStackView.alignment = .center
    
    // Labels stack view (horizontal)
    labelsStackView.axis = .horizontal
    labelsStackView.spacing = 8
    labelsStackView.alignment = .center
    
    // Prefix label
    prefixLabel.text = prefixText
    prefixLabel.font = UIFont.systemFont(ofSize: 17)
    prefixLabel.textColor = .label
    
    // Text field
    textField.text = "\(value)"
    textField.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    textField.textColor = .label
    textField.textAlignment = .center
    textField.keyboardType = .numberPad
    textField.borderStyle = .roundedRect
    textField.backgroundColor = .secondarySystemBackground
    textField.delegate = self
    
    // Set minimum content size for text field
    textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    textField.setContentCompressionResistancePriority(.required, for: .horizontal)
    
    // Suffix label
    suffixLabel.text = suffixText
    suffixLabel.font = UIFont.systemFont(ofSize: 17)
    suffixLabel.textColor = .label
    
    // Stepper
    stepper.value = Double(value)
    stepper.minimumValue = Double(minimumValue)
    stepper.maximumValue = Double(maximumValue)
    stepper.stepValue = 1
    
    // Assemble views
    labelsStackView.addArrangedSubview(prefixLabel)
    labelsStackView.addArrangedSubview(textField)
    labelsStackView.addArrangedSubview(suffixLabel)
    
    containerStackView.addArrangedSubview(labelsStackView)
    containerStackView.addArrangedSubview(stepper)
    
    addSubview(containerStackView)
  }
  
  private func setupConstraints() {
    containerStackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      // Container fills the view
      containerStackView.topAnchor.constraint(equalTo: topAnchor),
      containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      // Text field width
      textField.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
    ])
  }
  
  private func setupActions() {
    stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
    textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    
    // Add tap gesture to dismiss keyboard
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    tapGesture.cancelsTouchesInView = false
    addGestureRecognizer(tapGesture)
  }
  
  // MARK: - Actions
  
  @objc private func stepperValueChanged() {
    let newValue = Int(stepper.value)
    if newValue != value {
      value = newValue
    }
  }
  
  @objc private func textFieldEditingChanged() {
    guard let text = textField.text,
          let intValue = Int(text) else {
      return
    }
    
    // Clamp value to valid range
    let clampedValue = max(minimumValue, min(maximumValue, intValue))
    if clampedValue != value {
      value = clampedValue
    }
  }
  
  @objc private func viewTapped() {
    endEditing(true)
  }
  
  // MARK: - Public Methods
  
  public func setValue(_ newValue: Int, animated: Bool = false) {
    value = max(minimumValue, min(maximumValue, newValue))
  }
}

// MARK: - UITextFieldDelegate

extension IntervalStepperView: UITextFieldDelegate {
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // Only allow digits
    let allowedCharacters = CharacterSet.decimalDigits
    let characterSet = CharacterSet(charactersIn: string)
    return allowedCharacters.isSuperset(of: characterSet)
  }
  
  public func textFieldDidEndEditing(_ textField: UITextField) {
    // Ensure we have a valid value when editing ends
    if textField.text?.isEmpty ?? true {
      textField.text = "\(value)"
    }
  }
}