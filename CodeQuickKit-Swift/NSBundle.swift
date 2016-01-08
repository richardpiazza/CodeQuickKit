//===----------------------------------------------------------------------===//
//
// NSBundle.swift
//
// Copyright (c) 2016 Richard Piazza
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

extension NSBundle {
    @nonobjc static let BundleNameKey = "CFBundleName"
    @nonobjc static let BundleDisplayNameKey = "CFBundleDisplayName"
    @nonobjc static let BundleExecutableNameKey = "CFBundleExecutable"
    @nonobjc static let AppVersionKey = "CFBundleShortVersionString"
    @nonobjc static let BuildNumberKey = "CFBundleVersion"
    @nonobjc static let BundleIdentifierKey = "CFBundleIdentifier"
    @nonobjc static let LaunchScreenKey = "UILaunchStoryboardName"
    @nonobjc static let MainStoryboardKey = "UIMainStoryboardFile"
    
    var bundleName: String {
        if let value = self.objectForInfoDictionaryKey(NSBundle.BundleNameKey) as? String {
            return value
        }
        return ""
    }
    
    var bundleDisplayName: String {
        if let value = self.objectForInfoDictionaryKey(NSBundle.BundleDisplayNameKey) as? String {
            return value
        }
        return ""
    }
    
    var executableName: String {
        if let value = self.objectForInfoDictionaryKey(NSBundle.BundleExecutableNameKey) as? String {
            return value
        }
        return ""
    }
    
    var appVersion: String {
        if let value = self.objectForInfoDictionaryKey(NSBundle.AppVersionKey) as? String {
            return value
        }
        return ""
    }
    
    var buildNumber: String {
        if let value = self.objectForInfoDictionaryKey(NSBundle.BuildNumberKey) as? String {
            return value
        }
        return ""
    }
    
    var launchScreenStoryboard: String {
        if let value = self.objectForInfoDictionaryKey(NSBundle.LaunchScreenKey) as? String {
            return value
        }
        return ""
    }
    
    var mainStoryboard: String {
        if let value = self.objectForInfoDictionaryKey(NSBundle.MainStoryboardKey) as? String {
            return value
        }
        return ""
    }
    
    var bundleDescriptionDictionary: [String : String] {
        return [NSBundle.BundleNameKey:self.bundleName,
            NSBundle.BundleDisplayNameKey:self.bundleDisplayName,
            NSBundle.BundleExecutableNameKey:self.executableName,
            NSBundle.BundleIdentifierKey:(self.bundleIdentifier == nil) ? "" : self.bundleIdentifier!,
            NSBundle.AppVersionKey:self.appVersion,
            NSBundle.BuildNumberKey:self.buildNumber,
            NSBundle.LaunchScreenKey:self.launchScreenStoryboard,
            NSBundle.MainStoryboardKey:self.mainStoryboard]
    }
    
    var bundleDescription: String {
        return "Bundle Description: \(self.bundleDescriptionDictionary)"
    }
    
    var bundleDescriptionData: NSData? {
        do {
            return try NSJSONSerialization.dataWithJSONObject(self.bundleDescriptionDictionary, options: .PrettyPrinted)
        } catch {
            print(error)
            return nil
        }
    }
}
