#if os(iOS)

import UIKit

public typealias DefaultAlertCompletion = (_ selectedAction: String?, _ wasCanceled: Bool) -> Void
public typealias TextAlertCompletion = (_ selectedAction: String?, _ wasCanceled: Bool, _ enteredText: String?) -> Void
public typealias CredentialAlertCompletion = (_ selectedAction: String?, _ wasCanceled: Bool, _ enteredCredentials: URLCredential?) -> Void

/// Extension allowing for a single callback.
public extension UIAlertController {
    
    fileprivate struct Manager {
        var alertController: UIAlertController?
        var cancelAction: String?
        var defaultCompletion: DefaultAlertCompletion?
        var textCompletion: TextAlertCompletion?
        var credentialCompletion: CredentialAlertCompletion?
        
        fileprivate mutating func dismiss() {
            guard let alert = alertController else {
                return
            }
            
            alert.dismiss(animated: true, completion: nil)
            
            if let completion = defaultCompletion {
                completion(cancelAction, true)
            } else if let completion = textCompletion {
                completion(cancelAction, true, nil)
            } else if let completion = credentialCompletion {
                completion(cancelAction, true, nil)
            }
            
            reset()
        }
        
        fileprivate mutating func reset() {
            defaultCompletion = nil
            textCompletion = nil
            credentialCompletion = nil
            cancelAction = nil
            alertController = nil
        }
    }
    
    fileprivate static var manager = Manager()
    
    public static func reset() {
        manager.reset()
    }
    
    /// A basic message and single button `.Default` alert
    public static func prompt(presentedFrom vc: UIViewController?, withMessage message: String?, action: String = "OK") {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        manager.cancelAction = action
        
        let cancelAlertAction = UIAlertAction(title: action, style: .default) { (alertAction: UIAlertAction) -> Void in
            manager.reset()
        }
        
        alertController.addAction(cancelAlertAction)
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.present(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.Default` alert
    public static func alert(presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, cancelAction: String?, destructiveAction: String?, otherActions: [String]?, completion: @escaping DefaultAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.defaultCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .default, handler: { (UIAlertAction) -> Void in
                completion(cancelAction, true)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if destructiveAction != nil {
            let destroyAlertAction = UIAlertAction(title: destructiveAction, style: .destructive, handler: { (UIAlertAction) -> Void in
                completion(destructiveAction, false)
                manager.reset()
            })
            
            alertController.addAction(destroyAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .default, handler: { (UIAlertAction) -> Void in
                    completion(action, false)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.present(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.Default` style alert with a single `UITextField`
    public static func textAlert(presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, initialText: String?, cancelAction: String?, otherActions: [String]?, completion: @escaping TextAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.textCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .default, handler: { (UIAlertAction) -> Void in
                completion(cancelAction, true, nil)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .default, handler: { (UIAlertAction) -> Void in
                    let enteredText = alertController.textFields?.first?.text
                    completion(action, false, enteredText)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        alertController.addTextField { (textField: UITextField) -> Void in
            textField.text = initialText
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.present(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.Default` style alert with a single secure `UITextField`
    public static func secureAlert(presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, initialText: String?, cancelAction: String?, otherActions: [String]?, completion: @escaping TextAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.textCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .default, handler: { (UIAlertAction) -> Void in
                completion(cancelAction, true, nil)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .default, handler: { (UIAlertAction) -> Void in
                    let enteredText = alertController.textFields?.first?.text
                    completion(action, false, enteredText)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        alertController.addTextField { (textField: UITextField) -> Void in
            textField.text = initialText
            textField.isSecureTextEntry = true
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.present(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.Default` style alert with two `UITextField`s, the 
    /// second of which is secure
    public static func credentialAlert(presentedFrom vc: UIViewController?, withTitle title: String?, message: String?, initialCredentials: URLCredential?, cancelAction: String?, otherActions: [String]?, completion: @escaping CredentialAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.credentialCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .default, handler: { (UIAlertAction) -> Void in
                completion(cancelAction, true, nil)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .default, handler: { (UIAlertAction) -> Void in
                    var enteredUsername = ""
                    if let text = alertController.textFields?.first?.text {
                        enteredUsername = text
                    }
                    var enteredPassword = ""
                    if let text = alertController.textFields?.last?.text {
                        enteredPassword = text
                    }
                    let enteredCredentials = URLCredential(user: enteredUsername, password: enteredPassword, persistence: .none)
                    completion(action, false, enteredCredentials)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        alertController.addTextField { (textField: UITextField) -> Void in
            textField.text = initialCredentials?.user
        }
        
        alertController.addTextField { (textField: UITextField) -> Void in
            textField.text = initialCredentials?.password
            textField.isSecureTextEntry = true
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.present(alertController, animated: true, completion: nil)
        } else {
            manager.dismiss()
        }
    }
    
    /// A configurable `.ActionSheet` style alert presented from the 
    /// `viewController` or `sourceView` on Regular horizontal size classes
    public static func sheet(presentedFrom vc: UIViewController?, withBarButtonItem barButtonItem: UIBarButtonItem?, orSourceView sourceView: UIView?, title: String?, message: String?, cancelAction: String?, destructiveAction: String?, otherActions: [String]?, completion: @escaping DefaultAlertCompletion) {
        manager.dismiss()
        
        var vc = vc
        if vc == nil {
            vc = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        if cancelAction != nil {
            manager.cancelAction = cancelAction
            manager.defaultCompletion = completion
            
            let cancelAlertAction = UIAlertAction(title: cancelAction, style: .default, handler: { (UIAlertAction) -> Void in
                completion(cancelAction, true)
                manager.reset()
            })
            
            alertController.addAction(cancelAlertAction)
        }
        
        if destructiveAction != nil {
            let destroyAlertAction = UIAlertAction(title: destructiveAction, style: .destructive, handler: { (UIAlertAction) -> Void in
                completion(destructiveAction, false)
                manager.reset()
            })
            
            alertController.addAction(destroyAlertAction)
        }
        
        if let otherActions = otherActions {
            for action in otherActions {
                let alertAction = UIAlertAction(title: action, style: .default, handler: { (UIAlertAction) -> Void in
                    completion(action, false)
                    manager.reset()
                })
                
                alertController.addAction(alertAction)
            }
        }
        
        manager.alertController = alertController
        
        if let viewController = vc {
            viewController.present(alertController, animated: true, completion: nil)
            
            if let ppc = alertController.popoverPresentationController {
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

#endif
