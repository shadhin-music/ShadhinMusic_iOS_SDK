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

        // MARK: - Main SDK Target
        // All Swift sources (main + libraries) compiled together to match original
        // Xcode project structure where app-specific types are shared across files.
        .target(
            name: "ShadhinGP",
            dependencies: [
                "iCarousel",
                "LNPopupController",
                // Vmax binary frameworks
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
                // Duplicate file — parent directory has the active version
                "Shadhin/Version3/Model/VmaxAdModel/VmaxManager/VmaxAdModel.swift",
                // Non-source files in SnapKit
                "Library/SnapKit/PrivacyInfo.xcprivacy",
                // SignalR library wrapper (app version is in Shadhin/Version3)
                "Library/SignalRClient/SignalR.swift",
                // LNPopupController Private headers (handled by separate ObjC target)
                "Library/LNPopupController",
                // iCarousel handled by separate ObjC target
                "Library/iCarousel",
                // Vmax binary xcframeworks
                "Library/Vmax",
                // App-customized versions exist in Shadhin/ — exclude Library originals
                "Library/AudioPlayer/CircularProgress.swift",
                "Library/VGPlayer/MediaCache/VGPlayerCacheManager.swift",
            ],
            sources: [
                // Shadhin subdirectories (Resources and Storyboard excluded — declared in resources: below)
                "Shadhin/CollectionViewCell",
                "Shadhin/Controller",
                "Shadhin/CustomViews",
                "Shadhin/Database",
                "Shadhin/DownloadManager",
                "Shadhin/Extensions",
                "Shadhin/Protocol & Extension",
                "Shadhin/ShadhinCore",
                "Shadhin/Supporting Files",
                "Shadhin/TableViewCell",
                "Shadhin/Utilities",
                "Shadhin/Version3",
                "Shadhin/XIBs",
                "Library/Alamofire",
                "Library/AudioPlayer",
                "Library/Disk/Sources",
                "Library/DropDown",
                "Library/FSPagerView",
                "Library/KRPullLoader",
                "Library/Kingfisher",
                "Library/LoadingButton",
                "Library/PBPopupController",
                "Library/PageCotrol",
                "Library/SignalRClient",
                "Library/SnapKit",
                "Library/SwiftEntryKit",
                "Library/VGPlayer",
                "Library/Sources/CryptoSwift",
            ],
            resources: [
                .process("Shadhin/Resources"),
                .process("Shadhin/Storyboard"),
                .process("Shadhin/Localize"),
            ]
        ),

        // MARK: - ObjC Library Targets (must remain separate from Swift)

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

        // MARK: - Binary Targets (Vmax)

        .binaryTarget(
            name: "Vmax",
            path: "Shadhin_Gp/Library/Vmax/Vmax.xcframework"
        ),
        .binaryTarget(
            name: "VmaxVastHelper",
            path: "Shadhin_Gp/Library/Vmax/VmaxVastHelper.xcframework"
        ),
        .binaryTarget(
            name: "VmaxVideoHelper",
            path: "Shadhin_Gp/Library/Vmax/VmaxVideoHelper.xcframework"
        ),
        .binaryTarget(
            name: "VmaxNativeHelper",
            path: "Shadhin_Gp/Library/Vmax/VmaxNativeHelper.xcframework"
        ),
        .binaryTarget(
            name: "VmaxOM",
            path: "Shadhin_Gp/Library/Vmax/VmaxOM.xcframework"
        ),
        .binaryTarget(
            name: "VmaxDisplayHelper",
            path: "Shadhin_Gp/Library/Vmax/VmaxDisplayHelper.xcframework"
        ),
        .binaryTarget(
            name: "OMSDK_Vmax2",
            path: "Shadhin_Gp/Library/Vmax/OMSDK_Vmax2.xcframework"
        ),
    ]
)
