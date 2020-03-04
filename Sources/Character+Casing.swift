import Foundation

public extension Character {
    /// Determins if the instance is contained within the `uppercaseLetters` `CharacterSet`.
    var isUppercased: Bool {
        guard let unicodeScalar = unicodeScalars.first else {
            return false
        }
        
        return CharacterSet.uppercaseLetters.contains(unicodeScalar)
    }
}
