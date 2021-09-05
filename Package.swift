// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DependencyKit",
    products: [
        .library(
            name: "DependencyKit",
            targets: ["DependencyKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DependencyKit",
            dependencies: []),
        .testTarget(
            name: "DependencyKitTests",
            dependencies: ["DependencyKit"]),
    ]
)
