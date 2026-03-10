//
//  Enums.swift
//
//  Created by MD Murad Hossain on 06/10/25.
//  Copyright © 2025 Cloud 7 Limited. All rights reserved.
//

import Foundation

enum ContentType : String, Codable{
    case Song = "S"
    case PodCastTrack = "PDBC"
    case PodCastShow = "PDPS"
    case PodCast = "PD"
    case Album = "R"
    case Artist = "AR"
    case Playlist = "P"
    case UserPlaylist = "MP"
    case None
}
enum MoreMenuType : String, CaseIterable{
    case Songs = "S"
    case Album  = "R"
    case Artist = "A"
    case Podcast  =  "PD"
    case PodCastVideo = "VD"
    case Playlist  = "P"
    case UserPlaylist = "UP"
    case Video = "V"
    case AudioBook = "BK"
    case None = ""
    case ShortsSong = "SS"
    //case Download = "Download"
}
enum MoreMenuItemType : CaseIterable{
    case Download
    case RemoveDownload
    case Favorite
    case RemoveFevorite
    case Share
    case SetAsWelcomeTune
    case StopThisWelcomeTune
    case GotoArtist
    case AddToPlaylist
    case GotoAlbum
    case AddToQuary
    case OpenQueue
    case RemoveHistory
    case WatchLater
    case RemoveWatchLater
    case Remove
    case ConnectedDevice
    case SleepTimer
    case Speed
    case Copyright
}
public enum SMContentType: String, Decodable {
    case LK             = "LK"
    case artist         = "A"
    case album          = "R"
    case song           = "S"
    case podcast        = "PDHO"
    case podcastVideo   = "PDVD"
    case video          = "V"
    case playlist       = "P"
    case subscription   = "SUB"
    case myPlayList     = "MP"
    case audioBook      = "BK"
    case link           = "LINK"
    case unknown
    
    public init(rawValue: String?){
        var value = rawValue?.uppercased() ?? "0"
        if value.starts(with: "PD") || value.starts(with: "VD"),
           value.count > 2{
            value = String(value.prefix(2))
        }
        switch value {
        case "LK": self = .LK
        case "A" : self = .artist
        case "R" : self = .album
        case "S" : self = .song
        case "PD": self = .podcast
        case "VD": self = .podcastVideo
        case "V" : self = .video
        case "P" : self = .playlist
        case "SUB": self = .subscription
        case "MP": self = .myPlayList
        case "BK": self = .audioBook
        case "LINK": self = .link
        default  : self = .unknown
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = SMContentType(rawValue: string) ?? .unknown
    }
}
enum MenuOpenFrom {
    case Download
    case Album
    case Artist
    case Favourit
    case History
    case Podcast
    case RecentPlay
    case Playlist
    case Video
    case UserPlaylist
    case WatchLater
    case Player
    case AudioBook
    case ShortsSong
}

enum UserActionType{
    case add
    case remove
}

enum RBTSubType: Int{
    case OneTime     = 0
    case AutoRenewal = 1
}

enum RegistrationMedium: String{
    case mobile   = "M"
    case email    = "E"
    case facebook = "F"
    case google   = "G"
    case twitter  = "T"
    case linkedIn = "L"
    case apple    = "A"
}

enum UserGender: String{
    case male    = "Male"
    case female  = "Female"
    case unknown = ""
}

enum Telco: String{
    case GrameenPhone = "gp"
    case BanglaLink   = "bl"
    case Robi         = "robi"
    case Airtel       = "airtel"
    case Bkash        = "bkash"
    case Unknown      = "unknown"
    
    init?(rawValue: String) {
        switch rawValue.lowercased(){
        case "gp":
            self = .GrameenPhone
        case "bl":
            self = .BanglaLink
        case "robi":
            self = .Robi
        case "airtel":
            self = .Airtel
        case "bkash":
            self = .Bkash
        default:
            self = .Unknown
        }
    }
}

enum ImageSize: String{
    case BillboardBanner = "596"
}
