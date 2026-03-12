//
//  AlbumMyMusic+CoreDataProperties.swift
//  
//
//  Created by Gakk Alpha on 6/29/22.
//
//

import Foundation
import CoreData


extension AlbumMyMusic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlbumMyMusic> {
        return NSFetchRequest<AlbumMyMusic>(entityName: "AlbumMyMusic")
    }

    @NSManaged public var albumId: String?
    @NSManaged public var artist: String?
    @NSManaged public var artistId: String?
    @NSManaged public var contentID: String?
    @NSManaged public var contentType: String?
    @NSManaged public var date: Date?
    @NSManaged public var imageURL: String?
    @NSManaged public var title: String?

}
