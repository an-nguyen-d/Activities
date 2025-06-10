import UIKit
import ComposableArchitecture

public final class TimePickerVC: UIViewController {
  
  // MARK: - Properties
  
  private let store: StoreOf<TimePickerFeature>
  
  // MARK: - Private Properties
  
  private let hoursPicker = UIPickerView()
  private let minutesPicker = UIPickerView()
  private let secondsPicker = UIPickerView()
  
  private let hoursData = Array(0...23)
  private let minutesData = Array(0...59)
  private let secondsData = Array(0...59)
  
  // MARK: - UI Components
  
  private let scrollView = UIScrollView()
  private let contentStackView = UIStackView()
  private let titleLabel = UILabel()
  private let pickersStackView = UIStackView()
  private let buttonsStackView = UIStackView()
  private let cancelButton = UIButton(type: .system)
  private let doneButton = UIButton(type: .system)
  
  // MARK: - Initialization
  
  public init(store: StoreOf<TimePickerFeature>) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupConstraints()
    setupActions()
    updatePickersFromState()
  }
  
  // MARK: - Setup
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    // Title
    titleLabel.text = "Select Time"
    titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    titleLabel.textAlignment = .center
    
    // Pickers
    hoursPicker.dataSource = self
    hoursPicker.delegate = self
    minutesPicker.dataSource = self
    minutesPicker.delegate = self
    secondsPicker.dataSource = self
    secondsPicker.delegate = self
    
    // Picker labels
    let hoursLabel = createPickerLabel("Hours")
    let minutesLabel = createPickerLabel("Minutes")
    let secondsLabel = createPickerLabel("Seconds")
    
    // Pickers stack view
    pickersStackView.axis = .horizontal
    pickersStackView.distribution = .fillEqually
    pickersStackView.spacing = 16
    
    let hoursContainer = createPickerContainer(picker: hoursPicker, label: hoursLabel)
    let minutesContainer = createPickerContainer(picker: minutesPicker, label: minutesLabel)
    let secondsContainer = createPickerContainer(picker: secondsPicker, label: secondsLabel)
    
    pickersStackView.addArrangedSubview(hoursContainer)
    pickersStackView.addArrangedSubview(minutesContainer)
    pickersStackView.addArrangedSubview(secondsContainer)
    
    // Buttons
    cancelButton.setTitle("Cancel", for: .normal)
    cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    
    doneButton.setTitle("Done", for: .normal)
    doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    
    buttonsStackView.axis = .horizontal
    buttonsStackView.distribution = .fillEqually
    buttonsStackView.spacing = 16
    buttonsStackView.addArrangedSubview(cancelButton)
    buttonsStackView.addArrangedSubview(doneButton)
    
    // Content stack view
    contentStackView.axis = .vertical
    contentStackView.spacing = 24
    contentStackView.addArrangedSubview(titleLabel)
    contentStackView.addArrangedSubview(pickersStackView)
    contentStackView.addArrangedSubview(buttonsStackView)
    
    // Scroll view
    scrollView.addSubview(contentStackView)
    view.addSubview(scrollView)
    
    // Tap gesture to dismiss keyboard (though not needed here, good practice)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }
  
  private func createPickerLabel(_ text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    label.textColor = .secondaryLabel
    return label
  }
  
  private func createPickerContainer(picker: UIPickerView, label: UILabel) -> UIStackView {
    let container = UIStackView()
    container.axis = .vertical
    container.spacing = 8
    container.addArrangedSubview(label)
    container.addArrangedSubview(picker)
    return container
  }
  
  private func setupConstraints() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentStackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      // Scroll view
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      
      // Content stack view
      contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
      contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
      contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
      contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
      contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
      
      // Picker heights
      hoursPicker.heightAnchor.constraint(equalToConstant: 150),
      minutesPicker.heightAnchor.constraint(equalToConstant: 150),
      secondsPicker.heightAnchor.constraint(equalToConstant: 150),
      
      // Buttons height
      buttonsStackView.heightAnchor.constraint(equalToConstant: 44)
    ])
  }
  
  private func setupActions() {
    cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
  }
  
  // MARK: - Private Methods
  
  private func updatePickersFromState() {
    let state = store.state
    hoursPicker.selectRow(state.hours, inComponent: 0, animated: false)
    minutesPicker.selectRow(state.minutes, inComponent: 0, animated: false)
    secondsPicker.selectRow(state.seconds, inComponent: 0, animated: false)
  }
  
  // MARK: - Actions
  
  @objc private func viewTapped() {
    view.endEditing(true)
  }
  
  @objc private func cancelTapped() {
    store.send(.cancelButtonTapped)
  }
  
  @objc private func doneTapped() {
    store.send(.saveButtonTapped)
  }
}

// MARK: - UIPickerViewDataSource

extension TimePickerVC: UIPickerViewDataSource {
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView {
    case hoursPicker: return hoursData.count
    case minutesPicker: return minutesData.count
    case secondsPicker: return secondsData.count
    default: return 0
    }
  }
}

// MARK: - UIPickerViewDelegate

extension TimePickerVC: UIPickerViewDelegate {
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch pickerView {
    case hoursPicker: return "\(hoursData[row])"
    case minutesPicker: return String(format: "%02d", minutesData[row])
    case secondsPicker: return String(format: "%02d", secondsData[row])
    default: return nil
    }
  }
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView {
    case hoursPicker:
      store.send(.hoursChanged(row))
    case minutesPicker:
      store.send(.minutesChanged(row))
    case secondsPicker:
      store.send(.secondsChanged(row))
    default:
      break
    }
  }
}