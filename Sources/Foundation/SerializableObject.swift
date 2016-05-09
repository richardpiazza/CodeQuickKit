//===----------------------------------------------------------------------===//
//
// SerializableObject.swift
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

public class SerializableObject: NSObject, Serializable {
    public override init() {
        super.init()
        setDefaults()
    }
    
    public func setDefaults() {
        
    }
    
    public required convenience init(withDictionary dictionary: SerializableDictionary?) {
        self.init()
        update(withDictionary: dictionary)
    }
    
    public func update(withDictionary dictionary: SerializableDictionary?) {
        guard let d = dictionary else {
            return
        }
        
        for (key, value) in d {
            guard let propertyName = propertyName(forSerializedKey: key) else {
                continue
            }
            
            guard respondsToSetter(forPropertyName: propertyName) else {
                continue
            }
            
            if let typedValue = value as? SerializableDictionary {
                setValue(typedValue, forPropertyName: propertyName)
            } else if let typedValue = value as? [NSObject] {
                setValue(typedValue, forPropertyName: propertyName)
            } else if let typeValue = value as? Set<NSObject> {
                setValue(typeValue, forPropertyName: propertyName)
            } else {
                setValue(value, forPropertyName: propertyName)
            }
        }
    }
    
    public var dictionary: SerializableDictionary {
        var d: SerializableDictionary = SerializableDictionary()
        
        let propertyNames = Serializer.propertyNamesForClass(self.dynamicType)
        for propertyName in propertyNames {
            guard let serializedKey = serializedKey(forPropertyName: propertyName) else {
                continue
            }
            
            guard let value = valueForKey(propertyName) as? NSObject where !(value is NSNull.Type)  else {
                continue
            }
            
            guard let serializedObject = serializedObject(forPropertyName: propertyName, withData: value) else {
                continue
            }
            
            d[serializedKey] = serializedObject
        }
        
        return d
    }
    
    public required convenience init(withData data: NSData?) {
        self.init()
        update(withData: data)
    }
    
    public func update(withData data: NSData?) {
        guard let d = data else {
            return
        }
        
        do {
            if let dictionary = try NSJSONSerialization.JSONObjectWithData(d, options: .MutableContainers) as? SerializableDictionary {
                update(withDictionary: dictionary)
            }
        } catch {
            let e = error as! NSError
            Logger.error(e, message: "Failed update(withData:); \(d)")
        }
    }
    
    public var data: NSData? {
        let d = dictionary
        do {
            return try NSJSONSerialization.dataWithJSONObject(d, options: .PrettyPrinted)
        } catch {
            let e = error as! NSError
            Logger.error(e, message: "Failed data; \(d)")
        }
        
        return nil
    }
    
    public required convenience init(withJSON json: String?) {
        self.init()
        update(withJSON: json)
    }
    
    public func update(withJSON json: String?) {
        guard let j = json else {
            return
        }
        
        guard let data = j.dataUsingEncoding(NSUTF8StringEncoding) else {
            Logger.error(nil, message: "Failed update(withJSON:); \(j)")
            return
        }
        
        update(withData: data)
    }
    
    public var json: String? {
        guard let d = data else {
            return nil
        }
        
        guard let s = String(data: d, encoding: NSUTF8StringEncoding) else {
            return nil
        }
        
        return Serializer.stringByRemovingPrettyJSONFormatting(forString: s)
    }
    
    public func propertyName(forSerializedKey serializedKey: String) -> String? {
        return Serializer.propertyName(forSerializedKey: serializedKey)
    }
    
    public func serializedKey(forPropertyName propertyName: String) -> String? {
        return Serializer.serializedKey(forPropertyName: propertyName)
    }
    
    public func initializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        let propertyClass: AnyClass = Serializer.classForPropertyName(propertyName, ofClass: self.dynamicType)
        if propertyClass is NSNull.Type {
            return nil
        }
        
