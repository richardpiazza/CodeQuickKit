//===----------------------------------------------------------------------===//
//
// NSBundle.swift
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

import UIKit

public enum BundleConfiguration {
    case Debug
    case TestFlight
    case AppStore
    
    public var description: String {
        switch self {
        case .Debug: return "Debug"
        case .TestFlight: return "TestFlight"
        case .AppStore: return "App Store"
        }
    }
}

public extension NSBundle {
    
    public struct Keys {
        static let BundleName = "CFBundleName"
        static let BundleDisplayName = "CFBundleDisplayName"
        static let BundleExecutableName = "CFBundleExecutable"
        static let AppVersion = "CFBundleShortVersionString"
        static let BuildNumber = "CFBundleVersion"
        static let BundleIdentifier = "CFBundleIdentifier"
        static let LaunchScreen = "UILaunchStoryboardName"
        static let MainStoryboard = "UIMainStoryboardFile"
    }
    
    public var bundleName: String? { return self.objectForInfoDictionaryKey(Keys.BundleName) as? String }
    public var bundleDisplayName: String? { return self.objectForInfoDictionaryKey(Keys.BundleDisplayName) as? String }
    public var executableName: String? { return self.objectForInfoDictionaryKey(Keys.BundleExecutableName) as? String }
    public var appVersion: String? { return self.objectForInfoDictionaryKey(Keys.AppVersion) as? String }
    public var buildNumber: String? { return self.objectForInfoDictionaryKey(Keys.BuildNumber) as? String }
    public var launchScreenStoryboardName: String? { return self.objectForInfoDictionaryKey(Keys.LaunchScreen) as? String }
    public var mainStoryboardName: String? { return self.objectForInfoDictionaryKey(Keys.MainStoryboard) as? String }
    
    public var isSandboxReceipt: Bool { return appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" }
    
    public var configuration: BundleConfiguration {
        #if DEBUG
            return .Debug
        #else
            return (isSandboxReceipt) ? .TestFlight : .AppStore
        #endif
    }
    
    /// This call potentially throws an execption that cannot be caught.
    public var launchScreenStoryboard: UIStoryboard? {
        guard let name = launchScreenStoryboardName else {
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
    
    override var description: String {
        return "Bundle: \(dictionary)"
    }
    
    public var dictionary: [String : String] {
        return [
            Keys.BundleName : (bundleName == nil) ? "" : bundleName!,
            Keys.BundleDisplayName : (bundleDisplayName == nil) ? "" : bundleDisplayName!,
            Keys.BundleExecutableName : (executableName == nil) ? "" : executableName!,
            Keys.BundleIdentifier : (bundleIdentifier == nil) ? "" : bundleIdentifier!,
            Keys.AppVersion : (appVersion == nil) ? "" : appVersion!,
            Keys.BuildNumber : (buildNumber == nil) ? "" : buildNumber!,
            Keys.LaunchScreen : (launchScreenStoryboardName == nil) ? "" : launchScreenStoryboardName!,
            Keys.MainStoryboard : (mainStoryboardName == nil) ? "" : mainStoryboardName!,
            "Configuration" : configuration.description
        ]
    }
    
    public var data: NSData? {
        do {
            return try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
        } catch {
            print(error)
            return nil
        }
    }
    
    public func moduleClass(forClassNamed classNamed: String) -> AnyClass {
        var moduleClass: AnyClass? = NSClassFromString(classNamed)
        if moduleClass != nil {
            return moduleClass!
        }
        
        if let prefix = bundleDisplayName {
            let underscored = prefix.stringByReplacingOccurrencesOfString(" " , withString: "_")
            moduleClass = NSClassFromString("\(underscored).\(classNamed)")
            if moduleClass != nil {
                return moduleClass!
            }
        }
        
        if let prefix = bundleName {
            let underscored = prefix.stringByReplacingOccurrencesOfString(" " , withString: "_")
            moduleClass = NSClassFromString("\(underscored).\(classNamed)")
            if moduleClass != nil {
                return moduleClass!
            }
        }
        
        return NSNull.self
    }
    
    public func singularizedModuleClass(forClassNamed classNamed: String) -> AnyClass {
        var moduleClass: AnyClass? = self.moduleClass(forClassNamed: classNamed)
        if moduleClass != nil {
            return moduleClass!
        }
        
        let firstRange = Range(start: classNamed.startIndex, end: classNamed.startIndex.advancedBy(1))
        let endRange = Range(start: classNamed.endIndex.advancedBy(-1), end: classNamed.endIndex)
        
        var singular = classNamed
        singular.replaceRange(firstRange, with: singular.substringWithRange(firstRange).uppercaseString)
        if singular.lowercaseString.hasSuffix("s") {
            singular.replaceRange(endRange, with: "")
        }
        
        moduleClass = self.moduleClass(forClassNamed: singular)
        if moduleClass != nil {
            return moduleClass!
        }
        
        return NSNull.self
    }
}
