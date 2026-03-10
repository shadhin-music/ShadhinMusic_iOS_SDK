//
//  CommonContent.swift
//  Shadhin
//
//  Created by Gakk Alpha on 11/8/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

struct CommonContent_V0: Codable,CommonContentProtocol {
    var releaseId: String?
    var rbtOperators: [String]?
    var templateFlag: Bool?
    var hasRBT: Bool?
    var artistImage: String?
    
    var contentID: String?
    var image: String?
    var title: String?
    var playUrl: String?
    var artistId: String?
    var albumId: String?
    var duration0: String?
    var duration1: String?
    var contentType: String?
    var fav: String?
    var bannerImg: String?
    var newBannerImg: String?
    var playCount : Int?
    var totalStream : String?
    var duration : String? {
        get{
            if duration0 != nil{
                return duration0
            }else if duration1 != nil{
                return duration1
            }else{
                return nil
            }
        }
        set{
            duration0 = newValue
        }
    }
    var isPaid: Bool? = false
    var trackType : String?
    var copyright: String?
    var labelname: String?
    var releaseDate: String?
    var RootType: String?
    var artist: String?{
        get{
            if _artist != nil{
                return _artist
            } else if artistName != nil{
                return artistName
            }else{
                return nil
            }
        }
        set{
            artistName = newValue
            _artist = newValue
        }
    }
    var artistName: String?
    var _artist: String?
    var type: String?
    var teaserUrl: String?
    var followers: String?
    
    enum CodingKeys: String,CodingKey {
        case contentID = "ContentID"
        case image
        case title
        case fav = "fav"
        case playUrl = "PlayUrl"
        case _artist = "Artist"
        case artistId = "artistId"
        case albumId = "albumId"
        case duration0 = "Duration"
        case duration1 = "duration"
        case contentType = "ContentType"
        case bannerImg = "Banner"
        case newBannerImg = "NewBanner"
        case playCount = "PlayCount"
        case totalStream = "TotalStream"
        case isPaid = "IsPaid"
        case copyright
        case artistName = "artistname"
        case type = "Type"
        case trackType = "TrackType"
        case teaserUrl = "TeaserUrl"
        case followers = "Follower"
        case artistImage = "ArtistImage"
    }
}

struct CommonContent_V1: Codable,CommonContentProtocol {
    var artistImage: String?
    var rbtOperators: [String]?
    var templateFlag: Bool?
    var hasRBT: Bool?

    var contentID: String?
    var contentType: String?
    var image: String?
    var newBannerImg: String?
    var title: String?
    var playUrl: String?
    var artist: String?
    var artistId: String?
    var albumId: String?
    var duration: String?
    var fav: String?
    var playCount: Int?
    var isPaid: Bool?
    var trackType : String?
    var copyright: String?
    var labelname: String?
    var releaseDate: String?
    var teaserUrl: String?
    var followers: String?
    
    enum CodingKeys: String,CodingKey {
        case contentID = "ContentID"
        case contentType = "ContentType"
        case image
        case title
        case playUrl = "PlayUrl"
        case artist
        case artistId = "artistId"
        case albumId = "albumId"
        case artistImage = "ArtistImage"
        case duration
        case fav = "fav"
        case copyright
    }
}


struct CommonContent_V2: Codable,CommonContentProtocol {
    var artistImage: String?
    var rbtOperators: [String]?
    var templateFlag: Bool?
    var hasRBT: Bool?

    var artist: String?
    var artistId: String?
    var albumId: String?
    var contentID: String?
    var contentType: String?
    var image: String?
    var newBannerImg: String?
    var title: String?
    var playUrl: String?
    var duration: String?
    var fav: String?
    var playCount: Int?
    
    var isPaid: Bool?
    var trackType : String?
    var copyright: String?
    
    var labelname: String?
    var releaseDate: String?
    
    var teaserUrl: String?
    var followers: String?
    
    enum CodingKeys: String,CodingKey {
        case contentID = "ContentID"
        case contentType = "ContentType"
        case image
        case title
        case playUrl = "PlayUrl"
        case artist = "artistname"
        case artistId = "artistId"
        case albumId = "albumId"
        case duration
        case fav = "fav"
        case playCount = "TotalPlay"
        case copyright
        case artistImage = "ArtistImage"
    }
}

