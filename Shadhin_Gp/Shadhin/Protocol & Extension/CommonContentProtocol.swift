//
//  ContentDataProtocol.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation

protocol CommonContentProtocol {
    var contentID: String? { get set }
    var image: String? { get set }
    var newBannerImg: String? { get set }
    var title: String? { get set }

    var playUrl: String? { get set }
    var artist: String? { get set }
    var artistId: String? { get set }
    var albumId: String? { get set }

    var artistImage: String? { get set }
    var duration: String? { get set }
    var contentType: String? { get set }
    var fav: String? { get set }
    var playCount: Int? { get set }

    var trackType: String? { get set }
    var isPaid: Bool? { get set }
    var copyright: String? { get set }

    var labelname: String? { get set }
    var releaseDate: String? { get set }

    var hasRBT: Bool? { get set }
    var teaserUrl: String? { get set }
    var followers: String? { get set }
    var templateFlag : Bool? { get set }
    var rbtOperators: [String]? { get set }
    
    func getRoot() -> RootModel
}

extension CommonContentProtocol {
    var audioBook: AudioBook? {
        return nil
    }

    var ownership: HomeV3Ownership? {
        return nil
    }

    var track: Track? {
        return nil
    }

    var titleBn: String? {
        return nil
    }

    var titleEn: String? {
        return nil
    }

    func getRoot() -> RootModel {
        return RootModel(contentID: contentID ?? "", contentType: contentType ?? "")
    }
    
    var templateFlag : Bool? {
        return nil
    }
    
    var rbtOperators: [String]? {
        return nil
    }
    
    var release: Release? {
        return nil
    }
    
    var moods: Mood? {
        return nil
    }
    var genres: Genre? {
        return nil
    }
}

// Keep RootModel as a simple struct
struct RootModel: Equatable {
    var contentID: String
    var contentType: String
}

struct ShadhinContent: CommonContentProtocol {

    var rbtOperators: [String]?
    var templateFlag: Bool?
    
    var contentID: String?
    
    var newBannerImg: String?
    
    var title: String?
    
    var playUrl: String?
    
    var artist: String?
    
    var artistId: String?
    
    var albumId: String?
    
    var artistImage: String?
    
    var duration: String?
    
    var contentType: String?
    
    var fav: String?
    
    var playCount: Int?
    
    var trackType: String?
    
    var isPaid: Bool?
    
    var copyright: String?
    
    var labelname: String?
    
    var releaseDate: String?
    
    var hasRBT: Bool? = false
    
    var teaserUrl: String?
    
    var followers: String?
    var parentContentId: String?
    var titleEn: String?
    var image: String?
    var track: Track?
    var ownership: HomeV3Ownership?
    var release: Release?
    var artists: [HomeV3Artist]?
}

extension CommonContentProtocol {
    var releaseId: String? {
        get { return nil }
        set { }
    }
}