        if let dictionary = data as? SerializableDictionary {
            if propertyClass is NSArray.Type {
                let containgClass: AnyClass? = objectClassOfCollectionType(forPropertyname: propertyName)
                if containgClass is NSNull.Type {
                    return nil
                }
                
                if let serializableClass = containgClass as? Serializable.Type {
                    if let initializedObject = serializableClass.initializeSerializable(withDictionary: dictionary) as? NSObject {
                        return initializedObject
                    }
                }
            } else if propertyClass is NSSet.Type {
                let containgClass: AnyClass? = objectClassOfCollectionType(forPropertyname: propertyName)
                if containgClass is NSNull.Type {
                    return nil
                }
                
                if let serializableClass = containgClass as? Serializable.Type {
                    if let initializedObject = serializableClass.initializeSerializable(withDictionary: dictionary) as? NSObject {
                        return initializedObject
                    }
                }
            } else if propertyClass is Serializable.Type {
                if let serializableClass = propertyClass as? Serializable.Type {
                    if let initializedObject = serializableClass.initializeSerializable(withDictionary: dictionary) as? NSObject {
                        return initializedObject
                    }
                }
            } else if propertyClass is NSDictionary.Type {
                return dictionary
            }
        }
        
        return Serializer.initializedObject(forPropertyName: propertyName, ofClass: self.dynamicType, withData: data)
    }
    
    public func serializedObject(forPropertyName propertyName: String, withData data: NSObject) -> NSObject? {
        if let arrayData = data as? Array<NSObject> {
            var serializedArray = [NSObject]()
            for object in arrayData {
                if let serializableData = object as? Serializable {
                    serializedArray.append(serializableData.dictionary)
                } else if let serializedObject = serializedObject(forPropertyName: propertyName, withData: object) {
                    serializedArray.append(serializedObject)
                }
            }
            return serializedArray
        } else if let setData = data as? Set<NSObject> {
            var serializedSet = [NSObject]()
            for object in setData {
                if let serializedData = object as? Serializable {
                    serializedSet.append(serializedData.dictionary)
                } else if let serializedObject = serializedObject(forPropertyName: propertyName, withData: object) {
                    serializedSet.append(serializedObject)
                }
            }
            return serializedSet
        } else if let serializableData = data as? Serializable {
            return serializableData.dictionary
        }
        
        return Serializer.serializedObject(forPropertyName: propertyName, withData: data)
    }
    
    public func objectClassOfCollectionType(forPropertyname propertyName: String) -> AnyClass? {
        return NSBundle(forClass: self.dynamicType).singularizedModuleClass(forClassNamed: propertyName)
    }
    
    private func setValue(value: SerializableDictionary, forPropertyName propertyName: String) {
        if let initializedObject = initializedObject(forPropertyName: propertyName, withData: value) {
            setValue(initializedObject, forKey: propertyName)
        }
    }
    
    private func setValue(value: [NSObject], forPropertyName propertyName: String) {
        let propertyClass: AnyClass = Serializer.classForPropertyName(propertyName, ofClass: self.dynamicType)
        guard !(propertyClass is NSNull.Type) else {
            return
        }
        
        var initializedArray = [NSObject]()
        for element in value {
            if let initializedObject = initializedObject(forPropertyName: propertyName, withData: element) {
                initializedArray.append(initializedObject)
            }
        }
        
        setValue(initializedArray, forKey: propertyName)
    }
    
    private func setValue(value: Set<NSObject>, forPropertyName propertyName: String) {
        let propertyClass: AnyClass = Serializer.classForPropertyName(propertyName, ofClass: self.dynamicType)
        guard !(propertyClass is NSNull.Type) else {
            return
        }
        
        var initializedSet = Set<NSObject>()
        for element in value {
            if let initializedObject = initializedObject(forPropertyName: propertyName, withData: element) {
                initializedSet.insert(initializedObject)
            }
        }
        
        setValue(initializedSet, forKey: propertyName)
    }
    
    private func setValue(value: NSObject, forPropertyName propertyName: String) {
        if let initializedObject = initializedObject(forPropertyName: propertyName, withData: value) {
            setValue(initializedObject, forKey: propertyName)
        }
    }
}

public extension Serializable {
    static func initializeSerializable(withDictionary dictionary: SerializableDictionary?) -> Self {
        return self.init(withDictionary: dictionary)
    }
    
    static func initializeSerializable(withData data: NSData?) -> Self {
        return self.init(withData: data)
    }
    
    static func initializeSerializable(withJSON json: String?) -> Self {
        return self.init(withJSON: json)
    }
}
