//
//  Localize.swift
//  Shadhin
//
//  Created by Admin on 19/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension String{
    func capitalizeFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    //Downloads
    enum Downloads : String{
        case noDownloadTitle
        case noDownloadSubtitle
        case noFavorites
        case noFavoritesSubtitle
        case noSongs
        case noSongsSubtitle
        case selectAll
        case songs
        case songsSubtitle
        case playlist
        case album
        case noAlbum
        case audioPodcast
        case artist
        case history
        case favorites
        case favoritesSubtitle
        case recentlyPlayedAlbum
        case noAlbumSubtitle
        case download
    }
    enum ArtistList : String {
        case popularTrack
        case albums
        case fanAlsoLike
    }
    enum AlbumList : String{
        case trackList
    }
    enum MoreMenu : String{
        case removeFromFavorite
        case addToFavorite = "Add to Favorite"
        case share
        case shareVideo
        case addToWatchLater
        case removeFromWatchLater
        case removeFromDownload
        case download
        case removeFromHistory
        case gotoAlbum = "Go to Album"
        case gotoArtist = "Go to Artist"
        case addToPlaylist = "Add to Playlist"
        case SetAsWelcomeTune = "Set as Welcome Tune"
        case StopThisWelcomeTune = "Stop this Welcome Tune"
        case remove
        case connectedDevice
        case queueList
        case sleepTimer
        case sleep
    }
    enum Alert : String {
        case noArtistFound
        case noAlbumFound
        
    }
}

extension RawRepresentable {
    
   func format(_ args: CVarArg) -> String {
       let format = ^self
       return String(format: format, args)
   }
    
}

prefix operator ^
prefix func ^<Type: RawRepresentable> (_ value: Type) -> String {
   if let raw = value.rawValue as? String {
       let key = raw.capitalizeFirstLetter()
       return NSLocalizedString(key, comment: "")
   }
   return ""
}
