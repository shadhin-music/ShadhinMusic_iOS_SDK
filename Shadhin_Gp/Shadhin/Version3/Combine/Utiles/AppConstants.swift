//
//  AppConstant.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import Foundation

var SCREEN_WIDTH : CGFloat{
    return UIScreen.main.bounds.width
}

var SCREEN_HEIGHT : CGFloat{
    return  UIScreen.main.bounds.height
}

var HOMEV3PATCH: [HomeV3Patch]?
var COMMONCONTENT: CommonContentProtocol?
var USERSTREAMING: UserStreaming? = nil
var IS_RECENTPLAY: Bool = false


var SCREEN_SAFE_TOP : CGFloat {
    if #available(iOS 13.0, *) {
        let window = UIApplication.shared.windows.first
        return window?.safeAreaInsets.top ?? 0
    }else if #available(iOS 11.0, *) {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.top ?? 0
    }
}

var SCREEN_SAFE_BOTTOM : CGFloat{
    if #available(iOS 13.0, *) {
        let window = UIApplication.shared.windows.first
        return window?.safeAreaInsets.bottom ?? 0
    }else if #available(iOS 11.0, *) {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.bottom ?? 0
    }
}
