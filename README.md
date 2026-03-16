# ShadhinMusic iOS SDK

An iOS SDK that embeds the full Shadhin Music experience — streaming, downloads, playlists, podcasts, videos, and more — directly into your app.

---

## Requirements

| Requirement | Version |
|---|---|
| iOS | 14.0+ |
| Swift | 5.9+ |
| Xcode | 15.0+ |

---

## Package Version

**Current version: `1.0.8`**

| Component | Version |
|---|---|
| ShadhinGP SDK | 1.0.8 |
| Vmax Ad SDK | Bundled |
| VmaxVastHelper | Bundled |
| VmaxVideoHelper | Bundled |
| VmaxNativeHelper | Bundled |
| VmaxOM | Bundled |
| VmaxDisplayHelper | Bundled |
| OMSDK_Vmax2 | Bundled |

> All dependencies are pre-built and bundled as XCFrameworks. No additional package dependencies are required.

---

## Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/shadhin-music/ShadhinMusic_iOS_SDK
   ```
3. Select the version rule (e.g. **Up to Next Major**) and click **Add Package**.
4. Select the **ShadhinGP** library and add it to your target.

#### Adding via `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/shadhin-music/ShadhinMusic_iOS_SDK", from: "1.0.8")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "ShadhinGP", package: "ShadhinMusic_iOS_SDK")
        ]
    )
]
```

---

## Info.plist Permissions

Add the following keys to your app's `Info.plist` to support audio playback, downloads, and background features:

```xml
<!-- Background audio playback -->
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>fetch</string>
    <string>processing</string>
</array>

<!-- Network access (required) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>

<!-- Photo library access (for profile picture upload) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to select a profile picture.</string>

<!-- Camera access -->
<key>NSCameraUsageDescription</key>
<string>Used to take a profile picture.</string>

<!-- Microphone (if applicable) -->
<key>NSMicrophoneUsageDescription</key>
<string>Used for audio features.</string>
```

---

## Setup

### 1. Initialize the SDK

Call `ShadhinCore.instance.initialize()` early in your app lifecycle, typically in `AppDelegate` or your `@main` SwiftUI App struct.

**UIKit — AppDelegate:**

```swift
import ShadhinGP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ShadhinCore.instance.initialize()
        return true
    }
}
```

**SwiftUI:**

```swift
import SwiftUI
import ShadhinGP

@main
struct MyApp: App {
    init() {
        ShadhinCore.instance.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

### 2. Launch the Music Experience

Once you have an authenticated user access token from your backend, call:

```swift
import ShadhinGP

// From any UIViewController
ShadhinGP.shared.gotoShadhinMusic(
    parentVC: self,
    accesToken: "YOUR_USER_ACCESS_TOKEN"
)
```

The SDK will:
- Validate the token and fetch user info.
- Push (or present) the full music tab bar interface.
- Resume any previously active mini-player session.

---

### 3. Track Events (Optional)

Implement `ShadhinGPEventDelegate` to receive analytics events from the SDK:

```swift
import ShadhinGP

class MyViewController: UIViewController, ShadhinGPEventDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        ShadhinGP.shared.eventDelegate = self
    }

    // MARK: - ShadhinGPEventDelegate

    func shadhinGP(didTriggerEvent payload: [String: Any]) {
        let eventName = payload["shadhin_gp_event_name"] as? String ?? ""
        let params    = payload["shadhin_gp_parameters"] as? [String: Any] ?? [:]
        let timestamp = payload["shadhin_gp_timestamp"] as? TimeInterval ?? 0

        print("Shadhin event: \(eventName), params: \(params)")

        // Forward to your analytics provider (Firebase, Mixpanel, etc.)
    }
}
```

---

### 4. Core Notifications (Optional)

Conform to `ShadhinCoreNotifications` to observe authentication lifecycle events:

```swift
import ShadhinGP

class MyViewController: UIViewController, ShadhinCoreNotifications {

    override func viewDidLoad() {
        super.viewDidLoad()
        ShadhinCore.instance.addNotifier(notifier: self)
    }

    deinit {
        ShadhinCore.instance.removeNotifier(notifier: self)
    }

    // Called after a successful login
    func loginResponseV7(response: Tokenv7Obj?, errorMsg: String?) {
        if let token = response {
            print("User logged in: \(token)")
        } else {
            print("Login error: \(errorMsg ?? "unknown")")
        }
    }

    // Called after user profile is updated
    func profileInfoUpdated() {
        print("Profile updated")
    }
}
```

---

## Push Notifications (FCM)

Forward the FCM device token to the SDK after you receive it:

```swift
import ShadhinGP

// In AppDelegate or wherever you receive the FCM token:
ShadhinCore.instance.defaults.fcmToken = fcmToken
```

---

## Quick Reference

| API | Description |
|---|---|
| `ShadhinCore.instance.initialize()` | Bootstrap the SDK (call once at app launch) |
| `ShadhinGP.shared.gotoShadhinMusic(parentVC:accesToken:)` | Launch the music UI for an authenticated user |
| `ShadhinGP.shared.eventDelegate` | Assign to receive analytics event callbacks |
| `ShadhinCore.instance.addNotifier(notifier:)` | Subscribe to auth/profile lifecycle callbacks |
| `ShadhinCore.instance.removeNotifier(notifier:)` | Unsubscribe from lifecycle callbacks |
| `ShadhinCore.instance.defaults.fcmToken` | Set the FCM push token |

---

## Troubleshooting

**Build fails with missing xcframework symbols**

All XCFrameworks are distributed as pre-built binaries via GitHub Releases (no Git LFS required). If Xcode cannot resolve the package, try:

1. In Xcode: **File → Packages → Reset Package Caches**
2. Clean the build folder: **Product → Clean Build Folder** (`Cmd+Shift+K`)
3. Re-resolve packages: **File → Packages → Resolve Package Versions**

**Audio does not play in background**

Ensure `UIBackgroundModes` includes `audio` in `Info.plist` (see [Info.plist Permissions](#infoplist-permissions) above).

**SDK screen is presented but appears blank**

Confirm that `ShadhinCore.instance.initialize()` was called before `gotoShadhinMusic(parentVC:accesToken:)` and that the access token is valid and non-empty.

---

## License

© Cloud 7 Limited. All rights reserved.