// fix for SWIFT STRUCT ARRAY EXC_BAD_ACCESS (code=EXC_I386_GPFLT) (dont know why struct produces crash)
class CommonContent_V3: NSObject, Codable,CommonContentProtocol {
    var artistImage: String?
    var rbtOperators: [String]?
    var templateFlag: Bool?
    var hasRBT: Bool?

    var contentID: String?
    var contentType: String?
    var image: String?
    var newBannerImg: String?
    var title: String?
    var playUrl: String?
    var artist: String?
    var artistId: String?
    var albumId: String?
    var duration: String?
    var fav: String?
    var playCount: Int?
    
    var isPaid: Bool?
    var trackType : String?
    var copyright: String?
    
    var labelname: String?
    var releaseDate: String?
    
    var teaserUrl: String?
    var isSelected: Bool = true
    var followers: String?
    
    enum CodingKeys: String,CodingKey {
        case contentID = "ContentID"
        case contentType = "ContentType"
        case image
        case title
        case playUrl = "PlayUrl"
        case artist = "Artist"
        case artistId = "artistId"
        case albumId = "albumId"
        case duration = "Duration"
        case fav = "fav"
        case isPaid = "IsPaid"
        case copyright
        case artistImage = "ArtistImage"
    }
    
    
}


struct CommonContent_V4: Codable, CommonContentProtocol {
    var artistId: String?
    var artistImage: String?
    var rbtOperators: [String]? = nil
    var templateFlag: Bool? = false
    var hasRBT: Bool? = false

    var contentID: String?
    var contentType: String?
    var image: String?
    var newBannerImg: String?
    var title: String?
    var playUrl: String?
    var artist: String?
    var albumId: String?
    var duration: String?
    var fav: String?
    var playCount: Int?
    var isPaid: Bool?
    var trackType : String?
    var copyright: String?
    var labelname: String?
    var releaseDate: String?
    var teaserUrl: String?
    var followers: String?
    
    enum CodingKeys: String,CodingKey {
        case contentID = "ContentID"
        case contentType = "ContentType"
        case image
        case title
        case playUrl = "PlayUrl"
        case artist
        case artistId = "artistId"
        case albumId = "albumId"
        case duration
        case fav = "fav"
        case artistImage = "ArtistImage"
    }
}


class CommonContent_V5: Codable, CommonContentProtocol {
    var artistImage: String?
    var rbtOperators: [String]?
    var templateFlag: Bool?
    var hasRBT: Bool?

    var trackType: String?
    var isPaid: Bool?
    var duration: String?
    var playUrl: String?
    lazy var contentID: String? = {
        return String(id)
    }()
    lazy var image: String? = {
        return self.imageURL
    }()
    lazy var title: String? = {
        return self.name
    }()
    lazy var artist: String? = {
        return self.starring
    }()
    lazy var albumId: String? = {
        return self.episodeID
    }()
    var artistId: String?
    var contentType: String? = "pd"
    var fav: String?
    
    let id: Int
    let showID, episodeID, name: String
    let imageURL: String
    var newBannerImg: String?
    let starring: String
    let seekable: Bool
    let details, ceateDate: String
    var playCount: Int?
    var copyright: String?
    var labelname: String?
    var releaseDate: String?
    let _sort: Int
    var totalStream: Int?
    var teaserUrl: String?
    var followers: String?
    var sort: Int{
        if contentType?.lowercased() == "pdnw"{
            return 0
        }
        if let _playCount = totalStream{
            return _playCount
        }
        return _sort
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case showID = "ShowId"
        case episodeID = "EpisodeId"
        case name = "Name"
        case imageURL = "ImageUrl"
        case playUrl = "PlayUrl"
        case starring = "Starring"
        case duration = "Duration"
        case seekable = "Seekable"
        case details = "Details"
        case ceateDate = "CeateDate"
        case contentType = "ContentType"
        case _sort = "Sort"
        case trackType = "TrackType"
        case isPaid = "IsPaid"
        case copyright
        case totalStream
        case artistImage = "ArtistImage"
    }
    
