//
//  DownloadVC.swift
//  Shadhin
//
//  Created by Admin on 19/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import CoreData

class DownloadVC: UIViewController,NIBVCProtocol {
    @IBOutlet weak var emptyListView: EmptyListView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerView: HeaderViewDownload!
    
    //collection view property initial
    private var minHeaderHeight: CGFloat = 56 + 76 //+ 20
    private var maxHeaderHeight: CGFloat = 218 + 40
    @IBOutlet weak var headerConstraint: NSLayoutConstraint!
    
    lazy var listCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        return collectionFlowLayout
    }()
    
    lazy var gridCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        return collectionFlowLayout
    }()
    private func getVerticalSize() -> CGSize{
        let w = (screenWidth - 48)/2
        let h = w + DownloadGridCell.bottomHeight
        return CGSize(width: w, height: h)
    }
    
    private func getHorizontalSize() -> CGSize{
        let w = (screenWidth - 32)
        let h = 56.0
        return CGSize(width: w, height: h)
    }
    
    private lazy var screenWidth: CGFloat = {
        return UIScreen.main.bounds.width
    }()
    
    private var isSelectMood : Bool = false{
        didSet{
            collectionView.reloadData()
        }
    }
    
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
    
    //datasource
    private var dataSource : [CommonContent_V7] = []
    private var dataSourceAll : [CommonContent_V7] = []
    //database fetch
    var downloadType : DownloadChipType = .None
    private var isPodcast = false
    
    var navPreviousState = false
    
    var selectedDownloadSeg: DownloadChipModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewSafeAreaInsetsDidChange()
        let obj = EmptyViewModel(topIcon: AppImage.noDownload, title: ^String.Downloads.noDownloadTitle, subtitle: ^String.Downloads.noDownloadSubtitle)
        emptyListView.setData(with: obj)
        emptyListView.backgroundColor = .clear
        emptyListView.isHidden = false 
        // Do any additional setup after loading the view.
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        minHeaderHeight = minHeaderHeight + topPadding
        maxHeaderHeight = maxHeaderHeight + topPadding
        headerConstraint.constant = maxHeaderHeight
        //collection view set up
        //collectionView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.contentInset =  UIEdgeInsets(top: maxHeaderHeight + 8, left: 16, bottom: 0, right: 16)
        collectionView.collectionViewLayout = listCVLayout
        collectionView.register(DownloadGridCell.nib(), forCellWithReuseIdentifier: DownloadGridCell.identifier)
        collectionView.register(DownloadListCell.nib(), forCellWithReuseIdentifier: DownloadListCell.identifier)
        collectionView.register(MyPlaylistCell.nibGrid, forCellWithReuseIdentifier: MyPlaylistCell.identifierGrid)
        collectionView.register(MyPlaylistCell.nibList, forCellWithReuseIdentifier: MyPlaylistCell.identifierList)
        collectionView.allowsMultipleSelection = true
        collectionView.contentInsetAdjustmentBehavior = .never
        setUpHeader()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        onFilterPressed(type: downloadType)
    }

    override func viewWillAppear(_ animated: Bool) {
        navPreviousState = self.navigationController?.isNavigationBarHidden ?? true
        self.navigationController?.isNavigationBarHidden = true
        if self.collectionView.dataSource == nil{
           
        }
        
        //self.collectionView.reloadData()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    

    func setUpHeader(){
        headerView.delegate = self
        headerView.backButton.setClickListener {
            self.navigationController?.popViewController(animated: true)
        }
        //select all button click handler
        headerView.selectAllButton.setClickListener { [self] in
            self.isSelectMood = !self.isSelectMood
            //update allselect button icon
            self.headerView.selectMarkButton.isSelected = !headerView.selectMarkButton.isSelected
            self.headerView.isSelectMood = self.isSelectMood
        }
        headerView.isSelectMood = self.isSelectMood
        headerView.axis = self.axis
        //grid and list view change handler
        headerView.gridListButton.setClickListener {
            
            if self.isSelectMood{
                //delete all
                self.batchDelete()
                return
            }
            
            guard !self.inTransition, !self.dataSource.isEmpty else {return}
            self.inTransition = true
            if self.axis == .vertical{
                self.axis = .horizontal
                
            }else{
                self.axis = .vertical
                
            }
            self.headerView.axis = self.axis
        }
        //filter view pressed
        headerView.onFilterPressed = self.onFilterPressed(type:)
        headerView.onDownloadAllPressed = { isOn in
            if isOn{
                self.downloadAllHistory()
            }else{
                self.historyDownloadStop()
            }
        }
        if let selectedDownloadSeg = selectedDownloadSeg{
            self.downloadType = selectedDownloadSeg.type
            headerView.setSetected(obj: selectedDownloadSeg)
        }
    }
    
}

