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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "ObeseFood",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
            ]),
        .testTarget(
            name: "ObeseFoodTests",
            dependencies: ["ObeseFood"]),
    ]
)
