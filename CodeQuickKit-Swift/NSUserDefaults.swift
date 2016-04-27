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

public struct UserDefault {
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

public protocol UserDefaults {
    func dictionaryForKey(aKey: String) -> [String : AnyObject]?
    func setDictionary(aDictionary: [String : AnyObject]?, forKey aKey: String)
}

extension UserDefaults {
    func userDefaultForKey(key: String) -> UserDefault? {
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
        
        return UserDefault(value: value, timestamp: timestamp, build: build)
    }
    
    func valueForKey(key: String) -> NSObject? {
        return userDefaultForKey(key)?.value
    }
    
    func setUserDefault(userDefault: UserDefault, forKey key: String) {
        var dictionary = [String : NSObject]()
        dictionary[KeyValueUbiquityContainer.Keys.value] = userDefault.value
        dictionary[KeyValueUbiquityContainer.Keys.timestamp] = userDefault.timestamp
        if let build = userDefault.build {
            dictionary[KeyValueUbiquityContainer.Keys.build] = build
        }
        
        self.setDictionary(dictionary, forKey: key)
    }
    
    func setValue(value: NSObject, forKey key: String) {
        let userDefault = UserDefault(value: value, timestamp: NSDate(), build: nil)
        self.setUserDefault(userDefault, forKey: key)
    }
}

extension NSUserDefaults: UserDefaults {
    public func setDictionary(aDictionary: [String : AnyObject]?, forKey aKey: String) {
        if let dictionary = aDictionary {
            self.setObject(dictionary, forKey: aKey)
        } else {
            self.removeObjectForKey(aKey)
        }
    }
}

extension NSUbiquitousKeyValueStore: UserDefaults {
}

public protocol KeyValueUbiquityContainerDelegate {
    func shouldReplaceUserDefaults(existingDefualt oldValue: UserDefault, withDefault newValue: UserDefault, forKey key: String) -> Bool
    func didSetUserDefault(userDefault: UserDefault, forKey key: String)
}

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
                if !keyValueStore.synchronize() {
                    Logger.log(.Error, message: "Failed to synchronize Ubiquitious Key Value Store", error: nil, type: self.dynamicType)
                }
            }
        }
    }
    public var keyValueDelegate: KeyValueUbiquityContainerDelegate?
    
    convenience init(identifier: String?, delegate: UbiquityContainerDelegate?, keyValueDelegate: KeyValueUbiquityContainerDelegate?) {
        self.init(identifier: identifier, delegate: delegate)
        self.keyValueDelegate = keyValueDelegate
    }
    
    public override func ubiquityStateDidChange(oldState: UbiquityState, newState: UbiquityState) {
        if oldState == .Available && newState != .Available {
            self.keyValueStore = nil
        } else if oldState != .Available && newState == .Available {
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
                guard let ubiquityUserDefault = keyValueStore.userDefaultForKey(key) else {
                    Logger.debug("Removing NSUserDefaults object for key '\(key)'")
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
                    continue
                }
                
                guard let standardUserDefault = NSUserDefaults.standardUserDefaults().userDefaultForKey(key) else {
                    NSUserDefaults.standardUserDefaults().setUserDefault(ubiquityUserDefault, forKey: key)
                    if let delegate = keyValueDelegate {
                        delegate.didSetUserDefault(ubiquityUserDefault, forKey: key)
                    }
                    continue
                }
                
                var replace = true
                if let delegate = self.keyValueDelegate {
                    replace = delegate.shouldReplaceUserDefaults(existingDefualt: standardUserDefault, withDefault: ubiquityUserDefault, forKey: key)
                }
                
                if replace {
                    NSUserDefaults.standardUserDefaults().setUserDefault(ubiquityUserDefault, forKey: key)
                    if let delegate = keyValueDelegate {
                        delegate.didSetUserDefault(ubiquityUserDefault, forKey: key)
                    }
                }
            }
        default: break
        }
        
    }
}

public extension NSUserDefaults {
    public static var ubiquityUserDefaults: KeyValueUbiquityContainer = KeyValueUbiquityContainer()
    
    public static func setUserDefault(userDefault: UserDefault, forKey key: String) {
        NSUserDefaults.ubiquityUserDefaults.keyValueStore?.setUserDefault(userDefault, forKey: key)
    }
    
    public static func userDefaultForKey(key: String) -> UserDefault? {
        return NSUserDefaults.ubiquityUserDefaults.keyValueStore?.userDefaultForKey(key)
    }
}
