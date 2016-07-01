//===----------------------------------------------------------------------===//
//
// NSUserDefaults.swift
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

/// ### UserDefault
/// A defined structure for storing information in `NSUserDefaults` and `NSUbiquitousKeyValueStore`.
/// The `timestamp` and optional `build` variables allow for comparisson during syncing.
public struct KeyValueItem {
    public var value: NSObject
    public var timestamp: NSDate = NSDate()
    public var build: NSString?
    
    public init(value: NSObject, timestamp: NSDate? = nil, build: NSString? = nil) {
        self.value = value
        if let date = timestamp {
            self.timestamp = date
        }
        self.build = build
    }
}

/// ### KeyValueStorage
/// A protocol declaring dictionary conformance.
/// - note: These methods are taken from `NSUbiquitousKeyValueStore`.
public protocol KeyValueStorage {
    func dictionaryForKey(aKey: String) -> [String : AnyObject]?
    func setDictionary(aDictionary: [String : AnyObject]?, forKey aKey: String)
}

extension KeyValueStorage {
    func itemForKey(key: String) -> KeyValueItem? {
        guard let dictionary = self.dictionaryForKey(key) else {
            return nil
        }
        
        guard let value = dictionary[KeyValueUbiquityContainer.Keys.value] as? NSObject else {
            return nil
        }
        
        guard let timestamp = dictionary[KeyValueUbiquityContainer.Keys.timestamp] as? NSDate else {
            return nil
        }
        
        let build = dictionary[KeyValueUbiquityContainer.Keys.build] as? NSString
        
        return KeyValueItem(value: value, timestamp: timestamp, build: build)
    }
    
    func valueForKey(key: String) -> NSObject? {
        return itemForKey(key)?.value
    }
    
    func setItem(item: KeyValueItem, forKey key: String) {
        var dictionary = [String : NSObject]()
        dictionary[KeyValueUbiquityContainer.Keys.value] = item.value
        dictionary[KeyValueUbiquityContainer.Keys.timestamp] = item.timestamp
        if let build = item.build {
            dictionary[KeyValueUbiquityContainer.Keys.build] = build
        }
        
        self.setDictionary(dictionary, forKey: key)
    }
    
    func setValue(value: NSObject, forKey key: String) {
        self.setItem(KeyValueItem(value: value, timestamp: NSDate(), build: nil), forKey: key)
    }
}

extension NSUserDefaults: KeyValueStorage {
    public func setDictionary(aDictionary: [String : AnyObject]?, forKey aKey: String) {
        if let dictionary = aDictionary {
            self.setObject(dictionary, forKey: aKey)
        } else {
            self.removeObjectForKey(aKey)
        }
    }
}

extension NSUbiquitousKeyValueStore: KeyValueStorage {
}

public protocol KeyValueUbiquityContainerDelegate {
    func shouldReplaceItem(existingItem existingItem: KeyValueItem, withItem newItem: KeyValueItem, forKey key: String) -> Bool
    func didSetItem(item: KeyValueItem, forKey key: String)
}

/// ### KeyValueUbiquityContainer
/// A subclass of `UbiquityContainer` that manages access to a `NSUbiquitousKeyValueStore` instance.
public class KeyValueUbiquityContainer: UbiquityContainer {
    public struct Keys {
        static let value = "value"
        static let timestamp = "timestamp"
        static let build = "build"
    }
    
    public var keyValueStore: NSUbiquitousKeyValueStore? {
        willSet {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: self.keyValueStore)
        }
        didSet {
            if let keyValueStore = self.keyValueStore {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KeyValueUbiquityContainer.nsUbiquitiousKeyValueStoreDidChangeExternally(_:)), name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: keyValueStore)
                keyValueStore.synchronize()
            }
        }
    }
    public var keyValueDelegate: KeyValueUbiquityContainerDelegate?
    
    convenience init(identifier: String?, delegate: UbiquityContainerDelegate?, keyValueDelegate: KeyValueUbiquityContainerDelegate?) {
        self.init(identifier: identifier, delegate: delegate)
        self.keyValueDelegate = keyValueDelegate
    }
    
    public override func ubiquityStateDidChange(oldState: UbiquityState, newState: UbiquityState) {
        switch newState {
        case .Disabled:
            self.keyValueStore = nil
        default:
            self.keyValueStore = NSUbiquitousKeyValueStore.defaultStore()
        }
    }
    
    @objc func nsUbiquitiousKeyValueStoreDidChangeExternally(notification: NSNotification) {
        guard let keyValueStore = self.keyValueStore else {
            return
        }
        
        guard let dictionary = notification.userInfo else {
            return
        }
        
        guard let changeReason = dictionary[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }
        
        switch changeReason {
        case NSUbiquitousKeyValueStoreServerChange, NSUbiquitousKeyValueStoreInitialSyncChange:
            guard let changedKeys = dictionary[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
                return
            }
            
            for key in changedKeys {
                guard let ubiquityItem = keyValueStore.itemForKey(key) else {
                    Logger.debug("Removing NSUserDefaults object for key '\(key)'")
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
                    continue
                }
                
                guard let standardItem = NSUserDefaults.standardUserDefaults().itemForKey(key) else {
                    NSUserDefaults.standardUserDefaults().setItem(ubiquityItem, forKey: key)
                    if let delegate = keyValueDelegate {
                        delegate.didSetItem(ubiquityItem, forKey: key)
                    }
                    continue
                }
                
                var replace = true
                if let delegate = self.keyValueDelegate {
                    replace = delegate.shouldReplaceItem(existingItem: standardItem, withItem: ubiquityItem, forKey: key)
                }
                
                if replace {
                    NSUserDefaults.standardUserDefaults().setItem(ubiquityItem, forKey: key)
                    if let delegate = keyValueDelegate {
                        delegate.didSetItem(ubiquityItem, forKey: key)
                    }
                }
            }
        default: break
        }
        
        Logger.verbose("\(keyValueStore.dictionaryRepresentation)")
    }
}

public extension NSUserDefaults {
    public static var ubiquityUserDefaults: KeyValueUbiquityContainer = KeyValueUbiquityContainer()
    
    /// Attempts to set an item on `NSUbiquitousKeyValueStore`. Will fallback to `NSUserDefaults`
    public static func setItem(item: KeyValueItem, forKey key: String) {
        if let keyValueStore = NSUserDefaults.ubiquityUserDefaults.keyValueStore {
            keyValueStore.setItem(item, forKey: key)
            if let delegate = ubiquityUserDefaults.keyValueDelegate {
                delegate.didSetItem(item, forKey: key)
            }
        } else {
            NSUserDefaults.standardUserDefaults().setItem(item, forKey: key)
        }
    }
    
    /// Attemps to retrieve an item from `NSUbiquitousKeyValueStore`. Will fallback to `NSUserDefaults`
    public static func itemForKey(key: String) -> KeyValueItem? {
        if let item = NSUserDefaults.ubiquityUserDefaults.keyValueStore?.itemForKey(key) {
            return item
        }
        
        return NSUserDefaults.standardUserDefaults().itemForKey(key)
    }
}
