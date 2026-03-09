//
//  PlaylistOrSingleDetailsVM.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/25/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

class PlaylistOrSingleDetailsVM: NSObject{
    
    enum ViewType {
        case tracksHidden
        case tracksShown
    }
    
    let vc          : PlaylistOrSingleDetailsVC
    var viewType    : ViewType
    
    init(_ vc: PlaylistOrSingleDetailsVC) {
        self.vc = vc
        self.viewType = .tracksHidden
    }
    
    func checkRbtForSingleOrRelease(){
        if vc.discoverModel.contentType?.uppercased() == "S" ||
            vc.discoverModel.contentType?.uppercased() == "R"{
            weak var weakSelf = vc
            ShadhinCore.instance.api.checkContentsForRBT(vc.latestTracks) { items in
                guard let _self = weakSelf else {return}
                for (index, song) in _self.latestTracks.enumerated(){
                    if let contentId = song.contentID,
                       items.contains(contentId){
                        _self.latestTracks[index].hasRBT = true
                    }
                }
                _self.tableView.reloadData()
            }
        }
    }
    
    func getDataFromServer() {
        let id = vc.discoverModel.contentID?.replacingOccurrences(of: " ", with: "") ?? ""
        if vc.discoverModel.contentType?.lowercased() != "s"{
            if ShadhinCore.instance.isUserPro{
                self.viewType = .tracksShown
            }else{
                self.viewType = vc.discoverModel.isPaid ?? false ? .tracksHidden : .tracksShown
            }
            getPlaylistDetails(contentID: id)
            if vc.suggestedPlaylists.isEmpty{
                ShadhinCore.instance.api.getPatchDetailsBy(code: "P004", contentType: "P") {[weak self] data, error in
                    guard let self = self, let data = data else {return}
                    self.vc.suggestedPlaylists = data.shuffled()
                    self.vc.tableView.reloadData()
                }
            }
        }else{
            self.viewType = .tracksShown
            if (vc.discoverModel.playUrl?.isEmpty ?? true)
                || (vc.discoverModel.duration?.isEmpty ?? true){
                getSingleDetails(contentID: id)
            }
        }
        
    }
    
    func getSingleDetails(contentID: String) {
        var durations = 0
        ShadhinCore.instance.api.getAlbumOrPlaylistOrSingleDataById(
            ContentID: contentID,
            mediaType: .song) { data, err ,image in
                if let data = data, !data.isEmpty{
                    self.vc.discoverModel = data[0]
                    self.vc.latestTracks.removeAll()
                    durations += Int(self.vc.discoverModel.duration ?? "0") ?? 0
                    self.vc.latestTracks.append(self.vc.discoverModel)
                    self.vc.tableView.reloadData()
                }
            }
        self.vc.totalDurations = durations.formatTime()
    }
    
    private func getPlaylistDetails(contentID: String) {
        self.vc.view.lock()
        vc.contentID  = contentID
        vc.contentType = vc.discoverModel.contentType?.uppercased() ?? "P"
        vc.discoverModel.contentType = "P"
        vc.songsAndPlaylists.removeAll()
        ShadhinCore.instance.api.getAlbumOrPlaylistOrSingleDataById(
            ContentID: contentID,
            mediaType: .playlist,
            completion: { (albumAndPlaylistData, err, image) in
            if err != nil {
                ConnectionManager.shared.networkErrorHandle(err: err, view: self.vc.view)
            }else {
                self.vc.songsAndPlaylists = albumAndPlaylistData ?? []
                self.vc.songDurationsCalculate(albumAndPlaylistData ?? [])
                self.vc.dataFound()
                weak var weakSelf = self.vc
                ShadhinCore.instance.api.checkContentsForRBT(self.vc.songsAndPlaylists) { items in
                    guard let _self = weakSelf else {return}
                    for (index, song) in _self.songsAndPlaylists.enumerated(){
                        if let contentId = song.contentID,
                           items.contains(contentId){
                            _self.songsAndPlaylists[index].hasRBT = true
                        }
                    }
                    _self.tableView.reloadData()
                }
                self.checkPlaylistIsFav()
                self.vc.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                    self.vc.tableView.setContentOffset(.zero, animated: true)
                }
                self.vc.tableView.setContentOffset(.zero, animated: false)
                self.vc.view.unlock()
                self.getArtistInPlaylistFromServer(playlistId: contentID)
            }
        }, imageCompletion: { imageUrl in
            guard let url = imageUrl, !url.isEmpty else {return}
            self.vc.discoverModel.image = url
        }, isPaidComletion: {
            _isPaid in
            guard let isPaid = _isPaid, !ShadhinCore.instance.isUserPro else {return}
            self.vc.discoverModel.isPaid = isPaid
            self.viewType = self.vc.discoverModel.isPaid ?? false ? .tracksHidden : .tracksShown
        })
    }
    
    func checkPlaylistIsFav(){
        ShadhinCore.instance.api.getAllFavoriteByType(
            type: SMContentType.init(rawValue: vc.discoverModel.contentType)){ (favs, error) in
                Log.error(error?.localizedDescription ?? "")
                guard let favt = favs else {return}
                if favt.contains(where: {$0.contentID == self.vc.contentID}) {
                    self.vc.isListFav = true
                }else {
                    self.vc.isListFav = false
                }
                self.vc.gotFav = true
                self.vc.tableView.reloadData()
            }
    }
    
    func getArtistInPlaylistFromServer(playlistId: String){
        if vc.discoverModel.contentType?.lowercased() != "p"{
            self.vc.defaultToAlbumLoad = true
            self.vc.tableView.reloadData()
            return
        }
        ShadhinCore.instance.api.getArtistsInPlaylistBy(playListID: playlistId) { (data) in
            if let data = data, data.data.count > 0{
                self.vc.artistsInPlaylist = data.data
                self.vc.tableView.reloadSections(IndexSet.init(integer: 3), with: .automatic)
            }
        }
    }
    
    func addDeleteFav(){
        if vc.isListFav{
            deleteFav()
        }else{
            addFav()
        }
    }
    
    func addFav(){
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: vc.discoverModel,
            action: .add) { err in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.vc.view)
                }else {
                    self.vc.isListFav = true
                    self.vc.tableView.reloadData()
                }
            }
    }
    
    func deleteFav(){
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: vc.discoverModel,
            action: .remove) { err in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.vc.view)
                }else {
                    self.vc.isListFav = false
                    self.vc.tableView.reloadData()
                }
            }
    }
    
}
