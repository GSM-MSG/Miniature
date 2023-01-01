// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Miniature",
    platforms: [.iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macOS(.v10_15)],
    products: [
        .library(
            name: "Miniature",
            targets: ["Miniature"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Miniature",
            dependencies: []
        ),
        .testTarget(
            name: "MiniatureTests",
            dependencies: ["Miniature"]
        ),
    ]
)
