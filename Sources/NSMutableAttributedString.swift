import Foundation
#if canImport(UIKit)
import UIKit

#if swift(>=4.2)
public extension NSMutableAttributedString {
    /// Appends a plain `String` with the given parameters
    /// - parameter string: The `String` to append to the instance.
    /// - parameter textStyle: The preferred UIFont.TextStyle used to create the Font.
    /// - parameter scale: Multiplier to apply to the `textStyle` 'pointSize'.
    /// - parameter attributes: Additional attributes that should apply to the given `string`.
    /// - parameter traits: Traits that should be applied to the created Font.
    ///
    /// - note: If a NSAttributeString.Key.font is specified in the attributes, the requested
    ///         font will be used in place of one created from the provided `textStyle` and
    ///         `traits.
    public func append(_ string: String, textStyle: UIFont.TextStyle = .body, scale: CGFloat = 1.0, attributes: [NSAttributedString.Key : Any] = [:], traits: UIFontDescriptor.SymbolicTraits? = nil) {
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

#else
public extension NSMutableAttributedString {
/// Appends a plain `String` with the given parameters
/// - parameter string: The `String` to append to the instance.
/// - parameter textStyle: The preferred UIFontTextStyle used to create the Font.
/// - parameter scale: Multiplier to apply to the `textStyle` 'pointSize'.
/// - parameter attributes: Additional attributes that should apply to the given `string`.
/// - parameter traits: Traits that should be applied to the created Font.
///
/// - note: If a NSAttributeString.Key.font is specified in the attributes, the requested
///         font will be used in place of one created from the provided `textStyle` and
///         `traits.
public func append(_ string: String, textStyle: UIFontTextStyle = .body, scale: CGFloat = 1.0, attributes: [NSAttributedStringKey : Any] = [:], traits: UIFontDescriptorSymbolicTraits? = nil) {
let font = UIFont.preferredFont(forTextStyle: textStyle)
let size = font.pointSize * scale

let outputFont: UIFont
if let traits = traits, let fontDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
outputFont = UIFont(descriptor: fontDescriptor, size: size)
} else {
outputFont = UIFont(descriptor: font.fontDescriptor, size: size)
}

var fontAttributes: [NSAttributedStringKey : Any] = attributes
if !fontAttributes.keys.contains(.font) {
fontAttributes[.font] = outputFont
}

let attributedString = NSAttributedString(string: string, attributes: attributes)

self.append(attributedString)
}
}
#endif

#if swift(>=4.2)
public extension NSMutableAttributedString {
    public func appendPlain(_ string: String, textStyle: UIFont.TextStyle = .body, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor : color]
        self.append(string, textStyle: textStyle, attributes: attributes)
    }
    
    public func appendBold(_ string: String, textStyle: UIFont.TextStyle = .body, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor : color]
        self.append(string, textStyle: textStyle, attributes: attributes, traits: .traitBold)
    }
    
    public func appendItalic(_ string: String, textStyle: UIFont.TextStyle = .body, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor : color]
        self.append(string, textStyle: textStyle, attributes: attributes, traits: .traitItalic)
    }
    
    public func appendBoldItalic(_ string: String, textStyle: UIFont.TextStyle = .body, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor : color]
        let traits = UIFontDescriptor.SymbolicTraits(arrayLiteral: [.traitBold, .traitItalic])
        self.append(string, textStyle: textStyle, attributes: attributes, traits: traits)
    }
}
#endif

#endif
