import UIKit

extension UIFont {

  public enum PrimaryFontWeight {
    case regular
    case bold
  }

  public func primary(ofSize size: CGFloat, weight: PrimaryFontWeight = .regular) -> UIFont {

    return .systemFont(
      ofSize: size,
      weight: {
        switch weight {
        case .regular:
          return .regular
        case .bold:
          return .bold
        }
      }()
    )
  }

}
