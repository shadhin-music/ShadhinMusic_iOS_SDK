//
//  DatabaseContext.swift
//  Shadhin
//
//  Created by Admin on 21/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import CoreData

class DatabaseContext: NSObject {
    static let shared = DatabaseContext()
    private override init() {
        
    }
    
    var context = CoreDataManager.shared.persistentContainer.viewContext
    //fetch album songs
    func getSonngsByAlbum(where contentID : String) -> [CommonContent_V1]{
        var data : [ CommonContent_V1] = []
        let msisdn = ShadhinCore.instance.defaults.userIdentity
        guard !msisdn.isEmpty else {return data}
        let fetchRequest = SongsDownload.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        //todo
        //predicate not working if i set album id
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ ", msisdn)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do{
            let fetchResult = try context.fetch(fetchRequest)
            fetchResult.forEach { song in
                if song.albumId == contentID{
                    data.append(song.getContentProtocal().getAlbumAndPlaylistData())
                }
            }
        }catch{
            Log.error(error.localizedDescription)
        }
        
        return data
    }
    //fetch artistSonngs
    func getSonngsByArtist(where artistId : String) -> [CommonContent_V2]{
        var data : [ CommonContent_V2] = []
        let msisdn = ShadhinCore.instance.defaults.userIdentity
        guard !msisdn.isEmpty else {return data}
        let fetchRequest = SongsDownload.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        //todo
        //predicate not working if i set album id
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND artistId = %@", msisdn,artistId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do{
            let fetchResult = try context.fetch(fetchRequest)
            fetchResult.forEach { song in
                if song.artistId == artistId{
                    data.append(song.getContentProtocal().getArtistData())
                }
            }
        }catch{
            Log.error(error.localizedDescription)
        }
        
        return data
    }
    func getSongBy(id contentID : String)-> CommonContentProtocol?{
        let msisdn = ShadhinCore.instance.defaults.userIdentity
        let fetchRequest = SongsDownload.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", msisdn,contentID)
        do{
            return try context.fetch(fetchRequest).first?.getContentProtocal()
        }catch{
            Log.error(error.localizedDescription)
            return nil
        }
    }
    func getSongBy(songID contentID : String)-> CommonContent_V7?{
        let msisdn = ShadhinCore.instance.defaults.userIdentity
        let fetchRequest = SongsDownload.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", msisdn,contentID)
        do{
            return try context.fetch(fetchRequest).first?.getContentProtocal()
        }catch{
            Log.error(error.localizedDescription)
            return nil
        }
    }
    //songs fetch
    func getSongs()throws -> [CommonContent_V7] {
        let msisdn = ShadhinCore.instance.defaults.userIdentity
        var data : [CommonContent_V7] = []
        guard !msisdn.isEmpty else {return data}
        let fetchRequest = SongsDownload.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND isSingleDownload = %d", msisdn,true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let fetchResult = try context.fetch(fetchRequest)
        fetchResult.forEach { song in
            data.append(song.getContentProtocal())
        }
        return data
    }
    //check songs by user and content id
    func isSongExist(contentId id : String) throws -> SongsDownload?{
        let fetchResult = SongsDownload.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "contentID = %@ AND msisdn = %@", id, ShadhinCore.instance.defaults.userIdentity)
        let res =  try context.fetch(fetchResult).first
        return res
    }
    func isSongExist(contentId id : String)  -> Bool{
        let fetchResult = SongsDownload.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", ShadhinCore.instance.defaults.userIdentity,id)
        do{
            let allSongs =  try context.fetch(fetchResult)
            if let _ = allSongs.first(where: { ss in
                return ss.contentID == id
            }){
                return true
            }
            
            return false
        }catch{
            Log.error(error.localizedDescription)
            return false
        }
    }
    //adds song after download
    func addSong(content : CommonContent_V7, isSingleDownload : Bool = true, batchDownload : Bool = false){
        if isSongExist(contentId: content.contentID ?? ""){
            //update isSingleDownload parameter based on batch download
            if batchDownload{
                //update here
            }
            return
        }
        
        let song = SongsDownload(context: context)
        song.setData(with: content)
        song.isSingleDownload = isSingleDownload
        song.date = Date()
        self.save()
        let fetc = SongsDownload.fetchRequest()
        do{
            let count = try context.count(for: fetc)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    //adds song after download
    func addSong(content : CommonContentProtocol, isSingleDownload : Bool = true){
        if isSongExist(contentId: content.contentID ?? ""){
            return
        }
        
        let song = SongsDownload(context: context)
        song.setData(with: content)
        song.isSingleDownload = isSingleDownload
        song.date = Date()
        self.save()
        let fetc = SongsDownload.fetchRequest()
        do{
            let count = try context.count(for: fetc)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    //delete songs where album id match and is not single download
    func deleteSongsByAlbum(where albumId : String){
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = SongsDownload.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND albumId = %@", ShadhinCore.instance.defaults.userIdentity,albumId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try context.execute(deleteRequest)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    //song delete by artist id 
    func deleteSongsByArtist(where artistId : String){
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = SongsDownload.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND artistId = %@", ShadhinCore.instance.defaults.userIdentity,artistId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try context.execute(deleteRequest)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    
    func deleteSong(where contentID : String){
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = SongsDownload.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", ShadhinCore.instance.defaults.userIdentity,contentID)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try context.execute(deleteRequest)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
}
//MARK: Download Remaing database handler
extension DatabaseContext{
    func isDownloadExist(contentID : String)-> Bool{
        let fetchResult = DownloadRemaing.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", ShadhinCore.instance.defaults.userIdentity,contentID)
        do{
            if let exist = try context.fetch(fetchResult).first{
                exist.error = false
                save()
                Log.warning("This content all ready in download queue")
                return true
            }
        }catch{
            Log.error(error.localizedDescription)
        }
        return false
    }
    func isAlbumDownloading(albumId id: String)-> Bool{
        let fetchResult = DownloadRemaing.fetchRequest()
        do{
            let res = try context.fetch(fetchResult)
            if let _ = res.first(where: { dd in
                return dd.albumId == id
            }){
                return true
            }
            
        }catch{
            Log.error(error.localizedDescription)
        }
        return false
    }
    func isArtistDownloading(artistId id: String)-> Bool{
        let fetchResult = DownloadRemaing.fetchRequest()
        do{
            let res = try context.fetch(fetchResult)
            if let _ = res.first(where: { dd in
                return dd.artistId == id
            }){
                return true
            }
        }catch{
            Log.error(error.localizedDescription)
        }
        return false
    }
    func isPlaylistDownloading(playlistID id: String)-> Bool{
        let fetchResult = DownloadRemaing.fetchRequest()
        do{
            let res = try context.fetch(fetchResult)
            if let _ = res.first(where: { dd in
                return dd.playlistID == id
            }){
                return true
            }
        }catch{
            Log.error(error.localizedDescription)
        }
        return false
    }
    func updateAllDownloadDatabase(){
        let fetchResult = DownloadRemaing.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "msisdn = %@ AND error = %d", ShadhinCore.instance.defaults.userIdentity,true)
        do{
            let all = try context.fetch(fetchResult)
            all.forEach { obj in
                obj.error =  false
            }
            try context.save()
        }catch{
            Log.error(error.localizedDescription)
        }
        
        
    }
    func getRemaingDownload() -> DownloadRemaing?{
        let fetchResult = DownloadRemaing.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "msisdn = %@ AND error = %d", ShadhinCore.instance.defaults.userIdentity,false)
        fetchResult.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do{
            guard let first = try context.fetch(fetchResult).first else {
                return nil
            }
            return first
        }catch{
            Log.error(error.localizedDescription)
        }
        
        return nil
    }
    func addDownload(content : CommonContent_V7){
        if isDownloadExist(contentID: content.contentID!){
            return
        }
        let download = DownloadRemaing(context: context)
        download.setData(with: content)
        self.save()
        
    }
    func addDownload(content : CommonContentProtocol,playlistID : String? = nil,isSingleDownload : Bool = false){
        
        if isDownloadExist(contentID: content.contentID!){
            
            return
        }
        
        let download = DownloadRemaing(context: context)
        download.setData(with: content)
        download.playlistID = playlistID
        download.isSingleDownload =  isSingleDownload
        self.save()
        
    }
    func downloadRemaingBatchDelete(where albumId : String){
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = DownloadRemaing.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND albumId = %@", ShadhinCore.instance.defaults.userIdentity,albumId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest) //NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do{
            try context.execute(deleteRequest)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    func downloadRemaingBatchDeleteArtist(where artistId : String){
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = DownloadRemaing.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND artistId = %@", ShadhinCore.instance.defaults.userIdentity,artistId)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest) //NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do{
            try context.execute(deleteRequest)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    func downloadRemaingBatchDeleteByPlayList(where playlistID : String){
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = DownloadRemaing.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND playlistID = %@", ShadhinCore.instance.defaults.userIdentity,playlistID)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest) //NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do{
            try context.execute(deleteRequest)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    func delete(obj : DownloadRemaing){
        context.delete(obj)
    }
}
extension DatabaseContext{
    func save(){
        do{
            try context.save()
            //context.refreshAllObjects()
        }catch{
            Log.error(error.localizedDescription)
        }
    }
}

//MARK: Album download truck
extension DatabaseContext{
    func getAlbums() throws-> [CommonContent_V7]{
        let fetchRequest = AlbumDownloaded.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@", ShadhinCore.instance.defaults.userIdentity)
        fetchRequest.returnsObjectsAsFaults = false
        var data : [CommonContent_V7] = []
        let all = try context.fetch(fetchRequest)
        all.forEach { dd in
            data.append(dd.getContentProtocal())
        }
        return data
    }
    func isAlbumExist(for contentID : String)-> Bool{
        let fetchResult = AlbumDownloaded.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", ShadhinCore.instance.defaults.userIdentity,contentID)
        do{
            guard let _ = try context.fetch(fetchResult).first else {
                return false
            }
            return true
        }catch{
            Log.error(error.localizedDescription)
        }
        return false
    }
    func addAlbum(with data : CommonContent_V7){
        if isAlbumExist(for: data.contentID ?? ""){
            return
        }
        let album = AlbumDownloaded(context: context)
        album.setData(with: data)
        self.save()
    }
    func addAlbum(with data : CommonContentProtocol){
        if isAlbumExist(for: data.contentID ?? ""){
            return
        }
        let album = AlbumDownloaded(context: context)
        album.setData(with: data)
        self.save()
    }
    func deleteAlbum(where albumId : String){
        let fetchResult = AlbumDownloaded.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "msisdn = %@ AND albumId = %@", ShadhinCore.instance.defaults.userIdentity,albumId)
        do{
            guard let first = try context.fetch(fetchResult).first else {
                return
            }
            context.delete(first)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    func delete(obj : AlbumDownloaded){
        context.delete(obj)
    }
}
//MARK: Artist database handler
extension DatabaseContext {
    func addArtist(content : CommonContentProtocol){
        if isArtistExist(for: content.contentID ?? ""){
            return
        }
        let artist = ArtistDownloaded(context: context)
        artist.setData(with: content)
        self.save()
    }
    func addArtist(content : CommonContent_V7){
        if isArtistExist(for: content.contentID ?? ""){
            return
        }
        let artist = ArtistDownloaded(context: context)
        artist.setData(with: content)
        self.save()
    }
    func getArtist() throws-> [CommonContent_V7]{
        let fetchRequest = ArtistDownloaded.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@", ShadhinCore.instance.defaults.userIdentity)
        fetchRequest.returnsObjectsAsFaults = false
        var data : [CommonContent_V7] = []
        let all = try context.fetch(fetchRequest)
        all.forEach { dd in
            data.append(dd.getContentProtocal())
        }
        return data
    }
    func isArtistExist(for artistId : String)-> Bool{
        let fetchResult = ArtistDownloaded.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "msisdn = %@ AND artistId = %@", ShadhinCore.instance.defaults.userIdentity,artistId)
        do{
            guard let _ = try context.fetch(fetchResult).first else {
                return false
            }
            return true
        }catch{
            Log.error(error.localizedDescription)
        }
        return false
    }
    func numberOfSongsForArtistBy(artistId contentID : String)-> Int{
        let fetchResult = SongsDownload.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "msisdn = %@ AND artistId = %@", ShadhinCore.instance.defaults.userIdentity,contentID)
        fetchResult.returnsObjectsAsFaults = false
        
        do{
            return try context.count(for: fetchResult)
        }catch{
            Log.error(error.localizedDescription)
        }
        return  0
    }
    func deleteArtist(where artistId : String){
        let fetchResult = ArtistDownloaded.fetchRequest()
        fetchResult.predicate = NSPredicate(format: "msisdn = %@ AND artistId = %@", ShadhinCore.instance.defaults.userIdentity,artistId)
        do{
            guard let first = try context.fetch(fetchResult).first else {
                return
            }
            context.delete(first)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    func delete(obj : ArtistDownloaded){
        context.delete(obj)
    }
}

//MARK: Podcast
extension DatabaseContext{
    func addPodcast(content : CommonContentProtocol){
        if isPodcastExist(where: content.contentID ?? ""){
            return
        }
        let podcast = PodcastDownload(context: context)
        podcast.setData(with: content)
        self.save()
    }
    func addPodcast(content : CommonContent_V7){
        if isPodcastExist(where: content.contentID ?? ""){
            return
        }
        let podcast = PodcastDownload(context: context)
        podcast.setData(with: content)
        self.save()
    }
    func getPodcastBy(id contentID : String)-> CommonContentProtocol?{
        let fetchRequest = PodcastDownload.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", ShadhinCore.instance.defaults.userIdentity,contentID)
        fetchRequest.returnsObjectsAsFaults = false
        do{
            return try context.fetch(fetchRequest).first?.getContentProtocal()
        }catch{
            Log.error(error.localizedDescription)
            return nil
        }
    }
    func getAllPodcast()throws ->[CommonContent_V7]{
        let fetchRequest = PodcastDownload.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@", ShadhinCore.instance.defaults.userIdentity)
        fetchRequest.returnsObjectsAsFaults = false
        var data : [CommonContent_V7] = []
        let all = try context.fetch(fetchRequest)
        all.forEach { dd in
            data.append(dd.getContentProtocal())
        }
        return data
    }
    func isPodcastExist(where contentID : String)->  Bool{
        let fetchRequest = PodcastDownload.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", ShadhinCore.instance.defaults.userIdentity,contentID)
        fetchRequest.returnsObjectsAsFaults = false
        do{
            if let _ = try context.fetch(fetchRequest).first {
                return true
            }
            return false
        }catch{
            Log.error(error.localizedDescription)
        }
        return false
    }
    func removePodcast(with contentID : String){
        let fetchRequest : NSFetchRequest<NSFetchRequestResult>  = PodcastDownload.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", ShadhinCore.instance.defaults.userIdentity,contentID)
        fetchRequest.returnsObjectsAsFaults = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try context.execute(deleteRequest)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
}

//MARK: playlist databbase operations
extension DatabaseContext {
    func isPlaylistExist(playlistID contentId : String) -> Bool{
        let fetchRequest = PlayListDownload.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", ShadhinCore.instance.defaults.userIdentity,contentId)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 1
        do{
            let obj = try context.fetch(fetchRequest).first
            if obj != nil{
                return true
            }
        }catch{
            Log.error(error.localizedDescription)
        }
        return false
    }
    func addPlaylist(content : CommonContentProtocol){
        if isPlaylistExist(playlistID: content.contentID  ?? ""){
            return
        }
        let playlist = PlayListDownload(context: context)
        playlist.setData(with: content)
        self.save()
    }
    func addPlaylist(content : CommonContent_V7){
        if isPlaylistExist(playlistID: content.contentID  ?? ""){
            return
        }
        let playlist = PlayListDownload(context: context)
        playlist.setData(with: content)
        do{
            try context.save()
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    func getAllPlaylist()->[CommonContent_V7]{
        var data : [CommonContent_V7] = []
        let fetchRequest = PlayListDownload.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let all = try context.fetch(fetchRequest)
            all.forEach { obj in
                data.append(obj.getContentProtocal())
            }
        }catch{
            Log.error(error.localizedDescription)
        }
        
        return data
    }
    func getPlayListBy(id contentID : String)-> PlayListDownload?{
        let fetchRequest = PlayListDownload.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@",ShadhinCore.instance.defaults.userIdentity,contentID)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 1
        do{
            return try context.fetch(fetchRequest).first
        }catch{
            Log.error(error.localizedDescription)
        }
        return nil
    }
    func removePlaylistBy(id contentID : String){
        let fetchRequest = PlayListDownload.fetchRequest()
        let predicate = NSPredicate(format: "msisdn = %@ AND contentID = %@", ShadhinCore.instance.defaults.userIdentity,contentID)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        do{
            guard let first = try context.fetch(fetchRequest).first else {
                return
            }
            context.delete(first)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
}

//MARK: palylist song database handler
extension DatabaseContext{
    func isPlayListSongExist(songID : String,playlistID : String)-> Bool{
        let fetchRequest = PlaylistSongs.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "songID = %@ AND playlistId = %@", songID,playlistID)
        fetchRequest.returnsObjectsAsFaults =  false
        fetchRequest.fetchLimit = 1
        do{
            let obj = try context.fetch(fetchRequest).first
            if obj != nil {
                return true
            }
        }catch{
            Log.error(error.localizedDescription)
        }
        return false
    }
    func getPlayListSongsBy(playlistID id: String) -> [PlaylistSongs] {
        var songs: [PlaylistSongs] = []
        let fetchRequest = PlaylistSongs.fetchRequest()

        // Correct attribute name
        fetchRequest.predicate = NSPredicate(format: "playlistId = %@", id)
        fetchRequest.returnsObjectsAsFaults = true

        do {
            songs = try context.fetch(fetchRequest)
        } catch {
            Log.error(error.localizedDescription)
        }

        return songs
    }
    func addSongInPlaylist(songID : String,playlistID : String){
        if isPlayListSongExist(songID: songID, playlistID: playlistID){
            return
        }
        let song = PlaylistSongs(context: context)
        song.playlistID = playlistID
        song.songID = songID
        
        self.save()
    }
    func removePlaylistSongBy(id songId : String,playlistId : String){
        let fetchRequest  : NSFetchRequest<NSFetchRequestResult> = PlaylistSongs.fetchRequest()
        let predicate = NSPredicate(format: "songID = %@ AND playlistId =  %@", songId,playlistId)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try context.execute(batchDelete)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    func playListSongBatchDeleteBy(playlistID contentID : String){
        let fetchRequest : NSFetchRequest<NSFetchRequestResult> = PlaylistSongs.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "playlistId = %@", contentID)
        fetchRequest.returnsObjectsAsFaults = false
        let delete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do{
            try context.execute(delete)
        }catch{
            Log.error(error.localizedDescription)
        }
    }
    func numbebrOfSongsInPlaylistBy(playlistID  id : String)-> Int{
        let fetchRequest = PlaylistSongs.fetchRequest()
        fetchRequest.predicate  = NSPredicate(format: "playlistId = %@", id)
        fetchRequest.returnsObjectsAsFaults = false
        do{
            return try context.count(for: fetchRequest)
        }catch{
            Log.error(error.localizedDescription)
        }
        return 0
    }
    func delete(obj : PlaylistSongs){
        context.delete(obj)
        self.save()
    }
}

//recent download get
extension DatabaseContext{
    func getRecentlyDownloadList()-> [CommonContent_V7]{
        let songRequest = SongsDownload.fetchRequest()
        songRequest.fetchLimit =  10
        songRequest.returnsObjectsAsFaults = false
        songRequest.predicate = NSPredicate(format: "msisdn = %@ and isSingleDownload = %d", ShadhinCore.instance.defaults.userIdentity,true)
        songRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let albumRequest = AlbumDownloaded.fetchRequest()
        albumRequest.fetchLimit =  10
        albumRequest.returnsObjectsAsFaults = false
        albumRequest.predicate = NSPredicate(format: "msisdn = %@ ", ShadhinCore.instance.defaults.userIdentity)
        albumRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let artistRequest = ArtistDownloaded.fetchRequest()
        artistRequest.fetchLimit =  10
        artistRequest.returnsObjectsAsFaults = false
        artistRequest.predicate = NSPredicate(format: "msisdn = %@ ", ShadhinCore.instance.defaults.userIdentity)
        artistRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let playListRequest = PlayListDownload.fetchRequest()
        playListRequest.fetchLimit =  10
        playListRequest.returnsObjectsAsFaults = false
        playListRequest.predicate = NSPredicate(format: "msisdn = %@ ", ShadhinCore.instance.defaults.userIdentity)
        playListRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let podcastRequest = PodcastDownload.fetchRequest()
        podcastRequest.predicate = NSPredicate(format: "msisdn = %@", ShadhinCore.instance.defaults.userIdentity)
        podcastRequest.returnsObjectsAsFaults = false
        podcastRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        podcastRequest.fetchLimit =  10
        
        var all : [CommonContent_V7] = []
        do{
            let songs = try context.fetch(songRequest)
            let album = try context.fetch(albumRequest)
            let artist = try context.fetch(artistRequest)
            let playlist = try context.fetch(playListRequest)
            let podcasat = try context.fetch(podcastRequest)
            
            all  = songs.map { sd in
                return sd.getContentProtocal()
            }
            all.append(contentsOf: album.map({ ad in
                return ad.getContentProtocal()
            }))
            all.append(contentsOf: artist.map({ ar in
                return ar.getContentProtocal()
                
            }))
            all.append(contentsOf: playlist.map({ pl in
                return pl.getContentProtocal()
            }).filter({ dcm in
                return !dcm.isUserCreated
            }))
            all.append(contentsOf: podcasat.map({$0.getContentProtocal()}))
            
            let tmp = all.sorted { lhs, rhs in
                guard let ld = lhs.date, let rd = rhs.date else{
                    return false
                }
                return ld > rd
            }
            return tmp
        }catch{
            Log.error(error.localizedDescription)
        }
        return []
    }
}
