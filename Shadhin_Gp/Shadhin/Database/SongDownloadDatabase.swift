//
//  SongDownloadDatabase.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/1/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SongsDownloadDatabase {
    static let instance = SongsDownloadDatabase()
    
    var context = CoreDataManager.shared.persistentContainer.viewContext
    
    func saveDataToDatabase(musicData: CommonContentProtocol, isSingleDownload : Bool = true) {
        
        if DatabaseContext.shared.isSongExist(contentId: musicData.contentID!){
            return
        }
        
        let data         = SongsDownload(context: context)
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
        data.msisdn      = ShadhinCore.instance.defaults.userIdentity
        data.date        = Date()
        data.isSingleDownload = isSingleDownload
        do {
            try context.save()
        }catch {
            Log.error(error.localizedDescription)
        }
    }
    
    
    func getDataFromDatabase() throws->[CommonContent_V7] {
        let msisdn = ShadhinCore.instance.defaults.userIdentity
        var dataC = [CommonContent_V7]()
        guard !msisdn.isEmpty else {return dataC}
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "SongsDownload")
        fetchResult.returnsObjectsAsFaults = false
        fetchResult.predicate = NSPredicate(format: "msisdn = %@", msisdn)
        fetchResult.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let allData = try context.fetch(fetchResult)
        
        if allData.count > 0 {
            for data in allData as! [NSManagedObject] {
                let title       = data.value(forKey: "title") as! String
                var artist      = ""
                if data.value(forKey: "artist" ) != nil{
                    artist      = data.value(forKey: "artist") as! String
                }
                let img         = data.value(forKey: "imageURL") as! String
                let play        = data.value(forKey: "playURL") as! String
                let contentID   = data.value(forKey: "contentID") as! String
                let type        = data.value(forKey: "contentType") as! String
                let duration    = data.value(forKey: "duration") as! String
                let favs        = data.value(forKey: "favs") as? String
                let artistId    = data.value(forKey: "artistId") as? String
                let albumId     = data.value(forKey: "albumId") as? String
                //let msisdn      = data.value(forKey: "msisdn") as? String
                
                
                let playURL     = SDFileUtils.checkFileExists(urlName: play).fileString
                
                let p           = CommonContent_V7(contentID: contentID, contentType: type, image: img, title: title, playUrl: playURL, artist: artist,artistId: artistId,albumId: albumId, duration: duration, fav: favs)
                
                dataC.append(p)
            }
        }
        
        return dataC
    }
    
    func deleteDataFromDatabase(contentID: String) {
        let fetchResult       = NSFetchRequest<NSFetchRequestResult>(entityName: "SongsDownload")
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
    
    func getDataFromDatabase(contentId: String)-> CommonContentProtocol?{
        
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "SongsDownload")
        fetchResult.predicate = NSPredicate(format: "contentID = %@ AND msisdn = %@", contentId, ShadhinCore.instance.defaults.userIdentity)
        
        do {
            let objects = try context.fetch(fetchResult)
            for object in objects as! [NSManagedObject] {
                let title       = object.value(forKey: "title") as! String
                var artist      = ""
                if object.value(forKey: "artist" ) != nil{
                    artist      = object.value(forKey: "artist") as! String
                }
                let img         = object.value(forKey: "imageURL") as! String
                let play        = object.value(forKey: "playURL") as! String
                let contentID   = object.value(forKey: "contentID") as! String
                let type        = object.value(forKey: "contentType") as! String
                let duration    = object.value(forKey: "duration") as! String
                let favs        = object.value(forKey: "favs") as? String
                let artistId    = object.value(forKey: "artistId") as? String
                let albumId     = object.value(forKey: "albumId") as? String
                
                let playURL     = SDFileUtils.checkFileExists(urlName: play).fileString
                
                let item = CommonContent_V7(contentID: contentID, contentType: type, image: img, title: title, playUrl: playURL, artist: artist,artistId: artistId,albumId: albumId, duration: duration, fav: favs)
                return item
            }
        } catch {
            Log.error(error.localizedDescription)
        }
        return nil
    }
    
    func checkAndUpdateMsisdn(){
        let msisdn = ShadhinCore.instance.defaults.userIdentity
        guard !msisdn.isEmpty else {return}
        
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "SongsDownload")
        fetchResult.returnsObjectsAsFaults = false
        var saveIsNeeded = false
        let allDataOpt = try? context.fetch(fetchResult)
        
        if let allData = allDataOpt, allData.count > 0 {
            for data in allData as! [SongsDownload] {
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

