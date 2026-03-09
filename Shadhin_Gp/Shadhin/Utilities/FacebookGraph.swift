//
//  ThirdPartyService.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 4/20/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit


//
//class FacebookGraph {
//    
//    static let instance = FacebookGraph()
//    
//    func getFacebookUserProfileInfo(completion: @escaping (_ isSuccess: Bool, _ id: String?, _ username: String?, _ profileImageUrl: String?)->Void) {
//        let connection = GraphRequestConnection()
//        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields":"id, name"])) { httpResponse, result, error   in
//            
//            if error != nil {
//                completion(false,nil, nil,nil)
//                Log.error(error?.localizedDescription ?? "")
//                return
//            }
//            
//            if let result = result as? [String:Any],
//                let id = result["id"] as? String,
//                let profileName = result["name"] as? String {
//                completion(true,id,profileName,"https://graph.facebook.com/\(id)/picture?width=250&height=250")
//            }
//        }
//        connection.start()
//    }
//}
