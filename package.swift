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
        SwiftUI
        CoreML
        Firebase
        FirebaseFirestore
        FirebaseStorage
        FirebaseAuth
        FirebaseFunctions
        FirebaseUI
        FirebaseUIFirestore

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
