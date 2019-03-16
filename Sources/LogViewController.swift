#if !COCOAPODS && canImport(Amada)
import Amada
#endif
#if canImport(MessageUI)
import MessageUI
#endif
#if canImport(UIKit)
import UIKit

public protocol LogViewControllerDelegate: class {
    func shouldDismissLogViewController(_ viewController: LogViewController)
}

public class LogViewController: UIViewController, LogObserver {
    
    public weak var delegate: LogViewControllerDelegate?
    public private(set) var observerId: UUID = UUID()
    private var log: Log = Log.default {
        willSet {
            log.removeObserver(self)
        }
        didSet {
            log.addObserver(self)
        }
    }
    
    private lazy var viewer: UITextView = {
        let view = UITextView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.isSelectable = true
        return view
    }()
    
    private lazy var close: UIButton = {
        let control = UIButton(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setTitle("Close", for: .normal)
        control.setTitleColor(.blue, for: .normal)
        control.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        return control
    }()
    
    private lazy var clear: UIButton = {
        let control = UIButton(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setTitle("Clear", for: .normal)
        control.setTitleColor(.red, for: .normal)
        control.addTarget(self, action: #selector(didTapClear(_:)), for: .touchUpInside)
        return control
    }()
    
    private lazy var email: UIButton = {
        let control = UIButton(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.setTitle("Email", for: .normal)
        control.setTitleColor(.blue, for: .normal)
        control.addTarget(self, action: #selector(didTapEmail(_:)), for: .touchUpInside)
        return control
    }()
    
    public init(log: Log = Log.default) {
        super.init(nibName: nil, bundle: nil)
        self.log = log
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        log.removeObserver(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(viewer)
        view.addSubview(close)
        view.addSubview(clear)
        view.addSubview(email)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: close, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: close, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: email, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: email, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1.0, constant: -8.0),
            NSLayoutConstraint(item: clear, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: clear, attribute: .trailing, relatedBy: .equal, toItem: email, attribute: .leading, multiplier: 1.0, constant: -16.0),
            NSLayoutConstraint(item: clear, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: close, attribute: .trailing, multiplier: 1.0, constant: 16.0),
            NSLayoutConstraint(item: viewer, attribute: .top, relatedBy: .equal, toItem: close, attribute: .bottom, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: viewer, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1.0, constant: 8.0),
            NSLayoutConstraint(item: viewer, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1.0, constant: -8.0),
            NSLayoutConstraint(item: viewer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1.0, constant: -8.0)
            ])
        
        #if canImport(MessageUI)
        email.isEnabled = MFMailComposeViewController.canSendMail()
        #else
        email.isEnabled = false
        #endif
        
        if let data = log.data, let string = String(data: data, encoding: .utf8) {
            viewer.text = string
        } else {
            viewer.text = ""
        }
        
        log.addObserver(self)
    }
    
    // MARK: - LogObserver
    public func log(entry: Log.Entry) {
        guard let data = entry.data, let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        DispatchQueue.main.async {
            let output = String(format: "%@\n%@", self.viewer.text, string)
            self.viewer.text = output
            self.viewer.flashScrollIndicators()
        }
    }
}

// MARK: - IBActions
extension LogViewController {
    @IBAction private func didTapEmail(_ sender: UIButton) {
        #if canImport(MessageUI)
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        guard let data = log.data else {
            return
        }
        
        let app = App(bundleIdentifier: Bundle.main.bundleIdentifier) ?? .measure
        let subject = String(format: "%@ Log", app.name)
        let attachment = String(format: "%@.log.txt", app.name)
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setSubject(subject)
        controller.addAttachmentData(data, mimeType: "application/txt", fileName: attachment)
        
        present(controller, animated: true, completion: nil)
        #endif
    }
    
    @IBAction private func didTapClear(_ sender: UIButton) {
        log.clear()
        viewer.text = ""
    }
    
    @IBAction private func didTapClose(_ sender: UIButton) {
        guard let delegate = self.delegate else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        delegate.shouldDismissLogViewController(self)
    }
}

#endif

#if canImport(MessageUI) && canImport(UIKit)
extension LogViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
#endif
