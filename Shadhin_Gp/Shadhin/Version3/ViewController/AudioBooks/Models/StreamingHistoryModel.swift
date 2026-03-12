
import Foundation

// MARK: - Response Model
struct StreamingHistoryResponse: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: StreamingHistoryData
    let error: String?
}

// MARK: - Data
struct StreamingHistoryData: Codable {
    let contents: [StreamingHistoryContent]
}

// MARK: - StreamingHistoryContent
struct StreamingHistoryContent: Codable {
    let contentId: Int
    let contentType: String
    let titleBn: String
    let titleEn: String
    let details: String
    let imageUrl: String
    let imageWebUrl: String
    let imageModes: [String]
    let isPaid: Bool
    let likeCount: Int
    let streamingCount: Int
    let sort: Int
    let audioBook: StreamingHistoryAudioBookDetails
    let ownership: String?
    let playlist: String?
    let podcast: String?
    let release: String?
    let track: String?
    let artists: [String]
    let genres: [String]
    let moods: [String]
}

// MARK: - StreamingHistoryAudioBookDetails
struct StreamingHistoryAudioBookDetails: Codable {
    let contentSubType: String
    let duration: Int
    let isCommentPaid: Bool
    let rating: Double
    let reviewsCount: Int
    let completionPercentage: Int
    let categories: [StreamingHistoryCategory]
    let authors: [StreamingHistoryAuthor]
    let narrators: [String]
    let voiceArtists: [String]
}

// MARK: - StreamingHistoryCategory
struct StreamingHistoryCategory: Codable {
    let id: Int
    let name: String
}

// MARK: - StreamingHistoryAuthor
struct StreamingHistoryAuthor: Codable {
    let id: Int
    let name: String
    let image: String
    let role: String
}
