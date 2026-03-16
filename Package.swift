// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShadhinGP",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ShadhinGP",
            targets: ["ShadhinGP"]
        )
    ],
    targets: [
        .target(
            name: "ShadhinGP",
            dependencies: [
                "ShadhinGPBinary",
                "Vmax",
                "VmaxVastHelper",
                "VmaxVideoHelper",
                "VmaxNativeHelper",
                "VmaxOM",
                "VmaxDisplayHelper",
                "OMSDK_Vmax2",
            ],
            path: "Sources/ShadhinGP"
        ),
        .binaryTarget(name: "ShadhinGPBinary", url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.7/ShadhinGP.xcframework.zip", checksum: "270d33d80655fcf00ec7cea1f28e6375cb4d338bf57ed34aa6df5ab7a9011fe7"),
        .binaryTarget(name: "Vmax", url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.7/Vmax.xcframework.zip", checksum: "f4d5f194e61b8b0aec50684f08c3fd7e8f25e9b13ef9ea228b00b635d7deb528"),
        .binaryTarget(name: "VmaxVastHelper", url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.7/VmaxVastHelper.xcframework.zip", checksum: "5448e7ac074f572b85d47fa0fd58fbb6a86f5b260f97171e9c20001f9dd92a85"),
        .binaryTarget(name: "VmaxVideoHelper", url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.7/VmaxVideoHelper.xcframework.zip", checksum: "9916f2234c94ccba7c57c3abbb0c3184d02350e96143f89a8387710a127e1d94"),
        .binaryTarget(name: "VmaxNativeHelper", url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.7/VmaxNativeHelper.xcframework.zip", checksum: "147f3cc9ce99d5507fbc4ad4be6b475460e16e1ed17ec6e597da62f7496d4d59"),
        .binaryTarget(name: "VmaxOM", url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.7/VmaxOM.xcframework.zip", checksum: "08800014d5747d8377b81758ee37bdca4b8b5032b7288482d02f3369d18f9324"),
        .binaryTarget(name: "VmaxDisplayHelper", url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.7/VmaxDisplayHelper.xcframework.zip", checksum: "b04a7dfce4edaba56f9d09e54a90c433dc1f8cfe2b1d3017dd433f16160e3961"),
        .binaryTarget(name: "OMSDK_Vmax2", url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.7/OMSDK_Vmax2.xcframework.zip", checksum: "205a38fc6360b930c57c016cea11b0deb5ccba0e9116a22f537d6f8e81155b6b"),
    ]
)
