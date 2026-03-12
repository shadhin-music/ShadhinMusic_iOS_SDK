//
//  MusicArtistListVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/16/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class MusicArtistListVC: UIViewController {
    
    var history_data: CommonContentProtocol?
    private var artistSongs = [CommonContentProtocol]()
    private var favs = "-1"
    private var artistImg = ""
    private var artistFollow = ""
    private var artistFavImg = ""
    private var monthlyListeners = 0
    var discoverModel: CommonContentProtocol!
    
    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBannerMax: UIView!
    
    private var artistSummary = ""
    private var expandedCells = Set<Int>()
    
    var artistList : [CommonContent_V0]?
    var selectedArtistList : Int = 0
    var favPlaylistID = ""
    var artistId = ""
    var state: ReadMoreLessView.ReadMoreLessViewState = .collapsed
    var tagId = "4389c11a"
    var isVmaxAdShow = false
    private var isVmaxAdFailed = false
    
    private let downloadManager = SDDownloadManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBGColor()
        tableView.contentInsetAdjustmentBehavior = .never
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
                vc.selectedDownloadSeg = .init(title: ^String.Downloads.artist, type: .Artist)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if ConnectionManager.shared.isNetworkAvailable{
            getDataFromServer()
        }else{
            tableView.isHidden = true
            noInternetView.isHidden = false
        }
    }
    
    private func getDataFromServer() {
        artistId = discoverModel.artistId != "" && discoverModel.artistId != nil
            ? discoverModel.artistId!
            : discoverModel.contentID ?? ""

        if try! Reachability().connection == .unavailable {
            self.artistSongs = DatabaseContext.shared.getSonngsByArtist(where: artistId)
            self.tableView.reloadData()
            return
        }

        ShadhinCore.instance.api.getAlbumOrPlaylistOrSingleDataById(
            ContentID: artistId,
            contentType: "S",
            mediaType: .artist
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

                self.favs = self.discoverModel.fav ?? "-1"
                self.artistSongs = albumAndPlaylistData ?? []
                self.tableView.isHidden = false
                self.noInternetView.isHidden = true
                SwiftEntryKit.dismiss()

                self.getBiography()
                self.checkFavPlaylist()
                self.tableView.reloadData()
                self.checkIsFollowing()
            }
        } imageCompletion: { _ in

        } parentContentCompletion: { content in
            self.artistFollow = "\(content?.likeCount ?? 0)"
            self.discoverModel.artistId = content?.contentID
            self.monthlyListeners = content?.streamingCount ?? 0
            self.discoverModel.followers = "\(content?.likeCount ?? 0)"
            self.discoverModel.playCount = content?.streamingCount

            // Fix artist image and title from actual artist profile data
            if let image = content?.image, !image.isEmpty {
                self.artistImg = image
                self.discoverModel.image = image
            }

            if let title = content?.title, !title.isEmpty {
                self.discoverModel.title = title
            }

            if let artist = content?.artist, !artist.isEmpty {
                self.discoverModel.artist = artist
            }

            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }
    }

    private func checkFavPlaylist(){
        ShadhinCore.instance.api.getArtistFeaturedPlaylist(artistId) { _data in
            guard let data = _data else {return}
            if data.playListID.count > 0{
                self.favPlaylistID = data.playListID
                self.artistFavImg = data.playListImage
                self.tableView.reloadData()
            }
        }
    }
    
    private func checkIsFollowing(){
        
        ShadhinCore.instance.api.getAllFavoriteByType(
            type: .artist) { (artists, err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.favs = "0"
                    if let artists = artists{
                        for artist in artists{
                            if artist.contentID == self.artistId{
                                self.favs = "1"
                            }
                        }
                    }
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            }
    }
        
    private func getBiography() {

        let artistName = (discoverModel.artist?.isEmpty ?? true)
            ? (discoverModel.title ?? "")
            : (discoverModel.artist ?? "")

        ShadhinCore.instance.api.getArtistBioFromLastFm(artistName: artistName) { (summaries, err) in
            
            guard let summary = summaries else {
                DispatchQueue.main.async {
                    self.artistSummary = ""
                    self.tableView.reloadData()
                }
                return
            }

            DispatchQueue.main.async {
                self.artistSummary = self.subrangeArtistBiograghyFromLastFM(serverString: summary)
                self.artistSummary = self.artistSummary.count > 25 ? self.artistSummary : ""
                self.tableView.reloadData()
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.isVmaxAdShow = ShadhinGP.shared.isVmaxInitialized &&
            !ShadhinCore.instance.isUserPro &&
            VMAX_AD_ITEM_DATA.contains(where: { $0.adId == tagId })

        navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(forName: .DownloadStartNotify, object: nil, queue: .main) { notificationn in
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
        }
    }
    
    func subrangeArtistBiograghyFromLastFM(serverString: String) -> String {
        var actualString = serverString
        if let range = actualString.range(of: "<") {
            actualString.removeSubrange(range.lowerBound..<actualString.endIndex)
        }
        return actualString
    }
    
    func changeArtist(_ index : Int){
        discoverModel = artistList![index]
        selectedArtistList = index
        favPlaylistID = ""
        artistId = ""
        getDataFromServer()
        self.tableView.setContentOffset(.zero, animated: false)
    }
    
   private func shufflePlay(){
        openMusicPlayerV3(musicData: artistSongs, songIndex: 0, isRadio: false,rootModel: discoverModel)
        MusicPlayerV3.shared.turnOnShuffle()
    }
}

// MARK: - TableView Delegate

extension MusicArtistListVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if try! Reachability().connection == .unavailable{ return 2 }
        return (artistList == nil ? 4 : 5) + (favPlaylistID.count > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1 && favPlaylistID.count == 0) || (section == 2 && favPlaylistID.count > 0) {
            return artistSongs.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var section = indexPath.section
        if (section == 1 && favPlaylistID.count > 0) {
            section = 5
        } else if (section > 1 && favPlaylistID.count > 0) {
            section -= 1
        }
        
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistSongsViewCell") as! ArtistSongsViewCell
            
            cell.confifureCell(model:discoverModel,
                               index: artistSongs.count,
                               favs: self.favs,
                               artistImg: self.artistImg,
                               follow: self.artistFollow,
                               monthlyListener: self.monthlyListeners)
            
            cell.artistBioDescription.setText(text: self.artistSummary, state: self.state)

            cell.artistBioDescription.autoExpandCollapse = false
            cell.artistBioDescription.delegate = self
            cell.didTapFollowButton {
                
                if cell.isFollow {
                    ShadhinCore.instance.api.addOrRemoveFromFavorite(
                        content: self.discoverModel,
                        action: .remove) { (err) in
                            if err != nil {
                                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                            }else {
                                cell.followBtn.setTitle("Follow", for: .normal)
                                self.favs = "0"
                                self.view.makeToast("Artist removed from the following list")
                            }
                        }
                }else {
                    ShadhinCore.instance.api.addOrRemoveFromFavorite(
                        content: self.discoverModel,
                        action: .add) { (err) in
                            if err != nil {
                                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                            }else {
                                cell.followBtn.setTitle("Following", for: .normal)
                                self.favs = "1"
                                self.view.makeToast("You are now following the artist")
                            }
                        }
                }
                
                cell.isFollow.toggle()
            }
            
            cell.didTapBackButton {
                self.navigationController?.popViewController(animated: true)
            }
            
            cell.didTapShareButton {
                DeepLinks.createLinkTest(controller: self)
            }
            
            cell.biographyLbl.isHidden = self.artistSummary.isEmpty
            cell.artistBioDescription.isHidden = self.artistSummary.isEmpty
            
            if self.artistSummary.isEmpty {
                cell.biographyLbl.invalidateIntrinsicContentSize()
                cell.artistBioDescription.invalidateIntrinsicContentSize()
                cell.contentView.layoutIfNeeded()
            }
            
            return cell
            
        case 1:
            let adjustedRow = indexPath.row
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistSongsListCell") as! ArtistSongsListCell
            var item = artistSongs[adjustedRow]
            item.artistId = artistId
            
            let isFirstRbt: Bool = {
                guard item.rbtOperators?.containsGP() == true else { return false }
                let firstRbtIndex = artistSongs.firstIndex(where: { $0.rbtOperators?.containsGP() == true })
                return firstRbtIndex == adjustedRow
            }()

            cell.configureCell(model: item, true, indexInSection: isFirstRbt ? 0 : 1)

            cell.didTappedWelcomeTuneSet {
                let popupVC = SetWelcomeTunePopupVC.instantiateNib()
                let song = self.artistSongs[adjustedRow]
                popupVC.contentId = song.contentID ?? ""
                popupVC.topImageView = cell.songsImgView.image
                popupVC.musicName = cell.songTitleLbl.text ?? ""
                popupVC.artsitName = cell.songArtistLbl.text ?? ""
                var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                attribute.positionConstraints.size = .init(width: .fill, height: .constant(value: 760))
                SwiftEntryKit.display(entry: popupVC, using: attribute)
            }
            
            cell.didThreeDotMenuTapped {
                let menu = MoreMenuVC()
                var obj = self.artistSongs[adjustedRow]
                // ← ADD THIS: capture releaseId before type erasure
                    if let rc = obj as? ReleaseContent {
                        obj.releaseId = rc.releaseId
                    }

                menu.data = obj
                menu.delegate = self
                menu.menuType = .Songs
                menu.openForm = .Artist
                var height = MenuLoader.getHeightFor(vc: .Artist, type: .Songs, operators: self.discoverModel.rbtOperators)
                if obj.albumId == nil || obj.albumId == ""{
                    height -= 50
                }
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none
                SwiftEntryKit.display(entry: menu, using: attribute)
            }
            
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
            let artistId = discoverModel.artistId != "" && discoverModel.artistId != nil ? discoverModel.artistId! : discoverModel.contentID
            cell.configureCell(contentID: artistId ?? "")
            cell.didSelectAlbumList { (content) in
                let vc = self.goAlbumVC(isFromThreeDotMenu: false, content: content)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArtistListCell.identifier) as! ArtistListCell
            cell.configureCell(content: artistList!, index: selectedArtistList) { (index) in
                
                
                let alert = NoInternetPopUpVC.instantiateNib()
                alert.gotoDownload = {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC.instantiateNib()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.artist, type: .Artist)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                    
                }
                alert.retry = {[weak self] in
                    guard let self = self else {return}
                    if ConnectionManager.shared.isNetworkAvailable{
                        self.changeArtist(index)
                        SwiftEntryKit.dismiss()
                    }
                }
                
                if ConnectionManager.shared.isNetworkAvailable{
                    self.changeArtist(index)
                    SwiftEntryKit.dismiss()
                }else{
                    SwiftEntryKit.display(entry: alert, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
                }
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArtistFavCell.identifier) as! ArtistFavCell
            let imgUrl = artistFavImg.replacingOccurrences(of: "<$size$>", with: "300")
            cell.imgBg.kf.setImage(with: URL(string: imgUrl.safeUrl()))
            cell.imgMain.kf.indicatorType = .activity
            cell.imgMain.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            cell.artlistNameL.text = "\(self.discoverModel.title ?? "")'s"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 1 && favPlaylistID.count == 0) || (indexPath.section == 2 && favPlaylistID.count > 0) {
            tableView.deselectRow(at: indexPath, animated: true)
            openMusicPlayerV3(musicData: artistSongs, songIndex: indexPath.row, isRadio: false,rootModel: discoverModel)
        }else if (indexPath.section == 1 && favPlaylistID.count > 0){
            tableView.deselectRow(at: indexPath, animated: true)
            var temp = CommonContent_V0()
            temp.contentID = favPlaylistID
            temp.image = artistFavImg
            temp.contentType =  "p"
            temp.title = "Best of \(self.discoverModel.title ?? "")"
            let vc2 = goPlaylistVC(content: temp)
            navigationController?.pushViewController(vc2, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var _section = section
        if (_section == 1 && favPlaylistID.count > 0) {
            _section = 5
        } else if (_section > 1 && favPlaylistID.count > 0) {
            _section -= 1
        }
        
        if _section == 1{
            let newHeader = ShuffleAndDownloadView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            let artistId = discoverModel.artistId != "" && discoverModel.artistId != nil ? discoverModel.artistId! : discoverModel.contentID
            newHeader.downloadProgress.stopAnimating()
            let isDownloaded = DatabaseContext.shared.isArtistExist(for: artistId ?? "")
            let isDownloading = DatabaseContext.shared.isArtistDownloading(artistId: artistId ?? "")
            newHeader.downloadProgress.isHidden = true
            if isDownloading {
                newHeader.downloadProgress.isHidden = false
                newHeader.downloadProgress.startAnimating()
                newHeader.downloadButton.setImage(UIImage(named: "music_v4/ic_stop", in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            } else if isDownloaded {
                newHeader.downloadButton.setImage(UIImage(named: "downloadComplete", in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for:.normal)
                newHeader.downloadProgress.stopAnimating()
            }  else {
                newHeader.downloadButton.setImage(UIImage(named: "download",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                newHeader.downloadProgress.stopAnimating()
            }
            if let artistId = artistId {
                newHeader.contentID = artistId
                newHeader.contentType = "A"
                newHeader.updateShuffleBtn()
            }
            newHeader.shuffleButton.setClickListener {
                guard let artistId = artistId else {
                    return
                }
                
                if ShadhinCore.instance.defaults.checkShuffle(contentId:artistId,contentType:"A") {
                    ShadhinCore.instance.defaults.removeShuffle(contentId:artistId,contentType:"A")
                } else {
                    ShadhinCore.instance.defaults.addShuffle(contentId: artistId, contentType:"A")
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
                        newHeader.downloadButton.setImage(UIImage(named: "music_v4/ic_stop", in: Bundle.ShadhinMusicSdk, compatibleWith: nil), for: .normal)
                    }
                }
            }
            return newHeader
            
        } else if _section != 0 && _section != 2 && _section != 5 {
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
            let label = UILabel(frame: CGRect(x:12, y:10, width:tableView.frame.size.width, height:30))
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.text = [^String.ArtistList.albums, ^String.ArtistList.fanAlsoLike][_section - 3]
            view.addSubview(label)
            view.backgroundColor = .clear
            return view

        } else if _section == 2 {
            let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
            spacerView.backgroundColor = .clear
            return isVmaxAdShow && !isVmaxAdFailed ? spacerView : nil

        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var _section = section
        if (_section == 1 && favPlaylistID.count > 0){
            _section = 5
        } else if (_section > 1 && favPlaylistID.count > 0){
            _section -= 1
        }
        return _section == 0 || _section == 5 ? CGFloat.leastNormalMagnitude : (_section == 2 ? 8 : 50)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var _section = indexPath.section
        if (_section == 1 && favPlaylistID.count > 0){
            _section = 5
        } else if (_section > 1 && favPlaylistID.count > 0){
            _section -= 1
        }
        switch _section {
        case 0: return UITableView.automaticDimension
        case 1: return 70
        case 2: return (isVmaxAdShow && !isVmaxAdFailed) ? UITableView.automaticDimension : 0
        case 4: return ArtistListCell.height
        case 5: return ArtistFavCell.size
        default: return 186
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var _section = indexPath.section
        if (_section == 1 && favPlaylistID.count > 0){
            _section = 5
        } else if (_section > 1 && favPlaylistID.count > 0){
            _section -= 1
        }
        switch _section {
        case 0: return UITableView.automaticDimension
        case 1: return 70
        case 2: return (isVmaxAdShow && !isVmaxAdFailed) ? UITableView.automaticDimension : 0
        case 4: return ArtistListCell.height
        case 5: return ArtistFavCell.size
        default: return 186
        }
    }
}

//MARK: mennu delegate
extension MusicArtistListVC: MoreMenuDelegate{
    func openQueue() {}
    
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}
        
        guard checkProUser() else{
            return
        }
        guard let url = URL(string: content.playUrl?.decryptUrl() ?? "") else {
            return self.view.makeToast("Unable to get Download url for file")
        }
        self.view.makeToast("Downloading \(String(describing: content.title ?? ""))")
        
        let request = URLRequest(url: url)
        let _ = self.downloadManager.downloadFile(withRequest: request, onCompletion: { error, url in
            if error != nil{
                self.view.makeToast(error?.localizedDescription)
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
    func onRemoveFromHistory(content: CommonContentProtocol) {}
    
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
    func shareMyPlaylist(content: CommonContentProtocol) {}
    
    func openSleepTimer() {}
}


//MARK: Download all and cancel handler
extension MusicArtistListVC {
    func downloadAllSongs(){
        guard try! Reachability().connection != .unavailable else {return}

        guard ShadhinCore.instance.isUserPro
        else {
            SubscriptionPopUpVC.show(self)
            return
        }
        DatabaseContext.shared.addArtist(content: discoverModel)
        artistSongs.forEach { data in
            var content : CommonContentProtocol = data
            content.artistId = artistId
            if DatabaseContext.shared.isSongExist(contentId: content.contentID!){
            } else {
                DatabaseContext.shared.addDownload(content: content,isSingleDownload: false)
            }
        }
        SDDownloadManager.shared.checkDatabase()
    }
    func cancellAllDownload(){
        let artistId = ((discoverModel.artistId != nil) ? discoverModel.artistId : discoverModel.contentID) ?? ""
        DatabaseContext.shared.deleteArtist(where: artistId)
        DatabaseContext.shared.downloadRemaingBatchDeleteArtist(where: artistId)
        DatabaseContext.shared.deleteSongsByArtist(where: artistId)
        for song in artistSongs{
            if SDDownloadManager.shared.isDownloadInProgress(forKey: song.playUrl){
                if let key = song.playUrl, let url = URL(string: key){
                    SDDownloadManager.shared.cancelDownload(forUniqueKey: url.lastPathComponent)
                }
            }
            if let playUrl = song.playUrl{
                SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            }
        }
        
        if try! Reachability().connection == .unavailable{
            navigationController?.popViewController(animated: true)
        }
        self.tableView.reloadData()
    }
}

extension MusicArtistListVC: ReadMoreLessViewDelegate {
    func didClickButton(_ readMoreLessView: ReadMoreLessView) {
        if readMoreLessView.state == .collapsed {
            self.state = .expanded
        } else {
            self.state = .collapsed
        }
        
        let index = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [index], with: .automatic)
    }
    
    func didChangeState(_ readMoreLessView: ReadMoreLessView) { }
}

