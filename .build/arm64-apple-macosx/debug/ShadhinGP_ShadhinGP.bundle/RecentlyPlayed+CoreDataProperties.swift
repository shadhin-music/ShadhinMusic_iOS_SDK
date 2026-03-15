//
//  RecentlyPlayed+CoreDataProperties.swift
//  
//
//  Created by Admin on 21/6/22.
//
//

import Foundation
import CoreData


extension RecentlyPlayed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecentlyPlayed> {
        return NSFetchRequest<RecentlyPlayed>(entityName: "RecentlyPlayed")
    }

    @NSManaged public var albumId: String?
    @NSManaged public var artist: String?
    @NSManaged public var artistId: String?
    @NSManaged public var contentID: String?
    @NSManaged public var contentType: String?
    @NSManaged public var date: Date?
    @NSManaged public var duration: String?
    @NSManaged public var favs: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isPaid: Bool
    @NSManaged public var playURL: String?
    @NSManaged public var title: String?

}
