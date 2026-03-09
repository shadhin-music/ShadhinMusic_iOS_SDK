//
//  GPExploreMusicModel.swift
//  Shadhin_Gp
//
//  Created by Maruf on 21/8/24.
//

import Foundation

// MARK: - Root
struct GPExploreMusicModel: Codable {
    let success: Bool?
    let responseCode: Int?
    let title: String?
    let data: [GPPatchData]?
    let error: String?
}

// MARK: - PatchData
struct GPPatchData: Codable {
    let patch: GPPatch?
    let contents: [GPContent]?
}

// MARK: - Patch
struct GPPatch: Codable {
    let patchId: Int?
    let code, title, description: String?
    let imageUrl: String?
    let designType: Int?
    let isSeeAllActive, isShuffle: Bool?
    let sort: Int?
}

// MARK: - Content
struct GPContent: Codable {
    let contentId: Int?
    let contentType: String?
    let titleBn: String?
    let titleEn: String?
    let details: String?
    let imageUrl, imageWebUrl: String?
    let duration: Int?
    let streamingUrl: String?
    let isPaid: Bool?
    let likeCount, sort: Int?
    let ownership: GPOwnership?
    let release: GPRelease?
    let track: GPTrack?
    let artists: [GPArtist]?
    let genres: [GPGenre]?
    let moods: [GPMood?]?
    
    func toCommonContentV4() -> CommonContent_V1 {
        return CommonContent_V1(
            artistImage: nil,
            rbtOperators: nil,
            templateFlag: nil,
            hasRBT: nil,
            contentID: contentId.map { String($0) },
            contentType: contentType,
            image: imageUrl,
            newBannerImg: imageWebUrl,
            title: titleEn ?? titleBn,
            playUrl: streamingUrl,
            artist: artists?.first?.name,
            artistId: artists?.first?.id.map { String($0) },
            albumId: nil,
            duration: duration.map { String($0) },
            fav: nil,
            playCount: nil,
            isPaid: isPaid,
            trackType: track?.trackType,
            copyright: ownership?.copyright,
            labelname: ownership?.label,
            releaseDate: release?.date,
            teaserUrl: nil,
            followers: nil
        )
    }

    func convertToAudioItem()-> AudioItem? {
        let gpContent = self
        var url: URL? = nil
        if let streamingUrlStr = gpContent.streamingUrl, !streamingUrlStr.isEmpty {
            url = URL(string: streamingUrlStr)
        }
        
        // Initialize the AudioItem with the high-quality sound URL
        let audioItem = AudioItem(highQualitySoundURL: url)
        
        // Set additional properties
        audioItem?.contentId = gpContent.contentId.map { String($0) }
        audioItem?.contentType = gpContent.contentType
        audioItem?.trackType = gpContent.track?.trackType
        audioItem?.title = gpContent.titleEn
        audioItem?.artist = gpContent.artists?.first?.name
        audioItem?.urlKey = gpContent.streamingUrl
        
        if let imgUrl = gpContent.imageUrl?.replacingOccurrences(of: "<$size$>", with: "300"),
           let artworkUrl = URL(string: imgUrl) {
            // Assume KingfisherManager is available to download the image
            KingfisherManager.shared.downloader.downloadImage(with: artworkUrl) { result in
                if case let .success(value) = result {
                    audioItem?.artworkImage = value.image
                }
            }
        }
        return audioItem
    }
}

// MARK: - Ownership
struct GPOwnership: Codable {
    let label, copyright, productBy, publication: String?
}

// MARK: - Release
struct GPRelease: Codable {
    let id: Int?
    let name: String?
    let date: String?
}

// MARK: - Track
struct GPTrack: Codable {
    let streamingUrl: String?
    let duration: Int?
    let trackType: String?
    let isLive: Bool?
}

// MARK: - Artist
struct GPArtist: Codable {
    let id: Int?
    let name: String?
    let image: String?
}

// MARK: - Genre
struct GPGenre: Codable {
    let id: Int?
    let name: String?
    let image: String?
}

// MARK: - Mood
struct GPMood: Codable {
    let id: Int?
    let name: String?
    let image: String?
}

//
//// New Login Model:
//public class NewAuthResponseModel: NSObject, Codable {
//    let data: Data?
//    let error: ErrorResponseModel?
//    let responseCode: Int
//    let success: Bool
//    let title: String
//    var userData: UserData?
//    
//    struct Data: Codable {
//        var accessToken: String
//        let refreshToken: RefreshToken
//        
//        struct RefreshToken: Codable {
//            let expireAt: Int64
//            let tokenString: String
//            let username: String?
//        }
//    }
//}
//
//public class UserInfoResponseModel:NSObject, Codable {
//    let success: Bool?
//    let responseCode: Int?
//    let title: String?
//    let data: UserData?
//    let error: String?
//}
//// MARK: - UserData
//struct UserData: Codable {
//    let userCode: String?
//    let userFullName: String?
//    var phoneNumber: String?
//    let birthDate: String?
//    let gender: String?
//    let country: String?
//    let countryCode: String?
//    let city: String?
//    let userPic: String?
//    let registerWith: [String]?
//    let hasFavoriteArtist: Bool?
//    let hasFavoriteGenre: Bool?
//    let appleId: String?
//    let facebookId: String?
//    let googleId: String?
//    let linkedinId: String?
//    let twitterId: String?
//    var token: String?
//    var refreshToken: NewAuthResponseModel.Data.RefreshToken?
//}
//struct ErrorResponseModel: Codable {
//    let source: String
//    let message: String
//    let details: String
//    let errorCode: String
//}
