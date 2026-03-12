//
//  SearchModel.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/23/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation


struct SearchObj: Codable {
    var data: SearchData
    
    struct Track: Codable {
        var data: [CommonContent_V6]
    }

    struct Video: Codable {
        var data: [CommonContent_V6]
    }

    struct PodcastShow : Codable{
        var data: [CommonContent_V6]
    }

    struct PodcastEpisode : Codable {
        var data: [CommonContent_V6]
    }

    struct PodcastTrack : Codable {
        var data: [CommonContent_V6]
    }
    
    struct SearchData: Codable {
        var artist          : Artist
        var album           : Album
        var track           : Track
        var video           : Video
        var podcastShow     : PodcastShow
        var podcastEpisode  : PodcastEpisode
        var podcastTrack    : PodcastTrack
        
        enum CodingKeys: String,CodingKey {
            case artist = "Artist"
            case album = "Album"
            case track = "Track"
            case video = "Video"
            case podcastShow = "PodcastShow"
            case podcastEpisode = "PodcastEpisode"
            case podcastTrack = "PodcastTrack"
        }
        struct Artist: Codable {
            var data: [CommonContent_V6]
        }

        struct Album: Codable {
            var data: [CommonContent_V6]
        }
    }
}
