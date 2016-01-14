//===----------------------------------------------------------------------===//
//
// Deserializable.swift
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

public protocol Deserializable {
    func update(withDictionary dictionary: [String : AnyObject]?)
}

public extension Deserializable {
    public func propertyNameFor(serializedKey: String) -> String? {
        let redirects = Serializer.configuration.keyRedirects.filter({$0.serializedKey == serializedKey})
        if redirects.count > 0 {
            return redirects[0].propertyName
        }
        
        return serializedKey.stringByApplyingKeyStyle(Serializer.configuration.propertyKeyStyle)
    }
    
    public func initializedObjectFor(propertyName: String, data: AnyObject) -> AnyObject? {
        guard let any = self.dynamicType as? AnyClass else {
            return data
        }
        let propertyClass: AnyClass = NSObject.classForPropertyName(propertyName, ofClass: any)
        if propertyClass is NSNull.Type {
            return nil
        }
        
        if let value = data as? String, _ = propertyClass as? NSUUID.Type {
            return NSUUID(UUIDString: value)
        } else if let value = data as? String, _ = propertyClass as? NSURL.Type {
            return NSURL(string: value)
        } else if let value = data as? String, _ = propertyClass as? NSDate.Type {
            return NSDateFormatter.rfc1123DateFormatter.dateFromString(value)
        }
        
        return data
    }
    
    public func update(withDictionary dictionary: [String : AnyObject]?) {
        guard let dictionary = dictionary else {
            return
        }
        
        guard let object = self as? NSObject else {
            return
        }
        
        for (key, value) in dictionary {
            guard let propertyName = self.propertyNameFor(key) else {
                continue
            }
            
            guard let setter = NSObject.setterForPropertyName(propertyName) else {
                continue
            }
            
            guard object.respondsToSelector(setter) else {
                continue
            }
            
            if let valueArray = value as? [AnyObject] {
                var array = [AnyObject]()
                
                for item in valueArray {
                    if let initializedValue = self.initializedObjectFor(propertyName, data: item) {
                        array.append(initializedValue)
                    }
                }
                
                object.performSelector(setter, withObject: array)
            } else {
                if let initializedValue = self.initializedObjectFor(propertyName, data: value) {
                    object.performSelector(setter, withObject: initializedValue)
                }
            }
        }
    }
    
    public func update(withData data: NSData?) {
        guard let data = data else {
            return
        }
        
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            if let dictionary = (object as? [String : AnyObject]) {
                self.update(withDictionary: dictionary)
            }
        } catch {
            print(error)
        }
    }
    
    public func update(withJSON json: String?) {
        guard let json = json else {
            return
        }
        
        self.update(withData: json.dataUsingEncoding(NSUTF8StringEncoding))
    }
}
