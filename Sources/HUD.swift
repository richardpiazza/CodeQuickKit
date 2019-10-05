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
    
    private static var isPresented: Bool = false
    private static var isPresentationCanceled: Bool = false
    
    private static var container: CenteringContainerView = {
        let view = CenteringContainerView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
        view.contentView = hud
        return view
    }()
    private static var hud: HUD = HUD(frame: .zero)
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
        if #available(iOS 13.0, *) {
            view.color = UIColor.label
        } else {
            view.color = UIColor.white
        }
        view.hidesWhenStopped = false
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.startAnimating()
        return view
    }()
    
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .callout)
        if #available(iOS 13.0, *) {
            view.textColor = UIColor.label
        } else {
            view.textColor = UIColor.white
        }
        view.textAlignment = .center
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private var additionalConstraints: [NSLayoutConstraint] = []
    
    private func initializeSubviews() {
        isUserInteractionEnabled = false
        
        if #available(iOS 13.0, *) {
            layer.backgroundColor = UIColor.quaternarySystemFill.withAlphaComponent(0.5).cgColor
            layer.borderColor = UIColor.quaternarySystemFill.withAlphaComponent(0.8).cgColor
        } else {
            layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
            layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        }
        layer.borderWidth = 0.5
        layer.cornerRadius = 8.0
        
        addSubview(activity)
        addSubview(label)
        
        let activityLeading = NSLayoutConstraint(item: activity, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1.0, constant: 16.0)
        activityLeading.priority = .defaultHigh
        
        let activityTrailing = NSLayoutConstraint(item: activity, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -16.0)
        activityTrailing.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activity, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 16.0),
            NSLayoutConstraint(item: activity, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            activityLeading,
            activityTrailing,
            NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1.0, constant: 16.0),
            NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -16.0),
        ])
        
        updateSubviews()
    }
    
    private func updateSubviews() {
        NSLayoutConstraint.deactivate(additionalConstraints)
        additionalConstraints.removeAll()
        
        if let value = presentation.text, value != "" {
            additionalConstraints.append(contentsOf: [
                NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: activity, attribute: .bottom, multiplier: 1.0, constant: 8.0),
                NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -16.0),
                NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0),
            ])
        } else {
            additionalConstraints.append(contentsOf: [
                NSLayoutConstraint(item: activity, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -16.0),
                NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80.0),
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
