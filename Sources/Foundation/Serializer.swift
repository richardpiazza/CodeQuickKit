//===----------------------------------------------------------------------===//
//
// Serializer.swift
//
// Copyright (c) 2016 Richard Piazza
// https://github.com/richardpiazza/CodeQuickKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//===----------------------------------------------------------------------===//

import Foundation

/// Casing styles for `Serializable` object properties. (Default .MatchCase)
public enum SerializerKeyStyle {
    case matchCase
    case titleCase
    case camelCase
    case upperCase
    case lowerCase
}

/// Redirects that should be applied to all objects during the de/serialization process.
public typealias SerializerRedirect = (propertyName: String, serializedKey: String)

/// A collection of methods and properties the aid in the de/serializtion process.
open class Serializer {
    open static var propertyKeyStyle: SerializerKeyStyle = .matchCase
    open static var serializedKeyStyle: SerializerKeyStyle = .matchCase
    open static var dateFormatter: DateFormatter = DateFormatter.rfc1123DateFormatter
    open static var keyRedirects: [SerializerRedirect] = [SerializerRedirect]()
    
    /// Returns the properly cased property name for the given serialized key.
    open static func propertyName(forSerializedKey serializedKey: String) -> String? {
        for (p, s) in keyRedirects {
            if s == serializedKey {
                return p
            }
        }
        
        return stringByApplyingKeyStyle(propertyKeyStyle, forString: serializedKey)
    }
    
    /// Returns the properly cased serialized key for the given property name.
    open static func serializedKey(forPropertyName propertyName: String) -> String? {
        for (p, s) in keyRedirects {
            if p == propertyName {
                return s
            }
        }
        
        return stringByApplyingKeyStyle(serializedKeyStyle, forString: propertyName)
    }
    
    /// Transforms common JSON string values into corresponding `NSObject`'s
    open static func initializedObject(forPropertyName propertyName: String, ofClass: AnyClass, withData data: NSObject?) -> NSObject? {
        guard let d = data else {
            return nil
        }
        
        if let s = d as? String {
            let propertyClass: AnyClass = classForPropertyName(propertyName, ofClass: ofClass)
            
            switch propertyClass {
            case is UUID.Type: return UUID(uuidString: s) as NSObject?
            case is Date.Type: return dateFormatter.date(from: s) as NSObject?
            case is URL.Type: return URL(string: s) as NSObject?
            default: break
            }
        }
        
        return d
    }
    
    /// Transforms `NSObject`'s not handled by NSJSONSerialization into string serializable values.
    open static func serializedObject(forPropertyName propertyName: String, withData data: NSObject?) -> NSObject? {
        guard let d = data else {
            return nil
        }
        
        switch type(of: d) {
        case is UUID.Type:
            if let uuid = d as? UUID {
                return uuid.uuidString as NSObject?
            }
            break
        case is Date.Type:
            if let date = d as? Date {
                return dateFormatter.string(from: date) as NSObject?
            }
            break
        case is URL.Type:
            if let url = d as? URL {
                return url.absoluteString as NSObject?
            }
            break
        default: break
        }
        
        return d
    }
    
    /// Lists all property names for an object of the provided class.
    open static func propertyNamesForClass(_ objectClass: AnyClass) -> [String] {
        var properties: [String] = [String]()
        
        if let sc = objectClass.superclass() , (sc != SerializableObject.self && sc != NSObject.self) {
            properties.append(contentsOf: self.propertyNamesForClass(sc))
        }
        
        var propertyListCount: CUnsignedInt = 0
        let runtimeProperties = class_copyPropertyList(objectClass, &propertyListCount)
        
        for index in 0..<Int(propertyListCount) {
            let runtimeProperty = runtimeProperties?[index]
            let runtimeName = property_getName(runtimeProperty)
            let propertyName = NSString(utf8String: runtimeName!)
            guard var property = propertyName else {
                continue
            }
            if property.hasPrefix("Optional") {
                property = property.substring(with: NSMakeRange(8, property.length - 1)) as NSString
            }
            let propertyString = String(property)
            if !properties.contains(propertyString) {
                properties.append(propertyString)
            }
        }
        
        free(runtimeProperties)
        
        return properties
    }
    
    /// Provides the class for a property with the given name.
    /// Will return NSNull class if property name not found/valid or not an NSObject subclass.
    open static func classForPropertyName(_ propertyName: String, ofClass objectClass: AnyClass) -> AnyClass {
        let runtimeProperty = class_getProperty(objectClass, (propertyName as NSString).utf8String)
        guard runtimeProperty != nil else {
            return NSNull.self
        }
        
        let runtimeAttributes = property_getAttributes(runtimeProperty)
        let propertyAttributesString = NSString(utf8String: runtimeAttributes!)
        let propertyAttributesCollection = propertyAttributesString?.components(separatedBy: ",")
        guard let attributesCollection = propertyAttributesCollection , attributesCollection.count > 0 else {
            return NSNull.self
        }
        
        let propertyClassAttribute = attributesCollection[0]
        if (propertyClassAttribute as NSString).length == 2 {
            let type = (propertyClassAttribute as NSString).substring(from: 1)
            switch type {
            case "q": return NSNumber.self // Swift Int
            case "d": return NSNumber.self // Swift Double
            case "f": return NSNumber.self // Swift Float
            case "B": return NSNumber.self // Swift Bool
            case "@": return NSObject.self
            default: return NSObject.self
            }
        }
        
        let propertyClass = (propertyClassAttribute as NSString).substring(from: 1)
        let className = (propertyClass as NSString).substring(with: NSMakeRange(2, (propertyClass as NSString).length - 3))
        guard let anyclass = NSClassFromString(className) else {
            return NSNull.self
        }
        
        return anyclass.self
    }
    
    open static func stringByRemovingPrettyJSONFormatting(forString jsonString: String) -> String {
        let string: NSMutableString = NSMutableString(string: jsonString)
        string.replaceOccurrences(of: "\n", with: "", options: .caseInsensitive, range: NSMakeRange(0, string.length))
        string.replaceOccurrences(of: " : ", with: ":", options: .caseInsensitive, range: NSMakeRange(0, string.length))
        string.replaceOccurrences(of: "  ", with: "", options: .caseInsensitive, range: NSMakeRange(0, string.length))
        string.replaceOccurrences(of: "\\/", with: "/", options: .caseInsensitive, range: NSMakeRange(0, string.length))
        return string as String
    }
    
    open static func stringByApplyingKeyStyle(_ keyStyle: SerializerKeyStyle, forString string: String) -> String {
        guard string.lengthOfBytes(using: String.Encoding.utf8) <= 1 else {
            return string
        }
        
        switch (keyStyle) {
        case .titleCase:
            let range: Range = string.startIndex..<string.characters.index(string.startIndex, offsetBy: 1)
            let sub = string.substring(with: range).uppercased()
            return string.replacingCharacters(in: range, with: sub)
        case .camelCase:
            let range: Range = string.startIndex..<string.characters.index(string.startIndex, offsetBy: 1)
            let sub = string.substring(with: range).lowercased()
            return string.replacingCharacters(in: range, with: sub)
        case .upperCase: return string.uppercased()
        case .lowerCase: return string.lowercased()
        default: return string
        }
    }
}
