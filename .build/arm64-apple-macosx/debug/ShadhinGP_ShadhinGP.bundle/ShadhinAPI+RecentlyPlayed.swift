//
//  ShadhinAPI+RecentlyPlayed.swift
//  Shadhin
//
//  Created by Joy on 24/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    func recentlyPlayedPost(
        with contentID :  String,
        contentType :  String){
            
        var type = contentType
        var url = RECENTLY_PLAYED_POST
        if type.count > 1,type.prefix(2).uppercased() == "PD"{
            type = "PD"
            url = RECENTLY_PLAYED_PODCAST_POST
        }
        let body : [String : String] = ["contentId" : contentID,
                    "contentType" : type]
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseData { response in
            guard response.data != nil else{
                Log.error(response.error?.localizedDescription ?? "")
                return
            }
//            let str = String(data: data, encoding: .utf8)
//            Log.info(str!)
        }
    }
    
    func recentlyPlayedGetAll(
        with page :  Int,
        complete : @escaping (Result<RecentlyPlayedObj, Error>)->Void){
            
        AF.request(
            RECENTLY_PLAYED_GET_ALL(page),
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseDecodable(of: RecentlyPlayedObj.self) { response in
            switch response.result{
            case let .success(data):
                complete(.success(data))
            case .failure(_):
                let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                complete(.failure(error))
            }
        }
    }
}
