//
//  ReplyModel.swift
//  Shadhin
//
//  Created by Rezwan on 6/14/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//


struct RepliesObj: Codable {
    let status: Bool
    let message: String
    var data: [Reply]
    let totalData, totalPage: Int

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case data = "Data"
        case totalData = "TotalData"
        case totalPage = "TotalPage"
    }
    
    struct Reply: Codable {
        let replyID, commentID: Int
        let userName: String
        let userPic: String
        var replyLike: Bool
        let totalReplyLike: Int
        var replyFavorite: Bool
        var totalReplyFavorite: Int
        let message, createDate, adminUserType: String
        let isSubscriber: Bool?

        enum CodingKeys: String, CodingKey {
            case replyID = "ReplyId"
            case commentID = "CommentId"
            case userName = "UserName"
            case userPic = "UserPic"
            case replyLike = "ReplyLike"
            case totalReplyLike = "TotalReplyLike"
            case replyFavorite = "ReplyFavorite"
            case totalReplyFavorite = "TotalReplyFavorite"
            case message = "Message"
            case createDate = "CreateDate"
            case adminUserType = "AdminUserType"
            case isSubscriber = "IsSubscriber"
        }
    }


}

