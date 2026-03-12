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
                "iCarousel",
                "LNPopupController",
                "Vmax",
                "VmaxVastHelper",
                "VmaxVideoHelper",
                "VmaxNativeHelper",
                "VmaxOM",
                "VmaxDisplayHelper",
                "OMSDK_Vmax2",
            ],
            path: "Shadhin_Gp",
            exclude: [
                "Shadhin/Shadhin.entitlements",
                "Shadhin/download.json",
                "Shadhin/gakkpayBkash.cer",
                "Shadhin/gakkpayCert.cer",
                "Shadhin/Supporting Files/Shadhin-Bridging-Header.h",
                "Shadhin/Supporting Files/iCarousel.h",
                "Shadhin/Supporting Files/iCarousel.m",
                "Shadhin/Supporting Files/AudioPlayer",
                "Shadhin/Version3/Model/VmaxAdModel/VmaxManager/VmaxAdModel.swift",
                "Library/SnapKit/PrivacyInfo.xcprivacy",
                "Library/SignalRClient/SignalR.swift",
                "Library/LNPopupController",
                "Library/iCarousel",
                "Library/Vmax",
                "Library/AudioPlayer/CircularProgress.swift",
                "Library/VGPlayer/MediaCache/VGPlayerCacheManager.swift",
            ],
            resources: [
                .process("Shadhin/Resources"),
                .process("Shadhin/Storyboard"),
                .process("Shadhin/Localize"),
                .process("Shadhin/CollectionViewCell"),
                .process("Shadhin/Controller"),
                .process("Shadhin/CustomViews"),
                .process("Shadhin/Database"),
                .process("Shadhin/TableViewCell"),
                .process("Shadhin/XIBs"),
                .process("Shadhin/Version3"),
                .process("Library/DropDown/resources"),
            ]
        ),
        .target(
            name: "iCarousel",
            path: "Shadhin_Gp/Library/iCarousel",
            publicHeadersPath: "."
        ),
        .target(
            name: "LNPopupController",
            path: "Shadhin_Gp/Library/LNPopupController",
            exclude: ["Private"],
            publicHeadersPath: "."
        ),
        .binaryTarget(name: "Vmax", path: "Shadhin_Gp/Library/Vmax/Vmax.xcframework"),
        .binaryTarget(name: "VmaxVastHelper", path: "Shadhin_Gp/Library/Vmax/VmaxVastHelper.xcframework"),
        .binaryTarget(name: "VmaxVideoHelper", path: "Shadhin_Gp/Library/Vmax/VmaxVideoHelper.xcframework"),
        .binaryTarget(name: "VmaxNativeHelper", path: "Shadhin_Gp/Library/Vmax/VmaxNativeHelper.xcframework"),
        .binaryTarget(name: "VmaxOM", path: "Shadhin_Gp/Library/Vmax/VmaxOM.xcframework"),
        .binaryTarget(name: "VmaxDisplayHelper", path: "Shadhin_Gp/Library/Vmax/VmaxDisplayHelper.xcframework"),
        .binaryTarget(name: "OMSDK_Vmax2", path: "Shadhin_Gp/Library/Vmax/OMSDK_Vmax2.xcframework"),
    ]
)