extension DownloadVC : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dataSource.count == 0 {
            emptyListView.isHidden = false
        }else{
            emptyListView.isHidden = true
        }
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let obj = dataSource[indexPath.row]
        if axis == .horizontal{
            if downloadType == .Playlist{
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPlaylistCell.identifierList, for: indexPath) as? MyPlaylistCell else{
                    fatalError("Playlist cell not load")
                }
                cell.initAddPlaylist()
                cell.configureCell(playList: obj,isSelectMood: self.isSelectMood)
                cell.threeDotBtn.setClickListener {
                    self.onMoreClick(index: indexPath.row)
                }
                return cell
            }else{
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DownloadListCell.identifier, for: indexPath) as? DownloadListCell else{
                    fatalError("download cell not load")
                }
                //cell.isSelectMood = self.isSelectMood
                cell.setData(with: obj, isSelectMood: self.isSelectMood,from: downloadType)
                cell.setItemSelected(isSelect: obj.isSelect)
                
                cell.moreButton.setClickListener {
                    self.onMoreClick(index: indexPath.row)
                }
                return cell
            }
            
        }
        if downloadType == .PodCast{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPlaylistCell.identifierGrid, for: indexPath) as? MyPlaylistCell else{
                fatalError("Playlist cell not load")
            }
            cell.initAddPlaylist()
            cell.configureCell(playList: obj,isSelectMood: self.isSelectMood)
            cell.threeDotBtn.setClickListener {
                self.onMoreClick(index: indexPath.row)
            }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DownloadGridCell.identifier, for: indexPath) as? DownloadGridCell else{
            fatalError("download cell not load")
        }
        //cell select mood enable disable
        //cell.isSelectMood = self.isSelectMood
        cell.setData(with: obj,isSelectMood: self.isSelectMood,from: downloadType)
        cell.setItemSelected(isSelect: obj.isSelect)
        cell.moreButton.setClickListener {
            self.onMoreClick(index: indexPath.row)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if axis == .horizontal{
            return getHorizontalSize()
        }else{
            return getVerticalSize()
        }
    }
    
    func onMoreClick(index : Int){
        guard index < dataSource.count else { return }
        let menu = MoreMenuVC()
        menu.delegate = self
        menu.data = dataSource[index]
        var height: CGFloat = 368 + 50
        let data = dataSource[index]
        var type : MoreMenuType = .Songs
        //set menu type
        if let cType = data.contentType{
            if cType.count  > 1 {
                type = MoreMenuType(rawValue: String(cType.prefix(2))) ?? .Podcast
            }else if data.isUserCreated{
                type = .Playlist
            }else{
                type = MoreMenuType(rawValue: cType) ?? .Songs
            }
            
        }
        menu.menuType = type
        if downloadType == .History{
            menu.openForm = .History
            height = MenuLoader.getHeightFor(vc: .History, type: type, operators: dataSource.first?.rbtOperators)
        }else{
            menu.openForm = .Download
            height = MenuLoader.getHeightFor(vc: .Download, type: type, operators: dataSource.first?.rbtOperators)
        }
        //check album and artist id exist or not
        if downloadType == .Songs {
            if data.albumId == nil || data.albumId == ""{
                height -= 50
            }
            if data.artistId == nil || data.artistId ==  ""{
                height -= 50
            }
        }
        
        var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        SwiftEntryKit.display(entry: menu, using: attribute)
        
    }
    
}
extension DownloadVC : UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelectMood{
            dataSource[indexPath.row].isSelect = !dataSource[indexPath.row].isSelect
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            return
        }
        let content = dataSource[indexPath.row]
        let contentType = SMContentType(rawValue: content.contentType)
        if contentType == .song{
            let songs = dataSource.filter({$0.contentType == content.contentType})
            if let indx = songs.firstIndex(where: {$0.contentID == content.contentID}){
                openMusicPlayerV3(musicData: songs, songIndex: indx, isRadio: false)
            }
        }else if contentType == .album{
            let vc = self.goAlbumVC(isFromThreeDotMenu: false, content: content)
            self.navigationController?.pushViewController(vc, animated: true)
        }else if contentType == .artist{
            let vc = self.goArtistVC(content: content)
            self.navigationController?.pushViewController(vc, animated: true)
        }else if contentType == .podcast{
            let podcast = dataSource.filter({$0.contentType == content.contentType})
            if let indx = podcast.firstIndex(where: {$0.contentID == content.contentID}){
                openMusicPlayerV3(musicData: podcast, songIndex: indx, isRadio: false,rootModel: podcast[indx])
            }
        }else if contentType == .playlist{
            if content.isUserCreated{
                let storyBoard = UIStoryboard(name: "MyMusic", bundle:Bundle.ShadhinMusicSdk)
                let vc = storyBoard.instantiateViewController(withIdentifier: "PlaylistSongsVC") as! PlaylistSongsVC
                vc.playlistID = content.playListID ?? content.contentID ?? ""
                vc.playlistName = content.title  ?? ""
                navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = self.goPlaylistVC(content: content)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }

}


