//===----------------------------------------------------------------------===//
//
// UIAlertController.swift
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

public typealias DefaultAlertCompletion = (selectedAction: String?, wasCanceled: Bool) -> Void
public typealias TextAlertCompletion = (selectedAction: String?, wasCanceled: Bool, enteredText: String?) -> Void
public typealias CredentialAlertCompletion = (selectedAction: String?, wasCanceled: Bool, enteredCredentials: NSURLCredential?) -> Void

/// Extension allowing for a single callback.
public extension UIAlertController {
    
    private struct Manager {
        var alertController: UIAlertController?
        var cancelAction: String?
        var defaultCompletion: DefaultAlertCompletion?
        var textCompletion: TextAlertCompletion?
        var credentialCompletion: CredentialAlertCompletion?
        
        private mutating func dismiss() {
            guard let alert = alertController else {
                return
            }
            
            alert.dismissViewControllerAnimated(true, completion: nil)
            
            if let completion = defaultCompletion {
                completion(selectedAction: cancelAction, wasCanceled: true)
            } else if let completion = textCompletion {
                completion(selectedAction: cancelAction, wasCanceled: true, enteredText: nil)
            } else if let completion = credentialCompletion {
                completion(selectedAction: cancelAction, wasCanceled: true, enteredCredentials: nil)
            }
            
            reset()
        }
        
        private mutating func reset() {
            defaultCompletion = nil
            textCompletion = nil
            credentialCompletion = nil
            cancelAction = nil
            alertController = nil
        }
    }
    
    private static var manager = Manager()
    
    public static func reset() {
        manager.reset()
    }
    
    /// A basic message and single button `.Default` alert
    public static func prompt(presentedFrom vc: UIViewController?, withMessage message: String?, action: String = "OK") {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        manager.cancelAction = action
        
        let cancelAlertAction = UIAlertAction(title: action, style: .Default) { (alertAction: UIAlertAction) -> Void in
            manager.reset()
        }
        
        alertController.addAction(cancelAlertAction)
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.Default` alert
    public static func alert(presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, cancelAction: String?, destructiveAction: String?, otherActions: [String]?, completion: DefaultAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.defaultCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if destructiveAction != nil {
            let destroyAlertAction = UIAlertAction(title: destructiveAction, style: .Destructive, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: destructiveAction, wasCanceled: false)
                manager.reset()
            })
            
            alertController.addAction(destroyAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .Default, handler: { (UIAlertAction) -> Void in
                    completion(selectedAction: action, wasCanceled: false)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.Default` style alert with a single `UITextField`
    public static func textAlert(presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, initialText: String?, cancelAction: String?, otherActions: [String]?, completion: TextAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.textCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true, enteredText: nil)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .Default, handler: { (UIAlertAction) -> Void in
                    let enteredText = alertController.textFields?.first?.text
                    completion(selectedAction: action, wasCanceled: false, enteredText: enteredText)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.text = initialText
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.Default` style alert with a single secure `UITextField`
    public static func secureAlert(presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, initialText: String?, cancelAction: String?, otherActions: [String]?, completion: TextAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.textCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true, enteredText: nil)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .Default, handler: { (UIAlertAction) -> Void in
                    let enteredText = alertController.textFields?.first?.text
                    completion(selectedAction: action, wasCanceled: false, enteredText: enteredText)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.text = initialText
            textField.secureTextEntry = true
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.Default` style alert with two `UITextField`s, the 
    /// second of which is secure
    public static func credentialAlert(presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, initialCredentials: NSURLCredential?, cancelAction: String?, otherActions: [String]?, completion: CredentialAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.credentialCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true, enteredCredentials: nil)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .Default, handler: { (UIAlertAction) -> Void in
                    var enteredUsername = ""
                    if let text = alertController.textFields?.first?.text {
                        enteredUsername = text
                    }
                    var enteredPassword = ""
                    if let text = alertController.textFields?.last?.text {
                        enteredPassword = text
                    }
                    let enteredCredentials = NSURLCredential(user: enteredUsername, password: enteredPassword, persistence: .None)
                    completion(selectedAction: action, wasCanceled: false, enteredCredentials: enteredCredentials)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.text = initialCredentials?.user
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.text = initialCredentials?.password
            textField.secureTextEntry = true
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.ActionSheet` style alert presented from the 
    /// `viewController` or `sourceView` on Regular horizontal size classes
    public static func sheet(presentedFrom vc: UIViewController?, withBarButtonItem barButtonItem: UIBarButtonItem?, orSourceView sourceView: UIView?, title: String?, message: String?, cancelAction: String?, destructiveAction: String?, otherActions: [String]?, completion: DefaultAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.defaultCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if destructiveAction != nil {
            let destroyAlertAction = UIAlertAction(title: destructiveAction, style: .Destructive, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: destructiveAction, wasCanceled: false)
                manager.reset()
            })
            
            alertController.addAction(destroyAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .Default, handler: { (UIAlertAction) -> Void in
                    completion(selectedAction: action, wasCanceled: false)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
            
            if let ppc = viewController.popoverPresentationController {
                ppc.barButtonItem = barButtonItem
                ppc.sourceView = sourceView
                if sourceView != nil {
                    ppc.sourceRect = sourceView!.frame
                }
            }
        } else {
            manager.dismiss()
        }
    }
}
