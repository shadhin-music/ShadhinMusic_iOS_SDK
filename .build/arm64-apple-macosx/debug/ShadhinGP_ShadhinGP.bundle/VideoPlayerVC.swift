//
//  VIdeoPlayerVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 11/24/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit

class VideoPlayerVC: UIViewController,NIBVCProtocol {
    @IBOutlet weak var noInternetView : NoInternetView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var contentHolder: UIView!
    @IBOutlet weak var contentBtnHolder: UIView!
    @IBOutlet weak var autoPlayHolder: UIView!
    @IBOutlet weak var autoImg: UIImageView!
    @IBOutlet weak var videoHolder: UIView!
    @IBOutlet weak var currentVideoTitle: UILabel!
    @IBOutlet weak var currentVideoSubTitle: UILabel!
    @IBOutlet weak var favHolder: UIStackView!
    @IBOutlet weak var watchLaterHolder: UIStackView!
    @IBOutlet weak var shareHolder: UIStackView!
    @IBOutlet weak var downloadHolder: UIStackView!
    @IBOutlet weak var settingsHolder: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let downloadManager = SDDownloadManager.shared
    
    var previousBarStyle : UIBarStyle? = UIBarStyle.default
    
    var history_data: CommonContentProtocol?{
        didSet{
            if oldValue != nil{
                self.userHistoryTracking(
                    item: oldValue!,
                    start_time: history_start_time,
                    totalPlayedSeconds: history_total_duration)
            }
            history_start_time = getCurrentDateAndTime()
            history_total_duration = 0
        }
    }
    var history_start_time: String = ""
    var history_total_duration: Int = 0
    
    var index = 0{
        didSet{
            guard let collectionView = self.collectionView, index < videoList.count else {return}
            let indexBefore = IndexPath(row: oldValue, section: 0)
            let indexAfter = IndexPath(row: index, section: 0)
            collectionView.reloadItems(at: [indexBefore, indexAfter])
            DispatchQueue.main.asyncAfter(deadline: .now()+0.6) { [weak self] in
                self?.collectionView?.scrollToItem(at: indexAfter, at: [.top, .centeredHorizontally], animated: true)
            }
        }
    }
    var videoList = [CommonContentProtocol]()
    
