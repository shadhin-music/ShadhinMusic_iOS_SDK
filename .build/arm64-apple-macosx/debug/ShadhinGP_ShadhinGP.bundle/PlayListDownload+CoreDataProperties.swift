//
//  PlayListDownload+CoreDataProperties.swift
//  
//
//  Created by Admin on 5/7/22.
//
//

import Foundation
import CoreData


extension PlayListDownload {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayListDownload> {
        return NSFetchRequest<PlayListDownload>(entityName: "PlayListDownload")
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
    @NSManaged public var isUserCreated  : Bool

}

// MARK: Generated accessors for songs
extension PlayListDownload {

    @objc(addSongsObject:)
    @NSManaged public func addToSongs(_ value: PlaylistSongs)

    @objc(removeSongsObject:)
    @NSManaged public func removeFromSongs(_ value: PlaylistSongs)

    @objc(addSongs:)
    @NSManaged public func addToSongs(_ values: NSSet)

    @objc(removeSongs:)
    @NSManaged public func removeFromSongs(_ values: NSSet)

}
