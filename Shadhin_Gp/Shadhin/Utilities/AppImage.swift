//
//  AppImage.swift
//  Shadhin
//
//  Created by Admin on 19/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation
import UIKit

enum AppImage : String {
    
    typealias RawValue = String
    
    //version compactability . value change for diffrent version
    
    //Downloads
    case noDownload = "nodownload"
    case noFav = "nofav"
    case noSong = "nosong"
    case checkSqure = "checkmark.square"
    case uncheckSqure = "square"
    case checkSqure12 = "rbt_checkbox_checked"
    case uncheckSqure12 = "ic_artist_uncheck.pdf"
    case checkCircelFill = "ic_dl_check"
    case checkCircelFill12 = "ic_coupon_s"
    case grid = "square.grid.2x2"
    case grid12 = "ic_grid_mode"
    case list = "list.bullet"
    case list12 = "ic_list_mode"
    case close = "xmark"
    case close12 = "ic_close"
    case closeDownload = "ic_close_t"
    case trash = "trash"
    case trash12 = "ic_delete_header"
    case search = "magnifyingglass"
    case search12 = "ic_collapsible_search"
    case noAlbum = "noalbum"
    //pod cast
    case downloadPodcast = "ic_download_podcast"
    
    //ArtistPlayer List
    case downloaded12 = "ic_downloaded"
    case downloadIcon = "ic_download_video_active"
    case notDownload = "arrow.down.circle"
    case nonDownload12 = "ic_download_big"
    
    case artistPlaceholder = "default_artist"
    case songPlaceholder = "default_song"
    
    //more menu iems
    case addToFavorite = "ic_favorite_border"
    case removeFromFavorite = "ic_mymusic_favorite"
    case share = "ic_share_t"
    case downloadNormal = "ic_download_t"
    case remove = "ic_delete_black"
    case gotoAlbum = "ic_music_album"
    case gotoArtist = "ic_artist_black"
    case addToPlaylist = "addToPlaylist"
    case addToWatchLater = "ic_watch_later"
    case airPlay = "airplayaudio"
    case SetAsWelcomeTune = "ic_single_music_rbt"
    case StopWelcomeTuneSet = "stop_welcomeTune_ic"
    //leader board
    case leaderboardIcon = "leaderboardIcon"
    case userAvatar = "avatar-filled"
    //telco
    case gp = "gp"
    case robi = "robiLogo"
    case bl    = "bl"
    case bkash = "bkash"
    case nagad  = "nagad"
    
    //v4 content
    //music player v4 more menu
    case shuffleOffMV4
    case shuffleOnMV4
    case repateMV4
    case repateOnceMV4
    case downloadMV4
    case noDownloadMV4
    case likeMV4
    case likeOnMV4
    case addPlaylistMV4
    case gotoArtistMV4
    case gotoAlbumMV4
    case queueListMV4
    case removePlaylistMV4
    case shareMV4
    case sleepTimeOnMV4
    case sleepTimerMV4
    case podcastMV4
    case downloadCancelMV4
    case Sleep
    
    //get uiImage from appImage
    var uiImage : UIImage?{
        if (self == .Sleep){
            return speedImage()
        }
        if #available(iOS 13, *){
            return  UIImage(systemName: rawValue) ?? UIImage(named: rawValue,in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        }
        return UIImage(named: rawValue,in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
    }
    //get system image with tint color
    @available(iOS 13.0, *)
    func uiImage(with fontSize: CGFloat? = nil, tintColor : UIColor? = nil)-> UIImage?{
        var image = uiImage
        if let fontSize = fontSize {
            let font = UIFont.systemFont(ofSize: fontSize)
            image = image?.withConfiguration(UIImage.SymbolConfiguration(font: font))
        }
        if let tintColor = tintColor {
            return image?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        }else{
            return image
        }
    }
    
    private func speedImage() -> UIImage?{
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .primaryLableColor()
        nameLabel.text = "\(AudioPlayer.shared.rate)"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
}
