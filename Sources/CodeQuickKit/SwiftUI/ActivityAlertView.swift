#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI

/// A view which shows an 'activity' alert in SwiftUI.
///
/// To use, set an `ActivityAlertView` instance as the `.overlay()` or `.background()` of your element.
/// The alert will show/hide whenever the presentation binding changes.
public struct ActivityAlertView: UIViewControllerRepresentable {
    
    /// A binding to a Boolean value that determines whether to present the view.
    @Binding public var isPresented: Bool
    /// The header text of the presented alert
    public let title: String?
    /// The body text of the presented alert
    public let message: String?
    /// Inset values that should be used in place of defaults.
    public var padding: EdgeInsets? = nil
    
    public func makeCoordinator() -> UIAlertController {
        var insets: UIEdgeInsets?
        if let padding = padding {
            insets = UIEdgeInsets(top: padding.top, left: padding.leading, bottom: padding.bottom, right: padding.trailing)
        }
        
        return UIAlertController.makeActivityAlert(title: title, message: message, padding: insets)
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        UIViewController()
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let alertController = context.coordinator
        switch (isPresented, uiViewController.presentedViewController) {
        case (true, nil):
            uiViewController.present(alertController, animated: true)
        case (false, alertController):
            alertController.dismiss(animated: true)
        default:
            break
        }
    }
}
#endif
