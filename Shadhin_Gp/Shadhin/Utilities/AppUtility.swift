//
//  AppUtility.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/23/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

struct AppUtility {
    var orientationLock = UIInterfaceOrientationMask.portrait
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
    }
        func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            AppUtility.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }
