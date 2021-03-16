// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "DependencyKitCLI",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(name: "SwiftSyntax",
                 url: "https://github.com/apple/swift-syntax.git",
                 .exact("0.50300.0")),
        .package(name: "swift-argument-parser",
                 url: "https://github.com/apple/swift-argument-parser.git",
                 .exact("0.3.1")),
        .package(name: "Yams",
                 url: "https://github.com/jpsim/Yams.git",
                 from: "4.0.3"),
    ],
    targets: [
        .target(name: "DependencyKitCLI",
                dependencies: [
                    .product(name: "ArgumentParser",
                             package: "swift-argument-parser"),
                    .product(name: "SwiftSyntax",
                             package: "SwiftSyntax"),
                    .product(name: "Yams",
                             package: "Yams"),
        ]),
    ]
)
