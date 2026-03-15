//
//  SongsDownload+CoreDataClass.swift
//  
//
//  Created by Admin on 23/6/22.
//
//

import Foundation
import CoreData

@objc(SongsDownload)
public class SongsDownload: NSManagedObject {
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
        let playURL = SDFileUtils.checkFileExists(urlName: self.playURL!).fileString
        content.playUrl = playURL
        content.title = self.title
        content.isSingleDownload = self.isSingleDownload
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
        self.isSingleDownload = content.isSingleDownload
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
        self.date = Date()
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
        self.isSingleDownload = true
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
        self.date = Date()
    }
}
