////
////  MusicItemV4.swift
////  Shadhin
////
////  Created by Gakk Alpha on 1/3/23.
////  Copyright © 2023 Cloud 7 Limited. All rights reserved.
////
//
//import UIKit
//
//class MusicItemV4: UICollectionViewCell {
//    
//    static var nib:UINib {
//        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
//    }
//    
//    static var identifier: String {
//        return String(describing: self)
//    }
//    
//    static var size: CGSize {
//        return CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
//    }
//    
//    @IBOutlet weak var collectionHolder: UIView!
//    @IBOutlet weak var collectionImg: UIImageView!
//    @IBOutlet weak var collectionTitle: UILabel!
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var effect: UIVisualEffectView!
//    @IBOutlet weak var bg: UIImageView!
//    @IBOutlet weak var mainBg: UIImageView!
//    @IBOutlet weak var addCommentHolder: NSLayoutConstraint!
//    @IBOutlet weak var seekbar: UISlider!
//    @IBOutlet weak var playedTime: UILabel!
//    @IBOutlet weak var songTitle: UILabel!
//    @IBOutlet weak var songArtist: UILabel!
//    @IBOutlet weak var playPauseView: UIView!
//    @IBOutlet weak var liveTag: UILabel!
//    @IBOutlet weak var liveCount: UILabel!
//    
//    @IBOutlet weak var verticalItem0: UIImageView!
//    
//    @IBOutlet weak var verticalItem1: UIStackView!
//    @IBOutlet weak var verticalItem1Btn: UIButton!
//    @IBOutlet weak var verticalItem1Lbl: UILabel!
//    
//    @IBOutlet weak var verticalItem2: UIStackView!
//    @IBOutlet weak var verticalItem2Btn: UIButton!
//    @IBOutlet weak var verticalItem2Lbl: UILabel!
//    
//    @IBOutlet weak var verticalItem3: UIButton!
//    
//    @IBOutlet weak var verticalItem4: UIButton!
//    
//    @IBOutlet weak var shareBtn: UIButton!
//    @IBOutlet weak var circularProgressView: ProgressMV4!
//    
//
//    private var loadMoreComments : LoadMoreActivityIndicator?
//    private var pendingRequestWorkItem: DispatchWorkItem?
//    private var currentCommentPage = 0
//    private var userComments : [CommentsObj.Comment] = []
//    private var isFav = false
//    private var item: AudioItem?
//    private var lyricsRequest: DataRequest?
//    private var lyricsArray: [String.SubSequence] = []
//    private var favImageNormal: UIImage? = UIImage(named: "music_v4/ic_like_n",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
//    private var favImageActive: UIImage? = UIImage(named: "music_v4/ic_like_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        collectionView.register(LyricsV4.nib, forCellWithReuseIdentifier: LyricsV4.identifier)
//        collectionView.register(MusicCommentsV4.nib, forCellWithReuseIdentifier: MusicCommentsV4.identifier)
//        seekbar.setThumbImage(#imageLiteral(resourceName: "music_v4/ic_thumb.pdf"), for: .normal)
//        seekbar.setThumbImage(#imageLiteral(resourceName: "music_v4/ic_thumb.pdf"), for: .highlighted)
//        verticalItem2Btn.setImage(AppImage.downloadMV4.uiImage, for: .selected)
//        verticalItem2Btn.setImage(UIImage(named: "ic_download",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
//        collectionHolder.isHidden = true
//        lyricsArray = []
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        createMask()
//        NotificationCenter.default.addObserver(self, selector: #selector(checkFav), name: .init(rawValue: "FavDataUpdateNotify"), object: nil)
//        self.verticalItem1Btn.setClickListener {
//            self.favoritesAction()
//        }
//        self.shareBtn.setClickListener {
//            self.onSharePressed()
//        }
//        self.verticalItem3.setClickListener {
//            if self.verticalItem3.tag == 1{
//                self.presentComments()
//            }else{
//                self.addToPlaylistTapped()
//            }
//        }
//        self.verticalItem4.setClickListener {
//            self.onMorePressed()
//        }
//        loadMoreComments = LoadMoreActivityIndicator(scrollView: collectionView, spacingFromLastCell: -16, spacingFromLastCellWhenLoadMoreActionStart: 8, color: .white)
//        loadMoreComments?.stop()
//        
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        collectionHolder.isHidden = true
//        lyricsArray = []
//        collectionView.reloadData()
//        liveTag.isHidden = true
//        liveCount.isHidden = true
//        verticalItem2Btn.isHidden = false
//        circularProgressView.isHidden = true
//        self.verticalItem2Lbl.isHidden = true
//        circularProgressView.progress = 0
//    }
//    
//    func createMask(){
//        let yStart = (SCREEN_SAFE_TOP)/SCREEN_HEIGHT
//        let yEnd = (SCREEN_HEIGHT - 288 - SCREEN_SAFE_BOTTOM)/SCREEN_HEIGHT
//        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            UIColor.white.withAlphaComponent(1).cgColor,
//            UIColor.white.withAlphaComponent(0.5).cgColor,
//            UIColor.white.withAlphaComponent(0.2).cgColor,
//            UIColor.white.withAlphaComponent(0).cgColor,
//            UIColor.white.withAlphaComponent(0).cgColor,
//            UIColor.white.withAlphaComponent(0.3).cgColor,
//            UIColor.white.withAlphaComponent(1).cgColor]
//        gradientLayer.frame = .init(origin: .zero, size: .init(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: yStart)
//        gradientLayer.endPoint = CGPoint(x: 0.0 , y: yEnd)
//        effect.layer.mask = gradientLayer
//    }
//    
//    func setItem(audioItem: AudioItem) {
//        item = audioItem
//        songTitle.text = audioItem.contentData?.title
//        songArtist.text = audioItem.contentData?.artist
//        self.collectionHolder.isHidden = true
//        KingfisherManager.shared.retrieveImage(
//            with: KFImageResource(
//                downloadURL:URL(string: audioItem.contentData?.image?.replacingOccurrences(of: "<$size$>", with: "300").safeUrl() ?? "")!))
//        { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .success(let value):
//                self.mainBg.image = value.image
//                self.bg.image = value.image
//                if let url = URL(string: audioItem.rootData?.image?.replacingOccurrences(of: "<$size$>", with: "300").safeUrl() ?? ""){
//                    self.verticalItem0.kf.setImage(with: url)
//                }else{
//                    self.verticalItem0.image = value.image
//                }
//            case .failure:
//                Log.error("failed to load track thumb image")
//            }
//        }
//        switch SMContentType.init(rawValue: item?.contentType){
//        case .podcast:
//            collectionImg.image = UIImage(named: "music_v4/ic_comments_img",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
//            collectionTitle.text = "COMMENTS"
//            favImageNormal = UIImage(named: "music_v4/ic_like_pd_n",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
//            favImageActive = UIImage(named: "music_v4/ic_like_pd_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
//            verticalItem3.tag = 1
//            verticalItem3.setImage(UIImage(named: "music_v4/ic_comments",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
//            currentCommentPage = 0
//            userComments.removeAll()
//            getComments()
//            if item?.contentData?.trackType?.lowercased() == "lm"{
//                liveTag.isHidden = false
//            }else{
//                liveTag.isHidden = true
//            }
//        default:
//            getLyrics()
//            collectionImg.image = UIImage(named: "music_v4/ic_lyrics",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
//            collectionTitle.text = "LYRICS"
//            favImageNormal = UIImage(named: "music_v4/ic_like_n",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
//            favImageActive = UIImage(named: "music_v4/ic_like_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
//            verticalItem3.tag = 0
//            verticalItem3.setImage(UIImage(named: "music_v4/ic_add_to_playlist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
//            liveTag.isHidden = true
//        }
//        self.liveCount.isHidden = true
//        self.getFavCount(item: item?.contentData)
//        self.checkFav()
//        self.checkDownload()
//    }
//    
//    func onSharePressed() {
////        guard let currentData = item?.contentData, let vc = viewContainingController() else {return}
//     //   DeepLinks.createDeepLink(model: currentData, controller: vc, vcType: "")
//    }
//    
//    func onMorePressed() {
//        guard let content = item?.contentData else {
//            return
//        }
//        let type = SMContentType(rawValue: content.contentType)
//        let menu = PlayerMenuVC.instantiateNib()
//        menu.delegate = self
//        menu.content = item?.contentData
//        
//        var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: type == .podcast ? 450 : 500, offsetValue: 0)
//        attribute.entryBackground = .color(color: .clear)
//        attribute.border = .none
//        attribute.screenBackground = .clear
//        attribute.positionConstraints.verticalOffset = 0
//        attribute.positionConstraints.safeArea = .overridden
//        SwiftEntryKit.display(entry: menu, using: attribute)
//    }
//    @IBAction func onDownloadPressed(_ sender: Any) {
//        if verticalItem2Btn.isSelected{
//            return
//        }
//        guard let content = item?.contentData else{
//            return
//        }
//        ShadhinCore.instance.api.getDownloadUrl(content) { playUrl, error in
//            if let playUrl = playUrl, let url = URL(string: playUrl){
//                let _ = SDDownloadManager.shared.downloadFile(withRequest: URLRequest(url: url)) { error, fileUrl in
//                    if let error = error{
//                        self.makeToast(error.localizedDescription)
//                        return
//                    }
//                    self.circularProgressView.isHidden = true
//                    self.verticalItem2Btn.isHidden = false
//                    self.verticalItem2Btn.isSelected = true
//                    let isPdocast = content.contentType?.prefix(2).uppercased() == "PD" ? true : false
//                    if isPdocast{
//                        DatabaseContext.shared.addPodcast(content: content)
//                    }else{
//                        DatabaseContext.shared.addSong(content: content,isSingleDownload: true)
//                    }
//                    self.makeToast("Song download success")
//                    
//                }
//                self.checkDownload()
//            }
//        }
//    }
//    
//    @objc
//    func checkFav(){
//        guard let content = item?.contentData else {return}
//        if FavoriteCacheDatabase.intance.isFav(content: content){
//            self.verticalItem1Btn.setImage(favImageActive, for: .normal)
//            self.isFav = true
//        }else{
//            self.verticalItem1Btn.setImage(favImageNormal, for: .normal)
//            self.isFav = false
//        }
//    }
//    
//    func getFavCount(item: CommonContentProtocol?){
//        if item?.playCount ?? 0 > 0{
//            self.verticalItem1Lbl.isHidden = false
//            self.verticalItem1Lbl.text = numberCompact(num: Double((self.item?.contentData?.playCount ?? 0)), roundingNumber: 0)
//            return
//        }
//        guard let contentId = item?.contentID,
//              let contentType = item?.contentType
//        else {return verticalItem1Lbl.isHidden = true}
//        ShadhinCore.instance.api.getContentLikeCount(contentID: contentId, contentType: contentType) { count, contentId, contentType in
//            if self.item?.contentId == contentId,
//               self.item?.contentData?.contentType == contentType{
//                if count > 0{
//                    self.verticalItem1Lbl.isHidden = false
//                    self.verticalItem1Lbl.text = numberCompact(num: Double(count), roundingNumber: 0)
//                    self.item?.contentData?.playCount = count
//                }else{
//                    self.verticalItem1Lbl.isHidden = true
//                }
//            }
//        }
//    }
//    
//    
//    func favoritesAction() {
//        guard ShadhinCore.instance.isUserPro
//        else {
//           // SubscriptionPopUpVC.show(self.viewContainingController())
//            return
//        }
//        
//        guard let item = item?.contentData else {return}
//        
//        if isFav {
//            ShadhinCore.instance.api.addOrRemoveFromFavorite(
//                content: item,
//                action: .remove)
//            { (err) in
//                if err != nil {
//                    ConnectionManager.shared.networkErrorHandle(err: err, view: self)
//                    return
//                }else {
//                    NotificationCenter.default.post(name: .init("FavDataUpdateNotify"), object: nil)
//                    // self.favBtn.setImage(UIImage(named: "music_v4/ic_like_n"), for: .normal)
//                    self.makeToast("Removed from Favorites")
//                    if self.item?.contentData?.playCount ?? 0 > 1{
//                        self.verticalItem1Lbl.isHidden = false
//                        self.item?.contentData?.playCount? -= 1
//                        self.verticalItem1Lbl.text = numberCompact(num: Double((self.item?.contentData?.playCount ?? 0)), roundingNumber: 0)
//                    }else{
//                        self.verticalItem1Lbl.isHidden = true
//                    }
//                }
//            }
//        }else {
//            ShadhinCore.instance.api.addOrRemoveFromFavorite(
//                content: item,
//                action: .add)
//            { (err) in
//                if err != nil {
//                    ConnectionManager.shared.networkErrorHandle(err: err, view: self)
//                    return
//                }else {
//                    NotificationCenter.default.post(name: .init("FavDataUpdateNotify"), object: nil)
//                    //self.favBtn.setImage(UIImage(named: "music_v4/ic_like_a"), for: .normal)
//                    self.makeToast("Added To Favorites")
//                    if self.item?.contentData?.playCount ?? 0 > 0{
//                        self.verticalItem1Lbl.isHidden = false
//                        self.item?.contentData?.playCount? += 1
//                        self.verticalItem1Lbl.text = numberCompact(num: Double((self.item?.contentData?.playCount ?? 0)), roundingNumber: 0)
//                    }else{
//                        self.verticalItem1Lbl.isHidden = true
//                    }
//                }
//            }
//        }
//    }
//
//    
//    func addToPlaylistTapped() {
////        guard let parentVc = viewContainingController(),
////        parentVc.checkUser() else{
////            return
////        }
//        let vc = PlaylistCreateVC()
//        var height: CGFloat = 0
//        ShadhinCore.instance.api.getBothPlaylistsData{ (playlists, err) in
//            guard err == nil else {
//                ConnectionManager.shared.networkErrorHandle(err: err, view: self)
//                return
//            }
//            guard let playlist = playlists else {return}
//            if playlist.count > 0 {
//                let window = UIApplication.shared.windows.first
//                //let bottomPadding = window?.safeAreaInsets.bottom ?? 0
//                //let tableCellHeight: CGFloat = CGFloat((playlist.count * 72) + 130)
//                height = window?.bounds.height ?? 0//bottomPadding + tableCellHeight
//                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: height))
//                vc.playlists = playlist
//                vc.contentID = self.item?.contentId ?? ""
//            }else {
//                height = SCREEN_SAFE_BOTTOM + 250
//                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: height))
//            }
//        }
//    }
//    
//    func presentComments(){
//        guard let episodeId = Int(item?.contentData?.albumId ?? ""),
//              let contentType = item?.contentData?.contentType else {return }
////        let vc = PodcastCommentVC()
////        vc.willHideAreaComment = true
////        vc.headerHeightConstant = 0
////        vc.episodeID = episodeId
////        vc.contentType = contentType
////        viewContainingController()?.present(vc, animated: true)
//    }
//    
//    
//    
//    private func getLyrics(){
//        guard let contentId = item?.contentId else{
//            return
//        }
//        lyricsRequest?.cancel()
//        lyricsRequest = ShadhinCore.instance.api.getLyricsBy(contentId) { lyrics in
//            lyrics?.data.lyrics?.stringFromHTML {
//                lyricStr in
//                guard let lyricStr, contentId == self.item?.contentId, lyricStr.count > 10 else {return}
//                self.lyricsArray = lyricStr.split(whereSeparator: \.isNewline)
//                self.collectionHolder.alpha = 0
//                self.collectionHolder.isHidden = false
//                UIView.animate(withDuration: 1.5) {
//                    self.collectionHolder.alpha = 1
//                }
//                self.collectionView.setContentOffset(.zero, animated: false)
//                self.collectionView.reloadData()
//            }
//        }
//    }
//    
//    func startAnimation(){
//        let animation = CABasicAnimation(keyPath: "position.x")
//        animation.duration = 3
//        animation.fromValue = (SCREEN_WIDTH/2 - 21)
//        animation.byValue = 14
//        animation.autoreverses = true
//        animation.repeatCount = .infinity
//        self.mainBg.layer.removeAllAnimations()
//        self.mainBg.layer.add(animation, forKey: "oscilatingAnimation")
//        connectToSignalRIfNeeded() //since method called on will display
//    }
//    
//    func stopAnimation(){
//        self.mainBg.layer.removeAllAnimations()
//        disconnectFromSignalR() //since method called in did end displaying
//    }
//    
//    @IBAction func backTapped(_ sender: UIButton) {
//      //  sender.parentViewController?.minimiseMusicPlayer()
//    }
//    
//    func updateTrackProgress(progress: Float, time: TimeInterval){
//        seekbar.value = progress
//        playedTime.text = formatSecondsToString(time)
//    }
//    
//    func connectToSignalRIfNeeded(){
//        liveCount.isHidden = true
//        if item?.contentType?.lowercased() == "pd",
//           item?.contentData?.trackType?.lowercased() == "lm",
//            let showCode = item?.podcastShowCode {
//            SignalR.podcastCode = showCode
//            SignalR.instance.delegate = {
//                count in
//                guard let count_ : Int = Int(count), count_ > 0 else {return}
//                self.liveCount.isHidden = false
//                self.liveCount.text = "(\(count))"
//            }
//        }else{
//            SignalR.instance.delegate = nil
//        }
//    }
//    
//    func disconnectFromSignalR(){
//        SignalR.instance.delegate = nil
//    }
//    
//}
//
//
//extension MusicItemV4:
//    UICollectionViewDelegate,
//    UICollectionViewDataSource,
//    UICollectionViewDelegateFlowLayout,
//    UIScrollViewDelegate{
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if verticalItem3.tag == 1{
//            return self.userComments.count
//        }else{
//            return self.lyricsArray.count
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        if verticalItem3.tag == 1{
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicCommentsV4.identifier, for: indexPath) as! MusicCommentsV4
//            let comment = userComments[indexPath.row]
//            cell.commentLbl.text =  comment.message
//            cell.userName.text = comment.userName
//            if let userPicUrlEncoded = comment.userPic.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed){
//                cell.userImg.kf.setImage(with: URL(string:userPicUrlEncoded ),placeholder: UIImage(named: "ic_user_1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
//            }
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//            if let date =  dateFormatter.date(from: comment.createDate){
//                cell.timeAgo.text = timeAgoSince(date)
//            }else{
//                cell.timeAgo.text = " "
//            }
//            return cell
//        }else{
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LyricsV4.identifier, for: indexPath) as! LyricsV4
//            cell.sideBar.backgroundColor = indexPath.row % 2 == 0 ? .init(rgb: 0x00B0FF) : .lightGray
//            cell.lyricsLbl.text =  String(self.lyricsArray[indexPath.row])
//            return cell
//        }
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let contentType = item?.contentData?.contentType,
//              contentType.contains("PD") else {return}
//        loadMoreComments?.start {
//            self.getComments({self.loadMoreComments?.stop()})
//        }
//    }
//}
//
//
//extension MusicItemV4{
//    func getComments(_ completion: (() -> Void)? = nil) {
//        pendingRequestWorkItem?.cancel()
//        let requestWorkItem = DispatchWorkItem(block: {self.getCommentsFromServer(completion)})
//        pendingRequestWorkItem = requestWorkItem
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: requestWorkItem)
//    }
//    
//    func getCommentsFromServer(_ completion : (() -> Void)? = nil){
//        guard let contentType = item?.contentData?.contentType,
//              let episodeIDStr = item?.contentData?.albumId,
//              let episodeID = Int(episodeIDStr) else {
//            completion?()
//            return
//        }
//        currentCommentPage += 1
//        Log.info("\(currentCommentPage)")
//        ShadhinCore.instance.api.getCommentsBy(
//            String(contentType.prefix(2)),
//            episodeID,
//            currentCommentPage,
//            String(contentType.suffix(contentType.count - 2)))
//        {
//            _data in
//            guard let data = _data else {return}
//            if data.data.count > 0{
//                self.updateComments(data: data)
//            }else{
//                self.currentCommentPage -= 1
//            }
//            completion?()
//        }
//    }
//    
//    func updateComments(data : CommentsObj){
//        if currentCommentPage == 1{
//            self.collectionHolder.alpha = 0
//            self.collectionHolder.isHidden = false
//            UIView.animate(withDuration: 1.5) {
//                self.collectionHolder.alpha = 1
//            }
//        }
//        collectionTitle.text = "COMMENTS (\(data.totalData))"
////        var paths = [IndexPath]()
////        for item in 0..<data.data.count {
////            let indexPath = IndexPath(row: item + userComments.count, section: 0)
////            paths.append(indexPath)
////        }
//        userComments.append(contentsOf: data.data)
//        collectionView.reloadData()
//    }
//}
//
//extension MusicItemV4 : PlayerMenuV4Protocol{
//    func onMenuPressed(menuItem: MoreMenuItemMusicV4) {
//        guard let vc = self.parentViewController, let content = item?.contentData else {return}
//        switch menuItem.type{
//        case .AddToPlaylist:
//            addToPlaylistTapped()
//            break
//        case .RemoveFromPlaylist:
//            break
//        case .QueueList:
//            
//            break
//        case .SleepTimer:
//            SleepTimerVC.show()
//        case .SleepTimerOn:
//            SleepTimerVC.show()
//        case .GotoArtist:
//            let artist = vc.goArtistVC(content: content)
//            MusicPlayerV4.shared.minimiseMusicPlayer()
//            if let nav = MainTabBar.shared?.selectedViewController as? UINavigationController{
//                nav.pushViewController(artist, animated: true)
//            }
//            
//            Log.info("Artist pressed")
//        case .GotoAlbum:
//            let album = vc.goAlbumVC(isFromThreeDotMenu: true, content: content)
//            MusicPlayerV4.shared.minimiseMusicPlayer()
//            
//            if let nav = MainTabBar.shared?.selectedViewController as? UINavigationController{
//                nav.pushViewController(album, animated: true)
//            }
//        case .share:
//            onSharePressed()
//        case .gotoPodcast:
//            guard let episodeID = content.albumId, let id = Int(episodeID), let contentType = content.contentType else {return}
//            MusicPlayerV4.shared.minimiseMusicPlayer()
//            openPodcast(episodeId: id, podcastType: contentType)
//            
//        }
//    }
//    func openPodcast(episodeId: Int, podcastType: String){
//        let storyBoard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
//        if let tabVC = MainTabBar.shared,
//           let tabs = tabVC.viewControllers,
//           tabs.count > 2,
//           let nav = tabs[2] as? UINavigationController,
//           let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
//            podcastVC.podcastCode = podcastType
//            podcastVC.selectedEpisodeID = episodeId
//            nav.pushViewController(podcastVC, animated: false)
//            tabVC.selectedIndex = 2
//        }
//    }
//    func onShuffleViewPressed(isSelected: Bool) {
//        let mode = MusicPlayerV4.shared.audioPlayer.mode
//        if mode.contains(.repeat){
//            if mode.contains(.shuffle){
//                MusicPlayerV4.shared.audioPlayer.mode = [.repeat,.normal]
//            }else{
//                MusicPlayerV4.shared.audioPlayer.mode = [.repeat,.shuffle]
//            }
//            
//        }else{
//            if mode.contains(.shuffle){
//                MusicPlayerV4.shared.audioPlayer.mode = [.normal]
//            }else{
//                MusicPlayerV4.shared.audioPlayer.mode = [.shuffle]
//            }
//            
//        }
//    }
//    
//    func onRepeatViewPressed(isSelected: Bool) {
//        let mode = MusicPlayerV4.shared.audioPlayer.mode
//        if mode.contains(.shuffle){
//            if mode.contains(.repeat){
//                MusicPlayerV4.shared.audioPlayer.mode = [.normal,.shuffle]
//            }else{
//                MusicPlayerV4.shared.audioPlayer.mode = [.repeat,.shuffle]
//            }
//            
//        }else{
//            if mode.contains(.repeat){
//                MusicPlayerV4.shared.audioPlayer.mode = [.normal]
//            }else{
//                MusicPlayerV4.shared.audioPlayer.mode = [.repeat]
//            }
//            
//        }
//        
//    }
//    
//    func onDownloadPressed(isSelected: Bool) {
//        guard let content = item?.contentData, let url = URL(string: content.playUrl ?? "") else {return}
//        //check song already downloaded or not
//        if DatabaseContext.shared.isSongExist(contentId: content.contentID ?? ""){
//            return
//        }
//        //cancel download if song is downloading
//        if let _ = SDDownloadManager.shared.currentDownload(forKey: url.lastPathComponent){
//            SDDownloadManager.shared.cancelDownload(forUniqueKey: url.lastPathComponent )
//            self.circularProgressView.isHidden = true
//            self.verticalItem2Lbl.isHidden = true
//            self.circularProgressView.progress = 0
//            self.verticalItem2Btn.isHidden = false
//            return
//        }
//        //start download
//        ShadhinCore.instance.api.getDownloadUrl(content) { playUrl, error in
//            guard let playUrl = playUrl, let playU = URL(string: playUrl) else{
//                Log.error(error?.localizedDescription ?? "Error found")
//                return
//            }
//            
//            let _ = SDDownloadManager.shared.downloadFile(withRequest: URLRequest(url: playU)) { error, fileUrl in
//                self.circularProgressView.isHidden = true
//                self.verticalItem2Lbl.isHidden = true
//                self.circularProgressView.progress = 0
//                self.verticalItem2Btn.isHidden = false
//                self.verticalItem2Btn.isSelected = true
//                
//                if let error = error{
//                    self.makeToast(error.localizedDescription)
//                    return
//                }
//                let isPdocast = content.contentType?.prefix(2).uppercased() == "PD" ? true : false
//                if isPdocast{
//                    DatabaseContext.shared.addPodcast(content: content)
//                }else{
//                    DatabaseContext.shared.addSong(content: content,isSingleDownload: true)
//                }
//                self.makeToast("Song download success")
//            }
//            self.checkDownload()
//
//        }
//        
//    }
//    
//    func onLikePressed(isSelected: Bool) {
//        favoritesAction()
//    }
//    
//    
//}
//
//extension MusicItemV4{
//    func checkDownload(){
//        guard let content = item?.contentData,let url = URL(string: content.playUrl ?? ""),let obj = SDDownloadManager.shared.currentDownload(forKey: url.lastPathComponent) else {
//            self.verticalItem2Lbl.isHidden = true
//            self.circularProgressView.isHidden = true
//            self.verticalItem2Btn.isHidden = false
//            if(item?.contentType?.lowercased().starts(with: "pd") == true){
//                if DatabaseContext.shared.isPodcastExist(where: item?.contentData?.contentID ?? ""){
//                    self.verticalItem2Btn.isSelected = true
//                }else{
//                    self.verticalItem2Btn.isSelected = false
//                }
//            }else{
//                if DatabaseContext.shared.isSongExist(contentId: item?.contentData?.contentID ?? ""){
//                    self.verticalItem2Btn.isSelected = true
//                }else{
//                    self.verticalItem2Btn.isSelected = false
//                }
//            }
//            return
//            
//        }
//
//        verticalItem2Btn.isHidden = true
//        circularProgressView.isHidden = false
//        self.verticalItem2Lbl.isHidden = false
//        SDDownloadManager.shared.alterBlocksForOngoingDownload(withUniqueKey: url.lastPathComponent) { progress in
//            self.circularProgressView.progress = Float(progress)
//            self.verticalItem2Lbl.text = String(format: "%.f %%", progress * 100)
//        } setCompletion: { error, fileUrl in
//            self.circularProgressView.isHidden = true
//            self.verticalItem2Lbl.isHidden = true
//            self.circularProgressView.progress = 0
//            self.verticalItem2Btn.isHidden = false
//            self.verticalItem2Btn.isSelected = true
//            
//            if let error = error{
//                self.makeToast(error.localizedDescription)
//                return
//            }
//            let isPdocast = content.contentType?.prefix(2).uppercased() == "PD" ? true : false
//            if isPdocast{
//                DatabaseContext.shared.addPodcast(content: content)
//            }else{
//                DatabaseContext.shared.addSong(content: content,isSingleDownload: true)
//            }
//            self.makeToast("Song download success")
//        }
//
//        
//    }
//}
