//
//  PlaylistSongsPreviewVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/17/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit


class PlaylistSongsPreviewVC: UIViewController,NIBVCProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var downloadSwitch: UISwitch!
    @IBOutlet weak var playlistNameLbl: UILabel!
    @IBOutlet weak var playlistDetailsLbl: UILabel!
    @IBOutlet weak var playlistPlayHolder: UIView!
    @IBOutlet weak var playlistPlayPauseIcon: UIImageView!
    
    var playlistDetails: CommonContentProtocol!
    var songsInPlaylist  = [CommonContentProtocol]()
    private var minHeaderHeight: CGFloat = 102
    private var maxHeaderHeight: CGFloat = 215
    private let downloadManager = SDDownloadManager.shared
    
    private func getHorizontalSize() -> CGSize{
        let w = (screenWidth - 32)
        let h = 56.0
        return CGSize(width: w, height: h)
    }
    
    private lazy var screenWidth: CGFloat = {
        return UIScreen.main.bounds.width
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(DownloadListCell.nib(), forCellWithReuseIdentifier: DownloadListCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        downloadSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        playlistNameLbl.text = playlistDetails.title
        var detailsStr = "Various Artists • "
        if let artist = playlistDetails.artist, !artist.isEmpty{
            detailsStr = "\(artist) • "
        }
        detailsStr = detailsStr+"\(songsInPlaylist.count) Tracks"
        playlistDetailsLbl.text = detailsStr
        playlistPlayHolder.setClickListener {
            self.playPlaylist()
        }
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func playPlaylist(){
        guard !songsInPlaylist.isEmpty, let contentID = playlistDetails.contentID else {return}
        MusicPlayerV3.isAudioPlaying = true
        self.openMusicPlayerV3(
            musicData: songsInPlaylist.shuffled(),
            songIndex: 0,
            isRadio: false,
            playlistId: contentID,
            rootModel: playlistDetails)
    }
    
    @IBAction func downloadSwitchToggle(_ sender: UISwitch) {
        if self.checkProUser(){
            if sender.isOn{
                self.downloadAllSongs()
            }else{
                self.cancellAllDownload()
            }
        }else{
            sender.isOn = false
        }
    }
    
}

extension PlaylistSongsPreviewVC  : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songsInPlaylist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DownloadListCell.identifier, for: indexPath) as! DownloadListCell
        cell.setData(with: songsInPlaylist[indexPath.row],isSelectMood: false)
        cell.moreButton.setClickListener {
            self.onMoreClick(index: indexPath.row)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getHorizontalSize()
    }
    
    func onMoreClick(index : Int){
        guard index < songsInPlaylist.count else { return }
        let data = songsInPlaylist[index]
        let menu = MoreMenuVC()
        menu.delegate = self
        menu.data = data
        menu.openForm = .RecentPlay
        //set menu type
        var type : MoreMenuType = .Songs
        if let cType = data.contentType{
            if cType.count  > 1 {
                type = MoreMenuType(rawValue: String(cType.prefix(2))) ?? .Podcast
            }else{
                type = MoreMenuType(rawValue: cType) ?? .Songs
            }

        }
        menu.menuType = type
        let height = MenuLoader.getHeightFor(vc: .RecentPlay, type: type, operators: playlistDetails.rbtOperators)
        var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        SwiftEntryKit.display(entry: menu, using: attribute)
    }
    
    
}

extension PlaylistSongsPreviewVC: MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}
        
        //check user log in or not
        //check user is subscribe or not
        guard checkProUser() else{
            return
        }
        guard let url = URL(string: content.playUrl?.decryptUrl() ?? "") else {
            return self.view.makeToast("Unable to get Download url for file")
        }
        
        //send data to firebase analytics
        AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
        //send download info to server
        ShadhinApi().downloadCompletePost(model: content)
        
        self.view.makeToast("Downloading \(String(describing: content.title ?? ""))")
        
        let request = URLRequest(url: url)
        let _ = self.downloadManager.downloadFile(withRequest: request, onCompletion: { error, url in
            if error != nil{
                self.view.makeToast(error?.localizedDescription)
            }
        })
        collectionView.reloadData()
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        DatabaseContext.shared.deleteSong(where: content.contentID ?? "")
        if let playUrl = content.playUrl{
            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            self.view.makeToast("File Removed from Download")
        }
    }
    //no need to implement this
    func onRemoveFromHistory(content: CommonContentProtocol) {
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        let vc = goArtistVC(content: content)
        self.navigationController?.pushViewController(vc , animated: true )
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        let vc = goAlbumVC(isFromThreeDotMenu: true, content: content)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addToPlaylist(content: CommonContentProtocol) {
        goAddPlaylistVC(content: content)
    }
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
    
    }

}

extension PlaylistSongsPreviewVC : UIScrollViewDelegate{
    func calculateHeight() -> CGFloat {
        guard let collectionView = self.collectionView else {return .zero}
        let scroll = collectionView.contentOffset.y + maxHeaderHeight - 215
        let heightTemp = maxHeaderHeight - scroll
        if  heightTemp > maxHeaderHeight {
            return maxHeaderHeight
        } else if heightTemp < minHeaderHeight {
            return minHeaderHeight
        } else {
            return heightTemp
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerHeightConstraint.constant = calculateHeight()
    }
    
}


//MARK: download quary maintain
extension PlaylistSongsPreviewVC{
    func downloadAllSongs(){
        guard try! Reachability().connection != .unavailable else {return}
        guard ShadhinCore.instance.isUserPro
        else {
            SubscriptionPopUpVC.show(self)
            return
        }
        guard let playListID = playlistDetails.contentID else{
            return
        }
        let model : CommonContentProtocol = playlistDetails
        ShadhinApi().downloadCompletePost(model: model)
        AnalyticsEvents.downloadEvent(with: model.contentType, contentID: model.contentID, contentTitle: model.title)
        DatabaseContext.shared.addPlaylist(content: playlistDetails)
        songsInPlaylist.forEach { data in
            let content : CommonContentProtocol = data
            DatabaseContext.shared.addSongInPlaylist(songID: content.contentID ?? "", playlistID: playListID)
            do{
                if let _ =  try DatabaseContext.shared.isSongExist(contentId: data.contentID!){
                    //Log.info("Song exist")
                }else{
                    DatabaseContext.shared.addDownload(content: content,playlistID: playListID,isSingleDownload: false)
                }
            }catch{
                Log.error(error.localizedDescription)
            }
        }
        SDDownloadManager.shared.checkDatabase()
    }
    
    func cancellAllDownload(){
        guard let playListID = playlistDetails.contentID else{
            return
        }
        DatabaseContext.shared.removePlaylistBy(id: playListID)
        DatabaseContext.shared.downloadRemaingBatchDeleteByPlayList(where: playListID)
        DatabaseContext.shared.playListSongBatchDeleteBy(playlistID: playListID)
        for song in songsInPlaylist{
            if SDDownloadManager.shared.isDownloadInProgress(forKey: song.playUrl){
                if let key = song.playUrl, let url = URL(string: key){
                    SDDownloadManager.shared.cancelDownload(forUniqueKey: url.lastPathComponent)
                }
            }
            if let playUrl = song.playUrl{
                SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            }
            DatabaseContext.shared.deleteSong(where: song.contentID ?? "")
        }
        if try! Reachability().connection == .unavailable{
            navigationController?.popViewController(animated: true)
        }
        self.collectionView.reloadData()
    }
}
