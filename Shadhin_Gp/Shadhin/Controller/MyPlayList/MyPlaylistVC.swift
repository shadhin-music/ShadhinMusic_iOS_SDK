//
//  MyPlaylistVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/26/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation


class MyPlaylistVC: UIViewController,NIBVCProtocol {
    
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var layoutBtn: UIButton!
    @IBOutlet weak var selectionModeBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    private var minHeaderHeight: CGFloat = 92
    private var maxHeaderHeight: CGFloat = 218
    
    private var playlistsServer = [PlaylistsObj.PlaylistDetails]()
    private var playlistsFiltered = [PlaylistsObj.PlaylistDetails]()
    private var playlists : [PlaylistsObj.PlaylistDetails]{
        get{
            if inSearchMode{
                return playlistsFiltered
            }else{
                return playlistsServer
            }
        }
    }
    
    private var inSearchMode = false{
        didSet{
            if inSearchMode{
                searchBar.setIsHidden(false, animated: true)
                playlistsFiltered = playlistsServer
                searchBar.text = ""
                searchBar.becomeFirstResponder()
                searchBtn.setImage(UIImage(named:"ic_close_t",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                
                //
            }else{
                searchBar.endEditing(true)
                searchBar.setIsHidden(true, animated: true)
                searchBtn.setImage(UIImage(named:"ic_collapsible_search",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }
            collectionView.reloadData()
        }
    }
    
    private var inSelectionMode = false{
        didSet{
            if inSelectionMode{
                selectionModeBtn.setImage(UIImage(named:"ic_artist_check",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                layoutBtn.setImage(UIImage(named:"ic_delete_header",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }else{
                selectionModeBtn.setImage(UIImage(named:"ic_artist_uncheck",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                switch self.axis{
                case .horizontal:
                    layoutBtn.setImage(UIImage(named:"ic_grid_mode",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                default:
                    layoutBtn.setImage(UIImage(named:"ic_list_mode",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }
            collectionView.reloadData()
        }
    }
    
    lazy var listCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        return collectionFlowLayout
    }()
    
    lazy var gridCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        return collectionFlowLayout
    }()
    
    func getVerticalSize() -> CGSize{
        let w = (screenWidth - 52)/2
        let h = w * 1.3782
        return CGSize(width: w, height: h)
    }
    
    func getHorizontalSize() -> CGSize{
        let w = (screenWidth - 32)
        let h = w * 2.0/9.0 - 16
        return CGSize(width: w, height: h)
    }
    
    lazy var screenWidth: CGFloat = {
        return UIScreen.main.bounds.width
    }()
    
    var inTransition = false
    var axis : NSLayoutConstraint.Axis = .horizontal{
        didSet{
            let toLayout = axis == .horizontal ? self.listCVLayout : self.gridCVLayout
            self.collectionView.startInteractiveTransition(to: toLayout){
                _,_ in
                self.inTransition = false
            }
            self.collectionView.reloadData()
            self.collectionView.finishInteractiveTransition()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        getAllUserPlaylists()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        minHeaderHeight = 92 + topPadding
        maxHeaderHeight = 218 + topPadding
        collectionView.contentInset =  UIEdgeInsets(top: maxHeaderHeight + 8, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = listCVLayout
        collectionView.register(MyPlaylistCell.nibGrid, forCellWithReuseIdentifier: MyPlaylistCell.identifierGrid)
        collectionView.register(MyPlaylistCell.nibList, forCellWithReuseIdentifier: MyPlaylistCell.identifierList)
        initLayout()
    }
    
    private func createPlaylistAction() {
        let vc = PlaylistInputVC.instantiateNib()
        let height: CGFloat = 205
        SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: height))
        vc.didPlaylistCreateCompleted { newName in  // ← Pass back the name
            // Instantly insert at top
            let newPlaylist = PlaylistsObj.PlaylistDetails(id: UUID().uuidString, name: newName)
            self.playlistsServer.insert(newPlaylist, at: 0)
            self.collectionView.insertItems(at: [IndexPath(row: !self.inSelectionMode && !self.inSearchMode ? 1 : 0, section: 0)])
            // Then sync with server in background
            self.getAllUserPlaylists()
        }
    }

    private func initLayout(){
        layoutBtn.setClickListener {
            if self.inSelectionMode{
                self.sureDeleteAll()
                return
            }
            guard !self.inTransition, !self.playlists.isEmpty else {return}
            self.inTransition = true
            if self.axis == .vertical {
                self.axis = .horizontal
                self.layoutBtn.setImage(
                    UIImage(named: "ic_grid_mode.pdf", in: Bundle.ShadhinMusicSdk, compatibleWith: nil),
                    for: .normal
                )
            } else {
                self.axis = .vertical
                self.layoutBtn.setImage(
                    UIImage(named: "ic_list_mode.pdf", in: Bundle.ShadhinMusicSdk, compatibleWith: nil),
                    for: .normal
                )
            }
        }
        selectionModeBtn.setClickListener {
            guard !self.inTransition, !self.playlists.isEmpty else {return}
            self.inSelectionMode = !self.inSelectionMode
        }
        searchBtn.setClickListener {
            self.inSearchMode = !self.inSearchMode
        }
        backBtn.setClickListener {
            self.navigationController?.popViewController(animated: true)
        }
        if #available(iOS 13.0, *){
            searchBar.searchTextField.backgroundColor = .systemBackground
        }else if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField{
            let backgroundView = UIView(frame: textFieldInsideSearchBar.bounds)
            backgroundView.backgroundColor = .white
            backgroundView.layer.cornerRadius = 10
            backgroundView.clipsToBounds = true
            textFieldInsideSearchBar.insertSubview(backgroundView, at: 1)
        }
        searchBar.placeholder = "Search Playlist"
        searchBar.delegate = self
    }
    
    func sureDeleteAll(){
        let toDeletePlaylists = playlists.filter({$0.isSelected})
        if toDeletePlaylists.isEmpty{
            let alert = UIAlertController(title: "Notice", message: "No item selected.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Alert", message: "Delete all selected playlists?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: {_ in self.deleteAll(toDeletePlaylists)}))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteAll(_ playlists : [PlaylistsObj.PlaylistDetails]){
        self.view.lock()
        let dispatchGroup = DispatchGroup()
        for playlist in playlists{
            dispatchGroup.enter()
            ShadhinCore.instance.api.deleteUserPlaylist(
                playlistID: playlist.id) { err in
                    dispatchGroup.leave()
                }
        }
        dispatchGroup.notify(queue: .main) {
            self.getAllUserPlaylists()
        }
    }
    
}

extension MyPlaylistVC{
    private func getAllUserPlaylists() {
        self.view.lock()
        ShadhinCore.instance.api.getBothPlaylistsData { data, error in
            DispatchQueue.main.async {
                if let error = error {
                    ConnectionManager.shared.networkErrorHandle(err: error, view: self.view)
                }
                self.inSearchMode = false
                self.inSelectionMode = false
                self.playlistsServer = (data ?? []).reversed()
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                self.collectionView.reloadData()
                self.view.unlock()
            }
        }
    }
}


extension MyPlaylistVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = playlists.count + 1
        if inSelectionMode || inSearchMode{
            count -= 1
        }
        if count == 0{
            emptyListView.isHidden = false
        }else{
            emptyListView.isHidden = true
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : MyPlaylistCell!
        if self.axis == .horizontal{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPlaylistCell.identifierList, for: indexPath) as? MyPlaylistCell
        }else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPlaylistCell.identifierGrid, for: indexPath) as? MyPlaylistCell
        }
        if indexPath.row == 0, !inSelectionMode, !inSearchMode{
            cell.initAddPlaylist()
            return cell
        }else{
            var index = indexPath.row
            if !(inSelectionMode || inSearchMode){
                index -= 1
            }
            let model = playlists[index]
            cell.configureCell(model: model, inSelectionMode)
            cell.threeDotBtn.setClickListener {
                let menu = MoreMenuVC()
                menu.menuType = .UserPlaylist
                menu.openForm = .UserPlaylist
                menu.delegate = self
                
                var data = CommonContent_V0(
                    contentID: model.id,
                    title: model.name
                )
                if let imageUrl = model.Data?[0].image{
                    data.image = imageUrl
                }
                data.artist = "\(model.Data?.count ?? 0) songs"
                menu.data = data
                
                let height  = MenuLoader.getHeightFor(vc: .UserPlaylist, type: .UserPlaylist, operators: [])
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                SwiftEntryKit.display(entry: menu, using: attribute)
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0, !inSelectionMode, !inSearchMode{
            createPlaylistAction()
            return
        }
        var index = indexPath.row
        if !(inSelectionMode || inSearchMode){
            index -= 1
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "PlaylistSongsVC") as! PlaylistSongsVC
        vc.playlistID = playlists[index].id
        vc.playlistName = playlists[index].name
        if let aiImageUrl = playlists[index].aiImageUrl{
            vc.aiMoodImageURL = aiImageUrl
        } else {
            vc.aiMoodImageURL = ""
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if axis == .horizontal{
            return getHorizontalSize()
        }else{
            return getVerticalSize()
        }
    }
    
    func calculateHeight() -> CGFloat {
        guard let collectionView = self.collectionView else {return .zero}
        let scroll = collectionView.contentOffset.y + maxHeaderHeight
        let heightTemp = maxHeaderHeight - scroll
        if  heightTemp > maxHeaderHeight {
            return maxHeaderHeight
        } else if heightTemp < minHeaderHeight {
            return minHeaderHeight
        } else {
            return heightTemp
        }
    }
    
}

extension MyPlaylistVC: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerHeightConstraint.constant = calculateHeight()
    }
}


extension MyPlaylistVC: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.filterContentForSearchText(searchText)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty{
            playlistsFiltered = playlistsServer
        }else{
            playlistsFiltered = playlistsServer.filter { (playlist: PlaylistsObj.PlaylistDetails) -> Bool in
                return playlist.name.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
    }
    
}

extension MyPlaylistVC : MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard let playlistId = content.contentID,
              var index =  playlists.firstIndex(where: {$0.id == playlistId})
        else {return}
        if !(inSelectionMode || inSearchMode){
            index += 1
        }
        //print("Delete playlist with index \(index)")
        ShadhinCore.instance.api.deleteUserPlaylist(
            playlistID: playlistId) { err in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else{
                    if let _index = self.playlistsServer.firstIndex(where: {$0.id == playlistId}){
                        self.playlistsServer.remove(at: _index)
                    }
                    if let _index = self.playlistsFiltered.firstIndex(where: {$0.id == playlistId}){
                        self.playlistsFiltered.remove(at: _index)
                    }
                    self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                    //get all song from playlistSongs
                    let playListSongs = DatabaseContext.shared.getPlayListSongsBy(playlistID: playlistId)
                    playListSongs.forEach { pls in
                        if let song = DatabaseContext.shared.getSongBy(id: pls.songID!){
                            //remove from local
                            if let playUrl = song.playUrl{
                                SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                            }
                            //remove from database
                            DatabaseContext.shared.deleteSong(where: song.contentID ?? "")
                        }
                    }
                    //delete all playlist song from playlistsong database
                    DatabaseContext.shared.playListSongBatchDeleteBy(playlistID: playlistId)
                    //delete playlist from playlist database
                    DatabaseContext.shared.removePlaylistBy(id: playlistId)
                }
            }
    }
    
    func onRemoveFromHistory(content: CommonContentProtocol) {
        
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
        DeepLinks.createLinkTest(controller:self)
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
        
    }
}
