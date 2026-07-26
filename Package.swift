// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTTPNetworkClient",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HTTPNetworkClient",
            targets: ["HTTPNetworkClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git",
                 from: "0.57.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HTTPNetworkClient",
            path: "Sources/NetworkClient",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",
                        package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "HTTPNetworkClientTests",
            dependencies: ["HTTPNetworkClient"],
            path: "Tests/NetworkClientTests",
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin",
                        package: "SwiftLint")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
