//===----------------------------------------------------------------------===//
//
// NSManagedObject.swift
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

public extension NSManagedObject {
    /// Attemps to initialize an NSManagedObject by using the class name.
    public convenience init?(managedObjectContext context: NSManagedObjectContext) {
        var bundle = NSBundle.mainBundle()
        if let dictionary = bundle.infoDictionary where dictionary.count != 0 {
            bundle = NSBundle(forClass: self.dynamicType)
        }
        
        var entityName = NSStringFromClass(self.dynamicType)
        if entityName.hasPrefix("\(bundle.bundleDisplayName).") {
            let end = bundle.bundleDisplayName.endIndex.advancedBy(1)
            entityName = entityName.substringFromIndex(end)
        }
        
        guard let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context) else {
            return nil
        }
        
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
    public func shouldSerializeRelationship(withAttributeName attributeName: String) -> Bool {
        return true
    }
    
    public func classOfEntityForRelationship(withAttributeName attributeName: String) -> AnyClass? {
        var entityClass: AnyClass? = NSClassFromString(attributeName)
        if entityClass != nil {
            return entityClass
        }
        
        var singular = attributeName
        if attributeName.lowercaseString.hasSuffix("s") {
            singular = attributeName.substringToIndex(attributeName.endIndex.advancedBy(-1))
        }
        
        let firstIndex = Range<String.Index>(start: singular.startIndex, end: singular.startIndex.advancedBy(1))
        let capital = singular.substringWithRange(firstIndex).uppercaseString
        singular.replaceRange(firstIndex, with: capital)
        
        entityClass = NSClassFromString(singular)
        if entityClass != nil {
            return entityClass
        }
        
        return nil
    }
    
    public func initializedEntity(ofClass entityClass: AnyClass, forAttributeName attributeName: String, withDictionary dictionary: [String : AnyObject]) -> NSManagedObject? {
        guard let context = self.managedObjectContext else {
            return nil
        }
        
        guard let entity = NSManagedObject(managedObjectContext: context) else {
            return nil
        }
        
        entity.update(withDictionary: dictionary)
        return entity
    }
    
    public func serializedValue() -> AnyObject? {
        var results: [String : AnyObject] = [String : AnyObject]()
        
        let attributes = self.entity.attributesByName
        for (key, _) in attributes {
            guard let value = self.valueForKey(key) else {
                continue
            }
            
            guard let serializedValue = value.serializedValue() else {
                continue
            }
            
            results[key] = serializedValue
        }
        
        let relationships = self.entity.relationshipsByName
        for (key, _) in relationships {
            guard self.shouldSerializeRelationship(withAttributeName: key) else {
                continue
            }
            
            guard let value = self.valueForKey(key) else {
                continue
            }
            
            guard let serializedValue = value.serializedValue() else {
                continue
            }
            
            results[key] = serializedValue
        }
        
        return results
    }
}
