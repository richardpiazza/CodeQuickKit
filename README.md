# CodeQuickKit

A Swift library for simplifying some everyday tasks.

<p>
    <img src="https://github.com/richardpiazza/CodeQuickKit/workflows/Swift/badge.svg?branch=main" />
    <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" />
    <a href="https://twitter.com/richardpiazza">
        <img src="https://img.shields.io/badge/twitter-@richardpiazza-blue.svg?style=flat" alt="Twitter: @richardpiazza" />
    </a>
</p>

## 💻 Installation

This software is distributed using [Swift Package Manager](https://swift.org/package-manager). 
You can add it using Xcode or by listing it as a dependency in your `Package.swift` manifest:

```swift
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/richardpiazza/CodeQuickKit", .upToNextMajor(from: "7.0.0")
  ],
  ...
  targets: [
    .target(
      name: "MyPackage",
      dependencies: [
        "CodeQuickKit"
      ]
    )
  ]
)
```

## 📌 Features

Features in this project are largely grouped around how the apply-to or extend existing frameworks:

### Swift Core Library

* **Dependency Management**:
    `DependencyCache` offers a singleton approach to managing service and configuration dependencies throughout an application.
    The cache is configured by passing a `DependencySupplier` to the `configure(with:)` function.
    A _dependency_ can be directly resolved from the _cache_ using `resolve<T>() throws -> T`, or the `Dependency` property wrapper can be used to lazily reference as needed:
  
  ```swift
  @Dependency private var someService: SomeService
  ```

### Foundation

* **UserDefaults**:
    `UserDefault` is a property wrapper designed to interact with the `UserDefaults` storage.
  
  ```swift
  @UserDefault("counter", defaultValue: 0) var counter: Int
  ```

### UIKit

* **UIAlertController.ActivityAlertController**:
  
  This *hack* creates a alert dialog with a progress indicator and optional title/messaging strings.

### SwiftUI

* **ActivityAlertView**
  
  A SwiftUI workaround for using the `ActivityAlertController`. (UIKit Only)

## 🛠 Wanna Help?

Contributions are welcome and encouraged! See the [Contribution Guide](CONTRIBUTING.md) for more information.
