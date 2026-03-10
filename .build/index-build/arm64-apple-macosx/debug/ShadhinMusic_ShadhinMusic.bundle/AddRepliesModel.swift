//
//  AddRepliesModel.swift
//  Shadhin
//
//  Created by Maruf on 5/11/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct AudioBookReviewReplyRequest: Codable {
    let description: String
    let fullName: String
    let imageUrl: String
    let reviewId: Int
    let usercode: String
    
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
}


struct AudioBookReviewReplyResponse: Codable {
    let data: Int
    let error: ErrorResponse?
    let responseCode: Int
    let success: Bool
    let title: String
}

struct AudioBookReplyResponse: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [Reply]
    let error: ErrorResponse?
}

struct Reply: Codable {
    let replyId: Int
    let description: String
    let reactionCount: Int
    let isFavorite: Bool
    let usercode: String
    let fullName: String
    let imageUrl: String
    let createdDate: String // Use String to store the date if it is in ISO format
    
    // Optional: Convert createdDate to Date for easier handling
    var formattedCreatedDate: Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: createdDate)
    }
}

struct AudioBookReactionRequest: Codable {
    var reviewId: Int = 0
    var replyId: Int?
    var usercode: String = ""
    var toBeDeleted: Bool = false
    
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
    
}
struct AudioBookReactionResponse: Codable {
    var data: Int = 0
    var error: ReactionErrorResponse?
    var responseCode: Int = 0
    var success: Bool = false
    var title: String = ""
}

struct ReactionErrorResponse: Codable {
    // Define the properties for the error response here
    var message: String?
    var code: Int?
    // Add other properties as needed based on the API response
}
struct FollowResponse: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [String] // Update this to the actual type in your data array
    let error: String?
}

struct UnfollowResponse: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [String] // Assuming `data` is an array of strings. Change the type if necessary.
    let error: String?
}

// MARK: - Root Model
struct AudioBookModelHistory: Codable {
    let content: AudioBookContentHistory
    let currentDurationCursor: Int
    let deviceType: String
    let duration: Int
    let inTime: String
    let isSkipped: Bool
    let outTime: String
    
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
    

}

// MARK: - Content
struct AudioBookContentHistory: Codable {
    let albumId: String
    let artists: [String]
    let audioBook: AudioBookDetails
    let contentId: String
    let contentType: String
    let details: String
    let episodeId: String
    let genres: [String]
    let haveRBT: Bool
    let imageUrl: String
    let imageModes: [String]
    let imageWebUrl: String
    let isCurrentlyPlaying: Bool
    let isFavourite: Bool
    let isPaid: Bool
    let isRadio: Bool
    let likeCount: Int
    let moods: [String]
    let playlistId: String
    let rootImage: String
    let rootTitle: String
    let rootType: String
    let seekable: Bool
    let sort: Int
    let titleBn: String
    let titleEn: String
    let streamingCount: Int
}

// MARK: - AudioBookDetails
struct AudioBookDetails: Codable {
    let authorDisplayName: String
    let authors: [AudioBookAuthor]
    let categories: [String]
    let completionPercentage: Int
    let contentSubType: String
    let currentDurationCursor: Int
    let duration: Int
    let isCommentPaid: Bool
    let narrators: [AudioBookNarrator]
    let rating: Double
    let reviewsCount: Int
    let voiceArtists: [AudioBookVoiceArtist]
}

// MARK: - AudioBookAuthor
struct AudioBookAuthor: Codable {
    let booksCount: Int
    let id: Int
    let image: String
    let name: String
    let role: String
}

// MARK: - AudioBookNarrator
struct AudioBookNarrator: Codable {
    let booksCount: Int
    let id: Int
    let image: String
    let name: String
    let role: String
}

// MARK: - AudioBookVoiceArtist
struct AudioBookVoiceArtist: Codable {
    let booksCount: Int
    let id: Int
    let image: String
    let name: String
    let role: String
}

// MARK: - Root Model
struct AudioBookTrack: Codable {
    let currentDurationCursor: Int
    let deviceType: String
    let duration: Int
    let inTime: String
    let isSkipped: Bool
    let outTime: String
    
    // Convert model to dictionary
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
}


// MARK: - APIResponse
struct HistoryTrackAPIResponse: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [String] // Replace [String] with the appropriate type if the data array contains objects.
    let error: String?
}
