#if canImport(UIKit)
import UIKit

public class HUD: UIView {
    
    public enum Presentation {
        case activity(text: String?)
        case image(image: UIImage, text: String?)
        
        public var text: String? {
            switch self {
            case .activity(let text):
                return text
            case .image(_, let text):
                return text
            }
        }
    }
    
    /// The tint/highlight color of the text and visual components
    public static var tintColor: UIColor = .white {
        didSet {
            hud.tintColor = tintColor
        }
    }
    
    /// The color of the hud area
    public static var color: UIColor = UIColor.gray.withAlphaComponent(0.5) {
        didSet {
            hud.layer.backgroundColor = color.cgColor
        }
    }
    
    /// The color of the hud area
    public static var borderColor: UIColor = UIColor.gray.withAlphaComponent(0.8) {
        didSet {
            hud.layer.borderColor = borderColor.cgColor
        }
    }
    
    /// The color used to fill the rest of the window
    public static var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.3) {
        didSet {
            container.backgroundColor = backgroundColor
            hud.backgroundColor = backgroundColor
        }
    }
    
    private static var isPresented: Bool = false
    private static var isPresentationCanceled: Bool = false
    
    private static var container: CenteringContainerView = {
        let view = CenteringContainerView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = HUD.backgroundColor
        view.contentView = hud
        return view
    }()
    private static var hud = HUD(frame: .zero)
    private static var constraints: [NSLayoutConstraint] = []
    
    public static func show(presentation: Presentation, in view: UIView, animated: Bool = true, delayPresentation: TimeInterval = 0.25, autoHideAfter: TimeInterval? = -1.0) {
        isPresentationCanceled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + max(delayPresentation, 0.0)) {
            guard isPresentationCanceled == false else {
                isPresented = false
                return
            }
            
            isPresented = true
            
            if constraints.count > 0 {
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
            
            isPresented = false
            
            NSLayoutConstraint.deactivate(constraints)
            container.removeFromSuperview()
            constraints.removeAll()
        }
    }
    
    private var presentation: Presentation = .activity(text: nil) {
        didSet {
            switch presentation {
            case .activity(let text):
                activity.isHidden = false
                imageView.isHidden = true
                label.isHidden = (text == nil)
                label.text = text
            case .image(let image, let text):
                activity.isHidden = true
                imageView.isHidden = false
                imageView.image = image
                label.isHidden = (text == nil)
                label.text = text
            }
            
            updateSubviews()
        }
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    private lazy var activity: UIActivityIndicatorView = {
        let view: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
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
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .callout)
        view.textAlignment = .center
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textColor = HUD.tintColor
        return view
    }()
    
    private lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [activity, imageView, label])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 4.0
        return view
    }()
    
    private var additionalConstraints: [NSLayoutConstraint] = []
    
    private func initializeSubviews() {
        isUserInteractionEnabled = false
        
        backgroundColor = HUD.backgroundColor
        
        layer.backgroundColor = HUD.color.cgColor
        layer.borderColor = HUD.borderColor.cgColor
        layer.borderWidth = 1.5
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
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
        
        if let value = presentation.text, value != "" {
            additionalConstraints.append(contentsOf: [
                NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0),
            ])
        } else {
            additionalConstraints.append(contentsOf: [
            ])
        }
        
        NSLayoutConstraint.activate(additionalConstraints)
    }
}

internal class CenteringContainerView: UIView {

    internal var contentView: UIView? {
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

    override internal var backgroundColor: UIColor? {
        didSet {
            container.backgroundColor = backgroundColor
        }
    }

    private lazy var container: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        return view
    }()

    private var additionalConstraints: [NSLayoutConstraint] = []

    override internal init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
