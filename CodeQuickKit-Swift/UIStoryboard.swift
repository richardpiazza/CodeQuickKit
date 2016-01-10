//===----------------------------------------------------------------------===//
//
// UIStoryboard.swift
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

public extension UIStoryboard {
    /// Returns the main storyboard as specified in the Info.plist
    /// This call potentially throws an execption that cannot be caught.
    public static var mainStoryboard: UIStoryboard {
        var bundle = NSBundle.mainBundle()
        if let dictionary = bundle.infoDictionary where dictionary.count != 0 {
            bundle = NSBundle(forClass: self)
        }
        
        return UIStoryboard(name: bundle.mainStoryboard, bundle: bundle)
    }
    
    /// Creates an Identifier using the class name to be passed to
    /// `instantiateViewControllerWithIdentifier`.
    /// This call potentially throws an execption that cannot be caught.
    public func instantiateViewControllerForClass(any: AnyClass) -> UIViewController {
        var bundle = NSBundle.mainBundle()
        if let dictionary = bundle.infoDictionary where dictionary.count != 0 {
            bundle = NSBundle(forClass: any.self)
        }
        
        var identifier = NSStringFromClass(any)
        if identifier.hasPrefix("\(bundle.bundleDisplayName).") {
            let end = bundle.bundleDisplayName.endIndex.advancedBy(1)
            identifier = identifier.substringFromIndex(end)
        }
        
        return self.instantiateViewControllerWithIdentifier(identifier)
    }
}
