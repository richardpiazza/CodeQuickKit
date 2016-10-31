# CodeQuickKit
[![Version](https://img.shields.io/cocoapods/v/CodeQuickKit.svg?style=flat)](http://cocoadocs.org/docsets/CodeQuickKit)
[![Platform](https://img.shields.io/cocoapods/p/CodeQuickKit.svg?style=flat)](http://cocoadocs.org/docsets/CodeQuickKit)

An iOS Library for simplifying some everyday tasks.

#### Bundle.swift

Extension on `Bundle` that provides first level property access to common bundle items. Also provides methods for determining class names in other modules.

#### CoreData.swift

Provides an implementation of a CoreData Stack. Conveience initializers allow for the model to be retrieved from the app bundle or through specified `NSEntityDescription`s.

A common implementation looks like this:

	class Repository {
		static let coreData = CoreData(fromBundle: NSBundle.mainBundle(), modelName: "model")
	}

#### Date.swift

Extension on `Date` that provides several helpful variables and methods.

Some examples include:

    let nextWeek = Date.nextWeek
    let before = date1.isBefore(date2)
    let same = date1.isSame(date2)
    let after = date1.isAfter(date2)
    let future = Date().dateByAdding(hours: 4)

#### DateFormatter.swift

Extension on `DateFormatter` that provides a static reference to common date Formatters. The default formatter used in several classes of `CodeQuickKit` is the RFC1123 formatter.

#### Downloader.swift

A wrapper for NSURLSession similar to `WebAPI` for general purpose downloading of data and images.

#### FileManager.swift

Extension on `FileManager` that provides several helpful methods for interacting with the sandbox and ubiquity directories.

Also provided is a single implementation for initializing the Ubiquity containers.

	FileManager.defaultManager().initializeUbiquityContainer(nil) { (ubiquityState) -> Void in
		
	}

and a wrapper for `NSMetadataQuery` needed to access documents in the ubiquity containers:

	FileManager.defaultManager().ubiquityDocuments(withExtension: nil) { (documents: UbiquityDocuments?, error: NSError?)
		
	}

#### Logger.swift

Provides a single logger that allows for extension by proxying requests to `LoggerAgents`. The classes in CodeQuickKit use the Logger, add a `LoggerAgent` if you wish to process the log to another service.

#### NSManagedObjectContext.swift

A set of functions extending `NSManagedObjectContext` to handle merging changes through a private context.

#### NSMetadataQuery.swift

An extension of `NSMetadataQuery` that returns only visible documents (i.e. not hidden).

#### NSObject.swift

Extension on `NSObject` with methods for determining the Obj-c style setter for a given property.

#### NumberFormatter.swift

Provides static access to several common number formatters:

    NumberFormatter.integerFormatter()
    NumberFormatter.singleDecimalFormatter()
    NumberFormatter.decimalFormatter()
    NumberFormatter.currencyFormatter()
    NumberFormatter.percentFormatter()

#### Reusable.swift

Defines a protocol for use on `UIView` that provides the class name as a reuse identifier.

#### Serializable.swift

A protocol specifying methods for interacting with Dictionary/JSON representations of NSObjects.

#### Serializer.swift

A collection of methods and properties the aid in the de/serializtion process.

#### SerializableManagedObject.swift

A subclass of `NSManagedObject` that conforms to the `Serializable` protocol as well as providing convenience methods for initializing Core Data entities.

#### SerializableObject.swift

A subclass of `NSObject` that conforms to the `Serializable` protocol.

#### Storyboarded.swift

A protocol for use with UIViewController subclasses that are implemented in storyboards.

#### UIAlertController.swift

An extension on UIAlertController that provides static methods for displaying Alerts with a single callback handler.

#### WebAPI.swift

A wrapper for `NSURLSession` for communication with JSON REST API's. This class automatically deserializes a JSON response.
