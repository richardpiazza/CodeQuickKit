import Foundation

/// Protocol to which an enumeration can conform to produce String localizations.
///
/// Localization is one of the key differentiators between *good* apps and
/// *great* apps. Though many development teams take on this challenge only
/// after the application is 'complete'.
///
/// The aim of `LocalizedStringExpressable` is to quicken the procress of
/// localization, at the same time, taking much of the *guess-work* out of the
/// picture.
///
/// When implemented on an `String` based enum, localization becomes a quick
/// process that can be integrated at the beginning of any project. An example
/// implementation looks like this:
///
/// ```
/// /// Localized Strings for the MyAwesomeController class.
/// enum Strings: String, LocalizedStringExpressable {
///     /// My Awesome Controller
///     case navigationTitle = "My Awesome Controller"
///     /// Next
///     case nextButton = "Next"
///     /// Previous
///     case previousButton = "Previous"
/// }
/// ```
///
/// Each enumeration case will automagically refrence a specifc value in the
/// default 'Localizable.strings' file. The 'rawValue' will be used as the
/// default value in the scenario where a key is not found. A `///` comment
/// will provide a quick code-completion hint.
///
/// For detailed information on using `String` resources, see
/// [Apple's Documentation](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html#//apple_ref/doc/uid/20000005-97055)
public protocol LocalizedStringExpressable {
    /// The '.strings' unique identifier for the localization
    var key: String { get }
    
    /// Optional file name in the '.strings' file containing the 'key'
    var tableName: String? { get }
    
    /// The `Bundle` where the localization table can be found
    var bundle: Bundle { get }
    
    /// The default value
    ///
    /// If a lookup fails to find a 'key' in the specified 'table',
    /// a default value should be provided.
    var value: String { get }
    
    /// A comment to clarify the intented usage of the localization
    ///
    /// This should be provided to translation teams to assist in proper
    /// proper translation.
    var comment: String { get }
    
    /// A optional prefix appended to the beginning of the key.
    ///
    /// It is a common practice to group string localizations to help identify
    /// purpose and clarify meaning. The default implementation will append
    /// any given value to the beginning of the generated localization 'key'.
    ///
    /// - note: If a string is specified, it should be in the same style as
    ///         the enumeration case (i.e. camelCase) with no spaces or
    ///         punctuation.
    var prefix: String? { get }
}

public extension LocalizedStringExpressable {
    // Each localization needs a unique 'key' to be defined in the '.strings' files.
    // By default, a key will automatically be generated from the enumation case itself.
    // If a `prefix` is specific, it will be appended to the beginning of the key name.
    var key: String {
        if let prefix = self.prefix {
            return String(format: "%@_%@", prefix.localizableKey, String(describing: self).localizableKey)
        } else {
            return String(describing: self).localizableKey
        }
    }
    
    // By default, we are going to assume the default bundle.
    // If creating a shared library or multiple modules, the bundle value
    // can be specified by overriding this value.
    var bundle: Bundle {
        return Bundle.main
    }
    
    // By default, specifying 'nil' for the 'tableName' in NSLocalizedString()
    // will use the 'Localizable.strings' file. If multiple '.strings' files
    // are in use, the specific file can be indicated.
    var tableName: String? {
        return nil
    }
    
    // Comments are useful in clarifying usage and intent. That being said,
    // in the attempt to make localization as easy as possible, a default
    // empty string is supplied here.
    var comment: String {
        return ""
    }
    
    // A prefix is another useful option to group and express localization intent.
    // By default, the strings file key will be created from the enumeration case
    // only.
    var prefix: String? {
        return nil
    }
}

public extension LocalizedStringExpressable where Self: RawRepresentable, Self.RawValue == String {
    // When an enumaration is declared to be using a `RawValue` of type `String`,
    // the assumtion will be that the value specified is the default value for localization
    // should the '.strings' lookup fail.
    var value: String {
        return rawValue
    }
}

public extension LocalizedStringExpressable {
    /// The value returned from 'NSLocalizedString(...)'
    var localizedValue: String {
        return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment)
    }
}

extension StringProtocol {
    /// An '_' seperated, uppercased representation of a camelCased string.
    ///
    /// For example: the `String` 'navigationControllerTitle' would be converted to
    /// 'NAVIGATION_CONTROLLER_TITLE'. This can be used for identifying keys in
    /// Localizable.strings files.
    var localizableKey: String {
        let components = self.splitBefore(separator: { $0.isUppercased }).map({ String($0).uppercased() })
        return components.joined(separator: "_")
    }
}
