//
//  VideoHistoryAndWatchLater+CoreDataProperties.swift
//  
//
//  Created by Admin on 21/6/22.
//
//

import Foundation
import CoreData


extension VideoHistoryAndWatchLater {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoHistoryAndWatchLater> {
        return NSFetchRequest<VideoHistoryAndWatchLater>(entityName: "VideoHistoryAndWatchLater")
    }

    @NSManaged public var artist: String?
    @NSManaged public var contentID: String?
    @NSManaged public var contentType: String?
    @NSManaged public var date: Date?
    @NSManaged public var duration: String?
    @NSManaged public var favs: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isHistory: Bool
    @NSManaged public var playURL: String?
    @NSManaged public var title: String?

}
