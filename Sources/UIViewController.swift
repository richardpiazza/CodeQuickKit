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
