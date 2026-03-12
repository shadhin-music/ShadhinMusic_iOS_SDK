//
//  Database.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/24/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class RecentlyPlayedDatabase {
    static let instance = RecentlyPlayedDatabase()
    var context = CoreDataManager.shared.persistentContainer.viewContext
    
    var refreshListener: (() -> Void)?
    
    func insertData(musicData: CommonContentProtocol){
        guard let id = musicData.contentID else {return}
        let isDatabaseRecordExits = checkRecordExists(contentID: id)
        if isDatabaseRecordExits {
            updateDataToDatabase(musicData: musicData)
        }else {
            saveDataToDatabase(musicData: musicData)
        }
    }
    
    func saveDataToDatabase(musicData: CommonContentProtocol,_ nonBlockingLister: Bool = true) {
        let data = RecentlyPlayed(context: context)
        data.title = musicData.title
        data.artist = musicData.artist
        data.imageURL = musicData.image
        data.playURL = musicData.playUrl
        data.duration = musicData.duration
        data.contentID = musicData.contentID
        data.contentType = musicData.contentType
        data.favs = musicData.fav
        data.artistId = musicData.artistId
        data.albumId = musicData.albumId ?? ""
        data.isPaid = musicData.isPaid ?? false
        data.date = Date()
        
        do {
            try context.save()
            self.deleteMoreData()
            if let refreshListener = refreshListener, nonBlockingLister{
                refreshListener()
            }
        }catch {
            Log.error(error.localizedDescription)
        }
    }
    
    func updateDataToDatabase(musicData: CommonContentProtocol) {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentlyPlayed")
        fetchResult.predicate = NSPredicate(format: "contentID = %@", musicData.contentID ?? "")
        do {
            let allData = try context.fetch(fetchResult)
            let data = allData[0] as! RecentlyPlayed
            data.title = musicData.title
            data.artist = musicData.artist
            data.imageURL = musicData.image
            data.playURL = musicData.playUrl
            data.duration = musicData.duration
            data.contentID = musicData.contentID
            data.contentType = musicData.contentType
            data.favs = musicData.fav
            data.artistId = musicData.artistId ?? ""
            data.albumId = musicData.albumId ?? ""
            data.isPaid = musicData.isPaid ?? false
            data.date = Date()
            
            do {
                try context.save()
                if let refreshListener = refreshListener{
                    refreshListener()
                }
            }catch {
                Log.error(error.localizedDescription)
            }
            
        }catch {
            Log.error(error.localizedDescription)
        }
        
    }
    
    func checkRecordExists(contentID :String) -> Bool {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecentlyPlayed")
    fetchRequest.predicate = NSPredicate(format: "contentID = %@", contentID)
    
    var results: [NSManagedObject] = []
    
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            Log.error(error.localizedDescription)
        }
    
        return results.count > 0
    
    }
    
    func getDataFromDatabase(fetchLimit: Int) throws->[CommonContent_V7] {
        var dataC = [CommonContent_V7]()
        let fetchResult = RecentlyPlayed.fetchRequest() //NSFetchRequest<NSFetchRequestResult>(entityName: "RecentlyPlayed")
        fetchResult.returnsObjectsAsFaults = false
        fetchResult.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        if fetchLimit > 0{
            fetchResult.fetchLimit = fetchLimit
        }
        
        let allData = try context.fetch(fetchResult)
        
        if allData.count > 0 {
            for data in allData {
                if let type = data.contentType{

                    let title = data.title
                    let artist = data.artist
                    let img = data.imageURL
                    let playURL = data.playURL
                    let contentID = data.contentID
                    let duration = data.duration ?? "0"
                    let favs = data.favs
                    let artistId = data.artistId
                    let albumId = data.albumId
                    let isPaid = data.isPaid

                    let p = CommonContent_V7(
                        contentID: contentID,
                        contentType: type,
                        image: img,
                        title: title,
                        playUrl: playURL,
                        artist: artist,
                        artistId: artistId ?? "",
                        albumId: albumId,
                        duration: duration,
                        fav: favs,
                        isPaid: isPaid)
                    dataC.append(p)
                }
            }
        }
        
        return dataC
    }
    
    func deleteDataFromDatabase(contentID: String) {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentlyPlayed")
        fetchResult.predicate = NSPredicate(format: "contentID = %@", contentID)
        
        do {
            let objects = try context.fetch(fetchResult)
            for object in objects as! [NSManagedObject] {
                context.delete(object)
            }
            try context.save()
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    fileprivate func deleteMoreData() {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentlyPlayed")
        fetchResult.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let objects = try context.fetch(fetchResult)
            if objects.count > 25 {
                context.delete(objects.last as! NSManagedObject)
                try context.save()
            }
        } catch {
            Log.error(error.localizedDescription)
        }

    }
    
    struct RecentModel: Codable {
        let data: [RecentContentModel]
    }
    
    struct RecentContentModel: Codable,CommonContentProtocol {
        var rbtOperators: [String]?
        var templateFlag: Bool?
        var artistId: String?
        var artistImage: String?
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
        
        var hasRBT: Bool? = false
        var teaserUrl: String?
        var followers: String?
        
        enum CodingKeys: String,CodingKey {
            case contentID = "ContentId"
            case contentType = "ContentType"
            case image = "Image"
            case title = "Title"
            case playUrl = "PlayUrl"
            case artist = "Artist"
            case artistId = "artistId"
            case albumId = "albumId"
            case duration = "Duration"
            case fav
            case isPaid = "IsPaid"
            case trackType = "TrackType"
            case copyright
            case artistImage = "ArtistImage"
        }
    }
    
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            Log.error(error.localizedDescription)
        }
    }
    
    func addAllEntry(_ musicData: [CommonContentProtocol]){
        let count = musicData.count
        for i in 0..<count{
            saveDataToDatabase(musicData: musicData[i], false)
        }
    }
}


