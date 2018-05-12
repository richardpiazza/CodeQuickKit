#if os(iOS)

import UIKit

public protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension UIView: Reusable {
    open class var reuseIdentifier: String {
        return String(describing: self)
    }
}

#endif
