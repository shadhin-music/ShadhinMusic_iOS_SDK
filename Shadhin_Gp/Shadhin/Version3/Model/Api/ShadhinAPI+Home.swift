//
//  ShaadhinAPI+Home.swift
//  Shadhin
//
//  Created by Gakk Alpha on 12/10/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    class Home {
        static func getHomeV3(
            by page : Int,
            completion : @escaping (HomeV3ResponseModel?, Error?) -> Void)
        {
            AF.request(
                GET_PAGED_HOMEV3("\(page)"),
                method: .get,
                encoding: JSONEncoding.default,
                headers: ShadhinApiContants().API_HEADER
            )
            .validate()
            .responseDecodable(of: HomeV3ResponseModel.self){ response in
                switch response.result{
                case let .success(data):
                    completion(data,nil)
                    try? Disk.save(data, to: .caches, as:GET_PAGED_HOME("\(page)"))
                case .failure(_):
                    // print("My error",error)
                    if Disk.exists(GET_PAGED_HOME("\(page)"), in: .caches),
                       let homeResponse = try? Disk.retrieve(GET_PAGED_HOME("\(page)"), from:.caches, as: HomeV3ResponseModel.self){
                        completion(homeResponse,nil)
                    }else{
                        let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                        completion(nil,error)
                    }
                }
            }
        }
        
        static func getRecomandedHomeV3(days: String,completion : @escaping (HomeV3ResponseModel?, Error?) -> Void){
            
            AF.request(
                GET_RECOMANDED_V3(days),
                method: .get,
                encoding: JSONEncoding.default,
                headers: ShadhinApiContants().API_HEADER
                
            ).validate().responseDecodable(of: HomeV3ResponseModel.self){ response in
                switch response.result{
                case let .success(data):
                    completion(data,nil)
                    try? Disk.save(data, to: .caches, as:  GET_RECOMANDED_V3(days))
                case .failure(let err):
                    let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                    completion(nil,error)
                    Log.error(err.localizedDescription)
                }
            }.responseString { respose in
                if let str = respose.value {
                    Log.info(str)
                }
            }
        }
    }

    static func getAIMoods(completion: (@escaping (Result<AIMoodlistModel,AFError>)->Void)){
        AF.request(
            ShadhinApiURL.GET_AI_MOOD_LIST,
            method: .get,
            encoding: JSONEncoding.default,
            headers: ShadhinApiContants().API_HEADER
            
        ).validate().responseDecodable(of: AIMoodlistModel.self){ response in
            completion(response.result)
        }
    }
    
    static func getAIGeneratedPlayList(moodId: String, userCode: String, completion: (@escaping (Result<AIPlaylistResponseModel,AFError>)->Void)){
        print(ShadhinApiURL.GET_AI_GENERATED_PLAY_LIST(moodId, userCode))
        AF.request(
            ShadhinApiURL.GET_AI_GENERATED_PLAY_LIST(moodId, userCode),
            method: .get,
            encoding: JSONEncoding.default,
            headers: ShadhinApiContants().API_HEADER
            
        ).validate().responseDecodable(of: AIPlaylistResponseModel.self){ response in
            completion(response.result)
        }
    }
}
