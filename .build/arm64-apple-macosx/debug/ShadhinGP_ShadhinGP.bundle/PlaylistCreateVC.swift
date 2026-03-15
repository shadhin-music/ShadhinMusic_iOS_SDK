//
//  PlaylistCreateVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/7/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit


class PlaylistCreateVC: UIViewController {

    @IBOutlet weak var noPlaylistView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    var playlists = [PlaylistsObj.PlaylistDetails]()
    var contentID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "PlaylistListCell", bundle:Bundle.ShadhinMusicSdk), forCellReuseIdentifier: "PlaylistListCell")
        
        self.noPlaylistView.isHidden = !self.playlists.isEmpty
        self.tableView.isHidden = self.playlists.isEmpty
        
    }

    @IBAction func createPlaylistAction(_ sender: Any) {
        let height = view.safeAreaInsets.bottom + 200
        SwiftEntryKit.display(entry: PlaylistInputVC(), using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: height))
    }
}

extension PlaylistCreateVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistListCell") as! PlaylistListCell
        cell.configureCell(model: playlists[indexPath.row])
        
        cell.didSongsListButtonTapped {
            let vc = UserContentPlaylistAndQueueListVC()
            var height: CGFloat = 0
            ShadhinCore.instance.api.getContentsOfUserPlaylistBy(playlistID: self.playlists[indexPath.row].id) { (playlists, err) in
                guard let playlist = playlists else {return}
                if playlist.count > 0 {
                    let tableCellHeight: CGFloat = CGFloat((playlist.count * 66) + 70)
                    height = self.view.safeAreaInsets.bottom + tableCellHeight
                    SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: height))
                    vc.userContentPlaylists = playlist
                }else {
                    height = self.view.safeAreaInsets.bottom + 80
                    SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: height))
                }
                
            }
            vc.viewTitle = "Playlist"
            vc.playlistID = self.playlists[indexPath.row].id
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ShadhinCore.instance.api.addOrDeleteContentInUserPlaylist(id: playlists[indexPath.row].id, contentID: contentID, action: .add) { (status,err) in
            if err == nil {
                self.view.makeToast(status ?? "Successfully Added")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
