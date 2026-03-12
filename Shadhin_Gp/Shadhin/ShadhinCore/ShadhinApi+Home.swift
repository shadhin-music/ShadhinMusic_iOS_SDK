//
//  ShadhinApi+Home.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    func getHomePatchsBy(
        page : Int,
        completion : @escaping (DiscoverPatchesObj?, Error?) -> Void)
    {
        Log.info(ShadhinCore.instance.defaults.geoLocation)
        
        AF.request(
            GET_PAGED_HOME_CONTENT("\(page)"),
            method: .get,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).validate().responseDecodable(of: DiscoverPatchesObj.self){ response in
            //            if let data = response.data, let str = try? String(data: data, encoding: .utf8){
            //                Log.info(str)
            //            }
            switch response.result{
            case let .success(data):
                completion(data,nil)
                try? Disk.save(data, to: .caches, as: self.GET_PAGED_HOME_CONTENT("\(page)"))
            case .failure(_):
                if Disk.exists(self.GET_PAGED_HOME_CONTENT("\(page)"), in: .caches),
                   let discoverData = try? Disk.retrieve(self.GET_PAGED_HOME_CONTENT("\(page)"), from: .caches, as: DiscoverPatchesObj.self){
                    completion(discoverData,nil)
                }else{
                    let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                    completion(nil,error)
                }
            }
        }
    }
    
    func getPatchDetailsBy(
        code: String,
        contentType: String,
        completion: @escaping (_ data: [CommonContent_V0]?,Error?)-> Void) {
            AF.request(
                GET_PATCH_DETAILS_BY(code,contentType),
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: API_HEADER
            ).responseDecodable(of: PatchDetailsObj.self){ response in
                switch response.result{
                case let .success(data):
                    completion(data.data, nil)
                case .failure(_):
                    let error = NSError(domain: "", code: 400, userInfo: [ NSLocalizedDescriptionKey: "experiencing technical problems now which will be fixed soon.Thanks for your patience."])
                    completion(nil,error)
                }
            }
        }
    
    func rewindData(complete : @escaping (Result<TopStreammingElementModelData,AFError>)->Void){
        guard !ShadhinCore.instance.defaults.userIdentity.isEmpty else {return}
        let url = SHADHIN_REWIND(ShadhinCore.instance.defaults.userIdentity)
        AF.request(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .validate()
        .responseDecodable(of:TopStreammingElementModelData.self){ response in
            complete(response.result)
        }.responseString { response in
            if let str = response.value{
                Log.error(str)
            }
        }
    }
    
    func getUserInfo(token: String, completion: (@escaping (Result<UserInfoResponseModel,AFError>)->Void)){
        AF.request(
            GET_USER_INFO,
            method: .get,
            encoding: JSONEncoding.default,
            headers: getAPIHeaderForUserInfo(token: token)
        ).validate().responseDecodable(of: UserInfoResponseModel.self){ response in
            completion(response.result)
        }
    }

}
