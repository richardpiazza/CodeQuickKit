#if canImport(UIKit)
import UIKit

public extension NSMutableAttributedString {
    /// Appends a plain `String` with the given parameters
    /// - parameter string: The `String` appended to the instance.
    /// - parameter textStyle: The preferred UIFont.TextStyle used to create the Font.
    /// - parameter scale: Multiplier to apply to the `textStyle` 'pointSize'.
    /// - parameter attributes: Additional attributes that should apply to the given `string`.
    /// - parameter traits: Traits that should be applied to the created Font.
    ///
    /// - note: If a NSAttributeString.Key.font is specified in the attributes, the requested
    ///         font will be used in place of one created from the provided `textStyle` and
    ///         `traits.
    func append(_ string: String, textStyle: UIFont.TextStyle = .body, scale: CGFloat = 1.0, attributes: [NSAttributedString.Key : Any] = [:], traits: UIFontDescriptor.SymbolicTraits? = nil) {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle)
        let size = preferredFont.pointSize * scale
        
        let font: UIFont
        if let traits = traits, let fontDescriptor = preferredFont.fontDescriptor.withSymbolicTraits(traits) {
            font = UIFont(descriptor: fontDescriptor, size: size)
        } else {
            font = UIFont(descriptor: preferredFont.fontDescriptor, size: size)
        }
        
        var fontAttributes: [NSAttributedString.Key : Any] = attributes
        if !fontAttributes.keys.contains(.font) {
            fontAttributes[.font] = font
        }
        
        let attributedString = NSAttributedString(string: string, attributes: fontAttributes)
        
        self.append(attributedString)
    }
}

public extension NSMutableAttributedString {
    func appendPlain(_ string: String, textStyle: UIFont.TextStyle = .body, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor : color]
        self.append(string, textStyle: textStyle, attributes: attributes)
    }
    
    func appendBold(_ string: String, textStyle: UIFont.TextStyle = .body, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor : color]
        self.append(string, textStyle: textStyle, attributes: attributes, traits: .traitBold)
    }
    
    func appendItalic(_ string: String, textStyle: UIFont.TextStyle = .body, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor : color]
        self.append(string, textStyle: textStyle, attributes: attributes, traits: .traitItalic)
    }
    
    func appendBoldItalic(_ string: String, textStyle: UIFont.TextStyle = .body, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor : color]
        let traits = UIFontDescriptor.SymbolicTraits(arrayLiteral: [.traitBold, .traitItalic])
        self.append(string, textStyle: textStyle, attributes: attributes, traits: traits)
    }
}
#endif
