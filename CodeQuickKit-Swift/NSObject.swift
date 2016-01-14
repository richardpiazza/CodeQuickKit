//===----------------------------------------------------------------------===//
//
// NSObject.swift
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

// MARK: - Objective-C Runtime
public extension NSObject {
    /// Lists all property names for an object of the provided class.
    static func propertyNamesForClass(objectClass: AnyClass) -> [String] {
        var properties: [String] = [String]()
        
        if let sc = objectClass.superclass() where sc.self != NSObject.self {
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
    static func classForPropertyName(propertyName: String, ofClass objectClass: AnyClass) -> AnyClass {
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
            case "q": return NSNull.self //Int
            case "d": return NSNull.self //Double
            case "f": return NSNull.self //Float
            case "B": return NSNull.self //Bool
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
    
    /// Returns a probably Obj-C setter for the specified property name.
    static func setterForPropertyName(propertyName: String) -> Selector? {
        guard propertyName.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 else {
            return nil
        }
        
        let range = Range<String.Index>(start: propertyName.startIndex, end: propertyName.startIndex.advancedBy(1))
        let character = propertyName.substringWithRange(range).uppercaseString
        let setter = propertyName.stringByReplacingCharactersInRange(range, withString: character)
        
        return NSSelectorFromString("set\(setter):")
    }
    
    func propertyNames() -> [String] {
        return NSObject.propertyNamesForClass(self.dynamicType)
    }
    
    func classForPropertyName(propertyName: String) -> AnyClass {
        return NSObject.classForPropertyName(propertyName, ofClass: self.dynamicType)
    }
}

// MARK: - Serializable
extension NSObject: Serializable {}

// MARK: - Deserializable
extension NSObject: Deserializable {}
