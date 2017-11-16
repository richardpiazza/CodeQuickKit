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
