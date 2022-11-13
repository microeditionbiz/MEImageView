// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MEImageView",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "MEImageView",
            targets: ["MEImageView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MEImageView",
            dependencies: []),
        .testTarget(
            name: "MEImageViewTests",
            dependencies: ["MEImageView"]),
    ]
)
