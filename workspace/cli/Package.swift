// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DependencyKitCLI",
    dependencies: [
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50300.0")),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", .exact("0.3.1"))
    ],
    targets: [
        .target(
            name: "DependencyKitCLI",
            dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "SwiftSyntax", package: "SwiftSyntax"),
        ]),
    ]
)