//
//  PlaylistsVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/8/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistsVC: UIViewController {

    @IBOutlet weak var noPlaylistView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createPlaylistView: UIView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    private var playlists = [PlaylistsObj.PlaylistDetails]()
    var fromThreeDotMenu = false
    var addPlaylistData: CommonContentProtocol!
    
    private var backBarBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBGColor()
        createPlaylistView.isHidden = !fromThreeDotMenu
        tableViewTopConstraint.constant = fromThreeDotMenu ? 80 : 15
        if fromThreeDotMenu {
            navigationItem.title = "Add to playlist"
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
            backBarBtn = UIBarButtonItem(image: UIImage(named: "ic_back", in: Bundle.ShadhinMusicSdk, compatibleWith: nil), style: .done, target: self, action: #selector(backTapped))
            if #available(iOS 13.0, *) {
                backBarBtn.tintColor = .label
            } else {
                backBarBtn.tintColor = #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
            }
            navigationItem.leftBarButtonItem = backBarBtn
        }
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }
    
    @IBAction func createPlaylistAction(_ sender: Any) {
        let vc = PlaylistInputVC.instantiateNib()
        let height = view.safeAreaInsets.bottom + 200
        SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: height))
        vc.didPlaylistCreateCompleted { newName in  // ← Receive name back
            // Instantly insert new playlist at top
            let newPlaylist = PlaylistsObj.PlaylistDetails(id: UUID().uuidString, name: newName)
            self.playlists.insert(newPlaylist, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.noDataView()
            // Sync with server in background
            self.getData()
        }
    }

    private func getData() {
        ShadhinCore.instance.api.getBothPlaylistsData { (playlists, err) in
            DispatchQueue.main.async {
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                } else {
                    self.playlists = (playlists ?? []).reversed()
                    self.tableView.reloadData()
                }
                self.noDataView()
            }
        }
    }

    // ← Add viewWillAppear to always refresh when screen appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    private func noDataView() {
        self.noPlaylistView.isHidden = !self.playlists.isEmpty
        self.tableView.isHidden = self.playlists.isEmpty
    }

}

// MARK: - Table View

extension PlaylistsVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMusicPlaylistCell") as! MyMusicPlaylistCell
        cell.configureCell(model: playlists[indexPath.row],songCount: playlists.count)
        cell.didThreeDotMenuTapped {
            let menu = MoreMenuVC()
            menu.openForm = .UserPlaylist
            menu.menuType = .UserPlaylist
            menu.delegate = self
    
            var data = CommonContent_V0(title: self.playlists[indexPath.row].name)
            if let imageUrl =  self.playlists[indexPath.row].Data?[0].image{
                data.image = imageUrl
            }
            data.artist = "\(self.playlists[indexPath.row].Data?.count ?? 0) songs"
            data.contentID = self.playlists[indexPath.row].id
            menu.data = data

            let height = MenuLoader.getHeightFor(vc: .UserPlaylist, type: .UserPlaylist, operators: self.addPlaylistData.rbtOperators)
            
            var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
            attribute.entryBackground = .color(color: .clear)
            attribute.border = .none

            SwiftEntryKit.display(entry: menu, using: attribute)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if fromThreeDotMenu {
            ShadhinCore.instance.api.addOrDeleteContentInUserPlaylist(id: playlists[indexPath.row].id, contentID: addPlaylistData.contentID ?? "", action: .add) { (status,err) in
                if err != nil {
                    Log.error(err?.localizedDescription ?? "")
                }else {
                    self.view.makeToast(status ?? "Successfully Added")
                }
            }
        }else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "PlaylistSongsVC") as! PlaylistSongsVC
            vc.playlistID = playlists[indexPath.row].id
            vc.playlistName = playlists[indexPath.row].name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
}

extension PlaylistsVC : MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard let indx = playlists.firstIndex(where: {$0.id == content.contentID}) else{return}
        ShadhinCore.instance.api.deleteUserPlaylist(playlistID: playlists[indx].id) {(err) in
            if err != nil {
                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
            }else {
                self.playlists.remove(at: indx)
                self.tableView.reloadData()
                self.noDataView()
                self.onRemoveFromHistory(content: content)
            }
        }
    }
    //delete from local database 
    func onRemoveFromHistory(content: CommonContentProtocol) {
        DatabaseContext.shared.removePlaylistBy(id: content.contentID ?? "")
        DatabaseContext.shared.playListSongBatchDeleteBy(playlistID: content.contentID ?? "")
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        
    }
    
    func addToPlaylist(content: CommonContentProtocol) {
        
    }
    func shareMyPlaylist(content: CommonContentProtocol) {
        SwiftEntryKit.dismiss()

        guard let name = content.title,
            let contentID = content.contentID,
            let imgUrl = content.image else{
                self.view.makeToast("Playlist is empty")
                return
        }
    //    DeepLinks.createDeepLinkMyPlaylist(name: name, contentID: contentID, imgUrl: imgUrl, controller: self)
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
    
    }
    
}
