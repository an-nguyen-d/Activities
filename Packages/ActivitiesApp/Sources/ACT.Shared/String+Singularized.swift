import Foundation

public extension String {
  /// Simple singularization for converting plural unit names to singular
  /// Examples: "minutes" → "minute", "days" → "day", "entries" → "entry"
  func singularized() -> String {
    // Handle words ending in "ies" (e.g., "entries" → "entry")
    if self.hasSuffix("ies") {
      return String(self.dropLast(3)) + "y"
    }
    // Handle words ending in "es" but not "ses" (e.g., "boxes" → "box")
    else if self.hasSuffix("es") && !self.hasSuffix("ses") {
      return String(self.dropLast(2))
    }
    // Handle words ending in "s" but not "ss" (e.g., "minutes" → "minute")
    else if self.hasSuffix("s") && !self.hasSuffix("ss") {
      return String(self.dropLast())
    }
    // Return unchanged if no rule applies
    return self
  }
}