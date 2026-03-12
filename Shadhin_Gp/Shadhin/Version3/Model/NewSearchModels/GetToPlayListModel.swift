//
//  GetToPlayListModel.swift
//  Shadhin
//
//  Created by Maruf on 25/4/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

// Define a struct to represent the entire JSON response
struct GetToPlayListModel: Codable {
    let contents: [NewSearchPlaylist]
    let message: String
}

// Define struct for the model
struct NewSearchPlaylist:Codable {
    let contentId: String
    let contentType: String
    let artistId: String
    let artist: String
    let imageUrl: String
    let title: String
    let playUrl: String
    let albumId: String
    let albumTitle: String
    let resultType: String
    
    func toCommonContent() -> CommonContentProtocol{
        var contentItem = CommonContent_V1()
        contentItem.contentID  = self.contentId
        contentItem.contentType = self.contentType
        contentItem.image = self.imageUrl
        contentItem.title = self.title
        return contentItem
    }
}


// MARK: - ContentResponse
struct SearchV2ContentResponseObj: Codable {
    let contents: [SearchV2Content]
    let message: String
}

// MARK: - Content
struct SearchV2Content: Codable {
    var contentId: String?
    var contentType: String?
    var artistId: String?
    var artist: String?
    var imageUrl: String
    var title: String?
    var playUrl: String?
    var albumId: String?
    var albumTitle: String?
    var resultType: String?
    let source: String?
    let parentId: String?
    let contentName: String?
    let type: String?
    let similarity: Int?
    let groupNumber: Int?
    let trackType: String?
    
    func toCommonContent(shoudlHistoryAPICall: Bool) -> CommonContentProtocol{
        var contentItem = CommonContent_V1()
        if let playUrl {
            contentItem.playUrl = playUrl
        }
        contentItem.contentID  = self.contentId
        if let type {
            contentItem.contentType = type
        } else {
            contentItem.contentType = self.contentType
        }
        contentItem.image = self.imageUrl
        contentItem.title = self.title
        contentItem.artist = self.artist
        if contentItem.contentType == "A" && artist == nil {
            contentItem.artist = self.contentName
        }
        if shoudlHistoryAPICall {
            createSearchHistory(searchContentId: self.contentId ?? "", searchContentType: contentItem.contentType ?? "", searchTrackType: self.trackType ?? "")
        }
        return contentItem
    }
    
    func toCommonContentForPodcast(shoudlHistoryAPICall: Bool) -> CommonContentProtocol{
        var contentItem = CommonContent_V1()
        
        if let type, let trackType = trackType {
            if trackType.lowercased() == "track" {
                contentItem.contentID = self.parentId
                contentItem.trackType = "EPISODE"
            }
            if trackType.lowercased() == "episode" {
                contentItem.contentID = self.contentId
                contentItem.trackType = "EPISODE"
            }
            if trackType.lowercased() == "show" {
                contentItem.contentID = "0"
            }
            
            contentItem.contentType = type
            contentItem.image = self.imageUrl
            contentItem.title = self.title
            contentItem.artist = self.artist
            if shoudlHistoryAPICall {
                createSearchHistory(searchContentId: contentItem.contentID ?? "", searchContentType: type, searchTrackType: trackType)
            }
            print(contentItem)
            return contentItem
        } else {
            
            if let contentType, (contentType.uppercased().starts(with: "PD") || contentType.uppercased().starts(with: "VD")) {
                if let albumTitle, albumTitle.lowercased() == "track" {
                    contentItem.contentID = self.albumId
                    contentItem.trackType = "EPISODE"
                }
                if let albumTitle, albumTitle.lowercased() == "episode" {
                    contentItem.contentID = self.contentId
                    contentItem.trackType = "EPISODE"
                }
                if let albumTitle, albumTitle.lowercased() == "show" {
                    contentItem.contentID = "0"
                }
            }
            contentItem.contentType = contentType
            contentItem.image = self.imageUrl
            contentItem.title = self.title
            contentItem.artist = self.artist
            if shoudlHistoryAPICall {
                createSearchHistory(searchContentId: contentItem.contentID ?? "0", searchContentType: contentItem.contentType ?? "", searchTrackType: contentItem.trackType ?? "")
            }
            print(contentItem)
            return contentItem
        }
    }
    
    func createSearchHistory(searchContentId: String, searchContentType: String, searchTrackType: String) {
        
        print("BODY", searchContentId,searchContentType,searchTrackType)
        if ShadhinCore.instance.isUserLoggedIn {
            ShadhinCore.instance.api.createSearchHistories_V2(userCode: ShadhinCore.instance.defaults.userIdentity, contentId: searchContentId, contentType: searchContentType, trackType: searchTrackType) { responseModel in
                switch responseModel {
                case .success(let success):
                    break
                case .failure(let failure):
                    break
                }
            }
        }
    }

}

// MARK: - Welcome
struct GetResultFromDatabaseObj: Codable {
    let contents: [ResultDatabaseContent]
    let message: String
}

// MARK: - ResultDatabaseContent
struct ResultDatabaseContent: Codable {
    let source: String
    let contentID, contentName, type: String
    let similarity: Double
    let groupNumber: Int

    enum CodingKeys: String, CodingKey {
        case source
        case contentID = "contentId"
        case contentName, type, similarity, groupNumber
    }
}

// MARK: - SearchFromHistoryObj
struct SearchFromHistoryObj: Codable {
    let contents: [HistoryContent]
    let message: String
}

// MARK: - Content
struct HistoryContent: Codable {
    let source, contentID, contentName, type: String
    let similarity: Double
    let groupNumber: Int

    enum CodingKeys: String, CodingKey {
        case source
        case contentID = "contentId"
        case contentName, type, similarity, groupNumber
    }
}

struct RecentSearchHistoriesContent: Codable {
    let id: String
    let contentId: String
    let type: String
    let artist: String
    let imageUrl: String
    let title: String
    let playUrl: String
    let image: String
    let duration: Int
    let createDate: String
    let trackType: String?
    
    func toCommonContent() -> CommonContentProtocol{
        var contentItem = CommonContent_V1()
        contentItem.contentID  = self.contentId
        contentItem.contentType = self.type
        contentItem.image = self.imageUrl
        contentItem.title = self.title
        contentItem.artist = self.artist
        contentItem.playUrl = playUrl.isEmpty ? nil : playUrl
        contentItem.trackType = self.trackType
        print(contentItem)
        return contentItem
    }
}

struct RecentSearchHistoriesResponseObj: Codable {
    let contents: [RecentSearchHistoriesContent]
    let message: String
}

struct PostHistoryModel: Codable {
    let id, message: String
}


// MARK: - UpdatedSearchResponseModel
struct UpdatedSearchResponseModel_V2: Codable {
    let contents: [SearchV2Content]
    let message: String
}

// MARK: - Response
struct CreateSearchHistoryResponse: Codable {
    let id: String
    let message: String
}

struct DeleteSearchHistoryResponse: Codable {
    let id: String?
    let message: String
}
