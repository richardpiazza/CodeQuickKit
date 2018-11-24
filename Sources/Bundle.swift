import Foundation

/// A collection of key (strings) used to reference specific keys
/// within an iOS App Bundle.
public struct BundleKeys {
    /// CFBundleName
    public static let BundleName = kCFBundleNameKey as String
    /// CFBundleDisplayName
    public static let BundleDisplayName = "CFBundleDisplayName"
    /// CFBundleExecutable
    public static let BundleExecutableName = kCFBundleExecutableKey as String
    /// CFBundleShortVersionString
    public static let AppVersion = "CFBundleShortVersionString"
    /// CFBundleVersion
    public static let BuildNumber = kCFBundleVersionKey as String
    /// CFBundleIdentifier
    public static let BundleIdentifier = kCFBundleIdentifierKey as String
    /// UILaunchStoryboardName
    public static let LaunchScreen = "UILaunchStoryboardName"
    /// UIMainStoryboardFile
    public static let MainStoryboard = "UIMainStoryboardFile"
}

/// Extension on `Bundle` allowing for keyed access to common paths.
public extension Bundle {
    /// Typically the 'Product Name' of the app.
    /// - path: Build Settings > Packaging > Product Name
    public var bundleName: String? {
        return self.object(forInfoDictionaryKey: BundleKeys.BundleName) as? String
    }
    
    /// The Display Name entered for a given target.
    /// - path: Target > General > Display Name
    public var bundleDisplayName: String? {
        return self.object(forInfoDictionaryKey: BundleKeys.BundleDisplayName) as? String
    }
    
    /// The name of the Executable the bundle produces.
    public var executableName: String? {
        return self.object(forInfoDictionaryKey: BundleKeys.BundleExecutableName) as? String
    }
    
    /// The Version specificed for the Target, typically displayed as a semantic
    /// version number like: 2.3.4
    /// - path: Target > General > Version
    public var appVersion: String? {
        return self.object(forInfoDictionaryKey: BundleKeys.AppVersion) as? String
    }
    
    /// The Build specified for the Target, typically an auto incrementing or
    /// number specicified by a build pipeline.
    /// - path: Target > General > Build
    public var buildNumber: String? {
        return self.object(forInfoDictionaryKey: BundleKeys.BuildNumber) as? String
    }
    
    /// The name of the launch UIStroyboard specified in Target > General
    public var launchStoryboardName: String? {
        return self.object(forInfoDictionaryKey: BundleKeys.LaunchScreen) as? String
    }
    
    /// The name of the main UIStroyboard specified in Target > General
    public var mainStoryboardName: String? {
        return self.object(forInfoDictionaryKey: BundleKeys.MainStoryboard) as? String
    }
}

/// Additions to Bundle for presenting information
public extension Bundle {
    /// A human-readable version of the specified app version and build number.
    /// When both pieces of information are present, the format is: {VERSION} ({BUILD})
    /// - exampple: 3.2.1 (54)
    public var presentableVersionNumber: String {
        var output: [String] = []
        if let version = appVersion {
            output.append(version)
        }
        if let build = buildNumber {
            output.append("(\(build))")
        }
        return output.joined(separator: " ")
    }
    
    /// Common iOS App bundle keys and values for printing/logging.
    public var presentableDictionary: [String : String] {
        return [
            BundleKeys.BundleName : bundleName ?? "",
            BundleKeys.BundleDisplayName : bundleDisplayName ?? "",
            BundleKeys.BundleExecutableName : executableName ?? "",
            BundleKeys.BundleIdentifier : bundleIdentifier ?? "",
            BundleKeys.AppVersion : appVersion ?? "",
            BundleKeys.BuildNumber : buildNumber ?? "",
            BundleKeys.LaunchScreen : launchStoryboardName ?? "",
            BundleKeys.MainStoryboard : mainStoryboardName ?? ""
        ]
    }
}

