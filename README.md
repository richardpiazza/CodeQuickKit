# CodeQuickKit

A Swift library for simplifying some everyday tasks.

<p>
    <img src="https://github.com/richardpiazza/CodeQuickKit/workflows/Swift/badge.svg?branch=main" />
    <img src="https://img.shields.io/badge/Swift-5.2-orange.svg" />
    <a href="https://twitter.com/richardpiazza">
        <img src="https://img.shields.io/badge/twitter-@richardpiazza-blue.svg?style=flat" alt="Twitter: @richardpiazza" />
    </a>
</p>

## Installation

**CodeQuickKit** is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, Use the 
Xcode 'Swift Packages' menu or add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/richardpiazza/CodeQuickKit.git", .upToNextMinor(from: "6.8.5"))
    ],
    ...
)
```

Then import the **CodeQuickKit** packages wherever you'd like to use it:

```swift
import CodeQuickKit
```

## Features

### Bundle

Apple uses bundles to represent apps, frameworks, plug-ins, and many other specific types of content. Bundles organize their contained 
resources into well-defined subdirectories, and bundle structures vary depending on the platform and the type of the bundle.

**CodeQuickKit** offers some extensions to `Bundle` for some commonly used functions, including:
* Direct access to the _CFBundle*_ info dictionary keys like 'display name' and 'build number'.
  `Bundle.main.buildNumber`
* Retrieval and decoding of JSON resources.
  `Bundle.main.decodableData<T: Decodable>(ofType:forResource:withExtension:usingDecoder:) throws -> T`
* Storyboard references for _launch_ and _main_.
  `Bundle.main.mainStoryboard`
* Determining modularized and singularized class names.

### Character

The Character type represents a character made up of one or more Unicode scalar values, grouped by a Unicode boundary algorithm.

The extensions provided allow for a check on casing with: `Character.isUppercased`

### Date

A Date value encapsulate a single point in time, independent of any particular calendrical system or time zone. Date values represent a time 
interval relative to an absolute reference date.

**CodeQuickKit** extensions provide many semantic variables including:
```swift
let nextWeek = Date.nextWeek
let before = date1.isBefore(date2)
let same = date1.isSame(date2)
let after = date1.isAfter(date2)
let future = Date().dateByAdding(hours: 4)
```

#### DateFormatter.swift

Extension on `DateFormatter` that provides a static reference to common date Formatters. The default formatter used in several classes of 
**CodeQuickKit** is the RFC1123 formatter.

#### Downloader.swift

A wrapper for URLSession similar to `WebAPI` for general purpose downloading of data and images.

#### Environment.swift

Reports the Platform, Architecture, and Swift version currently in use.

#### FileManager.swift

Extension on `FileManager` that provides several helpful methods for interacting with the sandbox and ubiquity directories.

Also provided is a single implementation for initializing the Ubiquity containers.

	FileManager.defaultManager().initializeUbiquityContainer(nil) { (ubiquityState) -> Void in
		
	}

and a wrapper for `NSMetadataQuery` needed to access documents in the ubiquity containers:

	FileManager.defaultManager().ubiquityDocuments(withExtension: nil) { (documents: UbiquityDocuments?, error: Error?)
		
	}

#### Log.swift

Provides a single logger that allows for extension by proxying requests to `LogObserver`s. The classes in CodeQuickKit use the Log. Add a 
`LogOberserver` if you wish to process the log to another service.

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

