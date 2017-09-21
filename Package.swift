// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "CodeQuickKit",
    products: [
        .library(name: "CodeQuickKit", targets: ["CodeQuickKit"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "CodeQuickKit", path: "Sources"),
        .testTarget(name: "CodeQuickKitTests", dependencies: ["CodeQuickKit"], path:"Tests")
    ]
)
