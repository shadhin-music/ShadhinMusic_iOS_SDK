//
//  PlaylistSongsVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/8/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class PlaylistSongsVC: UIViewController {
    
    private var artistSongs = [CommonContent_V2]()
    var discoverModel: CommonContentProtocol!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noSongsView: UIView!
    
    var userContentPlaylists = [CommonContent_V4]()
    var artistModels = [CommonContent_V0]()

    var playlistID = ""
    var playlistName = "User Playlist"
    var playListImg = ""
    
    var showBackItem = false
    var isAIPlaylist = false
    var aiMoodImageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBGColor()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        if !isAIPlaylist {
            getData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(forName: .DownloadStartNotify, object: nil, queue: .main) { notificationn in
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc
    func back(){
        if showBackItem{
            self.dismiss(animated: true)
        }else{
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func noItemBackTapped(_ sender: UIButton) {
        self.back()
    }
    
//    func shareMyPlaylist(){
//        DeepLinks.createDeepLinkMyPlaylist(name: playlistName, contentID: playlistID, imgUrl: playListImg, controller: self)
//    }
    
    private func getData() {
        
        if try! Reachability().connection == .unavailable{
            let allPlaylistSong = DatabaseContext.shared.getPlayListSongsBy(playlistID: playlistID)
            allPlaylistSong.forEach { pls in
                if let song = DatabaseContext.shared.getSongBy(songID: pls.songID!){
                    self.userContentPlaylists.append(song.getUserPlaylist())
                }
            }
            tableView.reloadData()
            return
        }
        ShadhinCore.instance.api.getContentsOfUserPlaylistBy(playlistID: playlistID) { (userContents, err) in
            
            if err != nil {
                return ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
            }else {
                self.userContentPlaylists = userContents ?? []
                self.tableView.reloadData()
                self.getArtistData()
            }
            
            self.noDataView()
        }
    }
    
    func getArtistData(){
        ShadhinCore.instance.api.getTopArtistsBySkipping() { (data) in
            if let data = data, data.data.count > 0{
                self.artistModels = data.data
                self.tableView.insertSections(IndexSet(integer: 2), with: .none)
            }
        }
    }
    
    private func noDataView() {
        self.noSongsView.isHidden = !self.userContentPlaylists.isEmpty
        self.tableView.isHidden = self.userContentPlaylists.isEmpty
    }
    
    private func shufflePlay() {
        openMusicPlayerV3(musicData:userContentPlaylists, songIndex: 0,isRadio: false,rootModel: discoverModel)
        MusicPlayerV3.shared.turnOnShuffle()
    }
}

// MARK: - Table View

extension PlaylistSongsVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 2:
            return 1
        default:
            return userContentPlaylists.count
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var count =  2
        if !artistModels.isEmpty{
            count += 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let newHeader = ShuffleAndDownloadView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            let isDownloaded = DatabaseContext.shared.isPlaylistExist(playlistID: playlistID)
            let isDownloading = DatabaseContext.shared.isArtistDownloading(artistId: playlistID)
            newHeader.downloadProgress.isHidden = true
            if isDownloading {
                newHeader.downloadProgress.isHidden = false
                newHeader.downloadProgress.startAnimating()
                newHeader.downloadButton.setImage(UIImage(named: "music_v4/ic_stop",in: Bundle.ShadhinMusicSdk,compatibleWith:nil), for: .normal)
            } else if isDownloaded {
                newHeader.downloadButton.setImage(UIImage(named: "downloadComplete",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for:.normal)
            }   else {
                newHeader.downloadButton.setImage(UIImage(named: "download",in:Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }
            // for download button action change
            newHeader.downloadButton.setClickListener {
                if self.checkProUser() {
                    if(isDownloaded || isDownloading){
                        self.cancellAllDownload()
                    } else {
                        self.downloadAllSongs() //Todo neeed to remove after test
                        newHeader.downloadProgress.isHidden = false
                        newHeader.downloadProgress.startAnimating()
                        newHeader.downloadButton.setImage(UIImage(named: "music_v4/ic_stop",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    }
                }
            }
            newHeader.contentID = playlistID
            newHeader.contentType = "P"
            newHeader.updateShuffleBtn()
            newHeader.shuffleButton.setClickListener {
                //if checked remove(){update ui} else add(){update ui}
              //  guard let playListID = self.discoverModel.artistId else { return }
                if ShadhinCore.instance.defaults.checkShuffle(contentId:self.playlistID,contentType:"P") {
                    ShadhinCore.instance.defaults.removeShuffle(contentId:self.playlistID,contentType:"P")
                } else {
                    ShadhinCore.instance.defaults.addShuffle(contentId:self.playlistID, contentType:"P")
                }
                NotificationCenter.default.post(name: .init("ShuffleListNotify"), object: nil)
            }
            return nil
        }else if section == 2 {
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
            let label = UILabel(frame: CGRect(x:12, y:10, width:tableView.frame.size.width, height:30))
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = ^String.Downloads.artist  //["Track List","Artists"][section - 1]
            view.addSubview(label)
            view.backgroundColor = .clear
            return view
        }
        else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNormalMagnitude : 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserPlaylistHeaderCell") as! UserPlaylistHeaderCell
            cell.didTapBackButton {
                self.back()
            }
            let aiMoodURL = URL(string: aiMoodImageURL)
            
            if aiMoodImageURL.isEmpty{
                for (index, element) in userContentPlaylists.enumerated() {
                    let imgUrl = element.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
                    if index == 0 {
                        playListImg = imgUrl
                        cell.bgImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()))
                    }
                    cell.songsImgViews[index].kf.indicatorType = .activity
                    cell.songsImgViews[index].kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_album"))
                    if index == 3{
                        break
                    }
                }
            }else{
                cell.aiMoodImageView.kf.setImage(with: aiMoodURL)
            }
            cell.songTitleLbl.text = playlistName
            cell.songArtistLbl.text = cell.songListCountText(userContentPlaylists.count)
            cell.didTapPlayPauseButton {
                guard  !self.userContentPlaylists.isEmpty else {return}
                let contentid = self.userContentPlaylists[0].contentID
                if MusicPlayerV3.audioPlayer.currentItem?.contentId == contentid, MusicPlayerV3.audioPlayer.currentItem?.contentId != "" {
                    if MusicPlayerV3.isAudioPlaying {
                        cell.playPauseBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                        if MusicPlayerV3.audioPlayer.state == .stopped {
                            self.tableView(tableView, didSelectRowAt: IndexPath.init(row: 0, section: 1))
                        }else {
                            MusicPlayerV3.audioPlayer.resume()
                        }
                    }else {
                        MusicPlayerV3.audioPlayer.pause()
                        cell.playPauseBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    }
                } else {
                    cell.playPauseBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    self.tableView(tableView, didSelectRowAt: IndexPath.init(row: 0, section: 1))
                    MusicPlayerV3.isAudioPlaying = true
                }
                
                MusicPlayerV3.isAudioPlaying.toggle()
            }
            cell.shareBtn.setClickListener {
             //   self.shareMyPlaylist()
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistAlbumListCell") as! ArtistAlbumListCell
            
            cell.configureCell(data: artistModels)
            cell.didSelectAlbumList { ignored in
            }
            
            cell.didSelectArtist = { (index) in
                let vc = self.goArtistVC(content: self.artistModels[index])
                vc.artistList = self.artistModels
                vc.selectedArtistList = index
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMusicSongsAndFavCell") as! MyMusicSongsAndFavCell
            let index = indexPath.row

            guard index < userContentPlaylists.count else { return cell } // ← safety guard

            cell.configureCell(model: userContentPlaylists[index], isFav: false, hideMenu: showBackItem)
            cell.didThreeDotMenuTapped { [weak self] in
                guard let self = self else { return }
                guard let currentIndex = tableView.indexPath(for: cell)?.row,
                      currentIndex < self.userContentPlaylists.count else { return }

                let menu = MoreMenuVC()
                menu.menuType = .UserPlaylist
                menu.openForm = .UserPlaylist
                menu.data = self.userContentPlaylists[currentIndex]
                menu.delegate = self
                // ✅ Fix: safely unwrap discoverModel
                let operators = self.discoverModel?.rbtOperators ?? []
                let height = MenuLoader.getHeightFor(vc: .UserPlaylist, type: .UserPlaylist, operators: operators)

                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none

                SwiftEntryKit.display(entry: menu, using: attribute)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            tableView.deselectRow(at: indexPath, animated: true)
            if showBackItem{
//                AppDelegate.shared?.mainHome?.openMusicPlayerV3(musicData: userContentPlaylists, songIndex: indexPath.row, isRadio: false)
                MusicPlayerV3.isAudioPlaying = false
                return
            }
            openMusicPlayerV3(musicData: userContentPlaylists, songIndex: indexPath.row, isRadio: false, playlistId: playlistID)
            MusicPlayerV3.isAudioPlaying = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 408
        case 2:
            return 165
        default:
            return 66
        }
    }
    
}

//MARK: download quary maintain
extension PlaylistSongsVC{
    func downloadAllSongs(){
        guard try! Reachability().connection != .unavailable else {return}

        guard ShadhinCore.instance.isUserPro
        else {
            //self.goSubscriptionTypeVC()
            SubscriptionPopUpVC.show(self)
            return
        }
        var dd = CommonContent_V7()
        dd.contentID = playlistID
        dd.contentType = "UP"
        dd.playListID = playlistID
        dd.title = playlistName
        dd.isUserCreated = true
        //post download info to server
        let model : CommonContentProtocol = dd
        //non needs to post user create playlist
        //ShadhinApi().downloadComplete(model: model)
        //send event to firebasee analytics
      //  AnalyticsEvents.downloadEvent(with: model.contentType, contentID: model.contentID, contentTitle: model.title)
        //add to artist datababse
        DatabaseContext.shared.addPlaylist(content: dd)
        
        userContentPlaylists.forEach { data in
            let content : CommonContentProtocol = data
            
            //add song to  playlist songs database
            DatabaseContext.shared.addSongInPlaylist(songID: content.contentID ?? "", playlistID: playlistID)
            do{
                if let _ =  try DatabaseContext.shared.isSongExist(contentId: data.contentID!){
                    //add songs to playlist song database
                }else{
                    DatabaseContext.shared.addDownload(content: content,playlistID: playlistID,isSingleDownload: false)
                }
            }catch{
                Log.error(error.localizedDescription)
            }
        }
        SDDownloadManager.shared.checkDatabase()
    }
    func cancellAllDownload(){
        
        //delete artist from artist databae
        DatabaseContext.shared.removePlaylistBy(id: playlistID)
        //delete if download remaing
        DatabaseContext.shared.downloadRemaingBatchDeleteByPlayList(where: playlistID)
        //delete all song from playlist song database
        DatabaseContext.shared.playListSongBatchDeleteBy(playlistID: playlistID)
        //delete all download request
        for song in userContentPlaylists{
            if SDDownloadManager.shared.isDownloadInProgress(forKey: song.playUrl){
                if let key = song.playUrl, let url = URL(string: key){
                    SDDownloadManager.shared.cancelDownload(forUniqueKey: url.lastPathComponent)
                }
                
            }
            //remove song from local directory
            if let playUrl = song.playUrl{
                SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            }
            //remove song from song database 
            DatabaseContext.shared.deleteSong(where: song.contentID ?? "")
        }
        
        //check songs loads from internet or local
        if try! Reachability().connection == .unavailable{
            //load from local
            //pop back
            navigationController?.popViewController(animated: true)
        }
        self.tableView.reloadData()
    }
}
extension PlaylistSongsVC  : MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        if try! Reachability().connection == .unavailable{
            return
        }
        ShadhinCore.instance.api.addOrDeleteContentInUserPlaylist(id: playlistID, contentID: content.contentID ?? "", action: .remove) { (status,err) in
            if err != nil {
                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
            }else {
                //remove from database
                DatabaseContext.shared.removePlaylistSongBy(id: content.contentID ?? "", playlistId: self.playlistID)
                //remove from local
                if let playUrl = content.playUrl{
                    SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                }
                self.userContentPlaylists.removeAll(where: { (data) -> Bool in
                    return data.contentID == content.contentID
                })
                self.tableView.reloadData()
                self.noDataView()
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
//        DeepLinks.createDeepLinkMyPlaylist(name: name, contentID: contentID, imgUrl: imgUrl, controller: self)
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
    
    }
    
}
