//===----------------------------------------------------------------------===//
//
// NSManagedObjectContext.swift
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

public extension NSManagedObjectContext {
    /// Registers a parent `NSManagedObjectContext` in the `NSNotificationCenter`
    /// for watching `NSManagedObjectContextDidSaveNotification` notifications.
    func registerForDidSaveNotification(privateContext context: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(self, selector: #selector(NSManagedObjectContext.managedObjectContextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    /// Unregisterd a parent `NSManagedObjectContext` from notifications.
    func unregisterFromDidSaveNotification(privateContext context: NSManagedObjectContext) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    /// Calls `mergeChangesFromContextDidSaveNotification()` on the `NSManagedObjectContext`
    /// registered in `registerForDidSaveNotification(privateContext:)`
    dynamic func managedObjectContextDidSave(_ notification: Notification) {
        self.mergeChanges(fromContextDidSave: notification)
    }
    
    /// Executes a set of operations on a secondary `NSManagedObjectContext`.
    /// The changes are merged into the calling `NSManagedObjectContext` and a `save()` is triggered.
    public func mergeChanges(performingBlock block: @escaping (_ privateContext: NSManagedObjectContext) -> Void, savingWithCompletion completion: (_ error: NSError?) -> Void) {
        var e: NSError? = nil
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = self
        
        self.registerForDidSaveNotification(privateContext: privateContext)
        
        privateContext.performAndWait {
            block(privateContext)
            
            do {
                try privateContext.save()
            } catch {
                e = error as NSError
            }
        }
        
        self.unregisterFromDidSaveNotification(privateContext: privateContext)
        
        do {
            try self.save()
        } catch {
            e = error as NSError
        }
        
        completion(e)
    }
    
    /// Executes a set of operations on a secondary `NSManagedObjectContext`.
    /// The changes are merged into the calling `NSManagedObjectContext`.
    /// - note: a `save()` is not triggered on the calling context.
    public func mergeChanges(performingBlock block: @escaping (_ privateContext: NSManagedObjectContext) -> Void, withCompletion completion: (_ error: NSError?) -> Void) {
        var e: NSError? = nil
        
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = self
        
        self.registerForDidSaveNotification(privateContext: privateContext)
        
        privateContext.performAndWait { 
            block(privateContext)
            
            do {
                try privateContext.save()
            } catch {
                e = error as NSError
            }
        }
        
        self.unregisterFromDidSaveNotification(privateContext: privateContext)
        
        completion(e)
    }
}
