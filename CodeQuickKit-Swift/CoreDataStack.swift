//===----------------------------------------------------------------------===//
//
// CoreDataStack.swift
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

public enum CoreDataStackStoreType {
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

public protocol CoreDataStackConfiguration {
    func persistentStoreType(forCoreDataStack coreDataStack: CoreDataStack) -> CoreDataStackStoreType
    func persistentStoreURL(forCoreDataStack coreDataStack: CoreDataStack) -> NSURL
    func persistentStoreOptions(forCoreDataStack coreDataStack: CoreDataStack) -> [String : AnyObject]
}

/// Provides an implementation of a CoreData Stack. When no delegate is provided
/// during initialization, an in-memory store type is used.
public class CoreDataStack {
    static let defaultStoreName = "CoreData.sqlite"
    
    public var managedObjectContext: NSManagedObjectContext!
    public var persistentStore: NSPersistentStore!
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    public var managedObjectModel: NSManagedObjectModel!
    public var configurationDelegate: CoreDataStackConfiguration?
    
    public init?(withModel model: NSManagedObjectModel, delegate: CoreDataStackConfiguration? = nil) {
        self.configurationDelegate = delegate
        self.managedObjectModel = model
        
        guard let mom = self.managedObjectModel else {
            return nil
        }
        
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        guard let coordinator = self.persistentStoreCoordinator else {
            return nil
        }
        
        var storeType: String = NSInMemoryStoreType
        var storeURL: NSURL? = nil
        var storeOptions: [String : AnyObject]? = nil
        
        if let configDelegate = self.configurationDelegate {
            storeType = configDelegate.persistentStoreType(forCoreDataStack: self).stringValue
            storeURL = configDelegate.persistentStoreURL(forCoreDataStack: self)
            storeOptions = configDelegate.persistentStoreOptions(forCoreDataStack: self)
        }
        
        do {
            try self.persistentStore = coordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: storeURL, options: storeOptions)
        } catch {
            print(error)
            return nil
        }
        
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        guard let moc = self.managedObjectContext else {
            return nil
        }
        
        moc.persistentStoreCoordinator = coordinator
    }
    
    public convenience init?(withEntities entities: [NSEntityDescription], delegate: CoreDataStackConfiguration? = nil) {
        let model = NSManagedObjectModel()
        model.entities = entities
        self.init(withModel: model, delegate: delegate)
    }
}
