//
//  HomeV3ResponseModel.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 6/10/25.
//


// MARK: - HomeV3ResponseModel
struct HomeV3ResponseModel: Codable {
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [HomeV3Patch]
    let pagination: HomeV3Pagination?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case success, responseCode, title, data, pagination, error
    }
}

// MARK: - HomeV3Patch
struct HomeV3Patch: Codable {
    var patch: HomeV3PatchDetails
    var contents: [HomeV3Content]
}

// MARK: - HomeV3Content
struct HomeV3Content: Codable, CommonContentProtocol {
    var hasRBT: Bool?
    var copyright: String?
    var trackType: String?
    
    var albumId: String? {
        get { return "\(self.albumID ?? 0)" }
        set { /* Custom logic */ }
    }
    
    var albumID: Int? {
        didSet {
            self.albumId = "\(self.albumID ?? 0)"
            Log.info("\(self.albumID ?? 0)")
        }
    }
    
    var fav: String? = nil
//    var trackType: String? { type }
    var isPaid: Bool? = nil
    var templateFlag : Bool? = nil
    var rbtOperators: [String]? = nil
    
    var teaserUrl: String? = nil
    var followers: String? {
        get { return "\(self.playCount ?? 0)" }
        set { /* Custom logic */ }
    }
    var contentTypeCode: String?
    var type: String?
    var isRadio: Bool?
    var follower: Int?
    var contentID, contentType, title, image, releaseDate, playUrl, duration, artistId, artistImage,newBannerImg, labelname: String?
    // Override playCount to use audiobook's rating
    var playCount: Int? {
        get {
            guard let rating = audioBook?.rating else { return nil }
            return Int(rating) // Convert rating (Double) to Int
        }
        set{}
    }
    var artists: [HomeV3Artist]?
    var artist: String? {
        get {
            // Concatenate all artist names, separated by commas
            return artists?.compactMap { $0.name }.joined(separator: ", ")
        }
        set {
            // _artist = newValue
        }

    }

    var titleBn: String?
    var titleEn: String?
    var imageModes: [ImageMode]?
    var audioBook: AudioBook?
    var ownerShip : HomeV3Ownership?
    var track: Track?

    var owner: String? {
        get {return ownerShip.map({$0.label ?? ""})}
        set { }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode contentID as String, even if it's a number in the JSON
          if let intValue = try? container.decode(Int.self, forKey: .contentID) {
              contentID = String(intValue)
          } else if let stringValue = try? container.decode(String.self, forKey: .contentID) {
              contentID = stringValue
          }
        contentType = try container.decodeIfPresent(String.self, forKey: .contentType)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        fav = try container.decodeIfPresent(String.self, forKey: .fav)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        playUrl = try container.decodeIfPresent(String.self, forKey: .playUrl)
        duration = try container.decodeIfPresent(String.self, forKey: .duration)
        artistId = try container.decodeIfPresent(String.self, forKey: .artistId)
        labelname = try container.decodeIfPresent(String.self, forKey: .labelname)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        albumID = try container.decodeIfPresent(Int.self, forKey: .albumId)
        teaserUrl = try container.decodeIfPresent(String.self, forKey: .teaserUrl)
        follower = try container.decodeIfPresent(Int.self, forKey: .follower)
        contentTypeCode = try container.decodeIfPresent(String.self, forKey: .contentTypeCode)
        isRadio = try container.decodeIfPresent(Bool.self, forKey: .isRadio)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        artistImage = try container.decodeIfPresent(String.self, forKey: .artistImage)
        isPaid = try container.decodeIfPresent(Bool.self, forKey: .isPaid)
        copyright = try container.decodeIfPresent(String.self, forKey: .copyright)
        newBannerImg = try container.decodeIfPresent(String.self, forKey: .newBannerImg)
        playCount = try container.decodeIfPresent(Int.self, forKey: .playCount)
        imageModes = try container.decodeIfPresent([ImageMode].self, forKey: .imageModes)
        track = try container.decodeIfPresent(Track.self, forKey: .track)
        titleEn = try container.decodeIfPresent(String.self, forKey: .titleEn)
        titleBn = try container.decodeIfPresent(String.self, forKey: .titleBn)
        playUrl = self.track?.streamingUrl
        duration = "\(self.track?.duration ?? 0)"


        // Decoding `ownerShip`
        if let ownerObject = try? container.decode(HomeV3Ownership.self, forKey: .ownerShip) {
            ownerShip = ownerObject
            labelname = ownerObject.label
            copyright = ownerObject.copyright
        } else if let label = try? container.decode(String.self, forKey: .ownerShip) {
            ownerShip = HomeV3Ownership(label: label, copyright: "Hello", productBy: "", publication: "")
            labelname = label
            copyright = ""
        } else {
            ownerShip = nil
            labelname = nil
            copyright = nil
        }
        artists = try container.decodeIfPresent([HomeV3Artist].self, forKey: .artist)
        // Dynamic decoding for artists
        artists = nil
        if let artistArray = try? container.decode([HomeV3Artist].self, forKey: .artist) {
            // If the value is an array of artists
            artists = artistArray
        } else if let singleArtist = try? container.decode(String.self, forKey: .artist) {
            // If the value is a single artist string, construct a `HomeV3Artist` object
            let artistId = try container.decodeIfPresent(String.self, forKey: .artistId) ?? ""
            let artistImage = try container.decodeIfPresent(String.self, forKey: .artistImage) ?? ""
            artists = [HomeV3Artist(id: Int(artistId) ?? 0, name: singleArtist, image: artistImage)]
        }

        enum CodingKeys: String, CodingKey {
            case contentID = "contentId"
            case contentType = "contentType"
            case title = "titleEn"
            case image = "imageUrl"
            case playUrl = "PlayUrl"
            case artist = "artists"
            case duration = "Duration"
            case artistId = "id"
            case labelname = "label"
            case releaseDate = "ReleaseDate"
            case albumId = "albumId"
            case teaserUrl = "TeaserUrl"
            case follower = "Follower"
            case contentTypeCode = "ContentTypeCode"
            case isRadio = "IsRadio"
            case type = "Type"
            case artistImage = "ArtistImage"
            case isPaid = "isPaid"
            case copyright = "copyright"
            case newBannerImg = "imageWebUrl"
            case playCount = "likeCount"
            case ownerShip = "ownerShip"
            case imageModes = "imageModes"
            case track = "track"
            case titleEn = "titleEn2"
            case titleBn = "titleBn"
            case fav = "fav"
        }
    }

}
extension CommonContentProtocol {
    var rating: Int? {
        return nil // Default implementation, override as needed
    }
}

