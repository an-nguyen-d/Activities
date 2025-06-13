import Foundation

public enum ValueFormatting {
  
  /// Formats a numeric value based on the activity's session unit type
  public static func formatValue(_ value: Double, for sessionUnit: ActivityModel.SessionUnit) -> String {
    switch sessionUnit {
    case .integer:
      // For integer units, show as whole number
      return String(Int(value))
      
    case .floating:
      // For floating units, show decimals only if needed
      if value.truncatingRemainder(dividingBy: 1) == 0 {
        // It's a whole number, don't show decimals
        return String(Int(value))
      } else {
        // Show up to 2 decimal places, but trim trailing zeros
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ""
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
      }
      
    case .seconds:
      // For time units, always show as integer seconds
      return String(Int(value))
    }
  }
  
  /// Formats a value with its unit name
  public static func formatValueWithUnit(_ value: Double, for sessionUnit: ActivityModel.SessionUnit) -> String {
    let formattedValue = formatValue(value, for: sessionUnit)
    
    switch sessionUnit {
    case .integer(let unitName), .floating(let unitName):
      return "\(formattedValue) \(unitName)"
    case .seconds:
      // For seconds, use the time formatting utility
      return TimeFormatting.formatTimeDescription(seconds: value)
    }
  }
}