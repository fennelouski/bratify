import UIKit

extension UILabel {
    static var dynamicTypeLabel: UILabel {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        // Default font styles that respect dynamic type
        let preferredFont = UIFont.preferredFont(forTextStyle: .body)
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: preferredFont)
        
        // Optionally, you can also set a default text style and its associated font
        label.textStyle = .body
        
        return label
    }
    
    // Optionally add a property to set text style for easier configuration
    var textStyle: UIFont.TextStyle {
        get {
            return self.font.textStyle ?? .body
        }
        set {
            let preferredFont = UIFont.preferredFont(forTextStyle: newValue)
            self.font = UIFontMetrics(forTextStyle: newValue).scaledFont(for: preferredFont)
        }
    }
}

extension UIFont {
    // Helper to get text style from font descriptor
    var textStyle: UIFont.TextStyle? {
        guard let textStyle = fontDescriptor.object(forKey: .textStyle) as? UIFont.TextStyle else {
            return nil
        }
        return textStyle
    }
}
