//
//  FavoriteCache+CoreDataClass.swift
//  
//
//  Created by Gakk Alpha on 8/29/22.
//
//

import Foundation
import CoreData

@objc(FavoriteCache)
public class FavoriteCache: NSManagedObject {
    
    convenience init(context moc: NSManagedObjectContext, content: CommonContentProtocol){
        self.init(context: moc)
        self.setData(with: content)
    }
    
    func setData(with content : CommonContentProtocol){
        self.followers = content.followers
        self.teaserUrl = content.teaserUrl
        self.hasRBT = content.hasRBT ?? false
        self.releaseDate = content.releaseDate
        self.labelname = content.labelname
        self.copyright = content.copyright
        self.isPaid = content.isPaid
        self.trackType = content.trackType
        self.playCount = content.playCount
        self.fav = content.fav
        self.contentType = content.contentType
        self.crudDate = Date()
        self.duration = content.duration
        self.albumId = content.albumId
        self.artistId = content.artistId
        self.artist = content.artist
        self.playUrl = content.playUrl
        self.title = content.title
        self.newBannerImg = content.newBannerImg
        self.image = content.image
        self.contentID = content.contentID
    }
    
}
