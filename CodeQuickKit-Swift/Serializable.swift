//===----------------------------------------------------------------------===//
//
// Serializable.swift
//
// Copyright (c) 2016 Richard Piazza
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

public protocol Serializable {
    func serializedValue() -> AnyObject?
}

extension Serializable {
    public func serializedValue() -> AnyObject? {
        let mirror = Mirror(reflecting: self)
        guard mirror.children.count > 0 else {
            return self as? AnyObject
        }
        
        var results: [String : AnyObject] = [String : AnyObject]()
        for (label, value) in mirror.children {
            guard let key = label else {
                continue
            }
            
            if let url = value as? NSURL {
                results[key] = url.serializedValue()
            } else if let date = value as? NSDate {
                results[key] = date.serializedValue()
            } else if let uuid = value as? NSUUID {
                results[key] = uuid.serializedValue()
            } else if let any = value as? Serializable {
                results[key] = any.serializedValue()
            }
        }
        
        return results
    }
    
    public func serializedData() -> NSData? {
        do {
            guard let dictionary = self.serializedValue() as? [String : AnyObject] else {
                return nil
            }
            
            return try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print(error)
            return nil
        }
    }
    
    public func serializedJSON() -> String? {
        guard let data = self.serializedData() else {
            return nil
        }
        guard let json = String(data: data, encoding: NSUTF8StringEncoding) else {
            return nil
        }
        
        return json.stringByRemovingPrettyJSONFormatting
    }
}

extension String: Serializable {}
extension Double: Serializable {}
extension Float: Serializable {}
extension Int: Serializable {}
extension Bool: Serializable {}
extension NSObject: Serializable {}
extension NSURL {
    func serializedValue() -> AnyObject? {
        return self.absoluteString
    }
}
extension NSUUID {
    func serializedValue() -> AnyObject? {
        return self.UUIDString
    }
}
extension NSDate {
    func serializedValue() -> AnyObject? {
        return SerializableConfiguration.sharedConfiguration.dateFormatter.stringFromDate(self)
    }
}

public enum SerializableKeyStyle {
    case MatchCase
    case TitleCase
    case CamelCase
    case UpperCase
    case LowerCase
}

public typealias SerializableKeyRedirect = (propertyName: String, serializedKey: String)

public class SerializableConfiguration {
    static let sharedConfiguration: SerializableConfiguration = SerializableConfiguration()
    
    var propertyKeyStyle: SerializableKeyStyle = .MatchCase
    
    var serializedKeyStyle: SerializableKeyStyle = .MatchCase
    
    var keyRedirects: [SerializableKeyRedirect] = [SerializableKeyRedirect]()
    
    /// An `NSDateFormatter` that is preconfigured with RFC1123 format.
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
        return formatter
    }()
}
