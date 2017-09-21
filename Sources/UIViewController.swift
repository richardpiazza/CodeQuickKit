//===----------------------------------------------------------------------===//
//
// UIViewController.swift
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

extension UIViewController {
    /// Animates a title change on the first `UILabel` found in the
    /// UINavigationController.navigationBar.subviews.
    func setNavigationTitle(_ title: String, animationType: String = kCATransitionMoveIn, animationSubtype: String = kCATransitionFromTop, animationDuration: CFTimeInterval = 0.25) {
        guard let navigationController = self.navigationController else {
            self.navigationItem.title = title
            return
        }
        
        guard let titleView = navigationController.navigationBar.subviews.filter({ (view: UIView) -> Bool in
            return view.subviews.filter({ (subview: UIView) -> Bool in
                return subview is UILabel
            }).first != nil
        }).first else {
            self.navigationItem.title = title
            return
        }
        
        let animation = CATransition()
        animation.duration = animationDuration
        animation.type = animationType
        animation.subtype = animationSubtype
        
        titleView.layer.add(animation, forKey: "animateTitle")
        self.navigationItem.title = title
        titleView.layer.removeAnimation(forKey: "animateTitle")
    }
}

#endif
