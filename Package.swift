// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ShadhinMusic",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "ShadhinMusic",
            targets: ["ShadhinMusic"]
        ),
    ],
    targets: [

        // MARK: - Main Binary Target
        // Distributed as a pre-built XCFramework to protect source code.
        .binaryTarget(
            name: "ShadhinMusic",
            path: "ShadhinGP_Framework/Framework/Shadhin_Gp.xcframework"
        ),
    ]
)
