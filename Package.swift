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
        .binaryTarget(
            name: "ShadhinGPBinary",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.8/ShadhinGP.xcframework.zip",
            checksum: "cf1d3a19bf9e423db25376824482944b60d838ba23bbdd44086f80ef31e76fc6"
        ),
        .binaryTarget(
            name: "Vmax",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.8/Vmax.xcframework.zip",
            checksum: "  Zipping Vmax...
f4d5f194e61b8b0aec50684f08c3fd7e8f25e9b13ef9ea228b00b635d7deb528"
        ),
        .binaryTarget(
            name: "VmaxVastHelper",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.8/VmaxVastHelper.xcframework.zip",
            checksum: "  Zipping VmaxVastHelper...
5448e7ac074f572b85d47fa0fd58fbb6a86f5b260f97171e9c20001f9dd92a85"
        ),
        .binaryTarget(
            name: "VmaxVideoHelper",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.8/VmaxVideoHelper.xcframework.zip",
            checksum: "  Zipping VmaxVideoHelper...
9916f2234c94ccba7c57c3abbb0c3184d02350e96143f89a8387710a127e1d94"
        ),
        .binaryTarget(
            name: "VmaxNativeHelper",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.8/VmaxNativeHelper.xcframework.zip",
            checksum: "  Zipping VmaxNativeHelper...
147f3cc9ce99d5507fbc4ad4be6b475460e16e1ed17ec6e597da62f7496d4d59"
        ),
        .binaryTarget(
            name: "VmaxOM",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.8/VmaxOM.xcframework.zip",
            checksum: "  Zipping VmaxOM...
08800014d5747d8377b81758ee37bdca4b8b5032b7288482d02f3369d18f9324"
        ),
        .binaryTarget(
            name: "VmaxDisplayHelper",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.8/VmaxDisplayHelper.xcframework.zip",
            checksum: "  Zipping VmaxDisplayHelper...
b04a7dfce4edaba56f9d09e54a90c433dc1f8cfe2b1d3017dd433f16160e3961"
        ),
        .binaryTarget(
            name: "OMSDK_Vmax2",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.8/OMSDK_Vmax2.xcframework.zip",
            checksum: "  Zipping OMSDK_Vmax2...
205a38fc6360b930c57c016cea11b0deb5ccba0e9116a22f537d6f8e81155b6b"
        ),
    ]
)
