import UIKit

/// Protocol for presenting the time picker in a consistent way across the app
@MainActor
public protocol TimePickerPresenting: AnyObject {
  func presentTimePicker(
    from viewController: UIViewController,
    initialTimeInSeconds: Double,
    onTimeSelected: @escaping (Double) -> Void
  )
}

// MARK: - Default Implementation

public extension TimePickerPresenting {
  @MainActor
  func presentTimePicker(
    from viewController: UIViewController,
    initialTimeInSeconds: Double,
    onTimeSelected: @escaping (Double) -> Void
  ) {
    let timePickerVC = TimePickerVC()
    timePickerVC.initialTimeInSeconds = initialTimeInSeconds
    
    timePickerVC.onTimeSelected = { [weak viewController] timeInSeconds in
      onTimeSelected(timeInSeconds)
      viewController?.dismiss(animated: true)
    }
    
    timePickerVC.onCancel = { [weak viewController] in
      viewController?.dismiss(animated: true)
    }
    
    let navigationController = UINavigationController(rootViewController: timePickerVC)
    viewController.present(navigationController, animated: true)
  }
}