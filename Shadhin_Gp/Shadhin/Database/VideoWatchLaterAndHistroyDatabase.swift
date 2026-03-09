//
//  VideoWatchLaterAndHistroyDatabase.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/21/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VideoWatchLaterAndHistroyDatabase {
    static let instance = VideoWatchLaterAndHistroyDatabase()
    var context = CoreDataManager.shared.persistentContainer.viewContext
    func saveDataToDatabase(videoData: [CommonContentProtocol],songIndex: Int,isHistory: Bool) {
        let dataModel = VideoHistoryAndWatchLater(context: context)
        dataModel.title = videoData[songIndex].title
        dataModel.artist = videoData[songIndex].artist
        dataModel.imageURL = videoData[songIndex].image
        dataModel.playURL = videoData[songIndex].playUrl
        dataModel.duration = videoData[songIndex].duration
        dataModel.contentID = videoData[songIndex].contentID
        dataModel.contentType = videoData[songIndex].contentType
        dataModel.favs = videoData[songIndex].fav
        dataModel.isHistory = isHistory
        dataModel.date = Date()
        
        do {
            try context.save()
        }catch {
            Log.error(error.localizedDescription)
        }
    }
    
    func updateDataToDatabase(videoData: [CommonContentProtocol],songIndex: Int,isHistory: Bool) {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoHistoryAndWatchLater")
        fetchResult.predicate = NSPredicate(format: "contentID = %@", videoData[songIndex].contentID ?? "")
        do {
            let allData = try context.fetch(fetchResult)
            let dataModel = allData[0] as! VideoHistoryAndWatchLater
            dataModel.title = videoData[songIndex].title
            dataModel.artist = videoData[songIndex].artist
            dataModel.imageURL = videoData[songIndex].image
            dataModel.playURL = videoData[songIndex].playUrl
            dataModel.duration = videoData[songIndex].duration
            dataModel.contentID = videoData[songIndex].contentID
            dataModel.contentType = videoData[songIndex].contentType
            dataModel.favs = videoData[songIndex].fav
            dataModel.isHistory = isHistory
            dataModel.date = Date()
            
            do {
                try context.save()
            }catch {
                Log.error(error.localizedDescription)
            }
            
        }catch {
            Log.error(error.localizedDescription)
        }
        
    }
    
    func checkRecordExists(contentID :String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "VideoHistoryAndWatchLater")
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
    
    func isWatchLater(contentID :String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "VideoHistoryAndWatchLater")
        fetchRequest.predicate = NSPredicate(format: "contentID = %@ && isHistory = false", contentID)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            Log.error(error.localizedDescription)
        }
        return results.count > 0
    }
    
    func getDataFromDatabase(isHistory: Bool) throws->[CommonContent_V7] {
        var dataC = [CommonContent_V7]()
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoHistoryAndWatchLater")
        fetchResult.returnsObjectsAsFaults = false
        fetchResult.predicate = NSPredicate(format: "isHistory = %d", isHistory)
        fetchResult.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let allData = try context.fetch(fetchResult)
        
        if allData.count > 0 {
            for data in allData as! [NSManagedObject] {
                let title = data.value(forKey: "title") as! String
                let artist = (data.value(forKey: "artist") as? String) ?? "" //got a crash in firebase
                let img = data.value(forKey: "imageURL") as! String
                let play = data.value(forKey: "playURL") as! String
                let contentID = data.value(forKey: "contentID") as! String
                let type = data.value(forKey: "contentType") as! String
                let duration = data.value(forKey: "duration") as? String
                let favs = data.value(forKey: "favs") as? String
                
                let p = CommonContent_V7(contentID: contentID, contentType: type, image: img, title: title, playUrl: play, artist: artist,artistId: "",albumId: "", duration: duration, fav: favs)
                dataC.append(p)
            }
        }
        
        return dataC
    }
    
    func deleteDataFromDatabase(contentID: String) {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoHistoryAndWatchLater")
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
}
