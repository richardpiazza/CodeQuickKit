#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))

import Foundation

public enum UbiquityState {
    case disabled
    case deviceOnly
    case available
    
    public var description: String {
        switch self {
        case .disabled: return "Disabled"
        case .deviceOnly: return "Device Only"
        case .available: return "Available"
        }
    }
    
    public var longDescription: String {
        switch self {
        case .disabled: return "iCloud is not enabled on this device."
        case .deviceOnly: return "iCloud is enabled, but the application container does not exist."
        case .available: return "iCloud is enabled, and the application container is ready."
        }
    }
}

public enum UbiquityError: Error {
    case invalidState
    
    public var localizedDescription: String {
        return "Invalid Ubiquity State: This application does not have access to a valid iCloud ubiquity container."
    }
}

public protocol UbiquityContainerDelegate {
    func ubiquityStateDidChange(_ oldState: UbiquityState, newState: UbiquityState)
}

open class UbiquityContainer: UbiquityContainerDelegate {
    public static let defaultContainer: UbiquityContainer = UbiquityContainer()
    
    public internal(set) var identifier: String?
    public internal(set) var directory: URL?
    public internal(set) var ubiquityIdentityToken = FileManager.default.ubiquityIdentityToken
    public var delegate: UbiquityContainerDelegate?
    
    public var ubiquityState: UbiquityState {
        guard let _ = ubiquityIdentityToken else {
            return .disabled
        }
        
        guard let _ = directory else {
            return .deviceOnly
        }
        
        return .available
    }
    
    public init(identifier: String? = nil, delegate: UbiquityContainerDelegate? = nil) {
        self.identifier = identifier
        self.delegate = delegate != nil ? delegate : self
        
        NotificationCenter.default.addObserver(self, selector: #selector(UbiquityContainer.ubiquityIdentityDidChange(_:)), name: NSNotification.Name.NSUbiquityIdentityDidChange, object: nil)
        
        let oldState = ubiquityState
        
        DispatchQueue.global(qos: .default).async { 
            self.directory = FileManager.default.url(forUbiquityContainerIdentifier: identifier)
            let newState = self.ubiquityState
            
            if let delegate = self.delegate {
                DispatchQueue.main.async(execute: {
                    delegate.ubiquityStateDidChange(oldState, newState: newState)
                })
            }
        }
    }
    
    @objc fileprivate func ubiquityIdentityDidChange(_ notification: Notification) {
        let oldState = ubiquityState
        self.ubiquityIdentityToken = FileManager.default.ubiquityIdentityToken
        let newState = ubiquityState
        
        if let delegate = self.delegate {
            delegate.ubiquityStateDidChange(oldState, newState: newState)
        }
    }
    
    public func ubiquityStateDidChange(_ oldState: UbiquityState, newState: UbiquityState) {
        Log.debug("Ubiquity State did change from '\(oldState.description)' to '\(newState.description)'")
    }
}

#endif
