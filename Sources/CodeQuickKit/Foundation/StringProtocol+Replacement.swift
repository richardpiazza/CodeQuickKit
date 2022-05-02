import Foundation

public extension StringProtocol {
    /// Get a Range<String.Index> for an NSRange within the receiver
    ///
    /// - parameter range: A range within the receiver
    func indices(for range: NSRange) -> Range<String.Index> {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        return start..<end
    }

    /// Compose two strings. Useful for validating text entry in UITextFieldDelegate
    /// and UITextViewDelegate implementations.
    ///
    /// - parameter range: The range in which to replace text
    /// - parameter replacement: The replacement text
    func replacingCharacters<T>(in range: NSRange, with replacement: T) -> String where T: StringProtocol {
        let indices = self.indices(for: range)
        let newString = replacingCharacters(in: indices, with: replacement)
        return newString
    }
    
    /// Returns a new string in which the characters in a specified CharacterSet
    /// of the String are replaced by a given string.
    func replacingCharacters<T>(in characterSet: CharacterSet, with: T) -> String where T: StringProtocol {
        var output = String(self)
        
        while let range = output.rangeOfCharacter(from: characterSet) {
            output = output.replacingCharacters(in: range, with: with)
        }
        
        return output
    }
}
