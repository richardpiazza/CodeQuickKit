//===----------------------------------------------------------------------===//
//
// Storyboarded.swift
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

#if os(iOS)

import UIKit

public protocol Storyboarded {
    static func bundle() -> Bundle
    static func storyboard() -> UIStoryboard
    static func storyboardIdentifier() -> String
}

extension UIViewController: Storyboarded {
    public class func bundle() -> Bundle {
        return Bundle(for: self)
    }
    
    public class func storyboard() -> UIStoryboard {
        if let storyboard = self.bundle().mainStoryboard {
            return storyboard
        }
        
        assertionFailure("Bundle Storyboard Not Found")
        return UIStoryboard()
    }
    
    public class func storyboardIdentifier() -> String {
        return String(describing: self)
    }
}

public extension UIStoryboard {
    /// Instantiates a UIViewController for the provided `Storyboarded` class
    /// This call potentially throws an execption that cannot be caught.
    public func instantiateViewController<T: Storyboarded>(forClass viewControllerClass: T.Type) -> T {
        return self.instantiateViewController(withIdentifier: viewControllerClass.storyboardIdentifier()) as! T
    }
}

#endif
