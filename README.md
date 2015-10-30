# CodeQuickKit

An OS X / iOS Library for simplifying some everyday tasks.

### CQKCoreDataStack

Provided a wrapper for all the objects needed for interacting with Core Data.
By default, when no delegate has been specified, an in-memory store is created. This is very usefully when writing tests and performing temporary operations.

### CQKLogger

An extensible logging class. The CodeQuickKit uses this class for all loging. The default implementation will log to the console.
Add a `id<CQKLoggerAgent>` to recieve all log events that meet or excede the minimum logging level.

### CQKSerializable

Defines a protocol on `NSObject` for de/serializating objects to/from `NSDictionary`, `NSData`, and JSON `NSString`.
All of the serializable classes in the CodeQuickKit have a default implementaion of this protocol.

### CQKSerializableNSManagedObject

Subclass of `NSManagedObject` that implements the `CQKSerializable` protocol. This class also provides default initializers for creating new objects within a specified `NSManagedObjectContext`.
This class also provides several methods for controlling the de/serialization procoess.
By default, this class will attempt to de/serialize all `@property` objects on the class.

### CQKSerializableNSObject

Subclass of `NSObject` that implements the `CQKSerializable` protocol. This class will attempt to de/serialize all `@property` objects on this class.
This class has default implementation of several methods that control the de/serialization process, and can be overriden when needed for greater control.
The `[CQKSerializableNSObject configuration]` object has several properties that can be adjusted to apply to all de/serialization.

### CQKUbiquityNSFileManager

A subclass of `NSFileManager` with properties and methods for working with ubiquity (iCloud) document containers.

### CQKUbiquityNSUserDefaults

In development. Header not included in framework.

### CQKWebAPI

A wrapper for `NSURLSession` for interacting with JSON REST API's.

### NSBundle+CQKBundle

Provides first-level access to additional keys that are found in an `NSBundle` plist.

### NSFileManager+CQKSandbox

A category of `NSFileManger` that has helpful methods for accessing sandbox documents.

### NSNumberFormatter+CQKNumberFormatters

A category of `NSNumberFormatter` that provides class level methods for common number formatting.

### NSData+CQKCrypto

A category of `NSData` that returns the MD5 digest of an `NSData` object.

### NSDate+CQKDates

`NSDate` category with methods for date maniuplation and comparisson.

### NSObject+CQKRuntime

Leverages the Objc runtime to determine the properties/class for a particular class.

### UIAlertController+CQKAlerts

# iOS Only
A singleton-backed implementation of UIAlertController that provideds block-based callbacks. (Yes, I know the new UIAlertController class has block support. But building an alert still takes a lot of code.)

### UIStoryboard+CQKStoryboards

# iOS Only
Categories and methods for the classes `UIStoryboard`, `UIViewController`, and `UITableViewController` that make it easier to work with Storyboards from code.
