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
        .binaryTarget(
            name: "ShadhinMusic",
            url: "https://github.com/shadhin-music/MyGP_iOS_ShadhinMusicSDK/releases/download/1.0.3/Shadhin_Gp.xcframework.zip",
            checksum: "618c60572fbfb7b2aa7e266867302f449c3efd82ffe12428fd684ad9cb2aeb78"
        ),
    ]
)
