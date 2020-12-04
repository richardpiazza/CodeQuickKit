import Foundation

/// Extension on `Bundle` allowing for keyed access to common paths.
public extension Bundle {
    
    @available(*, deprecated, renamed: "Key")
    typealias Keys = Key
    
    /// A collection of key (strings) used to reference specific keys within an iOS App Bundle.
    enum Key {
        /// CFBundleName
        case name
        /// CFBundleDisplayName
        case displayName
        /// CFBundleExecutable
        case executableName
        /// CFBundleShortVersionString
        case version
        /// CFBundleVersion
        case build
        /// CFBundleIdentifier
        case identifier
        /// UILaunchStoryboardName
        case launchStoryboard
        /// UIMainStoryboardFile
        case mainStoryboard
        
        var rawValue: String {
            #if canImport(ObjectiveC)
            switch self {
            case .name: return kCFBundleNameKey as String
            case .executableName: return kCFBundleExecutableKey as String
            case .build: return kCFBundleVersionKey as String
            case .identifier: return kCFBundleIdentifierKey as String
            default:
                break
            }
            #endif
            
            switch self {
            case .name: return "CFBundleName"
            case .displayName: return "CFBundleDisplayName"
            case .executableName: return "CFBundleExecutable"
            case .version: return "CFBundleShortVersionString"
            case .build: return "CFBundleVersion"
            case .identifier: return "CFBundleIdentifier"
            case .launchStoryboard: return "UILaunchStoryboardName"
            case .mainStoryboard: return "UIMainStoryboardFile"
            }
        }
        
        @available(*, deprecated, renamed: "Key.name.rawValue")
        public static var BundleName: String { Key.name.rawValue }
        @available(*, deprecated, renamed: "Key.displayName.rawValue")
        public static var BundleDisplayName: String { Key.displayName.rawValue }
        @available(*, deprecated, renamed: "Key.executableName.rawValue")
        public static var BundleExecutableName: String { Key.executableName.rawValue }
        @available(*, deprecated, renamed: "Key.version.rawValue")
        public static var AppVersion: String { Key.version.rawValue }
        @available(*, deprecated, renamed: "Key.build.rawValue")
        public static var BuildNumber: String { Key.build.rawValue }
        @available(*, deprecated, renamed: "Key.identifier.rawValue")
        public static var BundleIdentifier: String { Key.identifier.rawValue }
        @available(*, deprecated, renamed: "Key.launchStoryboard.rawValue")
        public static var LaunchScreen: String { Key.launchStoryboard.rawValue }
        @available(*, deprecated, renamed: "Key.mainStoryboard.rawValue")
        public static var MainStoryboard: String { Key.mainStoryboard.rawValue }
    }
    
    private func object(forInfoDictionaryKey key: Key) -> Any? {
        return object(forInfoDictionaryKey: key.rawValue)
    }
    
    /// Typically the 'Product Name' of the app.
    /// - path: Build Settings > Packaging > Product Name
    var bundleName: String? { object(forInfoDictionaryKey: .name) as? String }
    
    /// The Display Name entered for a given target.
    /// - path: Target > General > Display Name
    var bundleDisplayName: String? { object(forInfoDictionaryKey: .displayName) as? String }
    
    /// The name of the Executable the bundle produces.
    var executableName: String? { object(forInfoDictionaryKey: .executableName) as? String }
    
    /// The Version specified for the Target, typically displayed as a semantic
    /// version number like: 2.3.4
    /// - path: Target > General > Version
    var appVersion: String? { object(forInfoDictionaryKey: .version) as? String }
    
    /// The Build specified for the Target, typically an auto incrementing or
    /// number specified by a build pipeline.
    /// - path: Target > General > Build
    var buildNumber: String? { object(forInfoDictionaryKey: .build) as? String }
    
    /// The name of the launch UIStoryboard specified in Target > General
    var launchStoryboardName: String? { object(forInfoDictionaryKey: .launchStoryboard) as? String }
    
    /// The name of the main UIStoryboard specified in Target > General
    var mainStoryboardName: String? { object(forInfoDictionaryKey: .mainStoryboard) as? String }
}

/// Additions to Bundle for presenting information
public extension Bundle {
    /// A human-readable version of the specified app version and build number.
    /// When both pieces of information are present, the format is: {VERSION} ({BUILD})
    /// - example: 3.2.1 (54)
    var presentableVersionNumber: String {
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
    var presentableDictionary: [String : String] {
        return [
            Key.name.rawValue : bundleName ?? "",
            Key.displayName.rawValue : bundleDisplayName ?? "",
            Key.executableName.rawValue : executableName ?? "",
            Key.identifier.rawValue : bundleIdentifier ?? "",
            Key.version.rawValue : appVersion ?? "",
            Key.build.rawValue : buildNumber ?? "",
            Key.launchStoryboard.rawValue : launchStoryboardName ?? "",
            Key.mainStoryboard.rawValue : mainStoryboardName ?? ""
        ]
    }
}
