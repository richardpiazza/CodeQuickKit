#if canImport(UIKit)
import UIKit

/// A simple Heads Up Display (**HUD**) implementation.
///
/// HUDs are a common component of app design. Typically used to indicated
/// to a user that action is in progress, or something has been completed.
public class HUD: UIView {

    public static var animationDuration: TimeInterval = 0.15

    /// Available presentation methods
    public enum Presentation {
        /// Presents a `UIActivityIndicatorView` as the central component along
        /// with an optional short text.
        case activity(text: String?)
        /// Presents an image along with optional text.
        case image(image: UIImage, text: String?)
        /// Presents a generic view along with optional text.
        case view(view: UIView, text: String?)

        public var text: String? {
            switch self {
            case .activity(let text):
                return text
            case .image(_, let text):
                return text
            case .view(_, let text):
                return text
            }
        }
    }

    /// The color used to fill the rest of the window
    ///
    /// This is a proxy to the `container.backgroundColor` and `hud.backgroundColor`.
    public static var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.3) {
        didSet {
            container.backgroundColor = backgroundColor
            hud.backgroundColor = backgroundColor
        }
    }

    /// The color of the hud area
    ///
    /// This is a proxy to the `hud.layer.backgroundColor`.
    public static var color: UIColor = .gray {
        didSet {
            hud.layer.backgroundColor = color.cgColor
        }
    }

    /// The tint/highlight color of the text and visual components
    ///
    /// This is a proxy to the `hud.tintColor` and `hud.label.textColor`
    public static var tintColor: UIColor = .white {
        didSet {
            hud.tintColor = tintColor
            hud.label.textColor = tintColor
        }
    }

    /// The color of the hud area
    ///
    /// This is a proxy to the `hud.layer.borderColor`.
    public static var borderColor: UIColor = UIColor.black.withAlphaComponent(0.8) {
        didSet {
            hud.layer.borderColor = borderColor.cgColor
        }
    }

    /// The width of the layer border around the hud.
    ///
    /// This is a proxy to `hud.layer.borderWidth`
    public static var borderWidth: CGFloat = 1.5 {
        didSet {
            hud.layer.borderWidth = borderWidth
        }
    }

    /// The corner radius of the hud view (and centering container in shared context).
    ///
    /// This is a proxy to the `container.cornerRadius` and `hud.layer.cornerRadius`
    public static var cornerRadius: CGFloat = 8.0 {
        didSet {
            hud.layer.cornerRadius = cornerRadius
            container.cornerRadius = cornerRadius
        }
    }

    /// The corners masked to use the 'cornerRadius'.
    ///
    /// This is a proxy to the `container.cornerRadius` and `hud.layer.cornerRadius`
    @available(iOS 11.0, *)
    public static var maskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner] {
        didSet {
            hud.layer.maskedCorners = maskedCorners
            container.maskedCorners = maskedCorners
        }
    }

    /// The current presentation/visibility status of the hud.
    private static var isPresented: Bool = false
    /// Determines if the presentation was canceled before being presented.
    private static var isPresentationCanceled: Bool = false

    private static var container: CenteringView = {
        let view = CenteringView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = HUD.backgroundColor
        view.contentView = hud
        view.cornerRadius = HUD.cornerRadius
        if #available(iOS 11.0, *) {
            view.maskedCorners = HUD.maskedCorners
        }
        return view
    }()

    /// A singular shared hud instance.
    private static var hud = HUD(frame: .zero)
    private static var constraints: [NSLayoutConstraint] = []

    /// Shows the HUD with the provided configuration options.
    ///
    /// Typically you want the hud to be presented at a `UIWindow` level, so passing
    /// `view.window ?? view` (in the context of a `UIViewController` subclass) or
    /// `window ?? self` (in the context of a `UIView` subclass).
    ///
    /// No animations are currently enabled, the hud is simply added to the view.
    ///
    /// The `delayPresentation` parameter helps to mitigate the undesired effect of
    /// 'flashing' HUDs onto the screen. It is typically to use a hud during asynchronous
    /// methods. Using a slight delay allows for quick methods to still call show/hide
    /// but not actually display the hud if the action is *quick enough*.
    ///
    /// - parameter presentation: The *style* of HUD to present
    /// - parameter view: The view instance in which to append the hud container
    /// - parameter animated: Determines if any animation is used in the presentation
    /// - parameter delayPresentation: The time interval in which to wait to display the hud.
    /// - parameter autoHideAfter: The time interval in which to automatically dismiss the hud.
    public static func show(presentation: Presentation, in view: UIView, animated: Bool = true, delayPresentation: TimeInterval = 0.25, autoHideAfter: TimeInterval? = -1.0) {
        isPresentationCanceled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + max(delayPresentation, 0.0)) {
            guard isPresentationCanceled == false else {
                isPresented = false
                return
            }

            isPresented = true

            if !constraints.isEmpty {
                NSLayoutConstraint.deactivate(constraints)
                container.removeFromSuperview()
            }

            hud.presentation = presentation
            view.addSubview(container)

            constraints = [
                NSLayoutConstraint(item: container, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: container, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            ]

            NSLayoutConstraint.activate(constraints)

            if animated {
                container.alpha = 0
                animator({ container.alpha = 1 }).startAnimation()
            }

            guard let interval = autoHideAfter, interval > 0.0 else {
                return
            }

            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + interval, execute: {
                self.hide(animated: animated)
            })
        }
    }

    public static func hide(animated: Bool = true) {
        DispatchQueue.main.async {
            guard isPresented else {
                isPresentationCanceled = true
                return
            }

            let remove: (UIViewAnimatingPosition) -> Void = { _ in
                self.isPresented = false

                NSLayoutConstraint.deactivate(self.constraints)
                self.container.removeFromSuperview()
                self.constraints.removeAll()
            }

            if animated {
                let animator = self.animator { container.alpha = 0 }
                animator.addCompletion(remove)
                animator.startAnimation()
            } else {
                remove(.end)
            }
        }
    }

    public var presentation: Presentation = .activity(text: nil) {
        didSet {
            switch presentation {
            case .activity(let text):
                supplementalView = nil
                activity.isHidden = false
                imageView.isHidden = true
                label.isHidden = (text == nil)
                label.text = text
            case .image(let image, let text):
                supplementalView = nil
                activity.isHidden = true
                imageView.isHidden = false
                imageView.image = image
                label.isHidden = (text == nil)
                label.text = text
            case .view(let view, let text):
                supplementalView = view
                activity.isHidden = true
                imageView.isHidden = true
                label.isHidden = (text == nil)
                label.text = text
            }

            updateSubviews()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func animator(_ animations: @escaping () -> Void) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut, animations: animations)
    }

    public private(set) lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()

    public private(set) lazy var activity: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView
        if #available(iOS 13.0, tvOS 13.0, *) {
            view = UIActivityIndicatorView(style: .large)
        } else {
            view = UIActivityIndicatorView(style: .whiteLarge)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = false
        view.color = HUD.tintColor
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.startAnimating()
        return view
    }()

    public private(set) lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .callout)
        view.textAlignment = .center
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textColor = HUD.tintColor
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return view
    }()

    private lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [activity, imageView, label])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 4.0
        return view
    }()

    private var supplementalView: UIView? {
        willSet {
            if let oldView = supplementalView {
                stack.removeArrangedSubview(oldView)
                oldView.removeFromSuperview()
            }
        }
        didSet {
            if let newView = supplementalView {
                stack.insertArrangedSubview(newView, at: 0)
            }
        }
    }

    private var additionalConstraints: [NSLayoutConstraint] = []

    private func initializeSubviews() {
        backgroundColor = HUD.backgroundColor

        layer.backgroundColor = HUD.color.cgColor
        layer.borderColor = HUD.borderColor.cgColor
        layer.borderWidth = HUD.borderWidth
        layer.cornerRadius = HUD.cornerRadius
        layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            layer.maskedCorners = HUD.maskedCorners
        }
        
        addSubview(stack)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: stack, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 16.0),
            NSLayoutConstraint(item: stack, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -12.0),
            NSLayoutConstraint(item: stack, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 16.0),
            NSLayoutConstraint(item: stack, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -16.0),
        ])

        updateSubviews()
    }

    private func updateSubviews() {
        NSLayoutConstraint.deactivate(additionalConstraints)
        additionalConstraints.removeAll()

        if let value = presentation.text, !value.isEmpty {
            additionalConstraints.append(contentsOf: [
                // Without at least some constraints, the hud could potentially fill the
                // entire width that it is presented in.
                NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0),
                NSLayoutConstraint(item: self, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0),
            ])
        }

        NSLayoutConstraint.activate(additionalConstraints)
    }
}

