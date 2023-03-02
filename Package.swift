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
        .library(
            name: "RxMiniature",
            targets: ["RxMiniature"]
        ),
        .library(
            name: "CombineMiniature",
            targets: ["CombineMiniature"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.5.0"))
    ],
    targets: [
        .target(
            name: "Miniature",
            dependencies: []
        ),
        .testTarget(
            name: "MiniatureTests",
            dependencies: ["Miniature"]
        ),
        .target(
            name: "RxMiniature",
            dependencies: [
                "Miniature",
                .product(name: "RxSwift", package: "RxSwift")
            ]
        ),
        .target(
            name: "CombineMiniature",
            dependencies: [
                "Miniature"
            ]
        )
    ]
)
