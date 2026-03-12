struct SimilerBooksResponseModel: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: SimilerBooksData?
    let error: String?
}

struct SimilerBooksData: Codable {
    let parentContents: [SimilerBooksParentContent]
    let contents: [SimilerBooksContent]
}

struct SimilerBooksParentContent: Codable {
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
    let audioBook: SimilerBooksAudioBookDetails
    let ownership: SimilerBooksOwnership?
    let playlist: String?
    let podcast: String?
    let release: String?
    let track: String?
    let artists: [String]
    let genres: [SimilerBooksGenre]
    let moods: [String]
}

struct SimilerBooksAudioBookDetails: Codable {
    var contentSubType: String
    var duration: Int
    var isCommentPaid: Bool
    var rating: Double
    var reviewsCount: Int
    var categories: [SimilerBooksCategory]
    var authors: [SimilerBooksAuthor]
    var narrators: [SimilerBooksNarrator]
    var voiceArtists: [SimilerBooksVoiceArtist] // Change this if it's defined as a String
}

struct SimilerBooksOwnership: Codable {
    let label: String
    let copyright: String
    let productBy: String
    let publication: String
}

struct SimilerBooksContent: Codable {
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
    let audioBook: SimilerBooksAudioBookDetails
    let ownership: SimilerBooksOwnership?
    let playlist: String?
    let podcast: String?
    let release: String?
    let track: String?
    let artists: [String]
    let genres: [SimilerBooksGenre]
    let moods: [String]
}

struct SimilerBooksCategory: Codable {
    let id: Int
    let name: String
}

struct SimilerBooksAuthor: Codable {
    let id: Int
    let name: String
    let image: String
    let role: String
    let booksCount: Int
}

struct SimilerBooksNarrator: Codable {
    let id: Int
    let name: String
    let image: String
    let role: String
    let booksCount: Int
}
struct SimilerBooksVoiceArtist: Codable {
    var id: Int
    var name: String
    var image: String
}

struct SimilerBooksGenre: Codable {
    let id: Int
    let name: String
    let image: String?
}
