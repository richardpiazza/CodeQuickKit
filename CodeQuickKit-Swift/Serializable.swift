//===----------------------------------------------------------------------===//
//
// Serializable.swift
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

public protocol Serializable {
    func serializedValue() -> AnyObject?
}

public extension Serializable {
    public func serializedKeyFor(propertyName: String) -> String? {
        let redirects = Serializer.configuration.keyRedirects.filter({$0.propertyName == propertyName})
        if redirects.count > 0 {
            return redirects[0].serializedKey
        }
        
        return propertyName.stringByApplyingKeyStyle(Serializer.configuration.serializedKeyStyle)
    }
    
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
            
            guard let serializedKey = self.serializedKeyFor(key) else {
                continue
            }
            
            if let url = value as? NSURL {
                results[serializedKey] = url.serializedValue()
            } else if let date = value as? NSDate {
                results[serializedKey] = date.serializedValue()
            } else if let uuid = value as? NSUUID {
                results[serializedKey] = uuid.serializedValue()
            } else if let any = value as? Serializable {
                results[serializedKey] = any.serializedValue()
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
