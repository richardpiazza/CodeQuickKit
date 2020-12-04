#if os(iOS)

import UIKit

@available(*, deprecated, message: "`Reusable` should be used instead.")
public protocol Storyboarded {
    static var bundle: Bundle { get }
    static var storyboard: UIStoryboard { get }
    static var storyboardIdentifier: String { get }
}

@available(*, deprecated)
extension UIViewController: Storyboarded {
    public class var bundle: Bundle {
        return Bundle(for: self)
    }
    
    public class var storyboard: UIStoryboard {
        guard let storyboard = self.bundle.mainStoryboard else {
            assertionFailure("Bundle Storyboard Not Found")
            return UIStoryboard()
        }
        
        return storyboard
    }
    
    public class var storyboardIdentifier: String {
        return String(describing: self)
    }
}

@available(*, deprecated)
public extension UIStoryboard {
    /// Instantiates a UIViewController for the provided `Storyboarded` class
    /// This call potentially throws an execption that cannot be caught.
    func instantiateViewController<T: Storyboarded>(forClass viewControllerClass: T.Type) -> T {
        return self.instantiateViewController(withIdentifier: viewControllerClass.storyboardIdentifier) as! T
    }
}

#endif
