//===----------------------------------------------------------------------===//
//
// CoreData.swift
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

public enum StoreType {
    case SQLite
    case Binary
    case InMemory
    
    public var stringValue: String {
        switch self {
        case .SQLite: return NSSQLiteStoreType
        case .Binary: return NSBinaryStoreType
        case .InMemory: return NSInMemoryStoreType
        }
    }
}

public protocol CoreDataConfiguration {
    var persistentStoreType: StoreType { get }
    var persistentStoreURL: NSURL { get }
    var persistentStoreOptions: [String : AnyObject] { get }
}

/// Provides an implementation of a CoreData Stack. When no delegate is provided
/// during initialization, an in-memory store type is used.
public class CoreData {
    public static let defaultStoreName = "CoreData.sqlite"
    public static let mergedManagedObjectModelExtension = "momd"
    
    public var managedObjectContext: NSManagedObjectContext!
    public var persistentStore: NSPersistentStore!
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    public var managedObjectModel: NSManagedObjectModel!
    public var delegate: CoreDataConfiguration?
    
    public init?(withModel model: NSManagedObjectModel, delegate: CoreDataConfiguration? = nil) {
        Logger.verbose("\(#function)", callingClass: self.dynamicType)
        self.delegate = delegate
        managedObjectModel = model
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        guard let coordinator = persistentStoreCoordinator else {
            Logger.warn("Persistent Store Coordinator is nil", callingClass: self.dynamicType)
            return nil
        }
        
        var storeType: String = NSInMemoryStoreType
        var storeURL: NSURL? = nil
        var storeOptions: [String : AnyObject]? = nil
        
        if let delegate = self.delegate {
            storeType = delegate.persistentStoreType.stringValue
            storeURL = delegate.persistentStoreURL
            storeOptions = delegate.persistentStoreOptions
        }
        
        do {
            try persistentStore = coordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: storeURL, options: storeOptions)
        } catch {
            Logger.error((error as NSError), message: "addPersistentStoreWithType", callingClass: self.dynamicType)
            return nil
        }
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        guard let moc = managedObjectContext else {
            Logger.warn("Managed Object Context is nil", callingClass: self.dynamicType)
            return nil
        }
        
        moc.persistentStoreCoordinator = coordinator
    }
    
    public convenience init?(withEntities entities: [NSEntityDescription], delegate: CoreDataConfiguration? = nil) {
        Logger.verbose("\(#function)", callingClass: self.dynamicType)
        let model = NSManagedObjectModel()
        model.entities = entities
        self.init(withModel: model, delegate: delegate)
    }
    
    public convenience init?(fromBundle bundle: NSBundle, modelName: String? = nil, delegate: CoreDataConfiguration? = nil) {
        Logger.verbose("\(#function)", callingClass: self.dynamicType)
        var name: String? = modelName
        if modelName == nil {
            name = bundle.bundleName
        }
        
        guard let momd = name else {
            Logger.warn("Model name is nil.", callingClass: self.dynamicType)
            return nil
        }
        
        guard let url = bundle.URLForResource(momd, withExtension: CoreData.mergedManagedObjectModelExtension) else {
            Logger.warn("Model with name '\(momd)' not found.", callingClass: self.dynamicType)
            return nil
        }
        
        guard let model = NSManagedObjectModel(contentsOfURL: url) else {
            Logger.warn("Model failed to load contents of url '\(url)'.", callingClass: self.dynamicType)
            return nil
        }
        
        self.init(withModel: model, delegate: delegate)
    }
    
    deinit {
        do {
            try persistentStoreCoordinator.removePersistentStore(persistentStore)
        } catch {
            Logger.error((error as NSError), message: "removePersistentStore", callingClass: self.dynamicType)
        }
    }
}
