//
//  MenuLoaderMV4.swift
//  Shadhin
//
//  Created by Joy on 19/3/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation

enum MoreMenuTypeMusicV4: String{
    case AddToPlaylist = "Add To Playlist"
    case RemoveFromPlaylist = "Remove From Playlist"
    case QueueList = "Queue List"
    case SleepTimer = "Sleep Timer"
    case SleepTimerOn = "Sleep Timer On"
    case GotoArtist = "Go To Artist"
    case GotoAlbum = "Go To Album"
    case share
    case gotoPodcast = "Go To Podcast"
}
struct MoreMenuItemMusicV4{
    var name : String
    var icon : AppImage
    var type : MoreMenuTypeMusicV4
}

struct MenuLoaderMV4{
    static func getMenu(isPodcast : Bool = false)->[MoreMenuItemMusicV4]{
        var arr : [MoreMenuItemMusicV4] = []
        if isPodcast{
            //arr.append(.init(name: "Queue List", icon: .queueListMV4, type: .QueueList))
            
            switch ShadhinPlayerSleepTimer.instance.currentState{
            case .off:
                arr.append(.init(name: "Sleep Timer", icon: .sleepTimerMV4, type: .SleepTimer))
            case .tenMinutes:
                arr.append(.init(name: "Sleep after 10 minutes", icon: .sleepTimeOnMV4, type: .SleepTimer))
            case .twentyMinutes:
                arr.append(.init(name: "Sleep after 20 minutes", icon: .sleepTimeOnMV4, type: .SleepTimer))
            case .thirtyMinutes:
                arr.append(.init(name: "Sleep after 30 minutes", icon: .sleepTimeOnMV4, type: .SleepTimer))
            case .sixtyMinutes:
                arr.append(.init(name: "Sleep after 1 hour", icon: .sleepTimeOnMV4, type: .SleepTimer))
            case .custom(let min):
                arr.append(.init(name: "Sleep after \(min) minutes", icon: .sleepTimeOnMV4, type: .SleepTimer))
            }
            
            
            arr.append(.init(name: "Goto Podcast", icon: .podcastMV4, type: .gotoPodcast))
            arr.append(.init(name: "Share Podcast", icon: .shareMV4, type: .share))
            
            return arr
        }
        arr.append(.init(name: "Add to Playlist", icon: .addPlaylistMV4, type: .AddToPlaylist))
        //arr.append(.init(name: "Queue List", icon: .queueListMV4, type: .QueueList))
        switch ShadhinPlayerSleepTimer.instance.currentState{
        case .off:
            arr.append(.init(name: "Sleep Timer", icon: .sleepTimerMV4, type: .SleepTimer))
        case .tenMinutes:
            arr.append(.init(name: "Sleep after 10 minutes", icon: .sleepTimeOnMV4, type: .SleepTimer))
        case .twentyMinutes:
            arr.append(.init(name: "Sleep after 20 minutes", icon: .sleepTimeOnMV4, type: .SleepTimer))
        case .thirtyMinutes:
            arr.append(.init(name: "Sleep after 30 minutes", icon: .sleepTimeOnMV4, type: .SleepTimer))
        case .sixtyMinutes:
            arr.append(.init(name: "Sleep after 1 hour", icon: .sleepTimeOnMV4, type: .SleepTimer))
        case .custom(let min):
            arr.append(.init(name: "Sleep after \(min) minutes", icon: .sleepTimeOnMV4, type: .SleepTimer))
        }
        arr.append(.init(name: "Goto Artist", icon: .gotoArtistMV4, type: .GotoArtist))
        arr.append(.init(name: "Share", icon: .shareMV4, type: .share))
        
        return arr
    }
}