/// A `CenteringView`
///
/// Container that will position its _contents_ centered horizontally and vertically.
/// The contents will always be presented at its intrinsic size.
internal class CenteringView: UIView {

    var contentView: UIView? {
        willSet {
            NSLayoutConstraint.deactivate(additionalConstraints)
            additionalConstraints.removeAll()
            contentView?.removeFromSuperview()
        }
        didSet {
            guard let contentView = self.contentView else {
                return
            }

            contentView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(contentView)

            additionalConstraints.append(contentsOf: [
                NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0.0),
                ])

            NSLayoutConstraint.activate(additionalConstraints)
        }
    }

    /// Proxy to the centering container `layer.cornerRadius`
    var cornerRadius: CGFloat {
        get {
            return container.layer.cornerRadius
        }
        set {
            container.layer.cornerRadius = newValue
        }
    }

    @available(iOS 11.0, *)
    var maskedCorners: CACornerMask {
        get {
            return container.layer.maskedCorners
        }
        set {
            container.layer.maskedCorners = newValue
        }
    }

    private lazy var container: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        return view
    }()

    override public var backgroundColor: UIColor? {
        didSet {
            container.backgroundColor = backgroundColor
        }
    }

    private var additionalConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }

    private func initializeSubviews() {
        addSubview(container)

        let topGreaterThan = NSLayoutConstraint(item: container, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        topGreaterThan.priority = .defaultLow

        let bottomLessThan = NSLayoutConstraint(item: container, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        bottomLessThan.priority = .defaultLow

        let leadingGreaterThan = NSLayoutConstraint(item: container, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        leadingGreaterThan.priority = .defaultLow

        let trailingLessThan = NSLayoutConstraint(item: container, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        trailingLessThan.priority = .defaultLow

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: container, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: container, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            topGreaterThan,
            bottomLessThan,
            leadingGreaterThan,
            trailingLessThan,
        ])
    }

}

#endif