//MARK: header section filter pressed
extension DownloadVC{
    func onFilterPressed(type: DownloadChipType){
        self.downloadType = type
        if type == .History{
            headerView.downloadView.isHidden = false
            headerView.allDownloadSwitch.isOn = false
        }else{
            headerView.downloadView.isHidden = true
        }
        isPodcast = false
        dataSource.removeAll()
        do{
            switch type {
            case .Album:
                //this process is not optiomize .
                //its normal way. you can optimize if you want
//                let tmp = try DatabaseContext.shared.getAlbums()
//                tmp.forEach { dcm in
//                    if DatabaseContext.shared.getSonngsByAlbum(where: dcm.albumId ?? "" ).count == 0 {
//                        DatabaseContext.shared.deleteAlbum(where: dcm.albumId ?? "")
//                    }
//                }
                dataSourceAll = try DatabaseContext.shared.getAlbums()
            case .Artist:
//                let tmp = try DatabaseContext.shared.getArtist()
//                tmp.forEach { dcm in
//                    if DatabaseContext.shared.numberOfSongsForArtistBy(artistId: dcm.contentID ?? "") == 0{
//                        DatabaseContext.shared.deleteArtist(where: dcm.contentID ?? "")
//                    }
//                }
                dataSourceAll = try DatabaseContext.shared.getArtist()
                break
            case .Songs:
                dataSourceAll = try DatabaseContext.shared.getSongs()
            case .Playlist:
//                let tmp  =  DatabaseContext.shared.getAllPlaylist()
//                tmp.forEach { dcm in
//                    if DatabaseContext.shared.numbebrOfSongsInPlaylistBy(playlistID: dcm.contentID ?? "") == 0{
//                        DatabaseContext.shared.removePlaylistBy(id: dcm.contentID ?? "")
//                    }
//                }
                dataSourceAll = DatabaseContext.shared.getAllPlaylist()
            case .PodCast:
                isPodcast = true
                dataSourceAll = try DatabaseContext.shared.getAllPodcast()
                break
            case .None:
                dataSourceAll = DatabaseContext.shared.getRecentlyDownloadList()
                break
            case .History:
                ShadhinApi().downloadCompleteGET { result in
                    switch result{
                    case .success(let data):
                        self.dataSourceAll = data.map({ dcm in
                            var dc = CommonContent_V7()
                            dc.downloadContent(with: dcm)
                            return dc
                        })
                        //check local database if data allready downloaded
                        //then not show in this list
                        self.historyDatacheck()
                    case .failure(let error):
                        Log.error(error.localizedDescription)
                    }
                }
                break
            }
        } catch{
            Log.error(error.localizedDescription)
        }
        dataSource = dataSourceAll
        collectionView.reloadData()
    }
    
