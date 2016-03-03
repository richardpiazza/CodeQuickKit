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
    
    var bundleName: String? { return self.objectForInfoDictionaryKey(Keys.BundleName) as? String }
    var bundleDisplayName: String? { return self.objectForInfoDictionaryKey(Keys.BundleDisplayName) as? String }
    var executableName: String? { return self.objectForInfoDictionaryKey(Keys.BundleExecutableName) as? String }
    var appVersion: String? { return self.objectForInfoDictionaryKey(Keys.AppVersion) as? String }
    var buildNumber: String? { return self.objectForInfoDictionaryKey(Keys.BuildNumber) as? String }
    var launchScreenStoryboardName: String? { return self.objectForInfoDictionaryKey(Keys.LaunchScreen) as? String }
    var mainStoryboardName: String? { return self.objectForInfoDictionaryKey(Keys.MainStoryboard) as? String }

    /// This call potentially throws an execption that cannot be caught.
    var launchScreenStoryboard: UIStoryboard? {
        guard let name = launchScreenStoryboardName else {
            return nil
        }
        
        return UIStoryboard(name: name, bundle: self)
    }
    
    /// This call potentially throws an execption that cannot be caught.
    var mainStoryboard: UIStoryboard? {
        guard let name = mainStoryboardName else {
            return nil
        }
        
        return UIStoryboard(name: name, bundle: self)
    }
    
    override var description: String {
        return "Bundle: \(dictionary)"
    }
    
    var dictionary: [String : String] {
        return [
            Keys.BundleName : (self.bundleName == nil) ? "" : self.bundleName!,
            Keys.BundleDisplayName : (self.bundleDisplayName == nil) ? "" : self.bundleDisplayName!,
            Keys.BundleExecutableName : (self.executableName == nil) ? "" : self.executableName!,
            Keys.BundleIdentifier : (self.bundleIdentifier == nil) ? "" : self.bundleIdentifier!,
            Keys.AppVersion : (self.appVersion == nil) ? "" : self.appVersion!,
            Keys.BuildNumber : (self.buildNumber == nil) ? "" : self.buildNumber!,
            Keys.LaunchScreen : (self.launchScreenStoryboardName == nil) ? "" : self.launchScreenStoryboardName!,
            Keys.MainStoryboard : (self.mainStoryboardName == nil) ? "" : self.mainStoryboardName!
        ]
    }
    
    var data: NSData? {
        do {
            return try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
        } catch {
            print(error)
            return nil
        }
    }
}
