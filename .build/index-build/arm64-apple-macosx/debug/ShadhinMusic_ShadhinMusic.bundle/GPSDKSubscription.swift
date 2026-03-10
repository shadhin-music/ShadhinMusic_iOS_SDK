//
//  AppDelegate+NewSubscription.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 30/7/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

class GPSDKSubscription {
    static func getNewUserSubscriptionDetails(completion: @escaping(Bool)->Void){
        ShadhinCore.instance.api.getNewUserSubscriptionDetails { response in
            switch response {
            case .success(let success):
                ShadhinCore.instance.defaults.newSubscriptionDetails = success.data?.first
                completion(success.data?.first != nil)
            case .failure(let failure):
                print(failure)
                completion(false)
            }
        }
    }
}
