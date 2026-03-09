//
//  ShadhinPlayerSkipLimit.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/2/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

class ShadhinPlayerSkipLimit{
    
    static let instance = ShadhinPlayerSkipLimit()
    
    let limitResetDurationInHours = 1
    let limitCapsAt = 6
    
    var isLimitingActive = false
    private init(){}
    
    func setNewRootContent(_ content : CommonContentProtocol?){
        guard !ShadhinCore.instance.isUserPro,
              let type = content?.contentType?.uppercased(),
              type == "P",
              let isPaid = content?.isPaid,
              isPaid
        else {return isLimitingActive = false}
        isLimitingActive = true
    }
    
    
    func isActionAllowed() -> Bool{
        guard isLimitingActive else {return true}
        let timestamp = ShadhinCore.instance.defaults.playerSkipLimitTimestamp
        var count     = ShadhinCore.instance.defaults.playerSkipCount
        guard timestamp > 0 else {
            ShadhinCore.instance.defaults.playerSkipLimitTimestamp = Date().timeIntervalSince1970
            ShadhinCore.instance.defaults.playerSkipCount = 0
            return true
        }
        let limit : Double = Double(limitResetDurationInHours * 60 * 60)
        let diff = Date().timeIntervalSince1970 - timestamp
        if diff < limit - 1{
            if count < limitCapsAt{
                count += 1
                ShadhinCore.instance.defaults.playerSkipCount = count
                return true
            }else{
                return false
            }
        }else{
            ShadhinCore.instance.defaults.playerSkipLimitTimestamp = Date().timeIntervalSince1970
            ShadhinCore.instance.defaults.playerSkipCount = 1
            return true
        }
    }
}
