//
//  ShadhinApi+Comment.swift
//  Shadhin
//
//  Created by Gakk Alpha on 5/31/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension ShadhinApi{
    
    public func addComment(
        _ contentId         : String,
        _ podcastShowCode   : String,
        _ comment           : String,
        _ podcastType       : String,
        completion : @escaping (_ success: Bool, _ errorMsg: String?,_ is402: Bool) -> Void)
    {
        
        var body:[String : Any] = [
            "ContentId" : "\(contentId)",
            "ContentType" : podcastShowCode,
            "Message" : comment
        ]
        
        let url = ADD_COMMENT(podcastType)
        if podcastType == "PD"{
            body["IsPaid"] = ShadhinCore.instance.isUserPro
        }
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            switch response.response?.statusCode {
            case 200:
                completion(true,nil,false)
                break
            default:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let msg = json["Message"]{
                    completion(false,msg,response.response?.statusCode == 402)
                }else{
                    completion(false,"Error occured! Please try again later",response.response?.statusCode == 402)
                }
                break
            }
        }
        
    }
    
    
    func addReply(
        _ commentId    : Int,
        _ replyMsg     : String,
        _ podcastType  : String,
        completion : @escaping (_ success: Bool, _ errorMsg: String?,_ is402: Bool) -> Void
    ){
        var body:[String : Any] = [
            "CommentId" : commentId,
            "Message"   : replyMsg
        ]
        let url = ADD_REPLY(podcastType)
        if podcastType == "PD"{
            body["IsPaid"] = ShadhinCore.instance.isUserPro
        }
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData{(response) in
            switch response.response?.statusCode {
            case 200:
                completion(true,nil,false)
                break
            default:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let msg = json["Message"]{
                    completion(false,msg,response.response?.statusCode == 402)
                }else{
                    completion(false,"Error occured! Please try again later",response.response?.statusCode == 402)
                }
                break
            }
        }
    }
    
    func getCommentsBy(
        _ podcastType: String,
        _ episodeID: Int,
        _ pageNumber: Int,
        _ podcastCode: String,
        _ completion: @escaping (CommentsObj?)->Void){
        let url = GET_COMMENTS(podcastType, episodeID, pageNumber, podcastCode)
        AF.request(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER
        ).responseDecodable(of: CommentsObj.self){ response in
            switch response.result{
            case let .success(data):
                completion(data)
            case let .failure(error):
                completion(nil)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func toggleFavoriteComment(
        _ podcastType: String,
        _ commentID: Int,
        _ completion: @escaping (_ success: Bool)->Void)
    {
        AF.request(
            UPDATE_COMMENT_FAV(podcastType, commentID),
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            switch response.result{
            case .success(_):
                completion(true)
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func likeComment(
        _ contentID: String,
        _ commentID: Int,
        _ completion: @escaping (_ success: Bool)->Void){
        AF.request(
            UPDATE_COMMENT_LIKE(contentID, commentID),
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            switch response.result{
            case .success(_):
                completion(true)
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
    
    func getRepliesInComment(
        _ podcastType: String,
        _ commentID: Int,
        _ completion: @escaping (RepliesObj?, _ errMsg: String?)->Void){
            
            AF.request(
                GET_REPLIES_IN_COMMENT(podcastType, commentID),
                method: .get,
                parameters: nil,
                encoding: JSONEncoding.default,
                headers: API_HEADER
            ).responseDecodable(of: RepliesObj.self) { response in
                switch response.result{
                case let .success(data):
                    completion(data, nil)
                case .failure(_):
                    completion(nil,"We are experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                }
            }
        }
    
    func toggleReplyFav(
        _ podcastType: String,
        _ commentID: Int,
        _ replyID: Int,
        _ completion: @escaping (_ success: Bool, _ errMsg: String?)->Void){
        AF.request(
            UPDATE_REPLY_FAV(podcastType,commentID,replyID),
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            switch response.result{
            case .success(_):
                completion(true, nil)
            case .failure(_):
                completion(false,"experiencing technical problems now which will be fixed soon. Thanks for your patience.")
            }
        }
    }
    
    func likeReply(
        _ podcastType: String,
        _ commentID: Int,
        _ replyID: Int,
        _ completion: @escaping (_ success: Bool, _ errMsg: String?)->Void){
        AF.request(
            UPDATE_REPLY_FAV(podcastType, commentID, replyID),
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData { response in
            switch response.result{
            case .success(_):
                completion(true, nil)
            case .failure(_):
                completion(false,"experiencing technical problems now which will be fixed soon. Thanks for your patience.")
            }
        }
    }
    
}
