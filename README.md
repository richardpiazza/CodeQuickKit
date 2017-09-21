# CodeQuickKit
[![Version](https://img.shields.io/cocoapods/v/CodeQuickKit.svg?style=flat)](http://cocoadocs.org/docsets/CodeQuickKit)
[![Platform](https://img.shields.io/cocoapods/p/CodeQuickKit.svg?style=flat)](http://cocoadocs.org/docsets/CodeQuickKit)

A Swift library for simplifying some everyday tasks.

#### Bundle.swift

Extension on `Bundle` that provides first level property access to common bundle items. Also provides methods for determining class names in other modules.

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

A wrapper for URLSession similar to `WebAPI` for general purpose downloading of data and images.

#### FileManager.swift

Extension on `FileManager` that provides several helpful methods for interacting with the sandbox and ubiquity directories.

Also provided is a single implementation for initializing the Ubiquity containers.

	FileManager.defaultManager().initializeUbiquityContainer(nil) { (ubiquityState) -> Void in
		
	}

and a wrapper for `NSMetadataQuery` needed to access documents in the ubiquity containers:

	FileManager.defaultManager().ubiquityDocuments(withExtension: nil) { (documents: UbiquityDocuments?, error: Error?)
		
	}

#### Log.swift

Provides a single logger that allows for extension by proxying requests to `LogObserver`s. The classes in CodeQuickKit use the Log. Add a `LogOberserver` if you wish to process the log to another service.

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

#### Storyboarded.swift

A protocol for use with UIViewController subclasses that are implemented in storyboards.

#### UIAlertController.swift

An extension on UIAlertController that provides static methods for displaying Alerts with a single callback handler.

#### WebAPI.swift

A wrapper for `NSURLSession` for communication with REST API's.
