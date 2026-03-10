//
//  ShadhinCoreNotifications.swift
//  Shadhin
//
//  Created by Gakk Alpha on 10/7/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import Foundation

@objc
public protocol ShadhinCoreNotifications{
    
    @objc
    optional func registationResponse(response: TokenObj?)
    
    @objc
    optional func registationResponseV5(response: Tokenv7Obj?)

    @objc
    optional func loginResponse(response: TokenObj?)

    @objc
    optional func loginResponseV5(response: Tokenv5Obj?)
    
    @objc
    optional func  loginResponseV7(response: Tokenv7Obj?, errorMsg: String?)
    
    @objc
    optional func profileInfoUpdated()
}
