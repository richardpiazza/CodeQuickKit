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
    case MatchCase
    case TitleCase
    case CamelCase
    case UpperCase
    case LowerCase
}

/// Redirects that should be applied to all objects during the de/serialization process.
public typealias SerializerRedirect = (propertyName: String, serializedKey: String)

/// A collection of methods and properties the aid in the de/serializtion process.
public class Serializer {
    public static var propertyKeyStyle: SerializerKeyStyle = .MatchCase
    public static var serializedKeyStyle: SerializerKeyStyle = .MatchCase
    public static var dateFormatter: NSDateFormatter = NSDateFormatter.rfc1123DateFormatter()
    public static var keyRedirects: [SerializerRedirect] = [SerializerRedirect]()
    
    /// Returns the properly cased property name for the given serialized key.
    public static func propertyName(forSerializedKey serializedKey: String) -> String? {
        for (p, s) in keyRedirects {
            if s == serializedKey {
                return p
            }
        }
        
        return stringByApplyingKeyStyle(propertyKeyStyle, forString: serializedKey)
    }
    
    /// Returns the properly cased serialized key for the given property name.
    public static func serializedKey(forPropertyName propertyName: String) -> String? {
        for (p, s) in keyRedirects {
            if p == propertyName {
                return s
            }
        }
        
        return stringByApplyingKeyStyle(serializedKeyStyle, forString: propertyName)
    }
    
    /// Transforms common JSON string values into corresponding `NSObject`'s
    public static func initializedObject(forPropertyName propertyName: String, ofClass: AnyClass, withData data: NSObject?) -> NSObject? {
        guard let d = data else {
            return nil
        }
        
        if let s = d as? String {
            let propertyClass: AnyClass = classForPropertyName(propertyName, ofClass: ofClass)
            
            switch propertyClass {
            case is NSUUID.Type: return NSUUID(UUIDString: s)
            case is NSDate.Type: return dateFormatter.dateFromString(s)
            case is NSURL.Type: return NSURL(string: s)
            default: break
            }
        }
        
        return d
    }
    
    /// Transforms `NSObject`'s not handled by NSJSONSerialization into string serializable values.
    public static func serializedObject(forPropertyName propertyName: String, withData data: NSObject?) -> NSObject? {
        guard let d = data else {
            return nil
        }
        
        switch d.dynamicType {
        case is NSUUID.Type:
            if let uuid = d as? NSUUID {
                return uuid.UUIDString
            }
            break
        case is NSDate.Type:
            if let date = d as? NSDate {
                return dateFormatter.stringFromDate(date)
            }
            break
        case is NSURL.Type:
            if let url = d as? NSURL {
                return url.absoluteString
            }
            break
        default: break
        }
        
        return d
    }
    
    /// Lists all property names for an object of the provided class.
    public static func propertyNamesForClass(objectClass: AnyClass) -> [String] {
        var properties: [String] = [String]()
        
        if let sc = objectClass.superclass() where (sc != SerializableObject.self && sc != NSObject.self) {
            properties.appendContentsOf(self.propertyNamesForClass(sc))
        }
        
        var propertyListCount: CUnsignedInt = 0
        let runtimeProperties = class_copyPropertyList(objectClass, &propertyListCount)
        
        for index in 0..<Int(propertyListCount) {
            let runtimeProperty = runtimeProperties[index]
            let runtimeName = property_getName(runtimeProperty)
            let propertyName = NSString(UTF8String: runtimeName)
            guard var property = propertyName else {
                continue
            }
            if property.hasPrefix("Optional") {
                property = property.substringWithRange(NSMakeRange(8, property.length - 1))
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
    public static func classForPropertyName(propertyName: String, ofClass objectClass: AnyClass) -> AnyClass {
        let runtimeProperty = class_getProperty(objectClass, (propertyName as NSString).UTF8String)
        guard runtimeProperty != nil else {
            return NSNull.self
        }
        
        let runtimeAttributes = property_getAttributes(runtimeProperty)
        let propertyAttributesString = NSString(UTF8String: runtimeAttributes)
        let propertyAttributesCollection = propertyAttributesString?.componentsSeparatedByString(",")
        guard let attributesCollection = propertyAttributesCollection where attributesCollection.count > 0 else {
            return NSNull.self
        }
        
        let propertyClassAttribute = attributesCollection[0]
        if (propertyClassAttribute as NSString).length == 2 {
            let type = (propertyClassAttribute as NSString).substringFromIndex(1)
            switch type {
            case "q": return NSNumber.self // Swift Int
            case "d": return NSNumber.self // Swift Double
            case "f": return NSNumber.self // Swift Float
            case "B": return NSNumber.self // Swift Bool
            case "@": return NSObject.self
            default: return NSObject.self
            }
        }
        
        let propertyClass = (propertyClassAttribute as NSString).substringFromIndex(1)
        let className = (propertyClass as NSString).substringWithRange(NSMakeRange(2, (propertyClass as NSString).length - 3))
        guard let anyclass = NSClassFromString(className) else {
            return NSNull.self
        }
        
        return anyclass.self
    }
    
    public static func stringByRemovingPrettyJSONFormatting(forString jsonString: String) -> String {
        let string: NSMutableString = NSMutableString(string: jsonString)
        string.replaceOccurrencesOfString("\n", withString: "", options: .CaseInsensitiveSearch, range: NSMakeRange(0, string.length))
        string.replaceOccurrencesOfString(" : ", withString: ":", options: .CaseInsensitiveSearch, range: NSMakeRange(0, string.length))
        string.replaceOccurrencesOfString("  ", withString: "", options: .CaseInsensitiveSearch, range: NSMakeRange(0, string.length))
        string.replaceOccurrencesOfString("\\/", withString: "/", options: .CaseInsensitiveSearch, range: NSMakeRange(0, string.length))
        return string as String
    }
    
    public static func stringByApplyingKeyStyle(keyStyle: SerializerKeyStyle, forString string: String) -> String {
        guard string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 1 else {
            return string
        }
        
        switch (keyStyle) {
        case .TitleCase:
            let range: Range = string.startIndex..<string.startIndex.advancedBy(1)
            let sub = string.substringWithRange(range).uppercaseString
            return string.stringByReplacingCharactersInRange(range, withString: sub)
        case .CamelCase:
            let range: Range = string.startIndex..<string.startIndex.advancedBy(1)
            let sub = string.substringWithRange(range).lowercaseString
            return string.stringByReplacingCharactersInRange(range, withString: sub)
        case .UpperCase: return string.uppercaseString
        case .LowerCase: return string.lowercaseString
        default: return string
        }
    }
}
