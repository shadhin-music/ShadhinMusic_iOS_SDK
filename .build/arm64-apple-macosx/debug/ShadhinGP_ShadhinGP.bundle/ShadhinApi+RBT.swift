//
//  ShadhinApi+RBT.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rig/Users/maruf/Documents/shadhin-ios-lastest/Shadhin/Version3/ShadhinCore/Api/ShadhinApi+RBT.swifthts reserved.
//

import Foundation

extension ShadhinApi{

    func checkContentsForRBT(
        _ contents : [CommonContentProtocol],
        _ completion : @escaping (_ items : [String])->Void)
    {
        var items : [[String:String]] = []
        for content in contents{
            if let contentId = content.contentID,
               let artistId = content.artistId{
                let item = [
                    "ContentId": contentId,
                    "artistId": artistId
                ]
                items.append(item)
            }
        }
        
        guard items.count > 0, ShadhinCore.instance.isUserLoggedIn else {return}
        var request = URLRequest(url: URL(string: CHECK_SONGS_FOR_RBT)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: items)
        
        AF.request(request)
            .responseData{ response in
                switch response.result{
                case let .success(data):
                    if let json = try? JSONSerialization.jsonObject(with: data),
                       let value = json as? [String : Any],
                       let datas = value["data"] as? [[String: Any]]{
                        var returnItems : [String] = []
                        for data in datas{
                            if let contentId = data["contentId"] as? String{
                                returnItems.append(contentId)
                            }
                        }
                        guard returnItems.count > 0 else {return}
                        completion(returnItems)
                    }
                case let .failure(error):
                    completion(["We are experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                    Log.error(error.localizedDescription)
                }
            }
    }
    
    func setRBT(
        contentId: String,
        artistId: String,
        callerTune: CallerTuneObj,
        subType: RBTSubType,
        _ completion: @escaping (_ succcess: Bool,_ msg: String,_ subType: RBTSubType)-> Void)
    {
        
        var number = ShadhinCore.instance.defaults.userMsisdn
        var url = SET_RBT_BL
        if ShadhinCore.instance.isGP(number){
            number = String(number.suffix(11))
            url = SET_RBT_GP
        }
        
        let body = [
            "msisdn": number,
            "contentId": contentId,
            "artistId": artistId,
            "subscriptionClass": callerTune.serviceID[subType.rawValue]
        ]
        
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER
        ).responseData { response in
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                   let data = value["data"] as? [String : String],
                   let remarks = data["remarks"],
                   let msg = data["message"] {
                    let success = remarks == "SUCCESS"
                    completion(success, msg, subType)
                }else{
                    completion(false, "Data format error", subType)
                }
            case .failure(_):
                completion(false,"We are experiencing technical problems now which will be fixed soon.Thanks for your patience.", subType)
            }
        }
    }
    
}
