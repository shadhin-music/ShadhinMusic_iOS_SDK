//
//  CommentModel.swift
//  Shadhin
//
//  Created by Rezwan on 6/10/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - CommentModel
struct CommentsObj: Codable {
    let status: Bool
    let message: String
    var data: [Comment]
    let totalData, totalPage: Int

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case data = "Data"
        case totalData = "TotalData"
        case totalPage = "TotalPage"
    }
    
    // MARK: - Datum
    struct Comment: Codable {
        let commentID: Int
        let contentID: String
        let contentType: String
        let contentTitle, message, createDate, userName: String
        let userPic: String
        var commentLike: Bool
        let totalCommentLike: Int
        var commentFavorite: Bool
        var totalCommentFavorite, totalReply: Int
        let adminUserType: String
        let currentPage: Int
        let isSubscriber: Bool?

        enum CodingKeys: String, CodingKey {
            case commentID = "CommentId"
            case contentID = "ContentId"
            case contentType = "ContentType"
            case contentTitle = "ContentTitle"
            case message = "Message"
            case createDate = "CreateDate"
            case userName = "UserName"
            case userPic = "UserPic"
            case commentLike = "CommentLike"
            case totalCommentLike = "TotalCommentLike"
            case commentFavorite = "CommentFavorite"
            case totalCommentFavorite = "TotalCommentFavorite"
            case totalReply = "TotalReply"
            case adminUserType = "AdminUserType"
            case currentPage = "CurrentPage"
            case isSubscriber = "IsSubscriber"
        }
    }
}

