//
//  MenuLoader.swift
//  Shadhin
//
//  Created by Joy on 13/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import Foundation

class MenuLoader : NSObject{
    static private func getHeight(menuType : MoreMenuType,isFromDownload : Bool = false, isHistory : Bool = false,operators:[String]?)-> CGFloat{
        let menues = isFromDownload ? getMenuForDownload(type: menuType,isHistory: isHistory, operators: operators) : getMenu(menuFrom: menuType, operators: operators)
        let height : CGFloat = CGFloat((menues.count * 50) + 218)
        return height
    }
    static private func getMenuForDownload(type from : MoreMenuType,isHistory : Bool = false,operators: [String]?)-> [MoreMenuModel]{
        var arr : [MoreMenuModel]  = []
        switch from {
        case .Songs:
            if isHistory{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.removeFromHistory, icon: AppImage.remove, type: .RemoveHistory),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else{
                //more option will be added
                let hasGP = operators?.contains { op in
                    op.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == "GP"
                } ?? false
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                       .init(title: ^String.MoreMenu.gotoAlbum, icon: AppImage.gotoAlbum, type: .GotoAlbum),
                       .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
                // Insert "Set Welcome Tune" at index 2 **only if GP exists**
                if hasGP {
                    let welcomeTuneItem = MoreMenuModel(title: ^String.MoreMenu.SetAsWelcomeTune,
                                                        icon: AppImage.SetAsWelcomeTune,
                                                        type: .SetAsWelcomeTune)
                    arr.insert(welcomeTuneItem, at: 3)
                }
            }
            break
        case .Album:
            if isHistory{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.removeFromHistory, icon: AppImage.remove, type: .RemoveHistory),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else{
                //more option will be added
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.gotoAlbum, icon: AppImage.gotoAlbum, type: .GotoAlbum),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }
            
            break
        case .Artist:
            if isHistory{
                //for future use
            }else{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }
            break
        case .Podcast:
            if isHistory{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.removeFromHistory, icon: AppImage.remove, type: .RemoveHistory),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else{
                //more option will be added
                arr = [
                    .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                    .init(title: "Add to Queue", icon: AppImage.queueListMV4, type: .OpenQueue),
                    .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                    .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                    .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)
                ]
            }
            break
        case .PodCastVideo:
            break
        case .Playlist:
            if isHistory{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.removeFromHistory, icon: AppImage.remove, type: .RemoveHistory),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else{
                //more option will be added
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }
            break
        case .Video:
            if isHistory{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.removeFromHistory, icon: AppImage.remove, type: .RemoveHistory),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.shareVideo, icon: AppImage.share, type: .Share)]
            }else{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.shareVideo, icon: AppImage.share, type: .Share)]
            }
            break
        case .UserPlaylist:
            break
        case .None:
            break
        case .AudioBook:
            arr = [
                .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share),
                .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                .init(title: ^String.MoreMenu.queueList, icon: AppImage.queueListMV4, type: .OpenQueue),
                .init(title: "Copyright : Shadhin Music", icon: .Sleep, type: .Copyright)
                ]
        case .ShortsSong:
            arr = [
                .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                .init(title: "Add to Queue", icon: AppImage.queueListMV4, type: .OpenQueue),
                .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
                .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)
            ]
        }
        return arr
    }
    
    static  private func getMenu(menuFrom : MoreMenuType,operators: [String]?)->[MoreMenuModel]{
        var arr : [MoreMenuModel] = []
        switch menuFrom {
        case .Songs:
            let hasGP = operators?.contains { op in
                op.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == "GP"
            } ?? false
            arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                   .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                   .init(title: ^String.MoreMenu.gotoAlbum, icon: AppImage.gotoAlbum, type: .GotoAlbum),
                   .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
                   .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                   .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]

            if hasGP {
                let welcomeTuneItem = MoreMenuModel(title: ^String.MoreMenu.SetAsWelcomeTune,
                                                    icon: AppImage.SetAsWelcomeTune,
                                                    type: .SetAsWelcomeTune)
                arr.insert(welcomeTuneItem, at: 3)
            }

            break
        case .Album:
            let hasGP = operators?.contains { op in
                op.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == "GP"
            } ?? false
            arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                   .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
                   .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                   .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            if hasGP {
                let welcomeTuneItem = MoreMenuModel(title: ^String.MoreMenu.SetAsWelcomeTune,
                                                    icon: AppImage.SetAsWelcomeTune,
                                                    type: .SetAsWelcomeTune)
                arr.insert(welcomeTuneItem, at: 2)
            }


        case .Artist:
            arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                   .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                   .init(title: ^String.MoreMenu.gotoAlbum, icon: AppImage.gotoAlbum, type: .GotoAlbum),
                   .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            break
        case .Podcast:
            arr = [
                .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                .init(title: "Add to Queue", icon: AppImage.queueListMV4, type: .OpenQueue),
                .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)
            ]
            break
        case  .PodCastVideo:
            arr = [.init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                   .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            break
        case .Playlist:
            arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                   .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                   .init(title: ^String.MoreMenu.gotoAlbum, icon: AppImage.gotoAlbum, type: .GotoAlbum),
                   .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
                   .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                   .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            break
        case .Video:
            arr = [.init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                   .init(title: ^String.MoreMenu.shareVideo, icon: AppImage.share, type: .Share),
                   .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                   .init(title: ^String.MoreMenu.addToWatchLater, icon: AppImage.addToWatchLater, type: .WatchLater)]
        case .UserPlaylist:
            arr = [.init(title: ^String.MoreMenu.remove, icon: AppImage.remove, type: .Remove),
                   .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            break
        case .None:
            break
            
        case .AudioBook:
            arr = [
                .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share),
                .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                .init(title: ^String.MoreMenu.queueList, icon: AppImage.queueListMV4, type: .OpenQueue),
                .init(title: "Copyright : Shadhin Music", icon: .Sleep, type: .Copyright)
            ]
        case .ShortsSong:
            arr = [
                .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                .init(title: "Add to Queue", icon: AppImage.queueListMV4, type: .OpenQueue),
                .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
                .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)
            ]
        }

        return arr
    }
    
    //MARK: this section use next version
    
    static func getHeightFor(vc from : MenuOpenFrom, type : MoreMenuType,operators: [String]?)-> CGFloat{
        let menues = getMenuFor(vc: from, type: type, operators: operators)
        let height : CGFloat = CGFloat((menues.count * 50) + 218)
        return height
    }
    
    static func getMenuFor(vc from : MenuOpenFrom, type : MoreMenuType,operators: [String]?)-> [MoreMenuModel]{
        var arr : [MoreMenuModel] = []
        switch from {
        case .Download:
            arr = getMenuForDownload(type: type, operators: operators)
        case .Album:
            arr  = getAllItemForSong(operators: operators)
            arr.removeAll(where: {$0.type == .GotoAlbum})
        case .Artist:
            arr  = getAllItemForSong(operators: operators)
            arr.removeAll(where: {$0.type == .GotoArtist})
        case .Favourit:
            if type  ==  .Songs{
                arr  = getAllItemForSong(operators: operators)
            }else if type == .Podcast{
                arr = [.init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else if type == .Video{
                arr =  [.init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),.init(title: ^String.MoreMenu.addToWatchLater, icon: AppImage.addToWatchLater, type: .WatchLater),
                        .init(title: ^String.MoreMenu.shareVideo, icon: AppImage.share, type: .Share)]
            } else if type == .PodCastVideo{
                arr = [.init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }
            else {
                arr = getMenu(menuFrom: type, operators: operators)
            }
            
            arr.removeAll(where: {$0.type == .Download})
        case .History:
            let removeHistory : MoreMenuModel = .init(title: ^String.MoreMenu.removeFromHistory, icon: AppImage.remove, type: .RemoveHistory)
            if type == .Songs{
                arr = getAllItemForSong(operators: operators)
                arr.insert(removeHistory, at: 1)
            }else if type == .Album{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),removeHistory,
                       .init(title: ^String.MoreMenu.gotoAlbum, icon: AppImage.gotoAlbum, type: .GotoAlbum),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else if type == .Podcast{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.removeFromHistory, icon: AppImage.remove, type: .RemoveHistory),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else if type == .Playlist{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.removeFromHistory, icon: AppImage.remove, type: .RemoveHistory),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else if type == .Video{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.removeFromHistory, icon: AppImage.remove, type: .RemoveHistory),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.shareVideo, icon: AppImage.share, type: .Share)]
            }
            else{
                arr = getMenuForDownload(type: type, isHistory: true, operators: operators)
            }
            
        case .Podcast:
            if type == .PodCastVideo{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else{
                arr = getMenu(menuFrom: type, operators: operators)
            }
            
        case .RecentPlay:
            
            if type == .Songs{
                arr = getAllItemForSong(operators: operators)
                arr.removeAll(where: {$0.type == .Download})
            }else if type == .Artist{
                arr = [.init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else if type == .Album{
                arr = [.init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.gotoAlbum, icon: AppImage.gotoAlbum, type: .GotoAlbum),
                       .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            } else if type == .Podcast{
                arr = [
                    .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                    .init(title: "Add to Queue", icon: AppImage.queueListMV4, type: .OpenQueue),
                    .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                    .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                    .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)
                ]
                //another item needs to add goto episod
            }else if type == .Playlist || type == .UserPlaylist{
                arr = [.init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)]
            }else{
                arr = getMenu(menuFrom: type, operators: operators)
            }
            
        case .Playlist:
            arr = getMenu(menuFrom: type, operators: operators)
        case .UserPlaylist:
            arr =  getMenu(menuFrom: type, operators: operators)
        case .Video:
            if type == .Video{
                arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                       .init(title: ^String.MoreMenu.addToWatchLater, icon: AppImage.addToWatchLater, type: .WatchLater),
                       .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                       .init(title: ^String.MoreMenu.shareVideo, icon: AppImage.share, type: .Share)]
            }else{
                arr = getMenu(menuFrom: type, operators: operators)
            }
            
        case .WatchLater:
            arr = [.init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                   .init(title: ^String.MoreMenu.addToWatchLater, icon: AppImage.addToWatchLater, type: .WatchLater),
                   .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                   .init(title: ^String.MoreMenu.shareVideo, icon: AppImage.share, type: .Share)]
        case .Player:
            arr = [.init(title: ^String.MoreMenu.queueList, icon: AppImage.queueListMV4, type: .OpenQueue),
                   .init(title: ^String.MoreMenu.share, icon: AppImage.shareMV4, type: .Share)
                  ]
            if type  ==  .Songs{
                arr.insert(.init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist), at: 0)
                arr.append(.init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtistMV4, type: .GotoArtist))
                arr.append(.init(title: ^String.MoreMenu.gotoAlbum, icon: AppImage.gotoAlbumMV4, type: .GotoAlbum))
            }else if type == .Podcast{
                arr.append(.init(title: "Speed", icon: AppImage.Sleep, type: .Speed))
            }
            arr.append(playerSleepIcon())
        
        case .AudioBook:
            arr = [
                .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share),
                .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                .init(title: ^String.MoreMenu.queueList, icon: AppImage.queueListMV4, type: .OpenQueue),
                .init(title: "Copyright : Shadhin Music", icon: .Sleep, type: .Copyright)
            ]
            
        case .ShortsSong:
            arr = [
                .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
                .init(title: "Add to Queue", icon: AppImage.queueListMV4, type: .OpenQueue),
                .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
                .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
                .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
                .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)
            ]
        }

        
        return arr
    }
    
    static private func playerSleepIcon() -> MoreMenuModel{
        switch ShadhinPlayerSleepTimer.instance.currentState{
        case .off:
            return MoreMenuModel.init(title: "Sleep Timer", icon: AppImage.sleepTimerMV4, type: .SleepTimer)
        case .tenMinutes:
            return MoreMenuModel.init(title: "Sleep after 10 minutes", icon: AppImage.sleepTimeOnMV4, type: .SleepTimer)
        case .twentyMinutes:
            return MoreMenuModel.init(title: "Sleep after 20 minutes", icon: AppImage.sleepTimeOnMV4, type: .SleepTimer)
        case .thirtyMinutes:
            return MoreMenuModel.init(title: "Sleep after 30 minutes", icon: AppImage.sleepTimeOnMV4, type: .SleepTimer)
        case .sixtyMinutes:
            return MoreMenuModel.init(title: "Sleep after 1 hour", icon: AppImage.sleepTimeOnMV4, type: .SleepTimer)
        case .custom(let min):
            return MoreMenuModel.init(title: "Sleep after \(min) minutes", icon: AppImage.sleepTimeOnMV4, type: .SleepTimer)
        }
    }
    static private func getAllItemForSong(operators: [String]?) -> [MoreMenuModel] {
        // Check if GP exists
        let hasGP = operators?.contains { op in
            op.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == "GP"
        } ?? false

        // Base menu items
        var arr: [MoreMenuModel] = [
            .init(title: ^String.MoreMenu.download, icon: AppImage.downloadNormal, type: .Download),
            .init(title: ^String.MoreMenu.addToPlaylist, icon: AppImage.addToPlaylist, type: .AddToPlaylist),
            .init(title: ^String.MoreMenu.addToFavorite, icon: AppImage.addToFavorite, type: .Favorite),
            .init(title: ^String.MoreMenu.gotoAlbum, icon: AppImage.gotoAlbum, type: .GotoAlbum),
            .init(title: ^String.MoreMenu.gotoArtist, icon: AppImage.gotoArtist, type: .GotoArtist),
            .init(title: ^String.MoreMenu.share, icon: AppImage.share, type: .Share)
        ]

        // Insert "Set Welcome Tune" at index 2 **only if GP exists**
        if hasGP {
            let welcomeTuneItem = MoreMenuModel(title: ^String.MoreMenu.SetAsWelcomeTune,
                                                icon: AppImage.SetAsWelcomeTune,
                                                type: .SetAsWelcomeTune)
            arr.insert(welcomeTuneItem, at: 2)
        }

        return arr
    }

}
