import Foundation

public extension StringProtocol {
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
