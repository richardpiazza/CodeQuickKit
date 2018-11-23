#if os(iOS)

import UIKit

public extension UITableView {
    @available(*, deprecated, renamed: "register(reusableType:)")
    public func register<T: UITableViewCell>(nibClass: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
        self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    @available(*, deprecated, renamed: "dequeueReusableCell(withType:for:)")
    public func dequeueReusableCell<T: UITableViewCell>(withClass: T.Type, for indexPath: IndexPath) -> T {
        let identifier = T.reuseIdentifier
        guard let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("\(#function); Failed to dequeue cell with identifier '\(identifier)'")
        }
        
        return cell
    }
}

#endif