    var inTransition = false
    var axis : NSLayoutConstraint.Axis = .horizontal{
        didSet{
            inTransition = true
            self.collectionView.startInteractiveTransition(to: axis == .horizontal ? self.listCVLayout : self.gridCVLayout){
                _,_ in
                self.inTransition = false
            }
            self.collectionView.reloadData()
            self.collectionView.finishInteractiveTransition()
        }
    }
    lazy var listCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        collectionFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionFlowLayout.itemSize = getHorizontalSize()
        collectionFlowLayout.minimumInteritemSpacing = 16
        collectionFlowLayout.minimumLineSpacing = 16
        collectionFlowLayout.scrollDirection = .vertical
        return collectionFlowLayout
    }()
    lazy var gridCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        collectionFlowLayout.scrollDirection = .vertical
        collectionFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionFlowLayout.itemSize = getVerticalSize()
        collectionFlowLayout.minimumInteritemSpacing = 16
        collectionFlowLayout.minimumLineSpacing = 16
        return collectionFlowLayout
    }()
    
    lazy var screenWidth: CGFloat = {
        return UIScreen.main.bounds.width
    }()
    
    private var videoPlayer : VGPlayer!
    
    private var isCurrentItemFav : Bool?{
        didSet{
            if isCurrentItemFav == nil{
                favHolder.isHidden = true
            }else{
                favHolder.isHidden = false
                let favImg = self.favHolder.viewWithTag(1) as? UIImageView
                if isCurrentItemFav!{
                    favImg?.image = UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                }else{
                    favImg?.image = UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                }
            }
        }
    }
    
    private var currentItemImgView: UIImageView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        history_start_time = ""
        history_total_duration = 0
        contentHolder.layer.cornerRadius = 16
        contentHolder.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        initClickListener()
        loadCollection()
        let playeView = VGCustomPlayerView()
        self.videoPlayer = VGPlayer(playerView: playeView)
        getVideoUrl(content: videoList[index])
        //playVideo(urlString: videoList[index].playUrl ?? "", title: videoList[index].title ?? "")
        addWatchLaterAndHistory(songsData: videoList, songIndex: index, isHistory: true)
        noInternetView.isHidden = true
        noInternetView.retry = {[weak self] in
            // guard let self = self else {return}
            if ConnectionManager.shared.isNetworkAvailable{
                //loadAll()
            }
        }
        noInternetView.gotoDownload = {[weak self] in
            guard let self = self else {return}
            if checkProUser(){
                let vc = DownloadVC.instantiateNib()
                vc.selectedDownloadSeg = .init(title: ^String.Downloads.songs, type: .None)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func initClickListener(){
        autoPlayHolder.setClickListener {
            if self.autoPlayHolder.tag == 0{
                self.autoPlayHolder.tag = 1
                UIView.transition(
                    with: self.autoImg,
                    duration: 0.2,
                    options: UIView.AnimationOptions.transitionCrossDissolve) {
                        self.autoImg.image = UIImage(named: "ic_toggle_v_off",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                    }
            }else{
                self.autoPlayHolder.tag = 0
                UIView.transition(
                    with: self.autoImg,
                    duration: 0.2,
                    options: UIView.AnimationOptions.transitionCrossDissolve) {
                        self.autoImg.image = UIImage(named: "ic_toggle_v_on",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                    }
            }
        }
        backBtn.setClickListener {
            self.navigationController?.popViewController(animated: true)
        }
        settingsHolder.setClickListener {
            let audioSettingVC = AudioSettingsVC.instantiateNib()
            audioSettingVC.player = self.videoPlayer.player
            let height: CGFloat = 205
            SwiftEntryKit.display(entry: audioSettingVC, using: SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 16))
        }
        watchLaterHolder.setClickListener {
            self.addWatchLaterAndHistory(songsData: self.videoList, songIndex: self.index, isHistory: false)
        }
        shareHolder.setClickListener {
            DeepLinks.createLinkTest(controller: self)
        }
        favHolder.setClickListener {
            self.toggleFav()
        }
        downloadHolder.setClickListener {
            var content =  self.videoList[self.index]
            ShadhinCore.instance.api.getDownloadUrl(content) { playUrl, error in
                if let playUrl = playUrl{
                    content.playUrl = playUrl
                    self.onDownload(content: content, type: .Video)
                }else{
                    self.view.makeToast(error?.localizedDescription, position: .bottom)
                }
            }
            
            
        }
    }
    
    private func getVideoUrl(content: CommonContentProtocol){
        history_data = content
        ShadhinCore.instance.api.getPlayUrl(content) { playUrl, error in
            guard let playUrl = playUrl else {return}
            self.playVideo(urlString: playUrl, title: content.title ?? "")
        }
    }
    
    private func playVideo(urlString: String,title: String) {
        let decodedUrlString = urlString.decryptUrl() ?? ""
        
        #if DEBUG
        print("Content play url -> \(decodedUrlString)")
        //decodedUrlString = "https://shadhinmusiccontent.sgp1.digitaloceanspaces.com/VideoMainFile/bhalobeshejebhulejay_imranandpuja.mp4"
        //decodedUrlString = "https://shadhinmusiccontent.sgp1.digitaloceanspaces.com/test_video_url/test_5.mp4"
        //"https://shadhinmusiccontent.sgp1.digitaloceanspaces.com/VideoMainFile/BhalobesheJeBhuleJay_ImranAndPuja.mkv"
        #endif
        
        guard let url = URL(string: decodedUrlString) else {return}
        self.videoPlayer.cleanPlayer()
        
        if self.videoPlayer.displayView.superview == nil{
            videoHolder.removeAllSubviews()
            videoHolder.addSubview(self.videoPlayer.displayView)
        
            self.videoPlayer.delegate = self
            self.videoPlayer.displayView.delegate = self
            
            self.videoPlayer.displayView.titleLabel.isHidden = true
            self.videoPlayer.displayView.closeButton.isHidden = true
            
            self.videoPlayer.displayView.snp.makeConstraints { [weak self] (make) in
                guard let strongSelf = self else { return }
                make.top.equalTo(strongSelf.videoHolder.snp.top)
                make.left.equalTo(strongSelf.videoHolder.snp.left)
                make.right.equalTo(strongSelf.videoHolder.snp.right)
                make.bottom.equalTo(strongSelf.videoHolder.snp.bottom)
            }
        }
        
        self.videoPlayer.replaceVideo(url)
        self.currentVideoTitle.text = title
        self.currentVideoSubTitle.text = videoList[index].artist
        self.videoPlayer.displayView.titleLabel.text = title
        self.videoPlayer.play()
    }
    
    func loadCollection(){
        self.collectionView.register(VideoPlayerHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: VideoPlayerHeaderView.identifier)
        collectionView.register(VideoPlayerCell.nib, forCellWithReuseIdentifier: VideoPlayerCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @IBAction func toggleBtnVisibility(_ sender: UIButton) {
        if sender.tag == 0{
            sender.tag = 1
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut,
                           animations: {
                self.contentBtnHolder.alpha = 0
                self.contentBtnHolder.isHidden = true
                sender.setImage(UIImage(named:"ic_drop_up_t",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            })
        }else{
            sender.tag = 0
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut,
                           animations: {
                self.contentBtnHolder.isHidden = false
                sender.setImage(UIImage(named:"ic_drop_t",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                self.contentBtnHolder.alpha = 1
            })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
      //  AudioPlayer.shared.stop()
        MusicPlayerV3.isAudioPlaying = false
        AppUtility.lockOrientation(.allButUpsideDown)
        previousBarStyle = self.navigationController?.navigationBar.barStyle
        self.navigationController?.navigationBar.barStyle = .black
        //AppDelegate.shared?.mainHome?.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        MusicPlayerV3.shared.dismissPopup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllFavorites()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //updatePopupBarAppearance()
        AppUtility.lockOrientation(.portrait)
        videoPlayer.delegate = nil
        videoPlayer.cleanPlayer()
        history_data = nil
        history_start_time = ""
        history_total_duration = 0
        if previousBarStyle != nil{
            self.navigationController?.navigationBar.barStyle = previousBarStyle!
        }
    }
    
    private func getAllFavorites(_ isSilentCheck : Bool = false) {
        if !isSilentCheck{
            isCurrentItemFav = nil
        }
        ShadhinCore.instance.api.getAllFavoriteByType(
            type: .video) { (favs, error) in
                Log.error(error?.localizedDescription ?? "")
                guard let favt = favs
                else {return}
                if favt.contains(where: {$0.contentID == self.videoList[self.index].contentID}) {
                    self.isCurrentItemFav = true
                }else {
                    self.isCurrentItemFav = false
                }
            }
        isItemDownloaded()
        isItemInHistory()
    }
    
    private func isItemInHistory(){
        guard let contentId = self.videoList[self.index].contentID,
        let watchLaterImg = watchLaterHolder.viewWithTag(1) as? UIImageView,
        let watchLaterLbl = watchLaterHolder.viewWithTag(2) as? UILabel else {return}
        
        if VideoWatchLaterAndHistroyDatabase.instance.isWatchLater(contentID: contentId){
           // watchLaterImg.image = #imageLiteral(resourceName: "ic_watchlater_active")
            watchLaterImg.image = UIImage(named: "ic_watchlater_active",in:Bundle.ShadhinMusicSdk,compatibleWith: nil)
            watchLaterLbl.text = "Saved"
        }else{
           // watchLaterImg.image = #imageLiteral(resourceName: "ic_watch_t")
            watchLaterImg.image = UIImage(named: "ic_watch_t",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            watchLaterLbl.text = "Watch later"
        }
    }
    
    private func isItemDownloaded(){
        guard let contentId = self.videoList[self.index].contentID,
        let downloadImg = downloadHolder.viewWithTag(1) as? UIImageView,
        let downloadLbl = downloadHolder.viewWithTag(2) as? UILabel else {return}
        
        if VideosDownloadDatabase.instance.isDownloaded(contentID: contentId){
           // downloadImg.image = #imageLiteral(resourceName: "ic_download_video_active")
            downloadImg.image = UIImage(named: "ic_download_video_active",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            downloadLbl.text = "Downloaded"
        }else{
           // downloadImg.image = #imageLiteral(resourceName: "ic_download_t")
            downloadImg.image = UIImage(named: "ic_download_t",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            downloadLbl.text = "Download"
        }
    }
    
    private func toggleFav(){
        guard let isCurrentItemFav = self.isCurrentItemFav else {return}
        let contentId = self.videoList[self.index].contentID ?? ""
        if isCurrentItemFav {
            ShadhinCore.instance.api.addOrRemoveFromFavorite(
                content: self.videoList[self.index],
                action: .remove) { (err) in
                    if err != nil {
                        ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                    }else {
                        if contentId == self.videoList[self.index].contentID{
                            self.isCurrentItemFav = false
                        }
                        self.view.makeToast("Removed from Favorites")
                    }
                }
        }else {
            ShadhinCore.instance.api.addOrRemoveFromFavorite(
                content: self.videoList[self.index],
                action: .add) { (err) in
                    if err != nil {
                        ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                    }else {
                        if contentId == self.videoList[self.index].contentID{
                            self.isCurrentItemFav = true
                        }
                        self.view.makeToast("Added To Favorites")
                    }
                }
        }
    }
    
    private func changeSongsWithIndex(songIndex: Int) {
        let model = videoList[songIndex]
        //playVideo(urlString: model.playUrl ?? "", title: model.title ?? "")
        getVideoUrl(content: model)
        addWatchLaterAndHistory(songsData: videoList, songIndex: songIndex, isHistory: true)
        getAllFavorites()
    }
    
    private func addWatchLaterAndHistory(songsData: [CommonContentProtocol], songIndex: Int,isHistory: Bool) {
        
        let instance = VideoWatchLaterAndHistroyDatabase.instance
        let contentId = songsData[songIndex].contentID ?? ""
        
        //print("is it in as history -> \(instance.isWatchLater(contentID : contentId))")
        
        if instance.isWatchLater(contentID : contentId) && isHistory{
            return
        }
        
        var isHistoryEntry = isHistory
        if !isHistory{
            isHistoryEntry = instance.isWatchLater(contentID : contentId)
        }
        
        let isExist = instance.checkRecordExists(contentID: songsData[songIndex].contentID ?? "")
        if isExist {
            instance.updateDataToDatabase(videoData: songsData, songIndex: songIndex, isHistory: isHistoryEntry)
        }else {
            instance.saveDataToDatabase(videoData: songsData, songIndex: songIndex, isHistory: isHistoryEntry)
        }

        if !isHistory {
            view.makeToast("\(isHistoryEntry ? "Removed from" : "Added to") watch history")
            isItemInHistory()
        }
    }
    
    private func userHistoryTracking(item: CommonContentProtocol, start_time: String, totalPlayedSeconds: Int) {
        if let contentID = item.contentID,
           let type = item.contentType{
            
//            #if DEBUG
//            print("id: \(contentID) type: \(type) start_time: \(start_time) duration: \(totalPlayedSeconds)")
//            return
//            #endif
            var playDuration : Int = totalPlayedSeconds
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let start = dateFormatter.date(from: start_time){
                let differenceInSeconds = Int(Date().timeIntervalSince(start))
                let videoPlayed = Int(totalPlayedSeconds)
                
                playDuration = min(min(differenceInSeconds, Int(videoPlayed)), playDuration)
                
            }
            guard playDuration > 0 else {return}
//            Analytics.logEvent("sm_content_played",
//                               parameters: [
//                                "content_type"  : type.lowercased() as NSObject,
//                                "content_id"    : contentID as NSObject,
//                                "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
//                                "content_name"  : item.title?.lowercased() ?? "" as NSObject,
//                                "duration_sec"  : playDuration as NSObject,
//                                "platform"      : "ios" as NSObject
//                               ])
            if let content = history_data{
                SMAnalytics.viewContent(content: content)
            }
            
            ShadhinCore.instance.api.trackUserHistory(
                contentID: contentID,
                type: type,
                playCount: "1",
                totalPlayInSeconds: playDuration,
                playInDate: start_time,
                playOutDate: getCurrentDateAndTime(),
                playlistId: "")
            { (success) in
                //print("streamed successfully")
            }
            ShadhinCore.instance.api.trackUserHistoryV6(
                contentID: contentID,
                type: type,
                playCount: "1",
                totalPlayInSeconds: playDuration,
                playInDate: start_time,
                playOutDate: getCurrentDateAndTime(),
                playlistId: "")
            { (success) in
                //print("streamed successfully")
            }
        }
    }

    
}

extension VideoPlayerVC: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        videoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPlayerCell", for: indexPath) as! VideoPlayerCell
        cell.stackView.axis = self.axis
        if axis == .horizontal{
            cell.stackView.spacing = 16
        }else{
            cell.stackView.spacing = 0
        }
        let model = videoList[indexPath.row]
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "1280") ?? ""
        cell.videoImg.kf.indicatorType = .activity
        cell.videoImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_video",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        cell.mainTitle.text = model.title ?? ""
        cell.subTitle.text = model.artist ?? ""
        if self.index == indexPath.row{
            cell.mainTitle.textColor = #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            currentItemImgView = cell.playPauseImg
            if videoPlayer.player?.rate ?? 0 > 0{
              //  currentItemImgView?.image = #imageLiteral(resourceName: "ic_video_pause.pdf")
                currentItemImgView?.image = UIImage(named: "ic_video_pause",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            }else{
                if let currentItemImgView {
                    currentItemImgView.image = UIImage(named: "ic_video_play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                } else {
                    print("No image")
                }
               
                currentItemImgView?.backgroundColor = .blue
               // currentItemImgView?.image = UIImage(named: "ic_video_play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            }
        }else{
            cell.mainTitle.textColor = .primaryLableColor()
         //   cell.playPauseImg.image = #imageLiteral(resourceName: "ic_video_play.pdf")
            cell.playPauseImg.image = UIImage(named: "ic_video_play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            
        }
        cell.playPauseImg.tag = indexPath.row
        cell.setClickListener {
            self.index = indexPath.row
            self.changeSongsWithIndex(songIndex: self.index)
        }
        cell.menuBtn.setClickListener {
            
            let menu = MoreMenuVC()
            menu.menuType = .Video
            menu.openForm = .Video
            menu.delegate = self
            menu.data = self.videoList[indexPath.row]
            let height = MenuLoader.getHeightFor(vc: .Video, type: .Video, operators: [])
            
            var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
            attribute.entryBackground = .color(color: .clear)
            attribute.border = .none
            attribute.lifecycleEvents.willDisappear = {
                self.getAllFavorites(true)
            }
            
            SwiftEntryKit.display(entry: menu, using: attribute)
            
        }
        cell.checkSongsIsDownloading(data: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        switch axis{
        case .vertical:
            return getVerticalSize()
        default:
            return getHorizontalSize()
        }
    }
    
    func getVerticalSize() -> CGSize{
        let w = (screenWidth - 48)/2
        let h = screenWidth * 0.378
        return CGSize(width: w, height: h)
    }
    
    func getHorizontalSize() -> CGSize{
        let w = (screenWidth - 32)
        let h = screenWidth * 0.178
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: VideoPlayerHeaderView.identifier, for: indexPath) as! VideoPlayerHeaderView
        headerView.viewModeBtn.setClickListener {
            if self.inTransition{
                return
            }
            switch self.axis{
            case .horizontal:
                self.axis = .vertical
                headerView.viewModeBtn.setImage(UIImage(named: "ic_list_mode",in: Bundle.ShadhinMusicSdk,compatibleWith: nil),for: .normal)
            default:
                self.axis = .horizontal
                headerView.viewModeBtn.setImage(UIImage(named: "ic_grid_mode",in: Bundle.ShadhinMusicSdk,compatibleWith: nil),for: .normal)
            }
        }
        return headerView
    }
}

extension VideoPlayerVC: VGPlayerDelegate {
    
    func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError) {
        Log.error(error.description)
    }
    
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        if state == .playFinished {
            if self.autoPlayHolder.tag == 0 {
                index += 1
                if index >= videoList.count {
                    index = 0
                }
                self.changeSongsWithIndex(songIndex: self.index)
            } else {
                currentItemImgView?.image = UIImage(named:"ic_video_play", in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                
            }
        }
        guard let imgView = currentItemImgView, imgView.tag == index else {return}
        if state == .playing{
            imgView.image = UIImage(named:"ic_video_pause", in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        }
        if state == .paused{
            imgView.image = UIImage(named: "ic_video_play",in: Bundle.ShadhinMusicSdk,compatibleWith:nil)
        }
    }
    
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {
        Log.info("buffer State --> \(state)")
    }
    
    func vgPlayer(_ player: VGPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
        //Log.info("vgPlayer --> bufferedDuration \(bufferedDuration)")
        //self.history_total_duration = Int(bufferedDuration)
    }
    var totalDurationWatched: TimeInterval {
       get {
           var totalDurationWatched = 0.0
           if let accessLog = videoPlayer.player?.currentItem?.accessLog(), accessLog.events.isEmpty == false {
               for event in accessLog.events where event.durationWatched > 0 {
                   totalDurationWatched += event.durationWatched
               }
           }
           let duration = videoPlayer.player?.currentItem?.duration.seconds ?? 0
           if totalDurationWatched <= duration{
               return totalDurationWatched
           }
           
           return 0
       }
   }
}

extension VideoPlayerVC: VGPlayerViewDelegate {
    
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {
        if fullscreen {
            self.videoPlayer.displayView.titleLabel.isHidden = false
            self.videoPlayer.displayView.closeButton.isHidden = false
        }else {
            self.videoPlayer.displayView.titleLabel.isHidden = true
            self.videoPlayer.displayView.closeButton.isHidden = true
        }
    }
    
    func vgPlayerView(didTappedClose playerView: VGPlayerView) {
        if playerView.isFullScreen {
            playerView.exitFullscreen()
        }
    }
    
    func vgPlayer(_ player: VGPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {
        //print(currentDuration)
        Log.info("vgPlayer --> currentDuration \(currentDuration)")
        self.history_total_duration += 1
    }
    
    func vgPlayerView(didDisplayControl playerView: VGPlayerView) {
        backBtn.isHidden = !playerView.isDisplayControl
    }
}


extension VideoPlayerVC : MoreMenuDelegate{
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        SDFileUtils.removeItemFromDirectory(urlName: content.playUrl ?? "")
        VideosDownloadDatabase.instance.deleteDataFromDatabase(contentID: content.contentID ?? "")
        RecentlyPlayedDatabase.instance.deleteDataFromDatabase(contentID: content.contentID ?? "")
        view.makeToast("Offline video removed from storage")
        
    }
    //remove from watch later
    func onRemoveFromHistory(content: CommonContentProtocol) {
        
        VideoWatchLaterAndHistroyDatabase.instance.updateDataToDatabase(videoData: [content], songIndex: 0, isHistory: true)
        isItemInHistory()
        view.makeToast("Remove from watch later")
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        
    }
    
    func addToPlaylist(content: CommonContentProtocol) {
        
    }
    
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}

        guard checkProUser() else {
            return
        }
    
//        guard let url = URL(string: content.playUrl?.decryptUrl() ?? "") else {
//            return self.view.makeToast("Unable to get Download url for file")
//        }
        
        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: content.playUrl)
        if isDownloading {
            return
        }
        
        //send data to firebase analytics
        AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
        
        if let playUrl = content.playUrl, let url = URL(string: playUrl){
            let request = URLRequest(url: url)
            let key = self.downloadManager.downloadFile(withRequest: request,onProgress: { progress in
                
            }, onCompletion: { error, url in
                if error != nil{
                    self.view.makeToast("Download failed")
                    if let url = URL(string: content.playUrl ?? "") {
                        self.downloadManager.cancelDownload(forUniqueKey: url.lastPathComponent)
                    }
                    
                }else if url != nil{
                    self.view.makeToast("File successfully downloaded.")
                    //save song
                    VideosDownloadDatabase.instance.saveDataToDatabase(musicData: content)
                    Log.info("Download complete")
                    //send download info to server
                    ShadhinApi().downloadCompletePost(model: content)
                    self.collectionView.reloadData()
                }
            })
            collectionView.reloadData()
           
        }
        self.view.makeToast("Downloading \(String(describing: content.title ?? ""))")
        
    }
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
    
    }
}

class AudioNotification {
    // Function to post play notification
    static func postAudioPlayNotification(contentId: String) {
        NotificationCenter.default.post(name: .audioPlayNotification, object: nil, userInfo: ["contentId": contentId])
    }

    // Function to post pause notification
    static func postAudioPauseNotification(contentId: String) {
        NotificationCenter.default.post(name: .audioPauseNotification, object: nil, userInfo: ["contentId": contentId])
    }

    // Function to post buffering notification
    static func postAudioBufferingNotification(contentId: String) {
        NotificationCenter.default.post(name: .audioBufferingNotification, object: nil, userInfo: ["contentId": contentId])
    }
    
}

extension Notification.Name {
    static let audioPlayNotification = Notification.Name("audioPlayNotification")
    static let audioPauseNotification = Notification.Name("audioPauseNotification")
    static let audioBufferingNotification = Notification.Name("audioBufferingNotification")
}
