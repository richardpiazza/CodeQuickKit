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
    case sqlite
    case binary
    case inMemory
    
    public var stringValue: String {
        switch self {
        case .sqlite: return NSSQLiteStoreType
        case .binary: return NSBinaryStoreType
        case .inMemory: return NSInMemoryStoreType
        }
    }
}

public struct PersistentStoreConfiguration {
    public var storeType: StoreType = .inMemory
    public var configurationName: String?
    public var url: URL?
    public var options: [String : AnyObject]?
    
    public init() {
    }
}

/// Provides an implementation of a CoreData Stack.
/// The default configuration uses an in-memory store type.
open class CoreData {
    fileprivate static let mergedManagedObjectModelExtension = "momd"
    
    public var managedObjectContext: NSManagedObjectContext!
    public var persistentStore: NSPersistentStore!
    public var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    public var managedObjectModel: NSManagedObjectModel!
    
    public init(withModel model: NSManagedObjectModel, configuration: PersistentStoreConfiguration = PersistentStoreConfiguration()) {
        Logger.verbose("\(#function)", callingClass: type(of: self))
        managedObjectModel = model
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        guard let coordinator = persistentStoreCoordinator else {
            fatalError("Persistent Store Coordinator is nil")
        }
        
        do {
            try persistentStore = coordinator.addPersistentStore(ofType: configuration.storeType.stringValue, configurationName: configuration.configurationName, at: configuration.url, options: configuration.options)
        } catch {
            fatalError("addPersistentStoreWithType failed")
        }
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        guard let moc = managedObjectContext else {
            fatalError("Managed Object Context is nil")
        }
        
        moc.persistentStoreCoordinator = coordinator
    }
    
    public convenience init(withEntities entities: [NSEntityDescription], configuration: PersistentStoreConfiguration = PersistentStoreConfiguration()) {
        Logger.verbose("\(#function)", callingClass: type(of: self))
        let model = NSManagedObjectModel()
        model.entities = entities
        self.init(withModel: model, configuration: configuration)
    }
    
    public convenience init(fromBundle bundle: Bundle, modelName: String? = nil, configuration: PersistentStoreConfiguration = PersistentStoreConfiguration()) {
        Logger.verbose("\(#function)", callingClass: type(of: self))
        var name: String? = modelName
        if modelName == nil {
            name = bundle.bundleName
        }
        
        guard let momd = name else {
            fatalError("Model name is nil.")
        }
        
        guard let url = bundle.url(forResource: momd, withExtension: CoreData.mergedManagedObjectModelExtension) else {
            fatalError("Model with name '\(momd)' not found.")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Model failed to load contents of url '\(url)'.")
        }
        
        self.init(withModel: model, configuration: configuration)
    }
    
    deinit {
        do {
            try persistentStoreCoordinator.remove(persistentStore)
        } catch {
            Logger.error((error as NSError), message: "removePersistentStore", callingClass: type(of: self))
        }
    }
}