    func batchDelete(){

        if downloadType == .Album{
            dataSource.filter { $0.isSelect}.forEach { dd in
                
                let allSongs = DatabaseContext.shared.getSonngsByAlbum(where: dd.albumId ?? "")
                //check music is playing or not. if any song is playing from this album.
                //album not deleted
                if let _ = allSongs.first(where: {$0.contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId}), MusicPlayerV3.isAudioPlaying{
                    view.makeToast("One of song is playing from this Album.")
                    
                }else{
                    allSongs.forEach { song in
                        //remove songs from local database
                        if let playUrl = song.playUrl{
                            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                        }
                    }
                    //delete album from album database
                    DatabaseContext.shared.deleteAlbum(where: dd.albumId ?? "")
                    
                    //delete songs from song database
                    DatabaseContext.shared.deleteSongsByAlbum(where: dd.albumId ?? "")
                    
                }
                
            }
            
        } else if downloadType == .Songs {
            dataSource.filter { $0.isSelect}.forEach { dd in
                if MusicPlayerV3.isAudioPlaying && MusicPlayerV3.audioPlayer
                    .currentItem?.contentId == dd.contentID{
                    view.makeToast("Songs is playing")
                }else{
                    //delete song from song database
                    DatabaseContext.shared.deleteSong(where: dd.contentID ?? "")
                    //remove file from local database
                    if let playUrl = dd.playUrl{
                        SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                    }
                }
                
            }
        }else if downloadType == .Artist{
            dataSource.filter { $0.isSelect}.forEach { dd in
                
                let allSongs = DatabaseContext.shared.getSonngsByArtist(where: dd.artistId ?? "")
                
                if  MusicPlayerV3.isAudioPlaying , let _ = allSongs.first(where: {$0.contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId}){
                    view.makeToast("One of song is playing from this Artist.")
                    
                }else{
                    allSongs.forEach { song in
                        //remove songs from local database
                        if let playUrl = song.playUrl{
                            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                        }
                    }
                    //delete album from album database
                    DatabaseContext.shared.deleteArtist(where: dd.artistId ?? "")
                    //delete songs from song database
                    DatabaseContext.shared.deleteSongsByArtist(where: dd.artistId ?? "")
                }
                
            }
            
        }else if downloadType == .PodCast{
            dataSource.filter{$0.isSelect}.forEach { dd in
                if MusicPlayerV3.isAudioPlaying && MusicPlayerV3.audioPlayer.currentItem?.contentId == dd.contentID{
                    view.makeToast("This Podcase is playing")
                }else{
                    DatabaseContext.shared.removePodcast(with: dd.contentID ?? "")
                    if let playUrl = dd.playUrl{
                        SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                    }
                }
                
            }
        }else if downloadType == .Playlist{
            dataSource.filter{$0.isSelect}.forEach { dd in
                let playlistID = dd.contentID ?? ""
                let allSongs = DatabaseContext.shared.getPlayListSongsBy(playlistID: playlistID)
                if MusicPlayerV3.isAudioPlaying && allSongs.contains(where: {$0.songID == MusicPlayerV3.audioPlayer.currentItem?.contentId}){
                    view.makeToast("One of song is playing from \(dd.title ?? "this") Playlist.")
                    return
                }
                //delete playlist from playlist database
                DatabaseContext.shared.removePlaylistBy(id: playlistID)
                //get all songs from playlistsong database
                let songs = DatabaseContext.shared.getPlayListSongsBy(playlistID: playlistID)
                songs.forEach { pls in
                    if let song = DatabaseContext.shared.getSongBy(id: pls.songID!){
                        //remove song from local database
                        if let playurl = song.playUrl{
                            SDFileUtils.removeItemFromDirectory(urlName: playurl)
                        }
                    }
                    //delete song from song database
                    DatabaseContext.shared.deleteSong(where: pls.songID!)
                }
                //delete all songs fçom playlistsong databbase
                DatabaseContext.shared.playListSongBatchDeleteBy(playlistID: playlistID)
            }
        }else if downloadType == .History{
            let delete  = dataSource.filter{$0.isSelect}
            if delete.count == 0{
                return
            }
            ShadhinCore.instance.api.deleteDownloadHistory(contents: delete)
        }else if downloadType == .None{
            dataSource.filter { $0.isSelect}.forEach { cc in
                let contentType = SMContentType(rawValue: cc.contentType)
                if contentType == .song{
                    if MusicPlayerV3.isAudioPlaying && MusicPlayerV3.audioPlayer
                        .currentItem?.contentId == cc.contentID{
                        view.makeToast("Songs is playing")
                    }else{
                        //delete song from song database
                        DatabaseContext.shared.deleteSong(where: cc.contentID ?? "")
                        //remove file from local database
                        if let playUrl = cc.playUrl{
                            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                        }
                    }
                }else if contentType == .album{
                    let allSongs = DatabaseContext.shared.getSonngsByAlbum(where: cc.albumId ?? "")
                    //check music is playing or not. if any song is playing from this album.
                    //album not deleted
                    if let _ = allSongs.first(where: {$0.contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId}), MusicPlayerV3.isAudioPlaying{
                        view.makeToast("One of song is playing from this Album.")
                        
                    }else{
                        allSongs.forEach { song in
                            //remove songs from local database
                            if let playUrl = song.playUrl{
                                SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                            }
                        }
                        //delete album from album database
                        DatabaseContext.shared.deleteAlbum(where: cc.albumId ?? "")
                        
                        //delete songs from song database
                        DatabaseContext.shared.deleteSongsByAlbum(where: cc.albumId ?? "")
                        
                    }
                }else if contentType == .artist{
                    let allSongs = DatabaseContext.shared.getSonngsByArtist(where: cc.artistId ?? "")
                    
                    if  MusicPlayerV3.isAudioPlaying , let _ = allSongs.first(where: {$0.contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId}){
                        view.makeToast("One of song is playing from this Artist.")
                        
                    }else{
                        allSongs.forEach { song in
                            //remove songs from local database
                            if let playUrl = song.playUrl{
                                SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                            }
                        }
                        //delete album from album database
                        DatabaseContext.shared.deleteArtist(where: cc.artistId ?? "")
                        //delete songs from song database
                        DatabaseContext.shared.deleteSongsByArtist(where: cc.artistId ?? "")
                    }
                }else if contentType == .podcast{
                    if MusicPlayerV3.isAudioPlaying && MusicPlayerV3.audioPlayer.currentItem?.contentId == cc.contentID{
                        view.makeToast("This Podcase is playing")
                    }else{
                        DatabaseContext.shared.removePodcast(with: cc.contentID ?? "")
                        if let playUrl = cc.playUrl{
                            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                        }
                    }
                }
            }
        }
        onFilterPressed(type: downloadType)
    }
}

