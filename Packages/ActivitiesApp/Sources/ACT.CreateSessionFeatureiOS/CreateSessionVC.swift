import UIKit
import ElixirShared
import ComposableArchitecture
import ACT_CreateSessionFeature
import ACT_SharedModels

public final class CreateSessionVC: BaseViewController {
  
  // MARK: - Typealiases
  
  public typealias Module = CreateSessionFeature
  public typealias Dependencies = Module.Dependencies
  
  private typealias View = CreateSessionView
  private typealias State = Module.State
  private typealias ViewAction = Module.Action.ViewAction
  
  // MARK: - Properties
  
  private let contentView = View()
  private var viewStore: Store<State, ViewAction>
  private let dependencies: Dependencies
  
  // MARK: - Init
  
  public init(
    store: StoreOf<Module>,
    dependencies: Dependencies
  ) {
    self.viewStore = store.scope(
      state: \.self,
      action: \.view
    )
    self.dependencies = dependencies
    super.init()
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View
  
  public override func loadView() {
    view = contentView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupPickerDelegates()
    setupInitialState() // This creates the buttons
    bindView() // This sets up button tap handlers
    observeStore()
    
    // Set scrollview delegate for keyboard dismissal
    contentView.scrollView.delegate = self
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // Show keyboard for number input
    if case .integer = viewStore.sessionUnit {
      contentView.numberTextField.becomeFirstResponder()
    } else if case .floating = viewStore.sessionUnit {
      contentView.numberTextField.becomeFirstResponder()
    }
  }
  
  private func setupInitialState() {
    // Configure view based on unit type and pass common values from state
    contentView.configureForUnit(viewStore.sessionUnit, commonValues: viewStore.commonValues)
    
    // Set initial picker selections for time
    if case .seconds = viewStore.sessionUnit {
      contentView.hoursPicker.selectRow(0, inComponent: 0, animated: false)
      contentView.minutesPicker.selectRow(1, inComponent: 0, animated: false) // 1 minute default
      contentView.secondsPicker.selectRow(0, inComponent: 0, animated: false)
    }
  }
  
  private func setupPickerDelegates() {
    contentView.hoursPicker.dataSource = self
    contentView.hoursPicker.delegate = self
    contentView.minutesPicker.dataSource = self
    contentView.minutesPicker.delegate = self
    contentView.secondsPicker.dataSource = self
    contentView.secondsPicker.delegate = self
  }
  
  private func observeStore() {
    observe { [weak self] in
      guard let self else { return }
      
      // Update value label
      self.contentView.valueLabel.text = self.viewStore.valueLabel
      
      // Update confirm button state
      self.contentView.confirmButton.isEnabled = self.viewStore.isValid
      self.contentView.confirmButton.backgroundColor = self.viewStore.isValid ? .peterRiver : UIColor(white: 0.1, alpha: 1)
      
      // Update number field if needed
      switch self.viewStore.sessionUnit {
      case .integer:
        if let currentValue = Int(self.contentView.numberTextField.text ?? ""),
           currentValue != self.viewStore.integerValue {
          self.contentView.numberTextField.text = "\(self.viewStore.integerValue)"
        }
        self.contentView.numberStepper.value = Double(self.viewStore.integerValue)
        
      case .floating:
        if let currentValue = Double(self.contentView.numberTextField.text ?? ""),
           abs(currentValue - self.viewStore.floatingValue) > 0.001 {
          self.contentView.numberTextField.text = String(format: "%.1f", self.viewStore.floatingValue)
        }
        self.contentView.numberStepper.value = self.viewStore.floatingValue
        
      case .seconds:
        break // Handled by picker delegates
      }
    }
  }
  
  private func bindView() {
    // Number text field
    contentView.numberTextField.addTarget(self, action: #selector(numberTextFieldChanged), for: .editingChanged)
    contentView.numberTextField.delegate = self
    
    // Number stepper
    contentView.numberStepper.addTarget(self, action: #selector(numberStepperChanged), for: .valueChanged)
    
    // Buttons
    contentView.confirmButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.confirmButtonTapped)
    }
    
    contentView.cancelButton.onTapHandler = { [weak self] in
      self?.viewStore.send(.cancelButtonTapped)
    }
    
    // Common value buttons
    for button in contentView.commonValueButtons {
      button.onTapHandler = { [weak self] in
        guard let self = self else { return }
        // Extract value from tag (divided by 100 since we multiplied by 100 when storing)
        let value = Float(button.tag) / 100.0
        
        // Dismiss keyboard
        self.view.endEditing(true)
        
        // Update value based on unit type
        switch self.viewStore.sessionUnit {
        case .integer:
          self.viewStore.send(.integerValueChanged(Int(value)))
        case .floating:
          self.viewStore.send(.floatingValueChanged(Double(value)))
        case .seconds:
          // Convert seconds to hours, minutes, seconds
          let totalSeconds = Int(value)
          let hours = totalSeconds / 3600
          let minutes = (totalSeconds % 3600) / 60
          let seconds = totalSeconds % 60
          
          // Update all three pickers
          self.contentView.hoursPicker.selectRow(hours, inComponent: 0, animated: true)
          self.contentView.minutesPicker.selectRow(minutes, inComponent: 0, animated: true)
          self.contentView.secondsPicker.selectRow(seconds, inComponent: 0, animated: true)
          
          // Send actions to update the state
          self.viewStore.send(.timeHoursChanged(hours))
          self.viewStore.send(.timeMinutesChanged(minutes))
          self.viewStore.send(.timeSecondsChanged(seconds))
        }
      }
    }
    
    // Dismiss keyboard on tap
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc private func numberTextFieldChanged() {
    guard let text = contentView.numberTextField.text else { return }
    
    switch viewStore.sessionUnit {
    case .integer:
      if let value = Int(text) {
        viewStore.send(.integerValueChanged(value))
      }
    case .floating:
      if let value = Double(text) {
        viewStore.send(.floatingValueChanged(value))
      }
    case .seconds:
      break
    }
  }
  
  @objc private func numberStepperChanged() {
    switch viewStore.sessionUnit {
    case .integer:
      viewStore.send(.integerValueChanged(Int(contentView.numberStepper.value)))
    case .floating:
      viewStore.send(.floatingValueChanged(contentView.numberStepper.value))
    case .seconds:
      break
    }
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
}

// MARK: - UITextFieldDelegate

extension CreateSessionVC: UITextFieldDelegate {
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // Allow backspace
    if string.isEmpty { return true }
    
    // Get the updated text
    let currentText = textField.text ?? ""
    let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
    
    switch viewStore.sessionUnit {
    case .integer:
      // Only allow digits
      return Int(updatedText) != nil
      
    case .floating:
      // Allow digits and one decimal point
      let components = updatedText.components(separatedBy: ".")
      if components.count > 2 { return false }
      if components.count == 2 && components[1].count > 1 { return false }
      return Double(updatedText) != nil
      
    case .seconds:
      return false
    }
  }
}

// MARK: - UIPickerViewDataSource & Delegate

// MARK: - UIScrollViewDelegate

extension CreateSessionVC: UIScrollViewDelegate {
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    // Dismiss keyboard when scrolling begins
    view.endEditing(true)
  }
}

// MARK: - UIPickerViewDataSource & Delegate

extension CreateSessionVC: UIPickerViewDataSource, UIPickerViewDelegate {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView {
    case contentView.hoursPicker:
      return 24 // 0-23
    case contentView.minutesPicker, contentView.secondsPicker:
      return 60 // 0-59
    default:
      return 0
    }
  }
  
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return "\(row)"
  }
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView {
    case contentView.hoursPicker:
      viewStore.send(.timeHoursChanged(row))
    case contentView.minutesPicker:
      viewStore.send(.timeMinutesChanged(row))
    case contentView.secondsPicker:
      viewStore.send(.timeSecondsChanged(row))
    default:
      break
    }
  }
}