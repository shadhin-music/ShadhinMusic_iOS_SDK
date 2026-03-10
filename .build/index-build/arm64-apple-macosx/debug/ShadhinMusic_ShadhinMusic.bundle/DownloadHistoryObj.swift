//
//  DownloadHistoryModel.swift
//  Shadhin
//
//  Created by Admin on 12/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

// MARK: - DownloadHistoryModel
struct DownloadHistoryObj: Codable {
    let status, message, type: String?
    let fav: String?
    let data: [DownloadContentModel]
    let image : String?
    let follow: Bool?
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseDatum { response in
//     if let datum = response.result.value {
//       ...
//     }
//   }

// MARK: - Datum
struct DownloadContentModel: Codable {
    let contentID: String?
    let image: String?
    let imageWeb: String?
    let title, contentType, playURL, duration: String?
    let fav: String?
    let banner, newBanner: String?
    let playCount: Int
    let type: String?
    let isPaid, seekable: Bool
    let trackType: String?
    let artistId, artist: String?
    let artistImage: String?
    let albumId, albumName: String?
    let albumImage: String?
    let playListID, playListName: String?
    let playListImage: String?
    let createDate, rootID, rootType: String?
    let teaserURL: String?

    enum CodingKeys: String, CodingKey {
        case contentID = "ContentID"
        case image, imageWeb, title
        case contentType = "ContentType"
        case playURL = "PlayUrl"
        case duration = "Duration"
        case fav
        case banner = "Banner"
        case newBanner = "NewBanner"
        case playCount = "PlayCount"
        case type = "Type"
        case isPaid = "IsPaid"
        case seekable = "Seekable"
        case trackType = "TrackType"
        case artistId = "artistId"
        case artist = "Artist"
        case artistImage = "ArtistImage"
        case albumId = "albumId"
        case albumName = "AlbumName"
        case albumImage = "AlbumImage"
        case playListID = "PlayListId"
        case playListName = "PlayListName"
        case playListImage = "PlayListImage"
        case createDate = "CreateDate"
        case rootID = "RootId"
        case rootType = "RootType"
        case teaserURL = "TeaserUrl"
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

//// MARK: - Alamofire response handlers
//
//extension DataRequest {
//    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
//        return DataResponseSerializer { _, response, data, error in
//            guard error == nil else { return .failure(error!) }
//
//            guard let data = data else {
//                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
//            }
//
//            return Result { try newJSONDecoder().decode(T.self, from: data) }
//        }
//    }
//
//    @discardableResult
//    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
//        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
//    }
//
//    @discardableResult
//    func responseDownloadHistoryModel(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<DownloadHistoryModel>) -> Void) -> Self {
//        return responseDecodable(queue: queue, completionHandler: completionHandler)
//    }
//}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
