// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Created by Markus Schmid on 17.07.22.
//

import PackageDescription

let package = Package(
    name: "sqlite-tool",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.2"),
    ],
    targets: [
        .executableTarget(
            name: "sqlite-tool",
            dependencies: [
                "SqliteUtil",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                ],
            path: "Sources/SqliteTool"),
        .target(
            name: "SqliteUtil",
            dependencies: [
                "DataController"
                ]),
        .target(
            name: "DataController",
            path: "Sources/DataConnect"),
    ]
)
