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
        var entityName = NSStringFromClass(self.dynamicType)
        if let lastPeriodRange = entityName.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil) {
            entityName = entityName.substringFromIndex(lastPeriodRange.endIndex)
        }
        
        guard let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context) else {
            return nil
        }
        
        self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    }
    
    public func classOfEntityForRelationship(withRelationshipName relationshipName: String) -> AnyClass? {
        var entityClass: AnyClass? = NSClassFromString(relationshipName)
        if entityClass != nil {
            return entityClass
        }
        
        var singular = relationshipName
        if relationshipName.lowercaseString.hasSuffix("s") {
            singular = relationshipName.substringToIndex(relationshipName.endIndex.advancedBy(-1))
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
}

// MARK: - Serializable
public extension NSManagedObject {
    override public func serializedValue() -> AnyObject? {
        var results: [String : AnyObject] = [String : AnyObject]()
        
        let attributes = self.entity.attributesByName
        for (key, _) in attributes {
            guard let serializedKey = self.serializedKeyFor(key) else {
                continue
            }
            
            guard let value = self.valueForKey(key) else {
                continue
            }
            
            guard let serializedValue = value.serializedValue() else {
                continue
            }
            
            results[serializedKey] = serializedValue
        }
        
        let relationships = self.entity.relationshipsByName
        for (key, _) in relationships {
            guard let serializedKey = self.serializedKeyFor(key) else {
                continue
            }
            
            guard let value = self.valueForKey(key) else {
                continue
            }
            
            guard let serializedValue = value.serializedValue() else {
                continue
            }
            
            results[serializedKey] = serializedValue
        }
        
        return results
    }
}
