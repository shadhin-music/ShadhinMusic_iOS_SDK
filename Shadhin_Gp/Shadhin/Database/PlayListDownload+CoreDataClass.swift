//
//  PlayListDownload+CoreDataClass.swift
//  
//
//  Created by Admin on 5/7/22.
//
//

import Foundation
import CoreData

@objc(PlayListDownload)
public class PlayListDownload: NSManagedObject {
    func getContentProtocal()-> CommonContent_V7{
        var content = CommonContent_V7()
        content.albumId = self.albumId
        content.artist = self.artist
        content.artistId = self.artistId
        content.contentID = self.contentID
        content.contentType = self.contentType
        //content.releaseDate = self.date
        //content.msisdn = self.msisdn
        content.duration = self.duration
        content.fav = self.favs
        content.image = self.imageURL
        //get local play url
        //let playURL = SDFileUtils.checkFileExists(urlName: self.playURL ?? "").fileString
        content.playUrl = self.playURL
        content.title = self.title
        content.isUserCreated = self.isUserCreated
        content.date = self.date
        return content
    }
    func setData(with content : CommonContent_V7){
        self.albumId = content.albumId
        self.artist = content.artist
        self.artistId = content.artistId
        self.contentID = content.contentID
        self.contentType = content.contentType
        self.duration = content.duration
        self.favs = content.fav
        self.imageURL = content.image
        //let playURL     = SDFileUtils.checkFileExists(urlName: content.playUrl!).fileString
        self.playURL = content.playUrl
        self.title = content.title
        self.date = Date()
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
        self.isUserCreated = content.isUserCreated
    }
    func setData(with content : CommonContentProtocol){
        self.albumId = content.albumId
        self.artist = content.artist
        self.artistId = content.artistId
        self.contentID = content.contentID
        self.contentType = content.contentType
        self.duration = content.duration
        self.favs = content.fav
        self.imageURL = content.image
        //let playURL     = SDFileUtils.checkFileExists(urlName: content.playUrl!).fileString
        self.playURL = content.playUrl
        self.title = content.title
        self.date = Date()
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
    }
}
