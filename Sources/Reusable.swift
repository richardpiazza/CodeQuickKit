#if os(iOS)

import UIKit

public protocol Reusable {
    static func reuseIdentifier() -> String
}

extension UIView: Reusable {
    open class func reuseIdentifier() -> String {
        return String(describing: self)
    }
}

#endif
