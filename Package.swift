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
        .target(
            name: "ShadhinMusic",
            dependencies: [...],
            path: "Shadhin_Gp",
            ...
        ),
        // all other targets
    ]
)
