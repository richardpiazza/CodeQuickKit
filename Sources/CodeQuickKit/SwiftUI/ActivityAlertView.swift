#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI

/// A view which shows an 'activity' alert in SwiftUI.
///
/// To use, set an `ActivityAlertView` instance as the `.overlay()` or `.background()` of your element.
/// The alert will show/hide whenever the presentation binding changes.
public struct ActivityAlertView: UIViewControllerRepresentable {
    
    /// A binding to a Boolean value that determines whether to present the view.
    public let isPresented: Binding<Bool>
    /// The header text of the presented alert
    public let title: Binding<String>?
    /// The body text of the presented alert
    public let message: Binding<String>?
    /// Inset values that should be used in place of defaults.
    public let padding: EdgeInsets?
    
    public init(isPresented: Binding<Bool>, title: String?, message: String?, padding: EdgeInsets? = nil) {
        self.isPresented = isPresented
        self.title = (title != nil) ? .constant(title!) : nil
        self.message = (message != nil) ? .constant(message!) : nil
        self.padding = padding
    }
    
    public init(isPresented: Binding<Bool>, title: Binding<String>? = nil, message: Binding<String>? = nil, padding: EdgeInsets? = nil) {
        self.isPresented = isPresented
        self.title = title
        self.message = message
        self.padding = padding
    }
    
    public func makeCoordinator() -> UIAlertController {
        var insets: UIEdgeInsets?
        if let padding = padding {
            insets = UIEdgeInsets(top: padding.top, left: padding.leading, bottom: padding.bottom, right: padding.trailing)
        }
        
        return UIAlertController.makeActivityAlert(title: title?.wrappedValue, message: message?.wrappedValue, padding: insets)
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        UIViewController()
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let alertController = context.coordinator
        switch (isPresented.wrappedValue, uiViewController.presentedViewController) {
        case (true, nil):
            alertController.title = title?.wrappedValue
            alertController.message = message?.wrappedValue
            uiViewController.present(alertController, animated: true)
        case (true, _):
            alertController.title = title?.wrappedValue
            alertController.message = message?.wrappedValue
        case (false, alertController):
            alertController.dismiss(animated: true)
        default:
            break
        }
    }
}
#endif
