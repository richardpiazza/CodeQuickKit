#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))

import Foundation

public extension NSObject {
    /// Returns a probable Obj-C setter for the specified property name.
    public func setter(forPropertyName propertyName: String) -> Selector? {
        guard propertyName.lengthOfBytes(using: String.Encoding.utf8) > 0 else {
            return nil
        }
        
        let range = propertyName.startIndex..<propertyName.index(propertyName.startIndex, offsetBy: 1)
        let character = propertyName[range].uppercased()
        let setter = propertyName.replacingCharacters(in: range, with: character)
        
        return NSSelectorFromString("set\(setter):")
    }
    
    public func respondsToSetter(forPropertyName propertyName: String) -> Bool {
        guard let selector = setter(forPropertyName: propertyName) else {
            return false
        }
        
        return responds(to: selector)
    }
}

#endif
