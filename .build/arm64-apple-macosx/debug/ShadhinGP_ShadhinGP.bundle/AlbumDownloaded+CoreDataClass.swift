//
//  AlbumDownloaded+CoreDataClass.swift
//  
//
//  Created by Admin on 26/6/22.
//
//

import Foundation
import CoreData

@objc(AlbumDownloaded)
public class AlbumDownloaded: NSManagedObject {
    func getContentProtocal()-> CommonContent_V7{
        var content = CommonContent_V7()
        content.albumId = self.albumId
        content.artist = self.artist
        content.artistId = self.artistId
        content.contentID = self.contentID
        content.contentType = self.contentType
        //content.releaseDate = self.date
        //content.msisdn = self.msisdn
        content.image = self.imageURL
        content.title = self.title
        content.isDownloading = self.isDownloading
        content.date = self.date
        return content
    }
    func setData(with content : CommonContent_V7){
        self.albumId = (content.albumId != nil && !content.artist!.isEmpty) ? content.albumId : content.contentID
        self.artist = content.artist
        self.artistId = content.artistId
        self.contentID = content.contentID
        self.contentType = content.contentType
        self.imageURL = content.image
        self.title = content.title
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
        self.isDownloading = true
        self.date = Date()
    }
    func setData(with content : CommonContentProtocol){
        self.albumId = (content.albumId != nil && !content.artist!.isEmpty) ? content.albumId : content.contentID
        self.artist = content.artist
        self.artistId = content.artistId
        self.contentID = content.contentID
        self.contentType = content.contentType
        self.imageURL = content.image
        self.title = content.title
        self.msisdn = ShadhinCore.instance.defaults.userIdentity
        self.isDownloading = true
        self.date  = Date()
    }
}
