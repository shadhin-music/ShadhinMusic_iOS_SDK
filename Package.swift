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

        // MARK: - Main Library Target
        // All Swift sources (Shadhin + Library) compile into one module,
        // matching the existing Xcode framework target structure.
        .target(
            name: "ShadhinMusic",
            dependencies: [
                "iCarousel",
                "LNPopupController",
                "Vmax",
                "VmaxDisplayHelper",
                "VmaxNativeHelper",
                "VmaxVastHelper",
                "VmaxVideoHelper",
                "VmaxOM",
                "OMSDK_Vmax2",
            ],
            path: "Shadhin_Gp",
            exclude: [
                // ObjC targets — handled separately in ObjCBridge/
                "Library/iCarousel",
                "Library/LNPopupController",
                // Vmax — binary targets below
                "Library/Vmax",
                // Duplicate AudioPlayer (same code lives in Shadhin/Supporting Files/AudioPlayer)
                "Library/AudioPlayer",
                // Only contains CryptoSwift.h ObjC header — not needed in SPM
                "Library/Sources",
                // ObjC header in Disk — Swift files are still included
                "Library/Disk/Sources/Disk.h",
                // ObjC files in Supporting Files — handled via iCarousel target
                "Shadhin/Supporting Files/iCarousel.h",
                "Shadhin/Supporting Files/iCarousel.m",
                "Shadhin/Supporting Files/Shadhin-Bridging-Header.h",
                // Framework umbrella header & docs
                "Shadhin_Gp.h",
                "Shadhin_Gp.docc",
                // Secondary database folder (not part of main SDK)
                "Shadhin 2",
                // Non-source assets not needed at package level
                "Shadhin/download.json",
                "Shadhin/gakkpayBkash.cer",
                "Shadhin/Shadhin.entitlements",
                "Shadhin/Resources/Timer.rtf",
                "Shadhin/Resources/GoogleService-Info.plist",
                // Duplicate file — one copy already compiled from VmaxAdModel/
                "Shadhin/Version3/Model/VmaxAdModel/VmaxManager/VmaxAdModel.swift",
            ],
            resources: [
                // Asset catalogs
                .process("Shadhin/Resources/Assets.xcassets"),
                .process("Shadhin/Resources/AssetV3.xcassets"),
                .process("Shadhin/Resources/Colors.xcassets"),
                // Fonts
                .process("Shadhin/Resources/Fonts"),
                // Storyboards
                .process("Shadhin/Storyboard"),
                // XIBs — scattered across many subdirectories;
                // .process on a directory handles all XIBs recursively
                .process("Shadhin/XIBs"),
                .process("Shadhin/CollectionViewCell"),
                .process("Shadhin/TableViewCell"),
                .process("Shadhin/Controller"),
                .process("Shadhin/Version3"),
                .process("Shadhin/CustomViews"),
                .process("Shadhin/ShadhinCore"),
            ]
        ),

        // MARK: - ObjC Targets
        // SPM cannot mix Swift and ObjC in one target.
        // These targets live in ObjCBridge/ (non-overlapping path) so
        // the main Swift target can depend on them.

        .target(
            name: "iCarousel",
            path: "ObjCBridge/iCarousel",
            publicHeadersPath: "."
        ),

        .target(
            name: "LNPopupController",
            path: "ObjCBridge/LNPopupController",
            publicHeadersPath: "."
        ),

        // MARK: - Vmax Binary Targets
        .binaryTarget(name: "Vmax",             path: "Shadhin_Gp/Library/Vmax/Vmax.xcframework"),
        .binaryTarget(name: "VmaxDisplayHelper", path: "Shadhin_Gp/Library/Vmax/VmaxDisplayHelper.xcframework"),
        .binaryTarget(name: "VmaxNativeHelper",  path: "Shadhin_Gp/Library/Vmax/VmaxNativeHelper.xcframework"),
        .binaryTarget(name: "VmaxVastHelper",    path: "Shadhin_Gp/Library/Vmax/VmaxVastHelper.xcframework"),
        .binaryTarget(name: "VmaxVideoHelper",   path: "Shadhin_Gp/Library/Vmax/VmaxVideoHelper.xcframework"),
        .binaryTarget(name: "VmaxOM",            path: "Shadhin_Gp/Library/Vmax/VmaxOM.xcframework"),
        .binaryTarget(name: "OMSDK_Vmax2",       path: "Shadhin_Gp/Library/Vmax/OMSDK_Vmax2.xcframework"),
    ]
)