    init(id: Int, showID: String, episodeID: String, name: String, imageURL: String, playUrl: String, starring: String, duration: String, seekable: Bool, details: String, ceateDate: String, contentType: String?, sort: Int, trackType: String?, isPaid : Bool?) {
        self.id = id
        self.showID = showID
        self.episodeID = episodeID
        self.name = name
        self.imageURL = imageURL
        self.playUrl = playUrl
        self.starring = starring
        self.duration = duration
        self.seekable = seekable
        self.details = details
        self.ceateDate = ceateDate
        self.contentType = contentType
        self._sort = sort
        self.trackType = trackType
        self.isPaid = isPaid
    }
}


struct CommonContent_V6: Codable,CommonContentProtocol  {
    var artistId: String?
    var rbtOperators: [String]?
    var templateFlag: Bool?
    var hasRBT: Bool?
    var artistImage: String?
    

    var artist: String?
    var albumId: String?
    var contentID: String?
    var contentType: String?
    var image: String?
    var newBannerImg: String?
    var title: String?
    var playUrl: String?
    var duration: String?
    var fav: String?
    var playCount: Int?
    var isPaid : Bool?
    var trackType : String?
    var copyright: String?
    var labelname: String?
    var releaseDate: String?
    var teaserUrl: String?
    var followers: String?
    
    enum CodingKeys: String,CodingKey {
        case contentID = "ContentID"
        case contentType = "ContentType"
        case image
        case title
        case playUrl = "PlayUrl"
        case artist = "Artist"
        case artistId = "artistId"
        case albumId = "albumId"
        case duration = "Duration"
        case fav = "fav"
        case isPaid = "IsPaid"
        case trackType = "TrackType"
        case copyright
        case artistImage = "ArtistImage"
    }
}


struct CommonContent_V7: Codable,CommonContentProtocol {
    var artistImage: String?
    var rbtOperators: [String]?
    var templateFlag: Bool?
    var hasRBT: Bool?

    var contentID: String?
    var contentType: String?
    var image: String?
    var newBannerImg: String?
    var title: String?
    var playUrl: String?
    var artist: String?
    var artistId: String?
    var albumId: String?
    var duration: String?
    var fav: String?
    var playCount: Int?
    
    var isPaid: Bool?
    var trackType : String?
    var copyright: String?
    
    var labelname: String?
    var releaseDate: String?
    
    var teaserUrl: String?
    var followers: String?
    
    //added by joy
    //for download item selection track
    var isSelect : Bool = true
    //check song download as all or single by single
    var isSingleDownload : Bool = true
    //check download start or not
    var isDownloading : Bool = false
    //playlist id
    var playListID : String?
    var isUserCreated  : Bool = false
    //create date
    var date : Date?
    
