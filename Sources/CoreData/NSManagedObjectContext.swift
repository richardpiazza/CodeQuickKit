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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NSManagedObjectContext.managedObjectContextDidSave(_:)), name: NSManagedObjectContextDidSaveNotification, object: context)
    }
    
    /// Unregisterd a parent `NSManagedObjectContext` from notifications.
    func unregisterFromDidSaveNotification(privateContext context: NSManagedObjectContext) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: context)
    }
    
    /// Calls `mergeChangesFromContextDidSaveNotification()` on the `NSManagedObjectContext`
    /// registered in `registerForDidSaveNotification(privateContext:)`
    dynamic func managedObjectContextDidSave(notification: NSNotification) {
        self.mergeChangesFromContextDidSaveNotification(notification)
    }
    
    /// Executes a set of operations on a secondary `NSManagedObjectContext`.
    /// A `save()` is triggered, and the changes are merged into the calling `NSManagedObjectContext`.
    func mergeChanges(performingBlock block: (privateContext: NSManagedObjectContext) -> Void, withCompletion completion: (error: NSError?) -> Void) {
        var e: NSError? = nil
        
        let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.parentContext = self
        
        self.registerForDidSaveNotification(privateContext: privateContext)
        
        privateContext.performBlockAndWait { 
            block(privateContext: privateContext)
            
            do {
                try privateContext.save()
            } catch {
                e = error as NSError
            }
        }
        
        self.unregisterFromDidSaveNotification(privateContext: privateContext)
        
        completion(error: e)
    }
}
