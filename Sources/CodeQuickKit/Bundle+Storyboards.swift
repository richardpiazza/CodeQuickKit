#if canImport(UIKit)
import UIKit

public extension Bundle {
    /// This call potentially throws an exception that cannot be caught.
    var launchScreenStoryboard: UIStoryboard? {
        guard let name = launchStoryboardName else {
            return nil
        }
        
        return UIStoryboard(name: name, bundle: self)
    }
    
    /// This call potentially throws an exception that cannot be caught.
    var mainStoryboard: UIStoryboard? {
        guard let name = mainStoryboardName else {
            return nil
        }
        
        return UIStoryboard(name: name, bundle: self)
    }
}
#endif
