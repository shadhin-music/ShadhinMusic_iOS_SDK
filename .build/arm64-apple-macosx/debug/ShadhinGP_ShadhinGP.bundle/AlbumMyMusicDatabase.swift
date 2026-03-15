//
//  AlbumMyMusicDatabase.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/26/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import CoreData

class AlbumMyMusicDatabase {
    static let instance = AlbumMyMusicDatabase()
    var context = CoreDataManager.shared.persistentContainer.viewContext
    
    func saveDataToDatabase(model: CommonContentProtocol) {
        let dataModel = AlbumMyMusic(context: context)
        dataModel.title = model.title
        dataModel.artist = model.artist
        dataModel.imageURL = model.image
        dataModel.contentID = model.contentID
        dataModel.contentType = model.contentType
        dataModel.artistId = model.artistId
        dataModel.albumId = model.albumId
        dataModel.date = Date()
        
        do {
            try context.save()
        }catch {
            Log.error(error.localizedDescription)
        }
    }
    
    func updateDataToDatabase(model: CommonContentProtocol) {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "AlbumMyMusic")
        fetchResult.predicate = NSPredicate(format: "contentID = %@", model.contentID ?? "")
        do {
            let allData = try context.fetch(fetchResult)
            let dataModel = allData[0] as! AlbumMyMusic
            dataModel.title = model.title
            dataModel.artist = model.artist
            dataModel.imageURL = model.image
            dataModel.contentID = model.contentID
            dataModel.contentType = model.contentType
            dataModel.artistId = model.artistId
            dataModel.albumId = model.albumId
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
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AlbumMyMusic")
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
    
    func getDataFromDatabase() throws->[AlbumMyMusic]? {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "AlbumMyMusic")
        fetchResult.returnsObjectsAsFaults = false
        fetchResult.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let allData = try context.fetch(fetchResult)
        
        if allData.count > 0 {
            let data = allData as? [AlbumMyMusic]
            return data
        }else {
            return []
        }
    }
    
    func deleteDataFromDatabase(contentID: String) {
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "AlbumMyMusic")
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


