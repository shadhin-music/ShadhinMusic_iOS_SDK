//
//  NagadAdHelper.swift
//  Shadhin
//
//  Created by Rezwan on 16/6/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import Foundation

class NagadAdHelper{
    
    static let instance = NagadAdHelper()
    
    var shouldLoadNagadAd = false
    var lastServerCall : Date?
    let delayTime = -10*60.0
    
    //var demo = 0
    
    @objc func shouldLoadNagadAd(_ completion: @escaping (_ shouldLoadNagadAd: Bool)->Void){

        
//        #if DEBUG
//            return completion(true)
//        #endif
//        
        return completion(false)
        
//        
//        if let last = lastServerCall, last.timeIntervalSinceNow > delayTime, shouldLoadNagadAd{
//            completion(shouldLoadNagadAd)
//            print("Nagad api not being calling \(last.timeIntervalSinceNow)")
//            return
//        }
//        print("Nagad api being calling")
//        lastServerCall = Date()
//        Alamofire.request("http://api.shadhin.co/api/ShadhinAds", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: API_HEADER).responseJSON { (response) in
//            guard response.result.error == nil else {
//                self.shouldLoadNagadAd = false
//                completion(false)
//                return
//            }
//            
//            if let value = response.result.value as? [String : Any] {
//                guard let bool = value["data"] as? Bool else {return}
//                if bool {
//                    self.shouldLoadNagadAd = true
//                    completion(true)
//                } else {
////                    #if DEBUG
////                    if self.demo > 5{
////                        self.shouldLoadNagadAd = false
////                        completion(false)
////                        return
////                    }else{
////                        self.shouldLoadNagadAd = true
////                        completion(true)
////                        return
////                    }
////                    #endif
//                    self.shouldLoadNagadAd = false
//                    completion(false)
//                }
//            }
//        }
    }
    
}
