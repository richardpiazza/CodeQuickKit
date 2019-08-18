import Foundation

/// Extension on `Bundle` allowing for keyed access to common paths.
public extension Bundle {
    
    /// A collection of key (strings) used to reference specific keys
    /// within an iOS App Bundle.
    struct Keys {
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
    
    /// Typically the 'Product Name' of the app.
    /// - path: Build Settings > Packaging > Product Name
    var bundleName: String? {
        return self.object(forInfoDictionaryKey: Keys.BundleName) as? String
    }
    
    /// The Display Name entered for a given target.
    /// - path: Target > General > Display Name
    var bundleDisplayName: String? {
        return self.object(forInfoDictionaryKey: Keys.BundleDisplayName) as? String
    }
    
    /// The name of the Executable the bundle produces.
    var executableName: String? {
        return self.object(forInfoDictionaryKey: Keys.BundleExecutableName) as? String
    }
    
    /// The Version specificed for the Target, typically displayed as a semantic
    /// version number like: 2.3.4
    /// - path: Target > General > Version
    var appVersion: String? {
        return self.object(forInfoDictionaryKey: Keys.AppVersion) as? String
    }
    
    /// The Build specified for the Target, typically an auto incrementing or
    /// number specicified by a build pipeline.
    /// - path: Target > General > Build
    var buildNumber: String? {
        return self.object(forInfoDictionaryKey: Keys.BuildNumber) as? String
    }
    
    /// The name of the launch UIStroyboard specified in Target > General
    var launchStoryboardName: String? {
        return self.object(forInfoDictionaryKey: Keys.LaunchScreen) as? String
    }
    
    /// The name of the main UIStroyboard specified in Target > General
    var mainStoryboardName: String? {
        return self.object(forInfoDictionaryKey: Keys.MainStoryboard) as? String
    }
}

/// Additions to Bundle for presenting information
public extension Bundle {
    /// A human-readable version of the specified app version and build number.
    /// When both pieces of information are present, the format is: {VERSION} ({BUILD})
    /// - exampple: 3.2.1 (54)
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
            Keys.BundleName : bundleName ?? "",
            Keys.BundleDisplayName : bundleDisplayName ?? "",
            Keys.BundleExecutableName : executableName ?? "",
            Keys.BundleIdentifier : bundleIdentifier ?? "",
            Keys.AppVersion : appVersion ?? "",
            Keys.BuildNumber : buildNumber ?? "",
            Keys.LaunchScreen : launchStoryboardName ?? "",
            Keys.MainStoryboard : mainStoryboardName ?? ""
        ]
    }
}
