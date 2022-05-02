// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CodeQuickKit",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7),
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
