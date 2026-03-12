//
//  MusicAllListVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/13/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class MusicAlbumListVC: UIViewController {
    
    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBannerMax: UIView!
    private var songsAndAlbums = [CommonContentProtocol]()
    
    var discoverModel: CommonContentProtocol!
    var id = ""
    var isFromThreeDotMenu = false
    var totalDurations = ""
    var isListFav = false
    var gotFav = false
    var tagId = "4389c11a"
    var isVmaxAdShow = false
    private var isVmaxAdFailed = false
    
    var willLoadAds = false
    private let downloadManager = SDDownloadManager.shared

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .customBGColor()
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableFooterView = UIView()
        tableView.register(VmaxMyProfileTVCell.nib, forCellReuseIdentifier: VmaxMyProfileTVCell.identifier)

        noInternetView.isHidden = true
        noInternetView.retry = {[weak self] in
            guard let self  = self else { return}
            if ConnectionManager.shared.isNetworkAvailable{
                getDataFromServer()
            }
        }
        
        noInternetView.gotoDownload = {[weak self] in
            guard let self  = self else { return}
            if self.checkProUser(){
                let vc = DownloadVC.instantiateNib()
                vc.selectedDownloadSeg = .init(title: ^String.Downloads.album, type: .Album)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if MusicPlayerV3.audioPlayer.state == .stopped {
            MusicPlayerV3.isAudioPlaying = true
        }
        //  ChorkiAudioAd.instance.fireEvent()
        NotificationCenter.default.addObserver(self, selector: #selector(self.buttonImgChanged), name: NSNotification.Name("didRecivedData"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
        self.isVmaxAdShow = ShadhinGP.shared.isVmaxInitialized &&
            !ShadhinCore.instance.isUserPro &&
            VMAX_AD_ITEM_DATA.contains(where: { $0.adId == tagId })

        if ConnectionManager.shared.isNetworkAvailable{
            getDataFromServer()
        }else{
            tableView.isHidden = true
            noInternetView.isHidden = false
        }
        
        //   loadAds()
        //after start download update table view for show progress
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableOnDownload), name: .DownloadStartNotify, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .DownloadStartNotify, object: nil)
    }

    @objc private func reloadTableOnDownload() {
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        //    InterstitialAdmob.instance.showAd(fromRootViewController: self)
    }
    
    //    private func loadAds(){
    //        guard let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String,
    //        !ShadhinCore.instance.isUserPro else {
    //            removeAd()
    //            return
    //        }
    //        if useAdProvider == "google"{
    //                  loadGoogleAd()
    //        }else if useAdProvider == "applovin", !InterstitialAdMax.instance.sdkNotInit{
    //            loadApplovinAd()
    //        }else{
    //            removeAd()
    //        }
    //    }
    
    //    private func removeAd(){
    //        if !adBannerMax.subviews.isEmpty,
    //            let adView = adBannerMax.subviews[0] as? MAAdView{
    //            adView.stopAutoRefresh()
    //            adView.isHidden = true
    //        }
    //        adBannerView.isHidden = true
    //        adBannerMax.isHidden = true
    //        if willLoadAds{
    //            willLoadAds = false
    //            tableView.reloadData()
    //        }
    //    }
    //
    //    private func loadGoogleAd(){
    ////        adBannerView.isHidden = false
    ////        let screenWidth = UIScreen.main.bounds.size.width
    ////        adBannerView.adUnitID = SubscriptionService.instance.googleBannerAdId
    ////        adBannerView.rootViewController = self
    ////        var size = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(screenWidth)
    ////        size.size.height = 50
    ////        adBannerView.adSize = size
    ////        adBannerView.load(GADRequest())
    ////        adBannerView.delegate = self
    //        if !willLoadAds{
    //            NativeAdLoader.shared(self.navigationController!).isReadyToLoadAds { success in
    //                if success{
    //                    self.willLoadAds = true
    //                    self.tableView.reloadData()
    //                }
    //            }
    //        }
    //    }
    
    //    private func loadApplovinAd(){
    //        if !willLoadAds{
    //            willLoadAds = true
    //            tableView.reloadData()
    //
    //        }
    //        guard adBannerMax.subviews.isEmpty else {return}
    //        let adView = MAAdView(adUnitIdentifier: AdConfig.maxBannerAdId)
    //        adView.delegate = self
    //        let height: CGFloat = 50
    //        let width: CGFloat = UIScreen.main.bounds.width
    //        adView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    //        adBannerMax.addSubview(adView)
    //        adView.snp.makeConstraints { [weak self] (make) in
    //            guard let strongSelf = self else { return }
    //            make.top.equalTo(strongSelf.adBannerMax.snp.top)
    //            make.left.equalTo(strongSelf.adBannerMax.snp.left)
    //            make.right.equalTo(strongSelf.adBannerMax.snp.right)
    //            make.bottom.equalTo(strongSelf.adBannerMax.snp.bottom)
    //        }
    //        adView.loadAd()
    //    }
    
    
    
    //    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
    //     //   adBannerView.isHidden =  true
    //    }
    
    private func getDataFromServer() {
        // Try contentID first, then albumId
        let contentId = discoverModel.contentID?.replacingOccurrences(of: " ", with: "") ?? ""
        let albumId = discoverModel.albumId?.replacingOccurrences(of: " ", with: "") ?? ""

        // Use whichever is valid (not empty and not "0")
        if !contentId.isEmpty && contentId != "0" {
            id = contentId
        } else if !albumId.isEmpty && albumId != "0" {
            id = albumId
        } else {
            id = ""
        }

        print("🔍 Final album id for API: \(id)")

        guard !id.isEmpty && id != "0" else {
            self.view.makeToast("Invalid album ID")
            return
        }

        discoverModel.contentType = "R"
        self.getPlaylistAndAlbum(contentID: id, mediaType: .album)
    }

    private func getPlaylistAndAlbum(contentID: String, mediaType: SMContentType) {
        if try! Reachability().connection == .unavailable {
            let albumId = (discoverModel.albumId != nil) ? discoverModel.albumId : discoverModel.contentID
            self.songsAndAlbums = DatabaseContext.shared.getSonngsByAlbum(where: albumId ?? "")
            self.tableView.reloadData()
            return
        }

        ShadhinCore.instance.api.getAlbumOrPlaylistOrSingleDataById(
            ContentID: contentID,
            mediaType: mediaType
        ) { (albumAndPlaylistData, err, image) in
            if err != nil {
                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
            } else {
                if self.discoverModel.artistId == nil, albumAndPlaylistData?.count ?? 0 > 0 {
                    self.discoverModel.artistId = albumAndPlaylistData?[0].artistId
                }

                if self.discoverModel.artist == nil {
                    self.discoverModel.artist = albumAndPlaylistData?[0].artist
                }

                // Fix: get image and title from first song's album data
                if let firstSong = albumAndPlaylistData?.first {
                    if let img = firstSong.image, !img.isEmpty {
                        self.discoverModel.image = img
                    }
                    // Fix: if title is missing or is the song title, get album title from API
                    if self.discoverModel.title == nil || self.discoverModel.title?.isEmpty == true {
                        self.discoverModel.title = firstSong.title
                    }
                }

                self.songsAndAlbums = albumAndPlaylistData ?? []
                self.songDurationsCalculate(albumAndPlaylistData ?? [])
                self.tableView.isHidden = false
                self.noInternetView.isHidden = true
                SwiftEntryKit.dismiss()

                weak var weakSelf = self
                ShadhinCore.instance.api.checkContentsForRBT(self.songsAndAlbums) { items in
                    guard let _self = weakSelf else { return }
                    for (index, song) in _self.songsAndAlbums.enumerated() {
                        if let contentId = song.contentID, items.contains(contentId) {
                            _self.songsAndAlbums[index].hasRBT = true
                        }
                    }
                    _self.tableView.reloadData()
                }
                self.checkAlbumIsFav()
                self.tableView.reloadData()
            }
        } imageCompletion: { image in
            if let image = image, !image.isEmpty {
                self.discoverModel.image = image
                DispatchQueue.main.async {
                    // Fix: reload only header cell to update image
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
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
    
    private func songDurationsCalculate(_ durations: [CommonContentProtocol]) {
        var totalDu = 0
        
        for item in durations {
            totalDu += Int(item.duration ?? "0") ?? 0
        }
        self.totalDurations = totalDu.formatTime()
    }

    private func playingSongFromTopButton() {
        //self.openMusicPlayer(musicData: songsAndAlbums, songIndex: 0, isRadio: false,rootModel: discoverModel)
        self.openMusicPlayerV3(musicData: songsAndAlbums, songIndex: 0, isRadio: false,rootModel: discoverModel)
        //self.saveAlbumToDatabase()
    }
    func shufflePlay() {
        openMusicPlayerV3(musicData: songsAndAlbums, songIndex: 0, isRadio: false,rootModel: discoverModel)
        MusicPlayerV3.shared.turnOnShuffle()
    }
    
    
    //    private func saveAlbumToDatabase() {
    //        if !LoginService.instance.isLoggedIn{
    //            //self.showNotUserPopUp(callingVC: self)
    //            return
    //        }
    //        let isDatabaseRecordExits = AlbumMyMusicDatabase.instance.checkRecordExists(contentID: discoverModel.contentID ?? "")
    //        if isDatabaseRecordExits {
    //            AlbumMyMusicDatabase.instance.updateDataToDatabase(model: discoverModel)
    //        }else {
    //            AlbumMyMusicDatabase.instance.saveDataToDatabase(model: discoverModel)
    //        }
    //    }
}

// MARK: - Table View

extension MusicAlbumListVC: UITableViewDelegate,UITableViewDataSource {
    
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
        if try! Reachability().connection  == .unavailable{
            return 2
        }
        return discoverModel.artistId == nil || discoverModel.artistId == "" ? 3 : 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 2, 3:
            return 1
        default:
            var count = songsAndAlbums.count
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
            
            guard self.songsAndAlbums.count > 0 else {return .init()}
            
            //cell.configureAlbumCell(model: songsAndAlbums[0], albumsAndPlaylistsIndex: songsAndAlbums.count)
            cell.configureAlbumCell(model: self.discoverModel, albumsAndPlaylistsIndex: songsAndAlbums.count, totalDurations: totalDurations)
            
            cell.didTapPlayPauseButton {
                //  guard !MusicPlayerV3.shared.isChorkiAdIsPlaying else {return}
                self.countButtonTouch()
                if let root = MusicPlayerV3.shared.rootContent,root.contentID == self.discoverModel.contentID, root.contentType == self.discoverModel.contentType{
                    if MusicPlayerV3.audioPlayer.state == .playing{
                        MusicPlayerV3.audioPlayer.pause()
                    }else if MusicPlayerV3.audioPlayer.state == .paused{
                        MusicPlayerV3.audioPlayer.resume()
                    }else if MusicPlayerV3.audioPlayer.state == .stopped{
                        self.playingSongFromTopButton()
                    }
                }else{
                    self.playingSongFromTopButton()
                }
                
            }
            
            cell.didTapBackButton {
                self.navigationController?.popViewController(animated: true)
                //self.dismiss(animated: true, completion: nil)
            }
            
            cell.didTapShareButton{
                Log.info("SharePressed")
                DeepLinks.createLinkTest(controller: self)
            }
            if gotFav{
                cell.favouriteBtn.isHidden = false
                if isListFav{
                    cell.favouriteBtn.setImage(UIImage(named: "ic_favorite_a",in:Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }else{
                    cell.favouriteBtn.setImage(UIImage(named: "ic_favorite_n",in: Bundle.ShadhinMusicSdk,compatibleWith:nil), for: .normal)
                }
                cell.favouriteBtn.setClickListener {
                    self.addDeleteFav()
                }
            }
            
            return cell
        case 1:
            
            /***
             
            if isIndexAnAd(index: indexPath.row){
                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
                if useAdProvider == "google"{
                    let cell =  tableView.dequeueReusableCell(withIdentifier: NativeSmallAdTCell.identifier, for: indexPath) as! NativeSmallAdTCell
                    if let nav = self.navigationController, let ad = NativeAdLoader.shared(nav).getNativeAd(){
                        cell.loadAd(nativeAd: ad)
                    }
                    return cell
                    
                }else if useAdProvider == "applovin"{
                    let cell =  tableView.dequeueReusableCell(withIdentifier: NativeAdMaxSmall.identifier, for: indexPath) as! NativeAdMaxSmall
                    cell.tableview = self.tableView
                    return cell
                }
            }
             
             ***/
            
            let adjustedRow = getAdAdjustedRow(row: indexPath.row)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MusicSongsListCell") as! MusicSongsListCell
            var obj = songsAndAlbums[adjustedRow]
            obj.albumId = (discoverModel.albumId != nil) ? discoverModel.albumId : discoverModel.contentID
            
            cell.configureCell(model: obj, contentType: discoverModel.contentType ?? "")           
            cell.didTappedWelcomeTuneSet {
                let popupVC = SetWelcomeTunePopupVC.instantiateNib()
                let song = self.songsAndAlbums[adjustedRow]  // ✅ get individual song
                popupVC.contentId = song.contentID ?? ""      // ✅ song's own contentID
                popupVC.topImageView = cell.songsImgView.image
                popupVC.musicName = cell.songTitleLbl.text ?? ""
                popupVC.artsitName = cell.songArtistLbl.text ?? ""
                var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                attribute.positionConstraints.size = .init(width: .fill, height: .constant(value: 770))
                SwiftEntryKit.display(entry: popupVC, using: attribute)
            }
            cell.didThreeDotMenuTapped {
                let menu = MoreMenuVC()
                let obj = self.songsAndAlbums[adjustedRow]

                menu.data = obj

                if let rc = obj as? ReleaseContent, let releaseId = rc.release?.id {
                    menu.resolvedAlbumId = "\(releaseId)"
                }

                menu.delegate = self
                menu.menuType = .Songs
                menu.openForm = .Album
                var height = MenuLoader.getHeightFor(vc: .Album, type: .Songs, operators: self.discoverModel.rbtOperators)
                if menu.data.albumId == nil || menu.data.albumId == "" || menu.data.albumId == "0" {
                    height -= 50
                }
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                SwiftEntryKit.display(entry: menu, using: attribute)
            }

            /*
             
             // MARK: Hash RBT
            if songsAndAlbums[adjustedRow].hasRBT ?? false {
                cell.rbtBtn.isHidden = false
                cell.songsDurationLbl.isHidden = true
                cell.rbtBtn.setClickListener {
                    CallerTunePaymentOptionsVC.setRbtOnContent(self, self.songsAndAlbums[adjustedRow])
                }
            }else{
                cell.rbtBtn.isHidden = true
                cell.songsDurationLbl.isHidden = false
            }
            
             */
            
            return cell
            
        case 2:
            
            if isVmaxAdShow && !isVmaxAdFailed {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: VmaxMyProfileTVCell.identifier,
                    for: indexPath
                ) as? VmaxMyProfileTVCell else {
                    fatalError()
                }
                cell.setupCell(tagId: tagId)
                
                cell.onAdFailed = { [weak self] in
                    guard let self = self else { return }
                    self.isVmaxAdFailed = true
                    self.tableView.reloadData()
                }
                
                cell.onHeightChanged = { [weak self] height in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                }
                return cell
            }
            return UITableViewCell()
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistAlbumListCell") as! ArtistAlbumListCell
            
            cell.configureCell(contentID: discoverModel.artistId ?? discoverModel.contentID ?? "")
            
            cell.didSelectAlbumList { (content) in
                
                let alert = NoInternetPopUpVC.instantiateNib()
                alert.gotoDownload = {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC.instantiateNib()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.album, type: .Album)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                    
                }
                alert.retry = {[weak self] in
                    guard let self = self else {return}
                    if ConnectionManager.shared.isNetworkAvailable{
                        let vc = self.goAlbumVC(isFromThreeDotMenu: true, content: content)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                }
                
                if ConnectionManager.shared.isNetworkAvailable{
                    let vc = self.goAlbumVC(isFromThreeDotMenu: true, content: content)
                    self.navigationController?.pushViewController(vc, animated: true)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 1:
            
            if isIndexAnAd(index: indexPath.row){
                return
            }
            tableView.deselectRow(at: indexPath, animated: true)
            let adjustedRow = getAdAdjustedRow(row: indexPath.row)
            
            //openMusicPlayer(musicData: songsAndAlbums, songIndex: adjustedRow, isRadio: false,rootModel: discoverModel)
            openMusicPlayerV3(musicData: songsAndAlbums, songIndex: adjustedRow, isRadio: false,rootModel: discoverModel)
            // self.saveAlbumToDatabase()
            
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MusicSongsViewCell else {return}
            cell.playPauseBtn.setImage(UIImage(named: "ic_Pause1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            MusicPlayerV3.isAudioPlaying = false
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            if section == 1 {
                let newHeader = ShuffleAndDownloadView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
                let id = ((discoverModel.albumId != nil) ? discoverModel.albumId : discoverModel.contentID)  ?? ""
                newHeader.downloadProgress.stopAnimating()
                let isDownloaded = DatabaseContext.shared.isAlbumExist(for: id)
                let isDownloading = DatabaseContext.shared.isAlbumDownloading(albumId: id)
                
                //                header.setTitle(with: ^String.Downloads.download,isHideSwitch: false)
                //                header.isOn = isDownloaded
                
                //                if DatabaseContext.shared.isAlbumDownloading(albumId: id){
                //                    header.isDownloading = true
                //                }else{
                //                    header.isDownloading = false
                //                }
                
                //                header.switchChangeHandler = {isOn in
                //                    if self.checkUser(){
                //                        if isOn{
                //                            self.downloadAllSongs()
                //                        }else{
                //                            self.cancellAllDownload()
                //                        }
                //                    }else{
                //                        header.isOn = false
                //                    }
                //
                //                }
                newHeader.downloadProgress.isHidden = true
                if isDownloading {
                    newHeader.downloadProgress.isHidden = false
                    newHeader.downloadProgress.startAnimating()
                    newHeader.downloadButton.setImage(UIImage(named: "music_v4/ic_stop",in: Bundle.ShadhinMusicSdk,compatibleWith:nil), for: .normal)
                } else if isDownloaded {
                    newHeader.downloadButton.setImage(UIImage(named: "downloadComplete",in:Bundle.ShadhinMusicSdk,compatibleWith: nil), for:.normal)
                    newHeader.downloadProgress.stopAnimating()
                } else {
                    newHeader.downloadButton.setImage(UIImage(named: "download",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    newHeader.downloadProgress.stopAnimating()
                }
               //  for shuffle button action
                newHeader.shuffleButton.setClickListener {
                    self.shufflePlay()
                }
                // for  download buttton action
                newHeader.contentID = id
                newHeader.contentType = "R"
                newHeader.updateShuffleBtn()
                
                newHeader.shuffleButton.setClickListener {
                    guard let albumId = self.discoverModel.albumId else {
                        return
                    }
                    //if checked remove(){update ui} else add(){update ui}
                    if ShadhinCore.instance.defaults.checkShuffle(contentId:albumId,contentType:"R"){
                        ShadhinCore.instance.defaults.removeShuffle(contentId:albumId,contentType:"R")
                    } else {
                        ShadhinCore.instance.defaults.addShuffle(contentId:albumId, contentType:"R")
                    }
                    NotificationCenter.default.post(name: .init("ShuffleListNotify"), object: nil)
                }
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
                return newHeader
            }else if section == 3 {
                let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
                let label = UILabel(frame: CGRect(x:12, y:10, width:tableView.frame.size.width, height:30))
                label.font = UIFont.boldSystemFont(ofSize: 20)
                label.text = ^String.ArtistList.albums
                view.addSubview(label)
                view.backgroundColor = .clear
                return view
            } else {
                return nil
            }
            
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 2:
            return CGFloat.leastNormalMagnitude
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 408
        case 1:
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
            
        case 2: return (isVmaxAdShow && !isVmaxAdFailed) ? UITableView.automaticDimension : 0

        default:
            return 186
        }
    }
}

//MARK: mennu delegate
extension MusicAlbumListVC: MoreMenuDelegate {
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
        //  AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
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
        tableView.reloadData()
    }
    //no need to implement this
    func onRemoveFromHistory(content: CommonContentProtocol) {
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        let vc = goArtistVC(content: content)
        self.navigationController?.pushViewController(vc , animated: true )
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        let vc = goAlbumVC(isFromThreeDotMenu: false, content: content)
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


extension MusicAlbumListVC{
    
    private func checkAlbumIsFav(){
        
        ShadhinCore.instance.api.getAllFavoriteByType(
            type: SMContentType.init(rawValue: self.discoverModel.contentType)) { (favs, error) in
                Log.error(error?.localizedDescription ?? "")
                guard let favt = favs else {return}
                if favt.contains(where: {$0.contentID == self.id}) {
                    self.isListFav = true
                }else {
                    self.isListFav = false
                }
                self.gotFav = true
                self.tableView.reloadData()
            }
    }
    
    func addDeleteFav(){
        if isListFav{
            deleteFav()
        }else{
            addFav()
        }
    }
    
    func addFav(){
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: discoverModel,
            action: .add){ (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.isListFav = true
                    self.tableView.reloadData()
                }
            }
    }
    
    func deleteFav(){
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: discoverModel,
            action: .remove){ (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.isListFav = false
                    self.tableView.reloadData()
                }
            }
    }
    
}


//MARK: Download all and cancel handler
extension MusicAlbumListVC {
    func downloadAllSongs(){
        
        guard try! Reachability().connection != .unavailable else {return}
        
        guard ShadhinCore.instance.isUserPro
        else {
            self.goSubscriptionTypeVC()
            SubscriptionPopUpVC.show(self)
            return
        }
        //post download info to server
        let model : CommonContentProtocol = discoverModel
        ShadhinApi().downloadCompletePost(model: model)
        //send event to firebasee analytics
        //    AnalyticsEvents.downloadEvent(with: model.contentType, contentID: model.contentID, contentTitle: model.title)
        //add album to album database
        discoverModel.contentID = (discoverModel.albumId != nil) ? discoverModel.albumId : discoverModel.contentID
        DatabaseContext.shared.addAlbum(with: discoverModel)
        for song in songsAndAlbums{
            var content : CommonContentProtocol = song
            content.albumId  = (discoverModel.albumId != nil) ? discoverModel.albumId : discoverModel.contentID
            if DatabaseContext.shared.isSongExist(contentId: content.contentID!){
                //nonthing to do because song all ready downloaded
                //                    ss.isSingleDownload = false
                //                    DatabaseContext.shared.save()
                //Log.info("Song exist")
            }else{
                DatabaseContext.shared.addDownload(content: content,isSingleDownload: false)
            }
        }
        
        SDDownloadManager.shared.checkDatabase()
    }
    func cancellAllDownload(){
        
        let albumId = ((discoverModel.albumId != nil) ? discoverModel.albumId : discoverModel.contentID) ?? ""
        //delete Album from album databae
        DatabaseContext.shared.deleteAlbum(where: albumId)
        //delete if download remaing
        DatabaseContext.shared.downloadRemaingBatchDelete(where: albumId)
        //delete downloaded songs if album download
        DatabaseContext.shared.deleteSongsByAlbum(where: albumId)
        //delete all download request
        for song in songsAndAlbums{
            if SDDownloadManager.shared.isDownloadInProgress(forKey: song.playUrl){
                if let key = song.playUrl, let url = URL(string: key){
                    SDDownloadManager.shared.cancelDownload(forUniqueKey: url.lastPathComponent)
                }
            }
            //remove song from local directory
            if let playUrl = song.playUrl{
                SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            }
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

