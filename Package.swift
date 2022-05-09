// swift-tools-version:5.5.2

import PackageDescription

let package = Package(
    name: "CodeQuickKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "CodeQuickKit",
            targets: ["CodeQuickKit"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CodeQuickKit"
        ),
        .testTarget(
            name: "CodeQuickKitTests",
            dependencies: ["CodeQuickKit"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
