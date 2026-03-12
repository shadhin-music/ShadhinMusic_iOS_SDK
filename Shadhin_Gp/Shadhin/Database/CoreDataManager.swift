//
//  CoreDataManager.swift
//  Shadhin_Gp
//
//  Created by Maruf on 11/6/24.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private let identifier: String  = Bundle.ShadhinMusicSdk.bundleIdentifier!     //Your framework bundle ID
    private let model: String       = "MusicDataModel 2"                      //Model name
    
    lazy var persistentContainer: NSPersistentContainer = {
            let messageKitBundle = Bundle(identifier: self.identifier)
            let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!
            let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
            let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
            container.loadPersistentStores { (storeDescription, error) in
                
                if let err = error{
                    fatalError("❌ Loading of store failed:\(err)")
                }else{
                    Log.info("persistentContainer Load")
                }
            }
            
            return container
        }()
    func reset() throws{
        let storeContainer =
            persistentContainer.persistentStoreCoordinator
        // Delete each existing persistent store
        for store in storeContainer.persistentStores {
            try storeContainer.destroyPersistentStore(
                at: store.url!,
                ofType: store.type,
                options: nil
            )
        }
        
    }
}
