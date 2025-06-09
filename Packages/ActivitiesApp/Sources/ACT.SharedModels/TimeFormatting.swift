import Foundation

/// Utility for formatting time-related values in the Activities app
public enum TimeFormatting {
  
  /// Formats seconds into a human-readable time description
  /// Examples:
  /// - 0 seconds -> "0s"
  /// - 45 seconds -> "45s"
  /// - 90 seconds -> "1m 30s"
  /// - 3665 seconds -> "1h 1m 5s"
  /// - 7200 seconds -> "2h"
  public static func formatTimeDescription(seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let secs = totalSeconds % 60
    
    var parts: [String] = []
    if hours > 0 { parts.append("\(hours)h") }
    if minutes > 0 { parts.append("\(minutes)m") }
    if secs > 0 || parts.isEmpty { parts.append("\(secs)s") }
    
    return parts.joined(separator: " ")
  }
  
  /// Formats seconds for display with "No time selected" fallback
  /// This is useful for UI elements that need to show a placeholder
  public static func formatTimeDescriptionWithPlaceholder(seconds: Double?) -> String {
    guard let seconds = seconds, seconds > 0 else {
      return "No time selected"
    }
    return formatTimeDescription(seconds: seconds)
  }
  
  /// Formats time in traditional HH:MM:SS format
  /// Examples:
  /// - 0 seconds -> "00:00:00"
  /// - 90 seconds -> "00:01:30"
  /// - 3665 seconds -> "01:01:05"
  public static func formatTimeColonSeparated(seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let secs = totalSeconds % 60
    
    return String(format: "%02d:%02d:%02d", hours, minutes, secs)
  }
}