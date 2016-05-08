//===----------------------------------------------------------------------===//
//
// Ubiquity.swift
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

public enum UbiquityState {
    case Disabled
    case DeviceOnly
    case Available
    
    var description: String {
        switch self {
        case .Disabled: return "Disabled"
        case .DeviceOnly: return "Device Only"
        case .Available: return "Available"
        }
    }
    
    var longDescription: String {
        switch self {
        case .Disabled: return "iCloud is not enabled on this device."
        case .DeviceOnly: return "iCloud is enabled, but the application container does not exist."
        case .Available: return "iCloud is enabled, and the application container is ready."
        }
    }
    
    static var invalidUbiquityState: NSError {
        var userInfo = [String : AnyObject]()
        userInfo[NSLocalizedDescriptionKey] = "Invalid ubiquity state."
        userInfo[NSLocalizedFailureReasonErrorKey] = "This application does not have access to a valid iCloud ubiquity container."
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = "Log into iCloud and initialize the ubiquity container."
        return NSError(domain: String(self), code: 0, userInfo: userInfo)
    }
}

public protocol UbiquityContainerDelegate {
    func ubiquityStateDidChange(oldState: UbiquityState, newState: UbiquityState)
}

public class UbiquityContainer: UbiquityContainerDelegate {
    public static let defaultContainer: UbiquityContainer = UbiquityContainer()
    
    public internal(set) var identifier: String?
    public internal(set) var directory: NSURL?
    public internal(set) var ubiquityIdentityToken = NSFileManager.defaultManager().ubiquityIdentityToken
    public var delegate: UbiquityContainerDelegate?
    
    public var ubiquityState: UbiquityState {
        guard let _ = ubiquityIdentityToken else {
            return .Disabled
        }
        
        guard let _ = directory else {
            return .DeviceOnly
        }
        
        return .Available
    }
    
    init(identifier: String? = nil, delegate: UbiquityContainerDelegate? = nil) {
        Logger.verbose("\(#function)", callingClass: self.dynamicType)
        self.identifier = identifier
        self.delegate = delegate != nil ? delegate : self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UbiquityContainer.ubiquityIdentityDidChange(_:)), name: NSUbiquityIdentityDidChangeNotification, object: nil)
        
        let oldState = ubiquityState
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            self.directory = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(identifier)
            let newState = self.ubiquityState
            
            if let delegate = self.delegate {
                dispatch_async(dispatch_get_main_queue(), {
                    delegate.ubiquityStateDidChange(oldState, newState: newState)
                })
            }
        }
    }
    
    @objc private func ubiquityIdentityDidChange(notification: NSNotification) {
        Logger.verbose("\(#function)", callingClass: self.dynamicType)
        let oldState = ubiquityState
        self.ubiquityIdentityToken = NSFileManager.defaultManager().ubiquityIdentityToken
        let newState = ubiquityState
        
        if let delegate = self.delegate {
            delegate.ubiquityStateDidChange(oldState, newState: newState)
        }
    }
    
    public func ubiquityStateDidChange(oldState: UbiquityState, newState: UbiquityState) {
        Logger.verbose("Ubiquity State did change from '\(oldState.description)' to '\(newState.description)'", callingClass: self.dynamicType)
    }
}
