//
//  PlaylistSongs+CoreDataProperties.swift
//  
//
//  Created by Admin on 5/7/22.
//
//

import Foundation
import CoreData


extension PlaylistSongs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaylistSongs> {
        return NSFetchRequest<PlaylistSongs>(entityName: "PlaylistSongs")
    }

    @NSManaged public var playlistID: String?
    @NSManaged public var songID: String?

}
