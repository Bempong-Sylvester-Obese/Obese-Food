// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ObeseFood",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ObeseFood",
            targets: ["ObeseFood"]),
    ],
    dependencies: [
        // Add your dependencies here
    ],
    targets: [
        .target(
            name: "ObeseFood",
            dependencies: []),
        .testTarget(
            name: "ObeseFoodTests",
            dependencies: ["ObeseFood"]),
    ]
)