    func getAlbumAndPlaylistData()-> CommonContent_V1{
        var album = CommonContent_V1()
        album.contentID = self.contentID
        album.contentType = self.contentType
        album.image = self.image
        album.newBannerImg = self.newBannerImg
        album.title = self.title
        album.playUrl = self.playUrl
        album.artist = self.artist
        album.artistId = self.artistId
        album.duration = self.duration
        album.fav = self.fav
        album.playCount  = self.playCount
        album.isPaid = self.isPaid
        album.trackType = self.trackType
        album.copyright = self.copyright
        album.labelname = self.labelname
        album.releaseDate = self.releaseDate
        album.hasRBT = self.hasRBT
        album.teaserUrl = self.teaserUrl
        
        return album
    }
    func getArtistData()-> CommonContent_V2{
        var artist = CommonContent_V2()
        artist.contentID = self.contentID
        artist.contentType = self.contentType
        artist.image = self.image
        artist.newBannerImg = self.newBannerImg
        artist.title = self.title
        artist.playUrl = self.playUrl
        artist.artist = self.artist
        artist.artistId = self.artistId
        artist.duration = self.duration
        artist.fav = self.fav
        artist.playCount  = self.playCount
        artist.isPaid = self.isPaid
        artist.trackType = self.trackType
        artist.copyright = self.copyright
        artist.labelname = self.labelname
        artist.releaseDate = self.releaseDate
        artist.hasRBT = self.hasRBT
        artist.teaserUrl = self.teaserUrl
        
        return artist
    }
    func getPlaylistData()-> PlaylistsObj.PlaylistDetails{
        
        let songs = DatabaseContext.shared.getPlayListSongsBy(playlistID: contentID ?? "")
        var pSong : [PlaylistsObj.PlaylistDetails.Songs]  = []
        songs.forEach { ss in
            if let song = DatabaseContext.shared.getSongBy(id: ss.songID ?? ""){
                let sp = PlaylistsObj.PlaylistDetails.Songs(image: song.image ?? "")
                pSong.append(sp)
            }
        }
        let playList = PlaylistsObj.PlaylistDetails(id: contentID  ?? "", name: title ?? "",Data: pSong)
        
        return playList
    }
    func getUserPlaylist()-> CommonContent_V4{
        var user = CommonContent_V4()
        user.contentID = self.contentID
        user.contentType = self.contentType
        user.image = self.image
        user.newBannerImg = self.newBannerImg
        user.title = self.title
        user.playUrl = self.playUrl
        user.artist = self.artist
        user.artistId = self.artistId
        user.duration = self.duration
        user.fav = self.fav
        user.playCount  = self.playCount
        user.isPaid = self.isPaid
        user.trackType = self.trackType
        user.copyright = self.copyright
        user.labelname = self.labelname
        user.releaseDate = self.releaseDate
        user.hasRBT = self.hasRBT
        user.teaserUrl = self.teaserUrl
        
        return user
    }
    
    mutating func downloadContent(with dcm : DownloadContentModel) {
        self.contentID =    dcm.contentID
        self.contentType =  dcm.contentType
        self.duration =     dcm.duration
        self.image =        dcm.image
        self.newBannerImg = dcm.newBanner
        self.title =        dcm.title
        self.playUrl =      dcm.playURL
        self.artist =       dcm.artist
        self.artistId =     dcm.artistId
        self.albumId =      dcm.albumId
        self.duration =     dcm.duration
        self.fav =          dcm.fav
        self.playCount  =   dcm.playCount
        self.isPaid =       dcm.isPaid
        self.trackType =    dcm.trackType
        self.teaserUrl =    dcm.teaserURL
        self.playListID =   dcm.playListID
    }
    mutating func setContentDataProtocal(cdp : CommonContentProtocol){
        self.contentID =    cdp.contentID
        self.contentType =  cdp.contentType
        self.duration =     cdp.duration
        self.image =        cdp.image
        self.newBannerImg = cdp.newBannerImg
        self.title =        cdp.title
        self.playUrl =      cdp.playUrl
        self.artist =       cdp.artist
        self.artistId =     cdp.artistId
        self.albumId =      cdp.albumId
        self.duration =     cdp.duration
        self.fav =          cdp.fav
        self.playCount  =   cdp.playCount
        self.isPaid =       cdp.isPaid
        self.trackType =    cdp.trackType
        self.teaserUrl =    cdp.teaserUrl
        self.hasRBT =       cdp.hasRBT
        self.copyright   =  cdp.copyright
        self.labelname  =   cdp.labelname
    }
    
    mutating func setAudioContentDataProtocal(cdp : AudioPatchContent){
        self.contentID   =   String(cdp.contentID)
        self.contentType =  cdp.contentType.rawValue
        self.duration =     String(cdp.streamingCount)
        self.image =        cdp.imageURL
        self.newBannerImg = cdp.imageWebURL
        self.title =        cdp.titleEn
        self.playUrl =      cdp.playlist
        self.artist =       cdp.artists.first
        self.artistId =     ""
        self.albumId =      ""
        self.duration =     ""
        self.fav =         ""
        self.playCount  =   cdp.likeCount
        self.isPaid =       cdp.isPaid
        self.trackType =     ""
        self.teaserUrl =   ""
        self.hasRBT   =       true
        self.copyright   =  ""
        self.labelname  =  ""
    }
    
}