extension DownloadVC : UIScrollViewDelegate{
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerConstraint.constant = calculateHeight()
    }
}

extension DownloadVC : JRHeaderDelegate{
    func onSearchCancel() {
        view.endEditing(true)
    }
    func onSearchText(text: String) {
        if text.isEmpty || text.elementsEqual(""){
            dataSource = dataSourceAll
            collectionView.reloadData()
            return
        }
        dataSource = dataSourceAll.filter({ dd in
            guard let title = dd.title else {return false}
            return title.lowercased().contains(text.lowercased())
        })
        collectionView.reloadData()
    }
}

extension DownloadVC : MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol,type : MoreMenuType) {
        //send event to firebasee analytics
        AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
        if downloadType == .History{
            switch type {
            case .Songs:
                //add to song database
                DatabaseContext.shared.addDownload(content: content,isSingleDownload: true)
                SDDownloadManager.shared.checkDatabase()
                //remove from current list
                self.dataSourceAll.removeAll(where: {$0.contentID == content.contentID})
                self.dataSource = self.dataSourceAll
                self.collectionView.reloadData()
                break
            case .Album:
                ShadhinCore.instance.api.getAlbumByContentID(contentId: content.contentID ?? "") { result in
                    switch result{
                    case .success(let response):
                        //download start post to server
                        ShadhinApi().downloadCompletePost(model: content)
                        //add to local database
                        DatabaseContext.shared.addAlbum(with: content)
                        //add song to download quary
                        self.downloadAlbum(data: response.data, albumId: content.contentID ?? "")
                        //remove this content form list
                        self.dataSource.removeAll { dcm in
                            dcm.contentID == content.contentID
                        }
                        self.collectionView.reloadData()
                        break
                    case .failure(let error):
                        Log.error(error.localizedDescription)
                    }
                }
            case .Artist:
                break
            case .Podcast:
                //add to song database
                DatabaseContext.shared.addDownload(content: content,isSingleDownload: true)
                SDDownloadManager.shared.checkDatabase()
                //remove from current list
                self.dataSourceAll.removeAll(where: {$0.contentID == content.contentID})
                self.dataSource = self.dataSourceAll
                self.collectionView.reloadData()
                break
            case .Playlist:
                ShadhinCore.instance.api.getAlbumOrPlaylistOrSingleDataById(
                    ContentID: content.contentID ?? "",
                    mediaType: .playlist) { _data, error, img in
                        guard let data = _data else {
                            return Log.error(error?.localizedDescription ?? "")
                        }
                        //add to playlist
                        DatabaseContext.shared.addPlaylist(content: content)
                        //download all song
                        self.downloadPlaylist(data : data,playlistID: content.contentID ?? "")
                        //remove this content form list
                        self.dataSource.removeAll { dcm in
                            dcm.contentID == content.contentID
                        }
                        self.collectionView.reloadData()
                    }
//                ShadhinCore.instance.api.getPlaylistBy(contentID: content.contentID ?? "") { result in
//                    switch result{
//                    case .success(let response):
//                        //add to playlist
//                        DatabaseContext.shared.addPlaylist(content: content)
//                        //download all song
//                        self.downloadPlaylist(data : response.data,playlistID: content.contentID ?? "")
//                        //remove this content form list
//                        self.dataSource.removeAll { dcm in
//                            dcm.contentID == content.contentID
//                        }
//                        self.collectionView.reloadData()
//                    case .failure(let error):
//                        Log.error(error.localizedDescription)
//                    }
//                }
                break
            case .None:
                break
            case .PodCastVideo:
                break
            case .Video:
                break
            case .UserPlaylist:
                break
            case .AudioBook:
                //TODO: - Make it work!
                print("On Downlaod")
                
            case .ShortsSong:
                print("Download")
            }
        }
    }
    
    func onRemoveDownload(content: CommonContentProtocol,type : MoreMenuType) {
        switch type {
        case .Songs:
            if MusicPlayerV3.isAudioPlaying && content.contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId{
                view.makeToast("This song is playing")
            }else{
                //remove from local storage
                SDFileUtils.removeItemFromDirectory(urlName: content.playUrl ?? "")
                //remove from datababse
                DatabaseContext.shared.deleteSong(where: content.contentID ?? "")
            }
        case .Album:
            let songs = DatabaseContext.shared.getSonngsByAlbum(where: content.albumId ?? "")
            //check music is playing or not. if any song is playing from this album.
            //album not deleted
            if let _ = songs.first(where: {$0.contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId}), MusicPlayerV3.isAudioPlaying{
                view.makeToast("One of song is playing from this Album.")
                return
            }
            songs.forEach { song in
                if let playUrl = song.playUrl{
                    SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                }
            }
            //delete album from database
            DatabaseContext.shared.deleteAlbum(where: content.albumId ?? "")
            //delete all songs which contain this album
            DatabaseContext.shared.deleteSongsByAlbum(where: content.albumId ??  "")
        case .Artist:
            let songs = DatabaseContext.shared.getSonngsByArtist(where: content.artistId ?? "")
            //check any music is playing from this artist. if playing dont delete this artist
            if let _ = songs.first(where: {$0.contentID == MusicPlayerV3.audioPlayer.currentItem?.contentId}), MusicPlayerV3.isAudioPlaying{
                view.makeToast("One of song is playing from this Artist.")
                return
            }
            songs.forEach { song in
                if let playUrl = song.playUrl{
                    SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                }
            }
            //delete artist from database
            DatabaseContext.shared.deleteArtist(where: content.artistId ?? "")
            //detele artist songs from song database
            DatabaseContext.shared.deleteSongsByArtist(where: content.artistId ??  "")
            //delete download history from server
            //there is no artist type define in system so its no need to call
            //ShadhinApi().deleteDownloadHistory(contentId: content.contentID ?? "", contentType: content.contentType ??  ContentType.Song.rawValue)
        case .Podcast:
            if MusicPlayerV3.isAudioPlaying && MusicPlayerV3.audioPlayer.currentItem?.contentId == content.contentID{
                view.makeToast("This Podcase is playing")
            }else{
                //remove podcast from podcast database
                DatabaseContext.shared.removePodcast(with: content.contentID ?? "")
                //remove from local storage
                if let playUrl = content.playUrl{
                    SDFileUtils.removeItemFromDirectory(urlName: playUrl)
                }
            }
        case .Playlist:
            guard let playlistID = content.contentID else {
                return
            }
            if MusicPlayerV3.isAudioPlaying && DatabaseContext.shared.isPlayListSongExist(songID: MusicPlayerV3.audioPlayer.currentItem?.contentId ?? "", playlistID: playlistID){
                view.makeToast("One of song is playing from this playlist")
            }else{
                //remove playlist from playlist database
                DatabaseContext.shared.removePlaylistBy(id: playlistID)
                //get all songs from playlist song database
                let songs = DatabaseContext.shared.getPlayListSongsBy(playlistID: playlistID)
                songs.forEach { pls in
                    if let song = DatabaseContext.shared.getSongBy(id: pls.songID!){
                        //remove song from local database
                        if let playurl = song.playUrl{
                            SDFileUtils.removeItemFromDirectory(urlName: playurl)
                        }
                    }
                    //delete song from song database
                    DatabaseContext.shared.deleteSong(where: pls.songID!)
                }
                //delete all songs from playlistsong databbase
                DatabaseContext.shared.playListSongBatchDeleteBy(playlistID: playlistID)
            }
        case .PodCastVideo:
            break
        case .None:
            break
        case .Video:
            break
        case .UserPlaylist:
            break
        case .AudioBook:
            print("Aduio Book Download")
            break
        case .ShortsSong:
            print("ShortsSong Download")
            break
        }
        
        RecentlyPlayedDatabase.instance.deleteDataFromDatabase(contentID: content.contentID ?? "")
        onFilterPressed(type: downloadType)
        collectionView.reloadData()
    }
    
    func onRemoveFromHistory(content: CommonContentProtocol) {
        ShadhinCore.instance.api.deleteDownloadHistory(contents: [content])
        self.dataSourceAll.removeAll(where: {$0.contentID == content.contentID})
        self.dataSource.removeAll(where: {$0.contentID == content.contentID})
    }
    func gotoAlbum(content: CommonContentProtocol) {
        let vc = goAlbumVC(isFromThreeDotMenu: true, content: content)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func gotoArtist(content: CommonContentProtocol) {
        let vc = goArtistVC(content: content)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func addToPlaylist(content: CommonContentProtocol) {
        goAddPlaylistVC(content: content)
    }
    func shareMyPlaylist(content: CommonContentProtocol) {
        SwiftEntryKit.dismiss()

        guard let name = content.title,
            let contentID = content.contentID,
            let imgUrl = content.image else{
                self.view.makeToast("Playlist is empty")
                return
        }
      //  DeepLinks.createDeepLinkMyPlaylist(name: name, contentID: contentID, imgUrl: imgUrl, controller: self)
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
    
    }
}

extension DownloadVC{
    private func historyDatacheck(){
        var removedID : [String] = []
        self.dataSourceAll.forEach { dcm in
            let contentType = dcm.contentType
            var type : ContentType = .Song
            if contentType!.count > 1{
                type = ContentType(rawValue: String(contentType!.prefix(2).uppercased())) ?? .None
            }else {
                type = ContentType(rawValue: contentType!) ?? .Song
            }
            switch type {
            case .Song:
                if DatabaseContext.shared.isSongExist(contentId: dcm.contentID ?? ""){
                    removedID.append(dcm.contentID!)
                }
            case .PodCast,.PodCastTrack,.PodCastShow:
                if DatabaseContext.shared.isPodcastExist(where: dcm.contentID ?? ""){
                    removedID.append(dcm.contentID!)
                }
            case .Album:
                if DatabaseContext.shared.isAlbumExist(for: dcm.contentID!){
                    removedID.append(dcm.contentID!)
                }
            case .Artist:
                if DatabaseContext.shared.isArtistExist(for: dcm.contentID!){
                    removedID.append(dcm.contentID!)
                }
            case .Playlist,.UserPlaylist:
                if DatabaseContext.shared.isPlaylistExist(playlistID: dcm.contentID!){
                    removedID.append(dcm.contentID!)
                }
            case .None:
                break
            }
        }
        self.dataSourceAll.removeAll(where: {removedID.contains($0.contentID!)})
        self.dataSource = self.dataSourceAll
        self.collectionView.reloadData()
    }
    private func downloadAlbum(data : [AlbumModel],albumId : String){
        data.forEach { amm in
            var content : CommonContentProtocol = amm.getDataContentProtocal()
            content.albumId = albumId
            if DatabaseContext.shared.isSongExist(contentId: content.contentID ?? ""){
                //song all ready downloaded
            }else{
                DatabaseContext.shared.addDownload(content: content,isSingleDownload: false)
            }
        }
        SDDownloadManager.shared.checkDatabase()
    }
    private func downloadPlaylist(data : [PlaylistContentModel], playlistID : String){
        data.forEach { amm in
            let content : CommonContentProtocol = amm.getDataContentProtocal()
            //add song to  playlist songs database
            DatabaseContext.shared.addSongInPlaylist(songID: content.contentID ?? "", playlistID: playlistID)
            if DatabaseContext.shared.isSongExist(contentId: content.contentID ?? ""){
                //song all ready downloaded
            }else{
                DatabaseContext.shared.addDownload(content: content,isSingleDownload: false)
            }
        }
        SDDownloadManager.shared.checkDatabase()
    }
    
    private func downloadPlaylist(data : [CommonContentProtocol], playlistID : String){
        data.forEach { content in
            //let content : ContentDataProtocol = amm.getDataContentProtocal()
            //add song to  playlist songs database
            DatabaseContext.shared.addSongInPlaylist(songID: content.contentID ?? "", playlistID: playlistID)
            if DatabaseContext.shared.isSongExist(contentId: content.contentID ?? ""){
                //song all ready downloaded
            }else{
                DatabaseContext.shared.addDownload(content: content,isSingleDownload: false)
            }
        }
        SDDownloadManager.shared.checkDatabase()
    }
    
    private func downloadAllHistory(){
    
        self.dataSourceAll.forEach { dcm in
            let contentType = dcm.contentType
            var type : ContentType = .Song
            if contentType!.count > 1{
                type = ContentType(rawValue: String(contentType!.prefix(2).uppercased())) ?? .None
            }else {
                type = ContentType(rawValue: contentType!) ?? .Song
            }
            switch type {
            case .Song:
                //download start post to server
                ShadhinApi().downloadCompletePost(model: dcm)
                //add to song database
                DatabaseContext.shared.addDownload(content: dcm,isSingleDownload: true)
                
                break
            case .PodCastTrack,.PodCastShow,.PodCast:
                //download start post to server
                ShadhinApi().downloadCompletePost(model: dcm)
                //add to song database
                DatabaseContext.shared.addDownload(content: dcm,isSingleDownload: false)
                
                break
            case .Album:
                ShadhinCore.instance.api.getAlbumByContentID(contentId: dcm.contentID ?? "") { result in
                    switch result{
                    case .success(let response):
                        //download start post to server
                        ShadhinApi().downloadCompletePost(model: dcm)
                        //add to local database
                        DatabaseContext.shared.addAlbum(with: dcm)
                        //add song to download quary
                        self.downloadAlbum(data: response.data, albumId: dcm.contentID ?? "")
                    case .failure(let error):
                        Log.error(error.localizedDescription)
                    }
                }
                break
            case .Artist:
                break
            case .Playlist:
                ShadhinCore.instance.api.getAlbumOrPlaylistOrSingleDataById(
                    ContentID: dcm.contentID ?? "",
                    mediaType: .playlist) { _data, error, img in
                        guard let data = _data else {
                            return Log.error(error?.localizedDescription ?? "")
                        }
                        //download start post to server
                        ShadhinApi().downloadCompletePost(model: dcm)
                        //add to playlist
                        DatabaseContext.shared.addPlaylist(content: dcm)
                        //download all song
                        self.downloadPlaylist(data : data, playlistID: dcm.contentID ?? "")
                    }
            case .UserPlaylist:
                
                break
            case .None:
                break
            }
        }
        SDDownloadManager.shared.checkDatabase()
        dataSourceAll.removeAll()
        dataSource.removeAll()
        collectionView.reloadData()
    }
    private func historyDownloadStop(){
        
        SDDownloadManager.shared.cancelAllDownloads()
    }
}
