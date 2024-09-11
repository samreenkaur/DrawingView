// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DrawingView",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DrawingView",
            targets: ["DrawingView"]),
    ],
    dependencies: [
           .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0")
       ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
//        .target(
//            name: "DrawingView"),
        .testTarget(
            name: "DrawingViewTests",
            dependencies: ["DrawingView"]),
        .target(
            name: "DrawingView",
            dependencies: [
                            "SDWebImage" // Link the SDWebImage package here
                        ],
            path: "Sources", // Path to your source code
            resources: [
                .process("DrawingView/Resources/Assets.xcassets")
            ]),
    ]
)
