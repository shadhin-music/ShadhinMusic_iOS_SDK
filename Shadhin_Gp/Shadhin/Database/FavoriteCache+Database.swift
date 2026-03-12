//
//  FavoriteCache+Database.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/29/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import CoreData
import UIKit

class FavoriteCacheDatabase{
    
    static let intance = FavoriteCacheDatabase()
    var context = CoreDataManager.shared.persistentContainer.viewContext
    
    private init(){}
    
    func save(){
        do{
            try context.save()
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    
    func getAllContentBy(type : SMContentType)->[CommonContentProtocol]{
        let fetchRequest = FavoriteCache.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        let all = try? context.fetch(fetchRequest)
        let items = all?.filter({$0.smContentType == type})
        return items ?? []
    }
    
    func addContent(content: CommonContentProtocol){
        if isFav(content: content){
            return
        }
        _ = FavoriteCache(context: context, content: content)
        self.save()
    }
    
    func deleteContent(content: CommonContentProtocol){
        guard let contentID = content.contentID, let contentType = content.contentType else {return}
        let fetchResult = FavoriteCache.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "contentID = %@ AND contentType = %@", contentID, contentType)
        do{
            guard let first = try context.fetch(fetchResult).first else {
                return
            }
            context.delete(first)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    
    
    func isFav(content : CommonContentProtocol)->Bool{
        guard let contentID = content.contentID, let contentType = content.contentType else {return false}
        let fetchResult = FavoriteCache.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "contentID = %@ AND contentType = %@", contentID, contentType)
        do{
            guard let _ = try context.fetch(fetchResult).first else {
                return false
            }
            return true
        }catch{
            Log.error(error.localizedDescription)
            return false
        }
    }
}
