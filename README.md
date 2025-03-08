# CodeQuickKit

A Swift library for simplifying some everyday tasks.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FCodeQuickKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/richardpiazza/CodeQuickKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FCodeQuickKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/richardpiazza/CodeQuickKit)

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
