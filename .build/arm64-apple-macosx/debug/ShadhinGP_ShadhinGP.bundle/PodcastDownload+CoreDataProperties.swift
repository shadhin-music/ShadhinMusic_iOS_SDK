//
//  PodcastDownload+CoreDataProperties.swift
//  
//
//  Created by Admin on 3/7/22.
//
//

import Foundation
import CoreData


extension PodcastDownload {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PodcastDownload> {
        return NSFetchRequest<PodcastDownload>(entityName: "PodcastDownload")
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
    @NSManaged public var msisdn: String?
    @NSManaged public var playURL: String?
    @NSManaged public var title: String?

}
