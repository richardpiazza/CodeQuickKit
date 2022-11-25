#if canImport(UIKit)
import UIKit

extension UIAlertController {
    class ActivityAlertController: UIViewController {
        
        private lazy var activityIndicator: UIActivityIndicatorView = {
            let view = UIActivityIndicatorView(style: .medium)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.hidesWhenStopped = false
            view.startAnimating()
            return view
        }()
        
        private var topPadding: NSLayoutConstraint!
        private var bottomPadding: NSLayoutConstraint!
        private var leadingPadding: NSLayoutConstraint!
        private var trailingPadding: NSLayoutConstraint!
        
        /// Minimum padding applied to the activity indicator.
        ///
        /// All of the padding constraints are in the form of greater/less than. The alert title
        /// and message also affect the visual padding of the view.
        var padding: UIEdgeInsets = .init(top: 32.0, left: 16.0, bottom: 32.0, right: 16.0) {
            didSet {
                topPadding.constant = padding.top
                bottomPadding.constant = -abs(padding.bottom)
                leadingPadding.constant = padding.left
                trailingPadding.constant = -abs(padding.right)

                view.layoutIfNeeded()
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.addSubview(activityIndicator)
            
            topPadding = activityIndicator.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: padding.top)
            bottomPadding = activityIndicator.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: -abs(padding.bottom))
            leadingPadding = activityIndicator.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: padding.left)
            trailingPadding = activityIndicator.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: -abs(padding.right))
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                topPadding,
                bottomPadding,
                leadingPadding,
                trailingPadding,
            ])
        }
    }
    
    /// Create a `UIAlertController` with an embedded `ActivityAlertController`.
    ///
    /// - parameters:
    ///   - title: The header text of the presented alert
    ///   - message: The body text of the presented alert
    ///   - padding: Inset values that should be used in place of defaults.
    public static func makeActivityAlert(
        title: String? = nil,
        message: String? = nil,
        padding: UIEdgeInsets? = nil
    ) -> UIAlertController {
        let activityController = ActivityAlertController()
        if let padding = padding {
            activityController.padding = padding
        }
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.setValue(activityController, forKey: "contentViewController")
        return controller
    }
}

extension UIViewController {
    private struct AlertScheduler {
        /// Allows for a delay between presenting and dismissing an alert. (Avoid flickering)
        static var scheduledActivation: Date?
    }
    
    /// The currently presented alert controller (if available)
    ///
    /// **WARNING**: Must be called on main thread!
    private var currentAlert: UIAlertController? { presentedViewController as? UIAlertController }
    
    /// Presents an alert dialog with an embedded `ActivityAlertController`.
    ///
    /// If an existing `UIAlertController` is already presented, the `title` and `message` will be updated
    /// with the new values.
    ///
    /// When a `delayPresentation` interval is provided, the alert will not show right away. This way, if the dismiss is
    /// called before it appears on screen, nothing happens. This avoids short/flickering HUD.
    ///
    /// **WARNING**: _This is a pure hack_.
    /// 'contentViewController' can be assigned on a `UIAlertController` to present additional content types.
    ///
    /// See [Stack Overflow](https://stackoverflow.com/questions/34593191) for multiple examples.
    ///
    /// - parameters:
    ///   - title: The header text of the presented alert
    ///   - message: The body text of the presented alert
    ///   - padding: Inset values that should be used in place of defaults.
    ///   - delayPresentation: Holds presentation for a short period.
    ///   - completion: Function executed after the alert is presented or updated.
    public func presentActivityAlert(
        title: String? = nil,
        message: String? = nil,
        padding: UIEdgeInsets? = nil,
        delayPresentation: TimeInterval = 0.0,
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                completion?()
                return
            }
            
            if let alert = self.currentAlert {
                alert.title = title
                alert.message = message
                completion?()
                return
            }
            
            let controller = UIAlertController.makeActivityAlert(title: title, message: message, padding: padding)
            
            AlertScheduler.scheduledActivation = Date(timeIntervalSinceNow: abs(delayPresentation))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + abs(delayPresentation)) { [weak self] in
                guard AlertScheduler.scheduledActivation != nil else {
                    completion?()
                    return
                }
                
                guard let self = self else {
                    completion?()
                    return
                }
                
                guard self.parent != nil else {
                    completion?()
                    return
                }
                
                self.present(controller, animated: true) {
                    if let handler = completion {
                        DispatchQueue.main.async {
                            handler()
                        }
                    }
                }
            }
        }
    }
    
    /// Dismisses the current alert if necessary and then executes the `completion` block.
    ///
    /// When called after `presentActivityAlert`, but before the `delayPresentation` time, and with a non-zero `visibility`:
    /// the scheduled alert will be presented and automatically dismissed after the interval provided.
    ///
    /// - parameters:
    ///   - visibility: A minimum time interval for which the dismissed alert should be displayed.
    ///   - completion: Function executed after the alert is dismissed.
    public func dismissAlert(
        afterMinimumVisibility visibility: TimeInterval = 0.0,
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                completion?()
                return
            }
            
            switch self.currentAlert {
            case .some(let alert):
                DispatchQueue.main.asyncAfter(deadline: .now() + abs(visibility)) {
                    alert.dismiss(animated: true, completion: completion)
                }
            case .none:
                let activation = AlertScheduler.scheduledActivation
                switch activation {
                case .some(let date):
                    guard visibility > 0.0 else {
                        AlertScheduler.scheduledActivation = nil
                        completion?()
                        return
                    }
                    
                    let deactivation = date.addingTimeInterval(visibility)
                    let interval = Date().timeIntervalSince(deactivation)
                    DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
                        if let alert = self?.currentAlert {
                            alert.dismiss(animated: true, completion: completion)
                        } else {
                            completion?()
                        }
                    }
                case .none:
                    break
                }
            }
        }
    }
}
#endif
