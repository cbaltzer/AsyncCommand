// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncCommand",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(
            name: "AsyncCommand",
            targets: ["AsyncCommand"]),
    ],
    dependencies: [
        // None :)
    ],
    targets: [
        .target(
            name: "AsyncCommand",
            dependencies: []),
        .testTarget(
            name: "AsyncCommandTests",
            dependencies: ["AsyncCommand"]),
    ]
)
