// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BlockOutGame",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "BlockOutGame",
            targets: ["BlockOutGame"]
        ),
    ],
    targets: [
        .target(
            name: "BlockOutGame",
            dependencies: [],
            path: "Sources/BlockOutGame"
        ),
        .testTarget(
            name: "BlockOutGameTests",
            dependencies: ["BlockOutGame"],
            path: "Tests/BlockOutGameTests"
        ),
    ]
)

