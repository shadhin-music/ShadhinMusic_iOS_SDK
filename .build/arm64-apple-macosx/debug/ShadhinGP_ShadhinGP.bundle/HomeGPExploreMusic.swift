//
//  HomeGPExploreMusic.swift
//  Shadhin_Gp
//
//  Created by Maruf on 21/8/24.
//

import Foundation

extension ShadhinApi {
    
    func getHomeGpExplorePatchItem(_ completion : @escaping (_ responseModel: Result<GPExploreMusicModel,AFError> )->()){
        AF.request(
            GP_EXPLORE_MUSICS,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseDecodable(of: GPExploreMusicModel.self) { response in
            completion(response.result)
        }
    }
    
    func getToken(by body: [String : Any], url: String, _ completion : @escaping (_ response: Result<RenewSubscriptionModel,AFError>)->()) {
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseDecodable(of: RenewSubscriptionModel.self) { response in
            completion(response.result)
        }
    }
    
    func getReelsResponseContents(
        _ completion : @escaping (_ responseModel: Result<ReelsResponseObject,AFError> )->()){
        AF.request(
            "https://connect.shadhinmusic.com/api/v2/reels/gp-patches?displayPageVal=17&cacheClean=false",
            method: .get,
            encoding: JSONEncoding.default,
            headers: ShadhinApiContants().API_HEADER,
            requestModifier: { $0.cachePolicy = .reloadIgnoringLocalCacheData }
        )
        .responseDecodable(of: ReelsResponseObject.self) { response in
            completion(response.result)
        }
    }
}
