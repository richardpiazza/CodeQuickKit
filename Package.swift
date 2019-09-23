// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CodeQuickKit",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v5),
    ],
    products: [
        .library(name: "CodeQuickKit", targets: ["CodeQuickKit"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "CodeQuickKit", path: "Sources"),
        .testTarget(name: "CodeQuickKitTests", dependencies: ["CodeQuickKit"], path:"Tests")
    ],
    swiftLanguageVersions: [.v5]
)
