// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShadhinGP",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ShadhinGP",
            targets: [
                "ShadhinGP",
                "Vmax",
                "VmaxVastHelper",
                "VmaxVideoHelper",
                "VmaxNativeHelper",
                "VmaxOM",
                "VmaxDisplayHelper",
                "OMSDK_Vmax2",
            ]
        )
    ],
    targets: [
        .binaryTarget(
            name: "ShadhinGP",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.4/ShadhinGP.xcframework.zip",
            checksum: "e82d3eda76f184a139900d2dc21ca37ed937aee8063af1b4c52c7da1013b484e"
        ),
        .binaryTarget(
            name: "Vmax",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.4/Vmax.xcframework.zip",
            checksum: "dd27ff70ef6fe90ad5905bb3e98c7d95dca2233c332d48ffc2b489ddf2bad9a5"
        ),
        .binaryTarget(
            name: "VmaxVastHelper",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.4/VmaxVastHelper.xcframework.zip",
            checksum: "b8f6416fcf6aa90166202d8fcce8516ab3c92cec72f283fe4e05c94ba4d0610f"
        ),
        .binaryTarget(
            name: "VmaxVideoHelper",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.4/VmaxVideoHelper.xcframework.zip",
            checksum: "d40a2b9a57e5dcbfccc31e6fd4985bf7fa6b819c275b4732dc8c7d49d726c84a"
        ),
        .binaryTarget(
            name: "VmaxNativeHelper",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.4/VmaxNativeHelper.xcframework.zip",
            checksum: "563e79bc73eb2402eaa786b1e88d8e9dfe6bae8a39ca802883b4e85199499e51"
        ),
        .binaryTarget(
            name: "VmaxOM",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.4/VmaxOM.xcframework.zip",
            checksum: "45dc4ed708aa59d66306d7ccc33f3065f6c5df8265c6b712776683c95f68219f"
        ),
        .binaryTarget(
            name: "VmaxDisplayHelper",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.4/VmaxDisplayHelper.xcframework.zip",
            checksum: "41be76f1fd2f2eb44738228f7c4ede1f2b30eddb89b043c949a34bfcb286a865"
        ),
        .binaryTarget(
            name: "OMSDK_Vmax2",
            url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK/releases/download/1.0.4/OMSDK_Vmax2.xcframework.zip",
            checksum: "90b519d79b13c385779b2f6482e45dfa13e767d3edce1383483c247a462700a2"
        ),
    ]
)
