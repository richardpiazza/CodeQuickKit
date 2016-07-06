//===----------------------------------------------------------------------===//
//
// SerializableManagedObject.swift
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
import CoreData

/// ## SerializableManagedObject
/// A subclass of `NSManagedObject` that implements the `ManagedSerializable` protocol
public class SerializableManagedObject: NSManagedObject, ManagedSerializable {
    public static var entityName: String {
        var entityName = NSStringFromClass(self)
        if let lastPeriodRange = entityName.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil) {
            entityName = entityName.substringFromIndex(lastPeriodRange.endIndex)
        }
        
        return entityName
    }
    
    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        Logger.verbose("Initialized entity '\(self.dynamicType.entityName)'", callingClass: self.dynamicType)
        setDefaults()
    }
    
    public required convenience init?(managedObjectContext context: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entityForName(self.dynamicType.entityName, inManagedObjectContext: context) else {
            return nil
        }
        
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
        Logger.verbose("Initialized entity '\(self.dynamicType.entityName)'", callingClass: self.dynamicType)
        setDefaults()
    }
    
    /// Called imediatley after initialization, allowing for property/relationship initialization.
    public func setDefaults() {
        
    }
    
    public required convenience init(withDictionary dictionary: SerializableDictionary?) {
        fatalError("init(managedObjectContext:withDictionary:) should be used")
    }
    
    /// Initialize an instance of the class and pass the referenced dictionary to update(withDictionary:).
    public convenience required init?(managedObjectContext context: NSManagedObjectContext, withDictionary dictionary: SerializableDictionary?) {
        guard let entityDescription = NSEntityDescription.entityForName(self.dynamicType.entityName, inManagedObjectContext: context) else {
            return nil
        }
        
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
        setDefaults()
        update(withDictionary: dictionary)
    }
    
    /// Updates the instance with values in the dictionary.
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
            } else {
                setValue(value, forPropertyName: propertyName)
            }
        }
    }
    
    /// Returns a dictionary representation of the instance.
    public var dictionary: SerializableDictionary {
        var d: SerializableDictionary = SerializableDictionary()
        
        let attributes = entity.attributesByName
        for (key, _) in attributes {
            guard let serializedKey = serializedKey(forPropertyName: key) else {
                continue
            }
            
            guard let value = valueForKey(key) as? NSObject where !(value is NSNull.Type) else {
                continue
            }
            
            guard let serializedObject = serializedObject(forPropertyName: key, withData: value) else {
                continue
            }
            
            d[serializedKey] = serializedObject
        }
        
        let relationships = entity.relationshipsByName
        for (key, _) in relationships {
            guard let serializedKey = serializedKey(forPropertyName: key) else {
                continue
            }
            
            guard let value = valueForKey(key) as? NSObject where !(value is NSNull.Type) else {
                continue
            }
            
            guard let serializedObject = serializedObject(forPropertyName: key, withData: value) else {
                continue
            }
            
            d[serializedKey] = serializedObject
        }
        
        return d
    }
    
    public required convenience init(withData data: NSData?) {
        fatalError("init(managedObjectContext:withData:) should be used")
    }
    
    /// Initialize an instance of the class and pass the referenced data to update(withData:).
    public convenience required init?(managedObjectContext context: NSManagedObjectContext, withData data: NSData?) {
        guard let entityDescription = NSEntityDescription.entityForName(self.dynamicType.entityName, inManagedObjectContext: context) else {
            return nil
        }
        
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
        setDefaults()
        update(withData: data)
    }
    
    /// Passes the `NSData` instance of an `NSDictionary` to update(withDictionary:).
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
    
    /// Returns the dictionary representation of the instance as an `NSData` object.
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
        fatalError("init(managedObjectContext:withJSON:) should be used")
    }
    
    /// Initialize an instance of the class and pass the referenced json to update(withJSON:).
    public convenience required init?(managedObjectContext context: NSManagedObjectContext, withJSON json: String?) {
        guard let entityDescription = NSEntityDescription.entityForName(self.dynamicType.entityName, inManagedObjectContext: context) else {
            return nil
        }
        
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
        setDefaults()
        update(withJSON: json)
    }
    
    /// Deserializes the JSON formatted string and pass the `NSDictionary` to update(withDictionary):.
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
    
    /// Returns the dictionary representation of the instance as a JSON formatted string.
    public var json: String? {
        guard let d = data else {
            return nil
        }
        
        guard let s = String(data: d, encoding: NSUTF8StringEncoding) else {
            return nil
        }
        
        return Serializer.stringByRemovingPrettyJSONFormatting(forString: s)
    }
    
    /// Maps a serialized key to a property name.
    /// Case translation is automatic based on `Serializer.propertyKeyStyle`.
    /// A nil return will skip the deserialization for this key.
    public func propertyName(forSerializedKey serializedKey: String) -> String? {
        return Serializer.propertyName(forSerializedKey: serializedKey)
    }
    
    /// Maps a propety name to serialized key.
    /// Case translation is automatic based on `Serializer.serializedKeyStyle`.
    /// A nil return will skip the deserialization for this key.
    ///
    /// When used in the context of `SerializableManagedObject` subclasses, a nil blocks recursive serialization.
    /// i.e. Given Person -> Address (One-to-many with reverse reference); When serializing a 'Person',
    /// you want the related Addresses but don't want the 'Person' referenced on the 'Address'.
    public func serializedKey(forPropertyName propertyName: String) -> String? {
        return Serializer.serializedKey(forPropertyName: propertyName)
    }
    
    /// Overrides the default initialization behavior for a given property.
    /// Many serialized object types can be nativly deserialized to their corresponding `NSObject` type.
    /// Objects that conform to `Serializable` will automatically by initialized.
    ///
    /// When used in the context of `SerializableManagedObject`, `init(intoManagedObjectContext:withDictionary:)`
    /// is called.
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
                
                if let serializableClass = containgClass as? ManagedSerializable.Type {
                    if let initializedObject = serializableClass.initializeSerializable(managedObjectContext: managedObjectContext, withDictionary: dictionary) as? NSManagedObject {
                        return initializedObject
                    }
                }
            } else if propertyClass is NSSet.Type {
                let containgClass: AnyClass? = objectClassOfCollectionType(forPropertyname: propertyName)
                if containgClass is NSNull.Type {
                    return nil
                }
                
                if let serializableClass = containgClass as? ManagedSerializable.Type {
                    if let initializedObject = serializableClass.initializeSerializable(managedObjectContext: managedObjectContext, withDictionary: dictionary) as? NSManagedObject {
                        return initializedObject
                    }
                }
            } else if propertyClass is Serializable.Type {
                if let serializableClass = propertyClass as? ManagedSerializable.Type {
                    if let initializedObject = serializableClass.initializeSerializable(managedObjectContext: managedObjectContext, withDictionary: dictionary) as? NSManagedObject {
                        return initializedObject
                    }
                }
            } else if propertyClass is NSDictionary.Type {
                return dictionary
            }
        }
        
        return Serializer.initializedObject(forPropertyName: propertyName, ofClass: self.dynamicType, withData: data)
    }
    
    /// Overrides the default serialization behavior for a given property.
    /// Several NSObject subclasses can nativley be serialized with the NSJSONSerialization class.
    /// When used in the context of `Serializable` the `dictionary` representation is returned.
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
    
    /// Specifyes the type of objects contained within a collection.
    /// Aids in deserializing array instances into appropriate `NSObject` subclasses.
    /// By default a singularized version of the provided propertyName will be used to
    /// identify the return class.
    public func objectClassOfCollectionType(forPropertyname propertyName: String) -> AnyClass? {
        return NSBundle(forClass: self.dynamicType).singularizedModuleClass(forClassNamed: propertyName)
    }
    
    /// Initializes an entity represented by the `value` and assigns to the `propertyName` attribute.
    private func setValue(value: SerializableDictionary, forPropertyName propertyName: String) {
        if let initializedObject = initializedObject(forPropertyName: propertyName, withData: value) {
            setValue(initializedObject, forKey: propertyName)
        }
    }
    
    /// Initializes multiple entities and assigns the set to the `propertyName` attribute.
    private func setValue(value: [NSObject], forPropertyName propertyName: String) {
        let propertyClass: AnyClass = Serializer.classForPropertyName(propertyName, ofClass: self.dynamicType)
        guard !(propertyClass is NSNull.Type) else {
            return
        }
        
        let initializedSet = NSMutableSet()
        for element in value {
            if let initializedObject = initializedObject(forPropertyName: propertyName, withData: element) {
                initializedSet.addObject(initializedObject)
            }
        }
        
        setValue(initializedSet, forKey: propertyName)
    }
    
    /// Sets the `value` to the `propertyName` attribute.
    private func setValue(value: NSObject, forPropertyName propertyName: String) {
        setValue(value, forKey: propertyName)
    }
}

public protocol ManagedSerializable: Serializable {
    init?(managedObjectContext context: NSManagedObjectContext)
    init?(managedObjectContext context: NSManagedObjectContext, withDictionary dictionary: SerializableDictionary?)
    init?(managedObjectContext context: NSManagedObjectContext, withData data: NSData?)
    init?(managedObjectContext context: NSManagedObjectContext, withJSON json: String?)
}

public extension ManagedSerializable {
    static func initializeSerializable(managedObjectContext moc: NSManagedObjectContext?, withDictionary dictionary: SerializableDictionary?) -> Self? {
        guard let moc = moc else {
            return nil
        }
        return self.init(managedObjectContext: moc, withDictionary: dictionary)
    }
    
    static func initializeSerializable(managedObjectContext moc: NSManagedObjectContext?, withData data: NSData?) -> Self? {
        guard let moc = moc else {
            return nil
        }
        return self.init(managedObjectContext: moc, withData: data)
    }
    
    static func initializeSerializable(managedObjectContext moc: NSManagedObjectContext?, withJSON json: String?) -> Self? {
        guard let moc = moc else {
            return nil
        }
        return self.init(managedObjectContext: moc, withJSON: json)
    }
}
