//
//  DeviceOrientation.swift
//  Shadhin
//
//  Created by MacBook Pro on 11/1/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

final class DeviceOrientation {
    
    static let shared: DeviceOrientation = DeviceOrientation()
    
    // MARK: - Private methods
    
    @available(iOS 13.0, *)
    private var windowScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
    
    // MARK: - Public methods
    
    func set(orientation: UIInterfaceOrientationMask) {
        if #available(iOS 16.0, *) {
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation)){error in
                Log.error(error.localizedDescription)
            }
            windowScene?.parentViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(orientation.toUIInterfaceOrientation.rawValue, forKey: "orientation")
        }
    }
    
    var isLandscape: Bool {
        if #available(iOS 16.0, *) {
            return windowScene?.interfaceOrientation.isLandscape ?? false
        }
        return UIDevice.current.orientation.isLandscape
    }
    
    var isPortrait: Bool {
        if #available(iOS 16.0, *) {
            return windowScene?.interfaceOrientation.isPortrait ?? false
        }
        return UIDevice.current.orientation.isPortrait
    }
    
    var isFlat: Bool {
        if #available(iOS 16.0, *) {
            return false
        }
        return UIDevice.current.orientation.isFlat
    }
}

extension UIInterfaceOrientationMask {
    var toUIInterfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .portrait:
            return UIInterfaceOrientation.portrait
        case .portraitUpsideDown:
            return UIInterfaceOrientation.portraitUpsideDown
        case .landscapeRight:
            return UIInterfaceOrientation.landscapeRight
        case .landscapeLeft:
            return UIInterfaceOrientation.landscapeLeft
        default:
            return UIInterfaceOrientation.unknown
        }
    }
}


func isVideoURL(_ url: URL) -> Bool {
    let videoExtensions = ["mp4", "mov", "m4v"]
    return videoExtensions.contains(url.pathExtension.lowercased())
}
