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

/// Yes, I understand UIAlertController is block-based now.
/// This extension allows for a single callback to be handled.

public extension UIAlertController {
    /// A basic message and single button `.Default` alert
    public static func prompt(var presentedFrom vc: UIViewController?, withMessage message: String?, action: String = "OK") {
        AlertManager.sharedManager.dismiss()
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        AlertManager.sharedManager.cancelAction = action
        
        let cancelAlertAction = UIAlertAction(title: action, style: .Default) { (alertAction: UIAlertAction) -> Void in
            AlertManager.sharedManager.reset()
        }
        
        alertController.addAction(cancelAlertAction)
        
        AlertManager.sharedManager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            AlertManager.sharedManager.dismiss()
        }
    }
    
    /// A configurable `.Default` alert
    public static func alert(var presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, cancelAction: String?, destructiveAction: String?, otherActions: [String]?, completion: DefaultAlertCompletion) {
        AlertManager.sharedManager.dismiss()
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if cancelAction != nil {
            AlertManager.sharedManager.cancelAction = cancelAction
            AlertManager.sharedManager.defaultCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true)
                AlertManager.sharedManager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if destructiveAction != nil {
            let destroyAlertAction = UIAlertAction(title: destructiveAction, style: .Destructive, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: destructiveAction, wasCanceled: false)
                AlertManager.sharedManager.reset()
            })
            
            alertController.addAction(destroyAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .Default, handler: { (UIAlertAction) -> Void in
                    completion(selectedAction: action, wasCanceled: false)
                    AlertManager.sharedManager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        AlertManager.sharedManager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            AlertManager.sharedManager.dismiss()
        }
    }
    
    /// A configurable `.Default` style alert with a single `UITextField`
    public static func textAlert(var presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, initialText: String?, cancelAction: String?, otherActions: [String]?, completion: TextAlertCompletion) {
        AlertManager.sharedManager.dismiss()
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if cancelAction != nil {
            AlertManager.sharedManager.cancelAction = cancelAction
            AlertManager.sharedManager.textCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true, enteredText: nil)
                AlertManager.sharedManager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .Default, handler: { (UIAlertAction) -> Void in
                    let enteredText = alertController.textFields?.first?.text
                    completion(selectedAction: action, wasCanceled: false, enteredText: enteredText)
                    AlertManager.sharedManager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.text = initialText
        }
        
        AlertManager.sharedManager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            AlertManager.sharedManager.dismiss()
        }
    }
    
    /// A configurable `.Default` style alert with a single secure `UITextField`
    public static func secureAlert(var presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, initialText: String?, cancelAction: String?, otherActions: [String]?, completion: TextAlertCompletion) {
        AlertManager.sharedManager.dismiss()
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if cancelAction != nil {
            AlertManager.sharedManager.cancelAction = cancelAction
            AlertManager.sharedManager.textCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true, enteredText: nil)
                AlertManager.sharedManager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .Default, handler: { (UIAlertAction) -> Void in
                    let enteredText = alertController.textFields?.first?.text
                    completion(selectedAction: action, wasCanceled: false, enteredText: enteredText)
                    AlertManager.sharedManager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.text = initialText
            textField.secureTextEntry = true
        }
        
        AlertManager.sharedManager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            AlertManager.sharedManager.dismiss()
        }
    }
    
    /// A configurable `.Default` style alert with two `UITextField`s, the 
    /// second of which is secure
    public static func credentialAlert(var presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, initialCredentials: NSURLCredential?, cancelAction: String?, otherActions: [String]?, completion: CredentialAlertCompletion) {
        AlertManager.sharedManager.dismiss()
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if cancelAction != nil {
            AlertManager.sharedManager.cancelAction = cancelAction
            AlertManager.sharedManager.credentialCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true, enteredCredentials: nil)
                AlertManager.sharedManager.reset()
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
                    AlertManager.sharedManager.reset()
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
        
        AlertManager.sharedManager.alertController = alertController
        
        if let viewController = vc {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        } else {
            AlertManager.sharedManager.dismiss()
        }
    }
    
    /// A configurable `.ActionSheet` style alert presented from the 
    /// `viewController` or `sourceView` on Regular horizontal size classes
    public static func sheet(var presentedFrom vc: UIViewController?, withBarButtonItem barButtonItem: UIBarButtonItem?, orSourceView sourceView: UIView?, title: String?, message: String?, cancelAction: String?, destructiveAction: String?, otherActions: [String]?, completion: DefaultAlertCompletion) {
        AlertManager.sharedManager.dismiss()
        if vc == nil {
            vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        if cancelAction != nil {
            AlertManager.sharedManager.cancelAction = cancelAction
            AlertManager.sharedManager.defaultCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .Default, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: cancelAction, wasCanceled: true)
                AlertManager.sharedManager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if destructiveAction != nil {
            let destroyAlertAction = UIAlertAction(title: destructiveAction, style: .Destructive, handler: { (UIAlertAction) -> Void in
                completion(selectedAction: destructiveAction, wasCanceled: false)
                AlertManager.sharedManager.reset()
            })
            
            alertController.addAction(destroyAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .Default, handler: { (UIAlertAction) -> Void in
                    completion(selectedAction: action, wasCanceled: false)
                    AlertManager.sharedManager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        AlertManager.sharedManager.alertController = alertController
        
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
            AlertManager.sharedManager.dismiss()
        }
    }
}

public typealias DefaultAlertCompletion = (selectedAction: String?, wasCanceled: Bool) -> Void
public typealias TextAlertCompletion = (selectedAction: String?, wasCanceled: Bool, enteredText: String?) -> Void
public typealias CredentialAlertCompletion = (selectedAction: String?, wasCanceled: Bool, enteredCredentials: NSURLCredential?) -> Void

public class AlertManager {
    public static let sharedManager: AlertManager = AlertManager()
    
    var alertController: UIAlertController?
    var cancelAction: String?
    var defaultCompletion: DefaultAlertCompletion?
    var textCompletion: TextAlertCompletion?
    var credentialCompletion: CredentialAlertCompletion?
    
    public func dismiss() {
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
    
    public func reset() {
        defaultCompletion = nil
        textCompletion = nil
        credentialCompletion = nil
        cancelAction = nil
        alertController = nil
    }
}