/// Extension to `Bundle` that adds `Decodable` support for JSON resources.
public extension Bundle {
    /// Finds the URL for a bundled resource and returns a `Data` representation.
    ///
    /// - parameter resource: The resource name (sans extension)
    /// - parameter extension: The resource extension (sans .)
    /// - throws: CocoaError
    /// - returns: A Data representation of the specified resource.
    public func data(forResource resource: String, withExtension `extension`: String = "json") throws -> Data {
        guard let fileURL = self.url(forResource: resource, withExtension: `extension`) else {
            throw CocoaError(.fileNoSuchFile)
        }
        
        return try Data(contentsOf: fileURL, options: .mappedIfSafe)
    }
    
    /// Loads data from a bundle resource and decodes using the specified decoder.
    ///
    /// - parameter type: The `Decodable` type
    /// - parameter resource: The resource name (sans extension)
    /// - parameter extension: The resource extension (sans .)
    /// - parameter decoder: The JSONDecoder used to produce the `ofType` output.
    /// - throws: CocoaError / DecodingError
    /// - returns: An object of the specified `Decodable` type.
    public func decodableData<T: Decodable>(ofType type: T.Type, forResource resource: String, withExtension `extension`: String = "json", usingDecoder decoder: JSONDecoder = JSONDecoder()) throws -> T {
        let data = try self.data(forResource: resource, withExtension: `extension`)
        return try decoder.decode(type, from: data)
    }
}

#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
public extension Bundle {
    /// Attempts to determine the "full" modularized name for a given class.
    /// For example: when using CodeQuickKit as a module, the moduleClass for
    /// the `WebAPI` class would be `CodeQuickKit.WebAPI`.
    public func moduleClass(forClassNamed classNamed: String) -> AnyClass {
        var moduleClass: AnyClass? = NSClassFromString(classNamed)
        if moduleClass != nil && moduleClass != NSNull.self {
            return moduleClass!
        }
        
        if let prefix = bundleDisplayName {
            let underscored = prefix.replacingOccurrences(of: " " , with: "_")
            moduleClass = NSClassFromString("\(underscored).\(classNamed)")
            if moduleClass != nil && moduleClass != NSNull.self {
                return moduleClass!
            }
        }
        
        if let prefix = bundleName {
            let underscored = prefix.replacingOccurrences(of: " " , with: "_")
            moduleClass = NSClassFromString("\(underscored).\(classNamed)")
            if moduleClass != nil && moduleClass != NSNull.self {
                return moduleClass!
            }
        }
        
        return NSNull.self
    }
    
    /// Takes the moduleClass for a given class and attempts to singularize it.
    public func singularizedModuleClass(forClassNamed classNamed: String) -> AnyClass {
        var moduleClass: AnyClass? = self.moduleClass(forClassNamed: classNamed)
        if moduleClass != nil && moduleClass != NSNull.self {
            return moduleClass!
        }
        
        let firstRange = classNamed.startIndex..<classNamed.index(classNamed.startIndex, offsetBy: 1)
        let endRange = classNamed.index(classNamed.endIndex, offsetBy: -1)..<classNamed.endIndex
        
        var singular = classNamed
        singular.replaceSubrange(firstRange, with: singular[firstRange].uppercased())
        if singular.lowercased().hasSuffix("s") {
            singular.replaceSubrange(endRange, with: "")
        }
        
        moduleClass = self.moduleClass(forClassNamed: singular)
        if moduleClass != nil && moduleClass != NSNull.self {
            return moduleClass!
        }
        
        return NSNull.self
    }
}
#endif

#if os(iOS) || os(tvOS)
import UIKit

public extension Bundle {
    /// This call potentially throws an execption that cannot be caught.
    public var launchScreenStoryboard: UIStoryboard? {
        guard let name = launchStoryboardName else {
            return nil
        }
        
        return UIStoryboard(name: name, bundle: self)
    }
    
    /// This call potentially throws an execption that cannot be caught.
    public var mainStoryboard: UIStoryboard? {
        guard let name = mainStoryboardName else {
            return nil
        }
        
        return UIStoryboard(name: name, bundle: self)
    }
}
#endif
