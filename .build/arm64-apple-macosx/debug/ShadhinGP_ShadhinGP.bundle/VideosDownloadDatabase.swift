//
//  VideosDownloadDatabase.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 3/5/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit
import CoreData

class VideosDownloadDatabase {
    
    static let instance = VideosDownloadDatabase()
    
    var context = CoreDataManager.shared.persistentContainer.viewContext
    
    func saveDataToDatabase(musicData: CommonContentProtocol) {
        if isDownloaded(contentID: musicData.contentID ?? ""){
            return
        }
        let data         = VideosDownload(context: context)
        data.title       = musicData.title
        data.artist      = musicData.artist
        data.imageURL    = musicData.image
        data.playURL     = musicData.playUrl
        data.duration    = musicData.duration
        data.contentID   = musicData.contentID
        data.contentType = musicData.contentType
        data.favs        = musicData.fav
        data.artistId    = musicData.artistId ?? ""
        data.albumId     = musicData.albumId ?? ""
        data.date        = Date()
        
        do {
            try context.save()
        }catch {
            Log.error(error.localizedDescription)
        }
    }
    
    func getDataFromDatabase() throws->[CommonContent_V7] {
        var dataC = [CommonContent_V7]()
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "VideosDownload")
        fetchResult.returnsObjectsAsFaults = false
        fetchResult.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let allData = try context.fetch(fetchResult)
        
        if allData.count > 0 {
            for data in allData as! [NSManagedObject] {
                let title       = data.value(forKey: "title") as! String
                let artist      = data.value(forKey: "artist") as! String
                let img         = data.value(forKey: "imageURL") as! String
                let play        = data.value(forKey: "playURL") as! String
                let contentID   = data.value(forKey: "contentID") as! String
                let type        = data.value(forKey: "contentType") as! String
                let duration    = data.value(forKey: "duration") as! String
                let favs        = data.value(forKey: "favs") as? String
                let artistId    = data.value(forKey: "artistId") as? String
                let albumId     = data.value(forKey: "albumId") as? String
                
                let playURL = SDFileUtils.checkFileExists(urlName: play).fileString
                
                let p = CommonContent_V7(contentID: contentID, contentType: type, image: img, title: title, playUrl: playURL, artist: artist,artistId: artistId,albumId: albumId, duration: duration, fav: favs)
                dataC.append(p)
            }
        }
        return dataC
    }
    
    func deleteDataFromDatabase(contentID: String) {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "VideosDownload")
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
    
    
    func isDownloaded(contentID :String) -> Bool {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "VideosDownload")
        fetchResult.predicate = NSPredicate(format: "contentID = %@", contentID)
        var results: [NSFetchRequestResult] = []
        do {
            results = try context.fetch(fetchResult)
        }
        catch {
            Log.error(error.localizedDescription)
        }
        return results.count > 0
    }
    
    
    func checkAndUpdateMsisdn(){
        let msisdn = ShadhinCore.instance.defaults.userIdentity
        guard !msisdn.isEmpty else {return}
        
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "VideosDownload")
        fetchResult.returnsObjectsAsFaults = false
        var saveIsNeeded = false
        let allDataOpt = try? context.fetch(fetchResult)
        
        if let allData = allDataOpt, allData.count > 0 {
            for data in allData as! [VideosDownload] {
                if data.msisdn == nil{
                    saveIsNeeded = true
                    data.msisdn = msisdn
                }
            }
            if saveIsNeeded{
                try? context.save()
            }
        }
    }
    
}