// MARK: - HomeV3Artist
struct HomeV3Artist: Codable {
    let id: Int
    let name: String
    let image: String
}
struct ImageMode: Codable {
    let darkModeImage: String?
    let lightModeImage: String?
}
// MARK: - HomeV3ContentType
enum HomeV3ContentType: String, Codable {
    case lk = "LK"
    case pdab = "PDAB"
    case pdmr = "PDMR"
    case pdtg = "PDTG"
    case r = "R"
}

// MARK: - HomeV3Ownership
struct HomeV3Ownership: Codable {
    let label: String?
    let copyright: String?
    let productBy: String?
    let publication: String?
}

// MARK: - HomeV3Podcast
struct HomeV3Podcast: Codable {
    let contentSubType: String
    let isComingSoon: Bool
    let isCommentPaid: Bool
}

// MARK: - HomeV3Release
struct HomeV3Release: Codable {
    let id: Int
    let name: String
    let date: String // Use Date with custom decoding if applicable
    
    // Use custom Date decoding strategy if needed
}

// MARK: - HomeV3PatchDetails
struct HomeV3PatchDetails: Codable {
    let id: Int
    let code: String
    let title: String
    let description: String?
    let imageURL: String
    let designType: Int?
    let isSeeAllActive: Bool
    let isShuffle: Bool
    var sort: Int
    
    enum CodingKeys: String, CodingKey {
        case id, code, title, description
        case imageURL = "imageUrl"
        case designType, isSeeAllActive, isShuffle, sort
    }
    func getDesign() -> HomePatchType{
        return HomePatchType(rawValue: designType ?? -1) ?? .UNKNOWN
    }
}

// MARK: - HomeV3Pagination
struct HomeV3Pagination: Codable {
    let pageNumber: Int
    let pageSize: Int
    let totalItems: Int
    let totalPages: Int
}

//// MARK: - Artist
struct Artist: Codable {
    let id: Int
    let name: String
    let image: String
    let role: Role?
}

enum Role: String, Codable {
    case author = "AUTHOR"
    case narrator = "NARRATOR"
    case voiceArtist = "VOICE_ARTIST"
}

enum ContentSubType: String, Codable {
    case episode = "EPISODE"
    case track = "TRACK"
}


// MARK: - Playlist
struct Playlist: Codable {
    let playlistSource: String?
    let sequence: Int?
    var autoGenerated: Bool = false
    var isRadio: Bool = false
    var contentsCount: Int = 0
    let titleBgColor: JSONNull?
}

struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue
        } else {
            value = ()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [AnyCodable]:
            try container.encode(arrayValue)
        case let dictValue as [String: AnyCodable]:
            try container.encode(dictValue)
        default:
            try container.encodeNil()
        }
    }
}
