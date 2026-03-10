//
//  PlaylistOrSingleDetailsVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 8/1/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class PlaylistOrSingleDetailsVC: UIViewController {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var discoverModel: CommonContentProtocol!
    var isFromThreeDotMenu = true
    var viewModel: PlaylistOrSingleDetailsVM!
    private var artistSongs = [CommonContent_V2]()
    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBannerMax: UIView!
    
    var songsAndPlaylists                           = [CommonContentProtocol]()
    var latestTracks                                = [CommonContentProtocol]()
    var artistsInPlaylist : [CommonContentProtocol]   = []
    var suggestedPairedPlaylists                    = [(CommonContentProtocol, CommonContentProtocol?)]()
    var suggestedPlaylists : [CommonContentProtocol]{
        set{
            let value = newValue.shuffled()
            for i in stride(from: 0, to: value.count - 1, by: 2) {
                let item0 : CommonContentProtocol = value[i]
                var item1 : CommonContentProtocol? = nil
                if i+1 < value.count{
                    item1 = value[i+1]
                }
                suggestedPairedPlaylists.append((item0, item1))
            }
        }
        get{
            []
        }
    }
    
    var totalDurations = ""
    var contentID = ""
    var contentType =  "P"
    var isListFav = false
    var willLoadAds = false
    var gotFav = false
    var defaultToAlbumLoad = false
    
    private let downloadManager = SDDownloadManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = .init(self)
        view.backgroundColor = .customBGColor()
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableFooterView = UIView()
//        tableView.register(NativeSmallAdTCell.nib, forCellReuseIdentifier: NativeSmallAdTCell.identifier)
//        tableView.register(NativeAdMaxSmall.nib, forCellReuseIdentifier: NativeAdMaxSmall.identifier)
        tableView.register(TracksHiddenSegmentTC.nib, forCellReuseIdentifier: TracksHiddenSegmentTC.identifier)
        tableView.register(ArtistsInPlaylistTC.nib, forCellReuseIdentifier: ArtistsInPlaylistTC.identifier)
        tableView.register(SuggestedPlaylistsTC.nib, forCellReuseIdentifier: SuggestedPlaylistsTC.identifier)
        
        if MusicPlayerV3.audioPlayer.state == .stopped {
            MusicPlayerV3.isAudioPlaying = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.buttonImgChanged), name: NSNotification.Name("didRecivedData"), object: nil)
        
        if discoverModel.contentType == "S"{
            defaultToAlbumLoad = true
        }else{
            defaultToAlbumLoad = false 
        }
        
        noInternetView.isHidden = true
        
        noInternetView.retry = {[weak self] in
            guard let self  = self else { return}
            if ConnectionManager.shared.isNetworkAvailable{
                setContentData()
            }
        }
        
        noInternetView.gotoDownload = {[weak self] in
            guard let self  = self else { return}
            if self.checkProUser(){
                let vc = DownloadVC.instantiateNib()
                vc.selectedDownloadSeg = .init(title: discoverModel.contentType == "S" ? ^String.Downloads.songs  : ^String.Downloads.playlist , type: discoverModel.contentType == "S" ? .Songs :  .Playlist)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        if ConnectionManager.shared.isNetworkAvailable{
            setContentData()
        }else{
            noInternetView.isHidden = false
            tableView.isHidden = true
        }
      //  ChorkiAudioAd.instance.fireEvent()
        
    }
    
    func setContentData(){
        latestTracks.append(discoverModel)
        viewModel.checkRbtForSingleOrRelease()
        viewModel.getDataFromServer()
    }
    
    func dataFound(){
        tableView.isHidden = false
        noInternetView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    //    loadAds()
        //after start download update table view for show progress
        NotificationCenter.default.addObserver(forName: .DownloadStartNotify, object: nil, queue: .main) { notificationn in
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func buttonImgChanged() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MusicSongsViewCell else {return}
        if MusicPlayerV3.isAudioPlaying {
            cell.playPauseBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        }else {
            cell.playPauseBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        }
    }
    
    private func playingSongFromTopButton() {
        if self.discoverModel.contentType?.uppercased() == "S" || discoverModel.contentType?.uppercased() == "R"{
            self.openMusicPlayerV3(musicData: latestTracks, songIndex: 0, isRadio: false,rootModel: discoverModel)
        } else {
            self.openMusicPlayerV3(musicData: songsAndPlaylists, songIndex: 0, isRadio: false, playlistId: contentID,rootModel: discoverModel)
        }
    }
    
    private func openPreview(){
        let vc = PlaylistSongsPreviewVC.instantiateNib()
        vc.songsInPlaylist = songsAndPlaylists
        vc.playlistDetails = discoverModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func shufflePlay(){
        openMusicPlayerV3(musicData:songsAndPlaylists, songIndex:0, isRadio: false,rootModel: discoverModel)
        MusicPlayerV3.shared.turnOnShuffle()
    }
    
    func songDurationsCalculate(_ durations: [CommonContentProtocol]) {
        var totalDu = 0
        for item in durations {
            totalDu += Int(item.duration ?? "0") ?? 0
        }
        self.totalDurations = totalDu.formatTime()
    }
}

// MARK: - Table View

extension PlaylistOrSingleDetailsVC: UITableViewDelegate,UITableViewDataSource {
    
    func isIndexAnAd(index : Int) -> Bool{
        if !willLoadAds{
            return false
        }
        return index % 4 == 0
    }
    
    func getAdAdjustedRow(row: Int) -> Int{
        if !willLoadAds{
            return row
        }
        let n = Double(row) / 4.0
        let _n = Int(n.rounded(.up))
        let adjustedSection = row - (1 * _n)
        return adjustedSection
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 2:
            if defaultToAlbumLoad{
                return 1
            }
            return 0
        case 3:
            return artistsInPlaylist.count > 0 ? 1 : 0
        case 4:
            return suggestedPairedPlaylists.count
        default:
            var count = 0
            if discoverModel.contentType?.uppercased() == "S" || discoverModel.contentType?.uppercased() == "R"{
                count = latestTracks.count
            }else {
                if viewModel.viewType == .tracksHidden{
                    return 1
                }
                count = songsAndPlaylists.count
            }
            if willLoadAds{
                let adsCountDouble = Double(count) / 3.0
                let adsCountInt = Int(adsCountDouble.rounded(.up))
                count += adsCountInt
            }
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MusicSongsViewCell") as! MusicSongsViewCell
            
            cell.configureCell(model: discoverModel, trackIndex: latestTracks.count, albumsAndPlaylistsIndex: songsAndPlaylists.count, totalDurations: self.totalDurations)
            
            cell.didTapPlayPauseButton {
                
                self.countButtonTouch()
                
                var contentid = ""
                if self.discoverModel.contentType?.uppercased() == "S" ||  self.discoverModel.contentType?.uppercased() == "R"{
                    contentid = self.latestTracks[0].contentID ?? ""
                }else {
                    guard self.songsAndPlaylists.count > 0 else {return }
                    contentid = self.songsAndPlaylists[0].contentID ?? ""
                }
                
                if MusicPlayerV3.audioPlayer.currentItem?.contentId == contentid{
                    if MusicPlayerV3.isAudioPlaying{
                        cell.playPauseBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                        if MusicPlayerV3.audioPlayer.state == .stopped{
                            self.playingSongFromTopButton()
                        }else{
                            MusicPlayerV3.audioPlayer.resume()
                        }
                    }else{
                        MusicPlayerV3.audioPlayer.pause()
                        cell.playPauseBtn.setImage(UIImage(named: "ic_Play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    }
                }else{
                    cell.playPauseBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    self.playingSongFromTopButton()
                    MusicPlayerV3.isAudioPlaying = true
                }
                MusicPlayerV3.isAudioPlaying.toggle()

            }
            
            cell.didTapBackButton {
                self.navigationController?.popViewController(animated: true)
               // self.dismiss(animated: true, completion: nil)
            }
            
            cell.didTapShareButton {
                DeepLinks.createLinkTest(controller: self)
            }
            
            cell.shareBtn.setClickListener {
                DeepLinks.createLinkTest(controller: self)
            }
            
            
            if gotFav{
                cell.favouriteBtn.isHidden = false
                if isListFav{
                    cell.favouriteBtn.setImage(UIImage(named: "ic_favorite_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }else{
                    cell.favouriteBtn.setImage(UIImage(named: "ic_favorite_n",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
                cell.favouriteBtn.setClickListener {
                    self.viewModel.addDeleteFav()
                }
            }
            
            return cell
        case 1:
            
            if viewModel.viewType == .tracksHidden{
                let cell =  tableView.dequeueReusableCell(withIdentifier: TracksHiddenSegmentTC.identifier, for: indexPath) as! TracksHiddenSegmentTC
                cell.setData(contents: songsAndPlaylists)
                cell.seeAll.setClickListener {
                    self.openPreview()
                }
                return cell
            }
            
            var index = indexPath.row
//            
//            if isIndexAnAd(index: index){
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    let cell =  tableView.dequeueReusableCell(withIdentifier: NativeSmallAdTCell.identifier, for: indexPath) as! NativeSmallAdTCell
//                    if let nav = self.navigationController, let ad = NativeAdLoader.shared(nav).getNativeAd(){
//                        cell.loadAd(nativeAd: ad)
//                    }
//                    return cell
//
//                }else if useAdProvider == "applovin"{
//                    let cell =  tableView.dequeueReusableCell(withIdentifier: NativeAdMaxSmall.identifier, for: indexPath) as! NativeAdMaxSmall
//                    cell.tableview = self.tableView
//                    return cell
//                }
//            }
            
            index = getAdAdjustedRow(row: index)
            
            var item : CommonContentProtocol!
            if self.discoverModel.contentType?.uppercased() == "S" ||  self.discoverModel.contentType?.uppercased() == "R"{
                item = self.latestTracks[index]
            }else {
                item = self.songsAndPlaylists[index]
            }
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MusicSongsListCell") as! MusicSongsListCell

            if discoverModel.contentType?.uppercased() == "S" || discoverModel.contentType?.uppercased() == "R" {
                cell.configureTrackCell(model: latestTracks[index])
            }else {
                cell.configureCell(model: songsAndPlaylists[index], contentType: discoverModel.contentType?.uppercased() ?? "")
            }
            cell.didTappedWelcomeTuneSet {
                let popupVC = SetWelcomeTunePopupVC.instantiateNib()
                popupVC.contentId = item.contentID ?? ""  // ✅ individual song's contentID
                popupVC.topImageView = cell.songsImgView.image
                popupVC.musicName = cell.songTitleLbl.text ?? ""
                popupVC.artsitName = cell.songArtistLbl.text ?? ""
                var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                attribute.positionConstraints.size = .init(width: .fill, height: .constant(value: 740))
                SwiftEntryKit.display(entry: popupVC, using: attribute)
            }
            cell.didThreeDotMenuTapped {
                let menu = MoreMenuVC()
                menu.data = item
                menu.delegate = self
                menu.menuType = .Songs
                menu.openForm = .Playlist
                var height = MenuLoader.getHeightFor(vc: .Playlist, type: .Songs, operators: self.discoverModel.rbtOperators)
                
                if let _ = item.albumId{
                    
                }else{
                    height = height - 50
                }
                
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none

                SwiftEntryKit.display(entry: menu, using: attribute)
            }
            
            if item.hasRBT ?? false {
                cell.rbtBtn.isHidden = false
                cell.songsDurationLbl.isHidden = true
                cell.rbtBtn.setClickListener {
                    CallerTunePaymentOptionsVC.setRbtOnContent(self, item)
                }
            }else{
                cell.rbtBtn.isHidden = true
                cell.songsDurationLbl.isHidden = false
                cell.songsDurationLbl.isHidden = true
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistAlbumListCell") as! ArtistAlbumListCell
            if defaultToAlbumLoad{
                cell.configureCell(contentID: discoverModel.artistId ?? discoverModel.contentID ?? "")
                cell.didSelectArtist = nil
                cell.didSelectAlbumList { (content) in
                    let alert = NoInternetPopUpVC.instantiateNib()
                    alert.gotoDownload = {[weak self] in
                        guard let self = self else {return}
                        if self.checkProUser(){
                            let vc = DownloadVC.instantiateNib()
                            vc.selectedDownloadSeg =  .init(title: discoverModel.contentType == "S" ? ^String.Downloads.songs  : ^String.Downloads.playlist , type: discoverModel.contentType == "S" ? .Songs :  .Playlist)
                            self.navigationController?.pushViewController(vc, animated: true)
                            SwiftEntryKit.dismiss()
                        }
                        
                    }
                    alert.retry = {[weak self] in
                        guard let self = self else {return}
                        if ConnectionManager.shared.isNetworkAvailable{
                            let vc = self.goAlbumVC(isFromThreeDotMenu: false, content: content)
                            self.navigationController?.pushViewController(vc, animated: true)
                            SwiftEntryKit.dismiss()
                        }
                    }
                    
                    if ConnectionManager.shared.isNetworkAvailable{
                        let vc = self.goAlbumVC(isFromThreeDotMenu: false, content: content)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }else{
                        SwiftEntryKit.display(entry: alert, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
                    }
                    
                }
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArtistsInPlaylistTC.identifier) as! ArtistsInPlaylistTC
            cell.setData(artistsInPlaylist)
            cell.didSelectArtist = {
                index in
                let artistContent = self.artistsInPlaylist[index]
                
                let alert = NoInternetPopUpVC.instantiateNib()
                alert.gotoDownload = {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC.instantiateNib()
                        vc.selectedDownloadSeg =  .init(title: discoverModel.contentType == "S" ? ^String.Downloads.songs  : ^String.Downloads.playlist , type: discoverModel.contentType == "S" ? .Songs :  .Playlist)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                    
                }
                alert.retry = {[weak self] in
                    guard let self = self else {return}
                    if ConnectionManager.shared.isNetworkAvailable{
                        let vc = self.goArtistVC(content: artistContent)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                }
                
                if ConnectionManager.shared.isNetworkAvailable{
                    let vc = self.goArtistVC(content: artistContent)
                    self.navigationController?.pushViewController(vc, animated: true)
                    SwiftEntryKit.dismiss()
                }else{
                    SwiftEntryKit.display(entry: alert, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
                }
                
                
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: SuggestedPlaylistsTC.identifier) as! SuggestedPlaylistsTC
            cell.setData(items: suggestedPairedPlaylists[indexPath.row]) {
                playlist in
                let alert = NoInternetPopUpVC.instantiateNib()
                alert.gotoDownload = {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC.instantiateNib()
                        vc.selectedDownloadSeg =  .init(title: discoverModel.contentType == "S" ? ^String.Downloads.songs  : ^String.Downloads.playlist , type: discoverModel.contentType == "S" ? .Songs :  .Playlist)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                    
                }
                alert.retry = {[weak self] in
                    guard let self = self else {return}
                    if ConnectionManager.shared.isNetworkAvailable{
                        self.openPlaylist(item: playlist)
                        SwiftEntryKit.dismiss()
                    }
                }
                
                if ConnectionManager.shared.isNetworkAvailable{
                    self.openPlaylist(item: playlist)
                    SwiftEntryKit.dismiss()
                }else{
                    SwiftEntryKit.display(entry: alert, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
                }
                
            }
            return cell
        default:
            return .init()
        }
    }
    
    func openPlaylist(item: CommonContentProtocol){
        self.discoverModel = item
        setContentData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 1:
            
            if viewModel.viewType == .tracksHidden{
                return //todo
            }
            if isIndexAnAd(index: indexPath.row){
                return
            }
            let adjustedRow = getAdAdjustedRow(row: indexPath.row)
            
            if discoverModel.contentType?.uppercased() == "S" || discoverModel.contentType?.uppercased() == "R"{
                openMusicPlayerV3(musicData: latestTracks, songIndex: adjustedRow, isRadio: false,rootModel: discoverModel)
            }else {
                openMusicPlayerV3(musicData: songsAndPlaylists, songIndex: adjustedRow, isRadio: false, playlistId: contentID,rootModel: discoverModel)
            }
            
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MusicSongsViewCell else {return}
            cell.playPauseBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            MusicPlayerV3.isAudioPlaying = false
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let newHeader = ShuffleAndDownloadView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            var isSwitchHide = true
            var title = ^String.Downloads.download
            //check this controller open for latest track or from playlist
            newHeader.downloadProgress.stopAnimating()

            if discoverModel.contentType?.uppercased() == "S"{
                    return nil
            }
//            //check artist allready download or not
            
            var isDownloaded = false
            var isDownloading = false
            if discoverModel.contentType?.uppercased() == "S" {
                isDownloaded = DatabaseContext.shared.isSongExist(contentId: discoverModel.contentID ?? "")
            } else {
                isDownloaded = DatabaseContext.shared.isPlaylistExist(playlistID: discoverModel.contentID ?? "")
                isDownloading = DatabaseContext.shared.isPlaylistDownloading(playlistID: discoverModel.contentID ?? "")
            }
    
            newHeader.downloadProgress.isHidden = true
            if isDownloading {
                newHeader.downloadProgress.isHidden = false
                newHeader.downloadProgress.startAnimating()
                newHeader.downloadButton.setImage(UIImage(named: "music_v4/ic_stop",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            }
            
            else if isDownloaded {
                newHeader.downloadButton.setImage(UIImage(named: "downloadComplete",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for:.normal)
                newHeader.downloadProgress.stopAnimating()
            }  else {
                newHeader.downloadButton.setImage(UIImage(named: "download",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                newHeader.downloadProgress.stopAnimating()
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
             newHeader.contentID = discoverModel.contentID
             newHeader.contentType = discoverModel.contentType ?? "P"
             newHeader.updateShuffleBtn()
             
             newHeader.shuffleButton.setClickListener {
                 guard let playListOrSingleId = self.discoverModel.contentID else {
                     return
                 }
                 //if checked remove(){update ui} else add(){update ui}
                 if ShadhinCore.instance.defaults.checkShuffle(contentId:playListOrSingleId, contentType: self.discoverModel.contentType ?? "P") {
                     ShadhinCore.instance.defaults.removeShuffle(contentId:playListOrSingleId, contentType: self.discoverModel.contentType ?? "P")
                 } else {
                     ShadhinCore.instance.defaults.addShuffle(contentId:playListOrSingleId, contentType: self.discoverModel.contentType ?? "P")
                 }
                 NotificationCenter.default.post(name: .init("ShuffleListNotify"), object: nil)
             }
            return newHeader
        case 2:
            guard defaultToAlbumLoad else {return nil}
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
            let label = UILabel(frame: CGRect(x:12, y:10, width:tableView.frame.size.width, height:30))
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = "Albums"
            view.addSubview(label)
            view.backgroundColor = .clear
            return view
        case 3:
            guard !artistsInPlaylist.isEmpty else {return nil}
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
            let label = UILabel(frame: CGRect(x:12, y:10, width:tableView.frame.size.width, height:30))
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = "Artists"
            view.addSubview(label)
            view.backgroundColor = .clear
            return view
        case 4:
            guard !suggestedPairedPlaylists.isEmpty else {return nil}
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
            let label = UILabel(frame: CGRect(x:12, y:10, width:tableView.frame.size.width, height:30))
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = "You Might Like"
            view.addSubview(label)
            view.backgroundColor = .clear
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            if discoverModel.contentType?.uppercased() == "S" {
                    return CGFloat.leastNormalMagnitude
            }
            return 50
        case 2:
            if defaultToAlbumLoad{
                return 50
            }
            return CGFloat.leastNormalMagnitude
        case 3:
            if artistsInPlaylist.isEmpty{
                return CGFloat.leastNormalMagnitude
            }
            return 50
        case 4:
            if suggestedPairedPlaylists.isEmpty{
                return CGFloat.leastNormalMagnitude
            }
            return 50
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 408
        case 1:
            if viewModel.viewType == .tracksHidden{
                return TracksHiddenSegmentTC.size
            }
//            if isIndexAnAd(index: indexPath.row){
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    return NativeSmallAdTCell.size
//                }else if useAdProvider == "applovin"{
//                    return NativeAdMaxSmall.size
//                }else{
//                    return .leastNormalMagnitude
//                }
//            }
            return 70
        case 2:
            if defaultToAlbumLoad{
                return 186
            }
            return CGFloat.leastNormalMagnitude
        case 3:
            return ArtistsInPlaylistTC.size
        case 4:
            return SuggestedPlaylistsTC.size
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
}

//MARK: mennu delegate
extension PlaylistOrSingleDetailsVC: MoreMenuDelegate{
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
            }else{
                //no need to do any thing
                //all case handle in cell
            }
        })
        tableView.reloadData()
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

//MARK: download quary maintain
extension PlaylistOrSingleDetailsVC{
    func downloadAllSongs(){
        guard try! Reachability().connection != .unavailable else {return}

        guard ShadhinCore.instance.isUserPro
        else {
         //   self.goSubscriptionTypeVC()
            SubscriptionPopUpVC.show(self)
            return
        }
        guard let playListID = discoverModel.contentID else{
            return
        }
        //post download info to server
        let model : CommonContentProtocol = discoverModel
        ShadhinApi().downloadCompletePost(model: model)
        //send event to firebasee analytics
        AnalyticsEvents.downloadEvent(with: model.contentType, contentID: model.contentID, contentTitle: model.title)
        //add to artist datababse
        DatabaseContext.shared.addPlaylist(content: discoverModel)
        
        songsAndPlaylists.forEach { data in
            let content : CommonContentProtocol = data
            
            //add song to  playlist songs database
            DatabaseContext.shared.addSongInPlaylist(songID: content.contentID ?? "", playlistID: playListID)
            do{
                if let _ =  try DatabaseContext.shared.isSongExist(contentId: data.contentID!){
                    //add songs to playlist song database
                    
                    //Log.info("Song exist")
                }else{
                    DatabaseContext.shared.addDownload(content: content,playlistID: playListID,isSingleDownload: false)
                }
            }catch{
                Log.error(error.localizedDescription)
            }
        }
        SDDownloadManager.shared.checkDatabase()
        //tableView.reloadData()
    }
    func cancellAllDownload(){
        guard let playListID = discoverModel.contentID else{
            return
        }
        //delete playlist from playlist database
        DatabaseContext.shared.removePlaylistBy(id: playListID)
        //delete if download remaing
        DatabaseContext.shared.downloadRemaingBatchDeleteByPlayList(where: playListID)
        //delete all song from playlist song database
        DatabaseContext.shared.playListSongBatchDeleteBy(playlistID: playListID)
        //delete all download request
        for song in songsAndPlaylists{
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
