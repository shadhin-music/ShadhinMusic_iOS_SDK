//
//  MusicPlayerV3.swift
//  Shadhin
//
//  Created by Joy on 22/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import iCarousel
import AVKit
import MediaPlayer

class MusicPlayerV3: UIViewController,NIBVCProtocol {
    var viewModel = GPAudioViewModel.shared
    static var shared : MusicPlayerV3 {
        if _initial == nil {
            _initial =  MusicPlayerV3()
        }
        return _initial!
    }
    //   var tabBar : UITabBarController?
     static var _initial : MusicPlayerV3?
    
    private init(){
        super.init(nibName: String(describing: "MusicPlayerV3"), bundle:Bundle.ShadhinMusicSdk)
        playPauseBarBtn = UIBarButtonItem(image: UIImage(named: "ic_pause", in:Bundle.ShadhinMusicSdk,compatibleWith: nil), style: .plain, target: self, action: #selector(playPauseAction))
        playPauseBarBtn.tintColor = .white
    }
    
    enum CardState {
        case collapsed
        case expanded
    }
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    var rootContent: CommonContentProtocol? = nil
    var cardLyricsVC : LyricsCardVC!
    var cardCommentsVC : PodcastCommentVC!
    var visualEffectView:UIVisualEffectView!
    var endCardHeight:CGFloat = 0
    var startCardHeight:CGFloat = 0
    var cardVisible = false
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    private var isRepeatOne = false
    private var isShuffleOn = false
    weak var delegate: ChapterCellUpdaterDelegate?
    var coordinator: HomeCoordinator?
    weak var audioDetailsVC: AudioBookDetailsVC!
    var audioPatchContent : [AudioBookContent]?
    var trackCompletionContent:AudioBookProgress?

    var isOnPlayingRetry = false
    static var isAudioPlaying = false
    static var songContentID = ""
    var episodeId = ""
    static var audioPlayer : AudioPlayer = AudioPlayer.shared
    var isFav = false
    var songsIndex = 0
    var playlistId = ""
    private var playStartTime = ""
  //  private var audioItems = [AudioItem]()
    private var playPauseBarBtn: UIBarButtonItem!
    private let downloadManager = SDDownloadManager.shared
    
    var history_data: CommonContentProtocol?
    var history_start_time: String?
    var history_total_duration: Int = 0{
        didSet{
            if !ShadhinCore.instance.isUserPro {
                //ChorkiAudioAd.instance.updateTime()
            }
        }
    }
    var history_timer = Timer()
    
    var currentTime: CMTime = .zero
    var waitedForFileToPlayTick: Int = 0
    
    var musicdata: [CommonContentProtocol] = [] {
        didSet {
            viewModel.audioItems.removeAll()
            if isViewLoaded {
                addAudioItems(urlArray: musicdata)
                self.iCarouselView.reloadData()
            }
        }
    }
    var lyricsRequest: DataRequest?
    
    private var gradientLayer : CAGradientLayer!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closePopupButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var iCarouselView: iCarousel!
    @IBOutlet weak var liveHolder: UIView!
    @IBOutlet weak var liveHolderOffset: NSLayoutConstraint!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    //for pop up animation view holder
    @IBOutlet weak var stackViewModule : UIView!{
        didSet{
            if let containerVC = self.popupContainerViewController{
                containerVC.popupContentView.popupStackModule  = stackViewModule
            }
        }
    }
    @IBOutlet weak var imageModule : UIView!{
        didSet{
            if let containerVC = self.popupContainerViewController{
                containerVC.popupContentView.popupTopModule  = imageModule
                containerVC.popupContentView.popupImageModule = imageModule
            }
        }
    }
    @IBOutlet weak var shadowImageView : UIImageView!{
        didSet{
            if let containerVC = self.popupContainerViewController{
                containerVC.popupContentView.popupImageView  = shadowImageView
            }
        }
    }
    // for animation view set on popup bar
    @IBOutlet weak var titleSubtitleStackView : PBPopupBarTitlesView!{
        didSet{
            if let containerVC = self.popupContainerViewController{
                containerVC.popupContentView.popupStackView = titleSubtitleStackView
            }
        }
    }
    
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var downloadProgressView: CircularProgress!
    
    //player traking view
    @IBOutlet weak var playDurationLbl: UILabel!
    @IBOutlet weak var trackDuration: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    
    
    //player control view
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var prevPlayBtn: UIButton!
    @IBOutlet weak var nextPlayBtn: UIButton!
    @IBOutlet weak var repeatBtn: UIButton!
    @IBOutlet weak var shuffleBtn: UIButton!
    
    
    @IBOutlet weak var bottomOptionHeight: NSLayoutConstraint!
    @IBOutlet weak var imageModuleWidth: NSLayoutConstraint!
    
    //bottom view
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var sleepTimerBtn: UIButton!
    @IBOutlet weak var songsInQueueBtn: UIButton!
    @IBOutlet weak var createPlaylistBtn: UIButton!
    @IBOutlet weak var playerSpeedBtn: UIButton!
    @IBOutlet weak var adBannerMax: UIView!
    
    @IBOutlet weak var topSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var routePickerView: AVRoutePickerView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        playPauseBarBtn = UIBarButtonItem(image: UIImage(named: "ic_pause",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), style: .plain, target: self, action: #selector(playPauseAction))
        playPauseBarBtn.tintColor = .white
    }
    
    deinit {
        //print("MusiciPlayerVC deinit called")
        NotificationCenter.default.removeObserver(self)
        ShadhinCore.instance.api.releaseServerLock()
        self.history_timer.invalidate()
        self.userHistoryTracking(newIndex: nil)
    }
    
    @IBOutlet weak var ChorkiAdView: UIView!
    @IBOutlet weak var ChorkiSlider: UISlider!
    @IBOutlet weak var ChorkiSkipBtn: UIButton!
    @IBOutlet weak var ChorkiAdDuration: UILabel!
    @IBOutlet weak var ChorkiWatchNowBtn: UIButton!
    var adPlayer: AVPlayer? = nil
    var isChorkiAdIsPlaying = false
    
    
    private func playChorkiAudioAd(){
        guard let url = Bundle.main.url(forResource: "ad_file", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        let content = CommonContent_V0()
        //        content.contentID = "0000"
        //        content.contentType = "s"
        //        content.image = imageUrl.absoluteString
        //        content.title = "Chorki Ad"
        //        content.artist = "Advertisement"
        //
        let playPauseBtnMini = (MainTabBar.shared?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini)?.playPauseBtn
        updateMiniPlayerInfo(content: content, tabBar: self.tabBarController)
        playPauseBtnMini?.showLoading()
        
        
        ChorkiAdDuration.text = "00:00"
        ChorkiAdView.isHidden = false
        ChorkiSkipBtn.isHidden = true
        self.view.bringSubviewToFront(ChorkiAdView)
        audioPause()
        isChorkiAdIsPlaying = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            //adPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            adPlayer = AVPlayer(url: url)
            adPlayer?.play()
            adPlayer?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main, using: { [weak self] time in
                if let duration = self?.adPlayer?.currentItem?.duration {
                    let duration = CMTimeGetSeconds(duration),
                        time = CMTimeGetSeconds(time)
                    let progress = Float(time/duration)
                    self?.ChorkiAdDuration.text = formatSecondsToString(time)
                    if time >= 20 , self?.ChorkiSkipBtn.isHidden == true{
                        self?.ChorkiSkipBtn.isHidden = false
                        
                    }
                    Log.info("progress \(progress)")
                    if progress < 0.99 {
                        self?.ChorkiSlider.value = progress
                    }else if(progress >= 0.99){
                        self?.adPlayer?.replaceCurrentItem(with: nil)
                        self?.adPlayer = nil
                        self?.ChorkiAdView.isHidden = true
                        self?.isChorkiAdIsPlaying = false
                        self?.audioResume()
                    }
                }
            })
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        
        
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
        //            self.ChorkiAdView.isHidden = true
        //            self.isChorkiAdIsPlaying = false
        //            self.audioResume()
        //        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        ChorkiAudioAd.instance.shouldPlayAudioAd = {
        //            self.playChorkiAudioAd()
        //        }
        //        ChorkiSkipBtn.setClickListener {
        //            self.adPlayer?.replaceCurrentItem(with: nil)
        //            self.adPlayer = nil
        //            self.ChorkiAdView.isHidden = true
        //            self.isChorkiAdIsPlaying = false
        //            self.audioResume()
        //        }
        //        ChorkiWatchNowBtn.setClickListener {
        //            if let url = URL(string: "https://www.chorki.com/series/procholito?utm_source=shadhin_chorki&utm_medium=cpm&utm_campaign=chorki_procholito_shadhin_audio_ads") {
        //                UIApplication.shared.open(url)
        //            }
        //        }
        if let popupBar = self.popupContainerViewController?.popupBar{
            popupBar.dataSource = self
            popupBar.titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            popupBar.subtitleLabel.font = .systemFont(ofSize: 10, weight: .regular)
            
        }
        gradientSetup()
        self.view.backgroundColor = .customBGColor()
        
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            let topPadding = window?.safeAreaInsets.top ?? 0
            topSpacing.constant = topPadding //+ 20
        }else{
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top ?? 0
            topSpacing.constant = topPadding //+ 20
        }
        
        imageModule.clipsToBounds = true
        imageModule.layer.cornerRadius = 10
        imageModule.isHidden = true
        shadowImageView.cornerRadius = 10
        //view.backgroundColor = .customBGColor()
        
        playerSlider.setThumbImage(UIImage(named: "slider img",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        playerSlider.setThumbImage(UIImage(named: "slider img",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .highlighted)
        
        playPauseBtn.setImage(UIImage(named: "music_v4/ic_play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        playPauseBtn.setImage(UIImage(named: "music_v4/ic_pause",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .selected)
        
        routePickerView.tintColor =  UIColor(red: 0.41, green: 0.42, blue: 0.44, alpha: 1.00)
        routePickerView.delegate = self
        
        iCarouselView.type = .custom
        iCarouselView.contentMode = .scaleToFill
        iCarouselView.isPagingEnabled = true
        iCarouselView.clipsToBounds = true
        
        MusicPlayerV3.audioPlayer.delegate = self
        MusicPlayerV3.audioPlayer.mode = .normal
        ShadhinPlayerSleepTimer.instance.delegate = self
        
        downloadProgressView.font = .systemFont(ofSize: 11)
        
        playerSpeedBtn.setClickListener {
            let speedAlert = UIAlertController(title: "Speed", message: "Please select your preferred player speed...", preferredStyle: UIAlertController.Style.actionSheet)
            
            let _050 = UIAlertAction(title: "x 0.50", style: .default) { (action: UIAlertAction) in
                MusicPlayerV3.audioPlayer.rate = 0.50
                self.playerSpeedBtn.setTitle("0.5x", for: .normal)
            }
            
            let _067 = UIAlertAction(title: "x 0.67", style: .default) { (action: UIAlertAction) in
                MusicPlayerV3.audioPlayer.rate = 0.67
                self.playerSpeedBtn.setTitle("0.67x", for: .normal)
            }
            
            let _080 = UIAlertAction(title: "x 0.80", style: .default) { (action: UIAlertAction) in
                MusicPlayerV3.audioPlayer.rate = 0.80
                self.playerSpeedBtn.setTitle("0.8x", for: .normal)
            }
            
            let _100 = UIAlertAction(title: "x 1.00", style: .default) { (action: UIAlertAction) in
                MusicPlayerV3.audioPlayer.rate = 1.0
                self.playerSpeedBtn.setTitle("1.0x", for: .normal)
            }
            
            let _125 = UIAlertAction(title: "x 1.25", style: .default) { (action: UIAlertAction) in
                MusicPlayerV3.audioPlayer.rate = 1.25
                self.playerSpeedBtn.setTitle("1.25x", for: .normal)
            }
            
            let _150 = UIAlertAction(title: "x 1.50", style: .default) { (action: UIAlertAction) in
                MusicPlayerV3.audioPlayer.rate = 1.50
                self.playerSpeedBtn.setTitle("1.5x", for: .normal)
            }
            
            let _200 = UIAlertAction(title: "x 2.00", style: .default) { (action: UIAlertAction) in
                MusicPlayerV3.audioPlayer.rate = 2.0
                self.playerSpeedBtn.setTitle("2.0x", for: .normal)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            speedAlert.addAction(_050)
            speedAlert.addAction(_067)
            speedAlert.addAction(_080)
            speedAlert.addAction(_100)
            speedAlert.addAction(_125)
            speedAlert.addAction(_150)
            speedAlert.addAction(_200)
            speedAlert.addAction(cancelAction)
            self.present(speedAlert, animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkFav), name: .init(rawValue: "FavDataUpdateNotify"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shuffleModified), name: .init(rawValue: "ShuffleListNotify"), object: nil)
    }
    
    
    @objc func shuffleModified(){
        guard let _rootContent = rootContent,
              let _contentID = _rootContent.contentID,
              let _contentType = _rootContent.contentType else {return}
        if ShadhinCore.instance.defaults.checkShuffle(contentId: _contentID,contentType: _contentType) {
            shuffleBtn.setImage(UIImage(named: "ic_shuffle_on",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            MusicPlayerV3.audioPlayer.mode = .shuffle
            isShuffleOn = true
        } else {
            shuffleBtn.setImage(UIImage(named: "ic_shuffle",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            if repeatBtn.currentImage == UIImage(named: "ic_repeat_normal",in: Bundle.ShadhinMusicSdk,compatibleWith: nil) {
                MusicPlayerV3.audioPlayer.mode = .normal
            }else {
                MusicPlayerV3.audioPlayer.mode = .repeatAll
            }
            isShuffleOn = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = self.view.bounds
    }
    override func viewDidAppear(_ animated: Bool) {
        self.checkSongsIsDownloading(index: self.songsIndex)
        liveHolderOffset.constant = iCarouselView.itemWidth / 2
        liveHolder.layer.masksToBounds = false
        liveHolder.layer.shadowRadius = 8
        liveHolder.layer.shadowOpacity = 0.9
        liveHolder.layer.shadowColor = UIColor.gray.cgColor
        liveHolder.layer.shadowOffset = CGSize(width: 0 , height:6)
        
        if let containerVC = self.popupContainerViewController {
            containerVC.popupContentView.popupImageView = shadowImageView
            containerVC.popupContentView.popupStackView = titleSubtitleStackView
        }
        imageModuleWidth.constant = iCarouselView.currentItemView?.width ?? 0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //    loadAds()
    }
    
    func dismissPopup(){
        print("music onClosePopupPressed")
        userHistoryTracking(newIndex: nil)
        self.coordinator?.tabBarController?.dismissPopupBar(animated: true)
        self.coordinator?.navigationController.dismissPopupBar(animated: true)
        navigationController?.dismissPopupBar(animated: true)
        tabBarController?.dismissPopupBar(animated: true)
        AudioPlayer.shared.stop()
    }
    
    @IBAction func onClosePopupPressed(_ sender: Any) {
        popupContainerViewController?.closePopup(animated: true)
    }

    @IBAction func onSleepTimerPressedd(_ sender: Any) {
        SleepTimerVC.show()
    }
    
    @IBAction func onSharePressed(_ sender: Any) {
        guard let currentData = MusicPlayerV3.audioPlayer.currentItem?.contentData else {return}
        DeepLinks.createDeepLink(model: currentData, controller: self, vcType: "")
    }
    
    
    @objc private func playPauseAction() {
        playAction(self)
    }
    
    @IBAction func playAction(_ sender: Any) {
        //self.countButtonTouch()
        //        NotificationCenter.default.post(name: .shouldMuteTeaser, object: nil)
        //        guard !isChorkiAdIsPlaying else {return}
        
        if MusicPlayerV3.audioPlayer.state == .stopped {
            self.audioPlay(index: self.iCarouselView.currentItemIndex)
            NotificationCenter.default.post(name: .shouldMuteTeaser, object: nil)
        }else {
            if !MusicPlayerV3.isAudioPlaying {
                NotificationCenter.default.post(name: .shouldMuteTeaser, object: nil)
                self.audioResume()
            }else {
                self.audioPause()
            }
        }
        
        //MusicPlayerVC.isAudioPlaying.toggle()
        NotificationCenter.default.post(name: NSNotification.Name.init("didRecivedData"), object: nil)
    }
    
    @IBAction func nextPlayAction(_ sender: Any) {
        //self.countButtonTouch()
        guard ShadhinPlayerSkipLimit.instance.isActionAllowed() else {
            var style = ToastManager.shared.style
            style.messageAlignment = .center
            self.view.makeToast("Free skip limit reached, Please subscribe or try after some time", style: style)
            return
        }
        MusicPlayerV3.audioPlayer.next()
        iCarouselView.currentItemIndex = MusicPlayerV3.audioPlayer.currentItemIndexInQueue ?? 0
        self.iCarouselView.reloadData()
        
    }
    
    @IBAction func prevPlayAction(_ sender: Any) {
        //self.countButtonTouch()
        guard ShadhinPlayerSkipLimit.instance.isActionAllowed() else {
            var style = ToastManager.shared.style
            style.messageAlignment = .center
            self.view.makeToast("Free skip limit reached, Please subscribe or try after some time", style: style)
            return
        }
        guard ShadhinPlayerSkipLimit.instance.isActionAllowed() else {
            _ = checkProUser()
            return
        }
        MusicPlayerV3.audioPlayer.previous()
        iCarouselView.currentItemIndex = MusicPlayerV3.audioPlayer.currentItemIndexInQueue ?? 0
        self.iCarouselView.reloadData()
    }
    
    @IBAction func shuffleSongsAction(_ sender: Any) {
        if isShuffleOn {
            guard let contentId = self.rootContent?.contentID,
                  let contentType  = self.rootContent?.contentType  else {
                return
            }
            if ShadhinCore.instance.defaults.checkShuffle(contentId:contentId, contentType: contentType) {
                ShadhinCore.instance.defaults.removeShuffle(contentId:contentId, contentType: contentType)
            } else {
                ShadhinCore.instance.defaults.addShuffle(contentId:contentId, contentType: contentType)
            }
            NotificationCenter.default.post(name: .init("ShuffleListNotify"), object: nil)
        }
        isShuffleOn.toggle()
    }
    
    func turnOnShuffle(){
        shuffleBtn.setImage(UIImage(named: "ic_shuffle_on",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        MusicPlayerV3.audioPlayer.mode = .shuffle
        isShuffleOn = true
    }
    
    private var counter = 0
    @IBAction func repeatSongsAction(_ sender: UIButton) {
        //self.countButtonTouch()
        
        let btnImgArr = ["ic_repeat_normal","ic_repeat_one","ic_repeat_all"]
        var audioModeArr = [AudioPlayerMode]()
        
        if isShuffleOn {
            audioModeArr = [[.normal,.shuffle],[.repeat],[.repeatAll,.shuffle]]
        }else {
            audioModeArr = [.normal,.repeat,.repeatAll]
        }
        counter += 1
        if counter >= btnImgArr.count {
            counter = 0
        }
        shuffleBtn.isEnabled = !(counter == 1)
        if counter == 1 {
            shuffleBtn.setImage(UIImage(named: "ic_shuffle",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            isShuffleOn = false
        }
        sender.setImage(UIImage(named: btnImgArr[counter],in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        MusicPlayerV3.audioPlayer.mode = audioModeArr[counter]
    }
    
    @IBAction func playerSliderAction(_ sender: UISlider) {
        let value = Float(MusicPlayerV3.audioPlayer.currentItemDuration ?? 1) * sender.value
        MusicPlayerV3.audioPlayer.seek(to: TimeInterval(value))
    }
    
    @IBAction func favoritesAction(_ sender: UIButton) {
//        guard ShadhinCore.instance.isUserPro  else {
//            self.goSubscriptionTypeVC()
//            return
//        }
        let item = musicdata[iCarouselView.currentItemIndex]
        
        if isFav {
            ShadhinCore.instance.api.addOrRemoveFromFavorite(
                content: item,
                action: .remove) { (err) in
                    if err != nil {
                        ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                    }else {
                        self.favBtn.setImage(UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                        self.view.makeToast("Removed from Favorites")
                        NotificationCenter.default.post(name: .init("FavDataUpdateNotify"), object: nil)
                    }
                }
        }else {
            ShadhinCore.instance.api.addOrRemoveFromFavorite(
                content: item,
                action: .add){ (err) in
                    if err != nil {
                        ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                    }else {
                        self.favBtn.setImage(UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                        self.view.makeToast("Added To Favorites")
                        NotificationCenter.default.post(name: .init("FavDataUpdateNotify"), object: nil)
                    }
                }
        }
        
        isFav.toggle()
        //updateMiniFavorite()
        
    }
    @IBAction func songsDownloadAction(_ sender: Any) {
        guard try! Reachability().connection != .unavailable else {return}
                guard checkProUser() else{
                    return
                }
        var dataValue = musicdata[iCarouselView.currentItemIndex]
        if let playUrl =  dataValue.playUrl, playUrl.contains("http"){
            self.startDownload(dataValue: dataValue, playUrl: playUrl)
        }
        ShadhinCore.instance.api.getDownloadUrl(dataValue) {
            url, error in
            guard let url = url else {return}
            dataValue.playUrl = url
            self.startDownload(dataValue: dataValue, playUrl: url)
        }
    }
    @IBAction func createPlaylistsAction(_ sender: Any) {
        guard checkProUser() else{
            return
        }
        let vc = PlaylistCreateVC()
        var height: CGFloat = 0
        ShadhinCore.instance.api.getBothPlaylistsData{ (playlists, err) in
            guard err == nil else {
                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                return
            }
            
            guard let playlist = playlists else {return}
            if playlist.count > 0 {
                let window = UIApplication.shared.windows.first
                let bottomPadding = window?.safeAreaInsets.bottom ?? 0
                let tableCellHeight: CGFloat = CGFloat((playlist.count * 72) + 130)
                height = bottomPadding + tableCellHeight
                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: height))
                vc.playlists = playlist
                vc.contentID = self.musicdata[self.iCarouselView.currentItemIndex].contentID ?? ""
            }else {
                height = self.view.safeAreaInsets.bottom + 250
                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: height))
            }
        }
    }
    
    @IBAction func playerSettingsAction(_ sender: Any) {
        guard MusicPlayerV3.audioPlayer.player != nil else {return}
        
        //self.routePickerView.isHidden = false
        
        //        let audioSettingVC = AudioSettingsVC()
        //        audioSettingVC.player = MusicPlayerV3.audioPlayer.player!
        //        let height: CGFloat = 205
        //        SwiftEntryKit.display(entry: audioSettingVC, using: SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 16))
    }
    
    @IBAction func onMorePressed(_ sender: Any) {
        guard let song = MusicPlayerV3.audioPlayer.currentItem?.contentData else {return}
        let menu = MoreMenuVC()
        menu.data = song
        menu.delegate = self
        var height : CGFloat = 0
        let tt = SMContentType(rawValue: song.contentType)
        if tt == .song{
            menu.menuType = .Songs
            menu.openForm = .Player
            height = MenuLoader.getHeightFor(vc: .Player, type: .Songs, operators: [])
            if song.albumId == nil || song.albumId == ""{
                height -= 50
            }
        }else{
            menu.menuType = .Podcast
            menu.openForm = .Player
            height = MenuLoader.getHeightFor(vc: .Player, type: .Podcast, operators: [])
        }
        
        var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        SwiftEntryKit.display(entry: menu, using: attribute)
    }
    
}

//MARK: initial setup
extension MusicPlayerV3{
    public func initplayer(_ rootContent: CommonContentProtocol? = nil, _ index: Int = 0){
        self.history_timer.invalidate()
        self.userHistoryTracking(newIndex: nil)
        ShadhinPlayerSkipLimit.instance.setNewRootContent(rootContent)
        if ShadhinPlayerSkipLimit.instance.isLimitingActive{
            self.iCarouselView.type                     = .invertedTimeMachine
            self.iCarouselView.isUserInteractionEnabled = false
            self.isShuffleOn                            = false
            self.shuffleBtn.isEnabled                   = false
            self.shuffleBtn.isUserInteractionEnabled    = false
            self.repeatBtn.isEnabled                    = false
            self.repeatBtn.isUserInteractionEnabled     = false
            self.songsInQueueBtn.isEnabled              = false
            self.shuffleSongsAction("")
        }else{
            self.iCarouselView.type                     = .custom
            self.iCarouselView.contentMode              = .scaleToFill
            self.iCarouselView.isUserInteractionEnabled = true
            self.isShuffleOn                            = true
            self.shuffleBtn.isEnabled                   = true
            self.shuffleBtn.isUserInteractionEnabled    = true
            self.repeatBtn.isEnabled                    = true
            self.repeatBtn.isUserInteractionEnabled     = true
            self.songsInQueueBtn.isEnabled              = true
            self.shuffleSongsAction("")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.audioPlay(index: index)
            // self.updateUI(withIndex: index)
            // self.iCarouselView.scrollToItem(at: index, animated: false)
            // self.playStartTime = getCurrentDateAndTime()
        }
    }
    func updateUI(withIndex index: Int) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.updateUI(withIndex: index) }
            return
        }
        guard index < musicdata.count else { return }

        songNameLabel.text = musicdata[index].title
        albumNameLabel.text = musicdata[index].artist
        MusicPlayerV3.songContentID = musicdata[index].contentID ?? ""
        songsIndex = index
        getCommentOrLyrics()

        // ✅ Reset gradient immediately so old playlist colors don't persist
        gradientLayer.colors = [
            UIColor.gray.cgColor,
            UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.00).cgColor
        ]

        let popupImgView = UIImageView(frame: .init(origin: .zero, size: .init(width: 50, height: 50)))
        popupImgView.kf.setImage(
            with: URL(string: musicdata[index].image?.replacingOccurrences(of: "<$size$>", with: "300").safeUrl() ?? ""),
            placeholder: UIImage(named: "default_song", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
        ) { result in
            switch result {
            case .success(let res):
                // ✅ Ensure UI updates on main thread
                DispatchQueue.main.async {
                    self.shadowImageView.image = res.image
                    self.backgroundImageView.image = res.image

                    if let popbar = self.popupContainerViewController?.popupBar {
                        popbar.image = res.image
                    }

                    // ✅ getColors callback is NOT guaranteed to be on main thread
                    res.image.getColors(quality: .lowest) { colors in
                        guard let colors = colors else { return }
                        DispatchQueue.main.async {
                            self.gradientLayer.colors = [
                                colors.background.cgColor,
                                UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.00).cgColor
                            ]
                            self.titleLabel.textColor = colors.primary
                            self.closePopupButton.tintColor = colors.primary
                        }
                    }
                }

            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }

        shadowImageView.image = popupImgView.image

        if let popbar = self.popupContainerViewController?.popupBar {
            popbar.title = musicdata[index].title ?? ""
            popbar.subtitle = musicdata[index].artist ?? ""
            popbar.image = popupImgView.image
            popbar.rightBarButtonItems = [playPauseBarBtn]
            popbar.titleLabel.font = self.songNameLabel.font
            popbar.subtitleLabel.font = self.albumNameLabel.font
            popbar.titleLabel.textColor = self.songNameLabel.textColor
            popbar.subtitleLabel.textColor = self.albumNameLabel.textColor
        }

        // ... rest of your existing code unchanged
    }
    private func userHistoryTracking(newIndex: Int?) {
        
        if let contentID = history_data?.contentID,
           let type = history_data?.contentType,
           let start_time = history_start_time,
           history_data?.trackType?.uppercased() != "LM"
        {
            let playCount = history_total_duration > 1 ? "1" : "0"
            
            //            Analytics.logEvent("sm_content_played",
            //                               parameters: [
            //                                "content_type"  : type.lowercased() as NSObject,
            //                                "content_id"    : contentID as NSObject,
            //                                "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
            //                                "content_name"  : history_data?.title?.lowercased() ?? "" as NSObject,
            //                                "duration_sec"  : history_total_duration as NSObject,
            //                                "platform"      : "ios" as NSObject
            //                               ])
            
            ShadhinCore.instance.api.trackUserHistory(
                contentID: contentID,
                type: type,
                playCount: playCount,
                totalPlayInSeconds: history_total_duration,
                playInDate: start_time,
                playOutDate: getCurrentDateAndTime(),
                playlistId: playlistId) { (success) in
                    //print("streamed successfully")
                }
            ShadhinCore.instance.api.trackUserHistoryV6(
                contentID: contentID,
                type: type,
                playCount: playCount,
                totalPlayInSeconds: history_total_duration,
                playInDate: start_time,
                playOutDate: getCurrentDateAndTime(),
                playlistId: playlistId) { (success) in
                    //print("streamed successfully")
                }
        }
        history_total_duration = 0
        guard let index = newIndex,
              index < musicdata.count else{
            history_data = nil
            history_start_time = nil
            return
        }
        history_data = musicdata[index]
        history_start_time = getCurrentDateAndTime()
        
    }
    
    private func subscribeToLive(_ pdSuffix: String){
        liveHolder.isHidden = false
        SignalR.podcastCode = pdSuffix
        SignalR.instance.delegate = { (amount) in
            guard let int : Int = Int(amount) else{
                return
            }
            self.liveLabel.text = String(int)
        }
    }
    
    private func unsubscribeFromLive(){
        liveHolder.isHidden = true
        SignalR.instance.delegate = nil
        self.liveLabel.text = "Loading..."
    }
    
    private func getCommentOrLyrics(){
        if musicdata[songsIndex].contentType?.prefix(2).uppercased() == "PD"{
            getComments()
        }else{
            getLyrics()
        }
    }
    
    
    private func getLyrics(){
        guard let contentId = musicdata[songsIndex].contentID else{
            return
        }
        lyricsRequest = ShadhinCore.instance.api.getLyricsBy(contentId) { (lyrics) in
            if lyrics == nil{
                self.setupLyricsCard("", contentId)
                return
            }
            guard let lyrics = lyrics, let str = lyrics.data.lyrics else {
                guard let _contentId = self.musicdata[self.songsIndex].contentID, contentId == _contentId else{return}
                self.removeCard()
                return
            }
            self.setupLyricsCard(str, contentId)
        }
    }
    func removeCard(){
        view.layer.removeAllAnimations()
        lyricsRequest?.cancel()
        cardVisible = false
        self.bottomOptionHeight.constant = 20
        if cardLyricsVC != nil{
            cardLyricsVC.willMove(toParent: nil)
            cardLyricsVC.view.removeFromSuperview()
            cardLyricsVC.removeFromParent()
            cardLyricsVC = nil
        }
        if cardCommentsVC != nil{
            cardCommentsVC.willMove(toParent: nil)
            cardCommentsVC.view.removeFromSuperview()
            cardCommentsVC.removeFromParent()
            cardCommentsVC = nil
        }
        if self.bottomOptionHeight.constant != 20{
            self.bottomOptionHeight.constant = 20
            UIView.animate(withDuration: 0.9, animations: {
                self.view.layoutIfNeeded()
            })
        }
        if visualEffectView != nil{
            visualEffectView.removeFromSuperview()
            visualEffectView = nil
        }
        
    }
    
    func gradientSetup() {
        // ✅ Remove existing gradient layer if already present
        gradientLayer?.removeFromSuperlayer()

        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.gray.cgColor,
            UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.00).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.25)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.78)
        self.effectView.contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
//MARK: Audio player setup
extension MusicPlayerV3{
    private func songsChangeWithIndex(index: Int) {
        //MusicPlayerV3.isAudioPlaying = false
        DispatchQueue.main.async {
            self.updateUI(withIndex: index)
        }
        // checkSongsIsDownloading(index: index)
    }

    private func addAudioItems(urlArray: [CommonContentProtocol]){
        urlArray.forEach { (data) in
            if let item = AudioItem(track: data){
                viewModel.audioItems.append(item)
            }else{
                Log.error("Couldn't create AudioItem for ContentDataProtocol -> \(data)")
            }
        }
    }
    
    private func audioPlay(index: Int) {
        MusicPlayerV3.audioPlayer.play(items: viewModel.audioItems, startAtIndex: index)
        //self.songsChangeWithIndex(index: index)
        playPauseBtn.isSelected = false
        playPauseBarBtn.image = UIImage(named: "ic_pause",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        //MusicPlayerV3.isAudioPlaying = true
    }
    
    private func audioResume() {
        // guard !isChorkiAdIsPlaying else {return}
        MusicPlayerV3.audioPlayer.resume()
        playPauseBarBtn.image = UIImage(named: "ic_pause",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        //MusicPlayerV3.isAudioPlaying = true
    }
    
    func audioPause() {
        playPauseBarBtn.image = UIImage(named: "normal play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        MusicPlayerV3.audioPlayer.pause()
        //MusicPlayerV3.isAudioPlaying = false
    }
}

//MARK: Song Download

extension MusicPlayerV3{
    private func startDownload(dataValue: CommonContentProtocol, playUrl: String){
        //let destinationUrl = SDFileUtils.checkFileExistsOrNot(urlName: dataValue.playUrl ?? "")
        // if destinationUrl.isExists {
        let isPdocast = dataValue.contentType?.prefix(2).uppercased() == "PD" ? true : false
        if let contentID = dataValue.contentID, isPdocast ? DatabaseContext.shared.isPodcastExist(where: contentID) : DatabaseContext.shared.isSongExist(contentId: contentID){
            view.makeToast("The file already exists at path")
        }else {
            downloadProgressView.isHidden = false
            downloadBtn.isHidden = true
            
            //send data to firebase analytics
            AnalyticsEvents.downloadEvent(with: dataValue.contentType, contentID: dataValue.contentID, contentTitle: dataValue.title)
            
            let request = URLRequest(url: URL(string: playUrl)!)
            _ = self.downloadManager.downloadFile(withRequest: request, onProgress: {(progress) in
                _ = String(format: "%.1f %", (progress * 100))
                self.downloadProgressView.setProgress(progress: progress, animated: true)
            }) { [weak self] (error, url) in
                if let error = error {
                    Log.error(error.localizedDescription)
                } else {
                    self?.updateUIAfterDownload(dataToSaveDB: dataValue)
                }
            }
        }
    }
    
    func updateUIAfterDownload(dataToSaveDB: CommonContentProtocol, isSingle : Bool = true) {
        if musicdata[self.iCarouselView.currentItemIndex].contentID == dataToSaveDB.contentID {
            self.downloadProgressView.isHidden = true
            self.downloadBtn.isHidden = false
            self.downloadBtn.setImage(UIImage(named: "downloadCompleteV3",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        }
        self.view.makeToast("File successfully downloaded.")
        let isPdocast = dataToSaveDB.contentType?.prefix(2).uppercased() == "PD" ? true : false
        if isPdocast{
            DatabaseContext.shared.addPodcast(content: dataToSaveDB)
        }else{
            DatabaseContext.shared.addSong(content: dataToSaveDB,isSingleDownload: isSingle)
        }
        //SongsDownloadDatabase.instance.saveDataToDatabase(musicData: dataToSaveDB)
    }
    
    func checkSongsIsDownloading(index: Int) {
        let dataValue = self.musicdata[index]
        let isDownloading = self.downloadManager.isDownloadInProgress(forKey: dataValue.playUrl)
        self.downloadBtn.isHidden = isDownloading
        self.downloadProgressView.isHidden = !isDownloading
        
        if isDownloading {
            guard let obj = SDDownloadManager.shared.currentDownload(forKey: dataValue.playUrl) else {
                return
            }
            //work it when download all song
            obj.progressBlock = { progress in
                self.downloadProgressView.setProgress(progress: progress, animated: true)
                if progress == 1.0 {
                    self.updateUIAfterDownload(dataToSaveDB: dataValue, isSingle: obj.isSingle ?? true)
                    self.downloadProgressView.setProgress(progress: 0)
                }
            }
        }else{
            checkSongDownloadedOrNot()
        }
    }
    
    private func checkSongDownloadedOrNot() {
        let content = musicdata[iCarouselView.currentItemIndex]
        let isPdocast = content.contentType?.prefix(2).uppercased() == "PD" ? true : false
        
        if isPdocast ? DatabaseContext.shared.isPodcastExist(where: content.contentID ?? "") : DatabaseContext.shared.isSongExist(contentId: content.contentID ?? ""){
            self.downloadBtn.setImage(UIImage(named: "downloadCompleteV3",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        }else  {
            self.downloadBtn.setImage(UIImage(named: "ic_downloadv3",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        }
    }
    
    @objc func checkFav(){
        guard var contentType = musicdata[self.iCarouselView.currentItemIndex].contentType else {return}
        if contentType.prefix(2).uppercased() == "PD"{
            contentType = "PD"
        }
        ShadhinCore.instance.api.getAllFavoriteByType(
            type: SMContentType.init(rawValue: contentType)) { (favs, error) in
                Log.error(error?.localizedDescription ?? "")
                guard let favt = favs else {return}
                if favt.contains(where: {$0.contentID == self.musicdata[self.iCarouselView.currentItemIndex].contentID}) {
                    self.favBtn.setImage(UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    self.isFav = true
                }else {
                    self.favBtn.setImage(UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                    self.isFav = false
                }
            }
    }
}

//MARK:  - iCarouse
extension MusicPlayerV3: iCarouselDelegate, iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return musicdata.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        var imageView: UIImageView!
        if UIScreen.main.bounds.height > 667 {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 310, height: 310))
        }else if UIScreen.main.bounds.height > 568 {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        }else {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 220, height: 220))
        }
        
        
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        
        
        imageView.kf.setImage(with: URL(string: musicdata[index].image?.replacingOccurrences(of: "<$size$>", with: "300").safeUrl() ?? ""), placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        
        return imageView
    }
    
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .spacing {
            return 1.12
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        // self.iCarouselView.reloadData()
        
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        //print(MusicPlayerVC.songContentID)
    }
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let offsetFactor = self.carousel(carousel, valueFor: .spacing, withDefault: 1) * carousel.itemWidth
        
        let zFactor: CGFloat = 150
        let normalFactor: CGFloat = 0
        let shrinkFactor: CGFloat = 10
        let f = sqrt(offset * offset + 1 ) - 1
        
        var transform = CATransform3DTranslate(transform, offset * offsetFactor, f * normalFactor, f * (-zFactor))
        transform = CATransform3DScale(transform, 1 / (f / shrinkFactor + 1), 1 / (f / shrinkFactor + 1), 1)
        return transform
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        guard self.musicdata.count > self.iCarouselView.currentItemIndex else {return}
        if !(self.musicdata[self.iCarouselView.currentItemIndex].contentID == MusicPlayerV3.songContentID) {
            //self.userHistoryTracking()
            
            MusicPlayerV3.audioPlayer.play(items: viewModel.audioItems, startAtIndex: self.iCarouselView.currentItemIndex)
            self.songsChangeWithIndex(index: carousel.currentItemIndex)
            //self.playStartTime = getCurrentDateAndTime()
        }else {
            //print("same contentid")
        }
        
    }
    
}

//MARK: - Audio player
extension MusicPlayerV3: AudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        //print("Look from - \(from) to - \(state)")
        self.history_timer.invalidate()
        MusicPlayerV3.isAudioPlaying = false
        let playPauseBtnMini = (MainTabBar.shared?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini)?.playPauseBtn
        
        if state == .stopped {
            playPauseBtn.isSelected = true
            playPauseBarBtn.image = UIImage(named: "normal play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            playerSlider.value = 0
            playDurationLbl.text = "00:00"
            playPauseBtnMini?.hideLoading()
            playPauseBtnMini?.setPlaying(false)
            if let popupbar = self.popupContainerViewController.popupBar{
                popupbar.progress = 0
            }
            NotificationCenter.default.post(name: .MUSIC_PAUSE, object: nil)
        }else if state == .buffering {
            //print("buffering")
            shouldRetryOnBuffering()
            loader.startAnimating()
            playPauseBtn.isHidden = true
            playPauseBtnMini?.showLoading()
        }else if state == .waitingForConnection {
            //print("waiting for connection")
            shouldRetryPlaying()
            loader.startAnimating()
            playPauseBtn.isHidden = true
            playPauseBtnMini?.showLoading()
        }else if state == .playing {
            self.history_timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                self.history_total_duration += 1
                self.checkIfFileExpired()
            })
            //getCommentOrLyrics()
            MusicPlayerV3.isAudioPlaying = true
            loader.stopAnimating()
            playPauseBtn.isHidden = false
            playPauseBtn.isSelected = true
            playPauseBarBtn.image = UIImage(named: "ic_pause",in:Bundle.ShadhinMusicSdk,compatibleWith: nil)
            
            playPauseBtnMini?.hideLoading()
            playPauseBtnMini?.setPlaying(true)
            NotificationCenter.default.post(name: .MUSIC_PLAY, object: nil)
            self.history_timer.invalidate()
        }else if state == .paused {
            
            loader.stopAnimating()
            playPauseBtn.isHidden = false
            playPauseBtn.isSelected = false
            playPauseBarBtn.image = UIImage(named: "normal play",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            
            playPauseBtnMini?.hideLoading()
            playPauseBtnMini?.setPlaying(false)
            
            ShadhinCore.instance.api.releaseServerLock()
            NotificationCenter.default.post(name: .MUSIC_PAUSE, object: nil)
        }else if case .failed(let error) = state{
            //print("Look from -> Failed \(error)  \(error._code)")
            Log.error("Failed \(error) \(error._code)")
            loader.stopAnimating()
            playPauseBtn.isHidden = false
            playPauseBtnMini?.hideLoading()
            playPauseBtnMini?.setPlaying(false)
            
            shouldRetryPlaying()
            if case .foundationError(let err) = error, err._code == -1002, musicdata[songsIndex].trackType?.uppercased() != "LM"{
                //print("A normal \(err._code)")
                MusicPlayerV3.audioPlayer.retryContentPlay()
            }
        }
    }
    
    func checkIfFileExpired(){
        guard
            let _currentTime = MusicPlayerV3.audioPlayer.player?.currentItem?.currentTime(),
            songsIndex < musicdata.count,
            musicdata[songsIndex].trackType?.uppercased() != "LM" else {return}
        
        if currentTime != _currentTime{
            currentTime = _currentTime
            waitedForFileToPlayTick = 0
            return
        }
        waitedForFileToPlayTick += 1
        guard waitedForFileToPlayTick > 6 else {return}
        waitedForFileToPlayTick = 0
        MusicPlayerV3.audioPlayer.retryContentPlay()
    }
    
    func shouldRetryPlaying(){
        if isOnPlayingRetry || musicdata[songsIndex].trackType?.uppercased() != "LM"{
            return
        }
        isOnPlayingRetry = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            [weak self] in
            self?.isOnPlayingRetry = false
            guard let strongSelf = self,
                  strongSelf.musicdata[strongSelf.songsIndex].trackType?.uppercased() == "LM" else {return}
            var isWaiting = false
            var isFailed = false
            if MusicPlayerV3.audioPlayer.state == .waitingForConnection{
                isWaiting = true
            }
            if case .failed(_) = MusicPlayerV3.audioPlayer.state{
                isFailed = true
            }
            guard (isWaiting || isFailed) else {return}
            AudioPlayer.shared.stop()
            strongSelf.audioPlay(index: strongSelf.songsIndex)
        }
    }
    
    func shouldRetryOnBuffering(){
        if isOnPlayingRetry || musicdata[songsIndex].trackType?.uppercased() != "LM"{
            return
        }
        isOnPlayingRetry = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            [weak self] in
            self?.isOnPlayingRetry = false
            guard let strongSelf = self,
                  strongSelf.musicdata[strongSelf.songsIndex].trackType?.uppercased() == "LM",
                  MusicPlayerV3.audioPlayer.state == .buffering else {return}
            AudioPlayer.shared.stop()
            strongSelf.audioPlay(index: strongSelf.songsIndex)
        }
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didFindDuration duration: TimeInterval, for item: AudioItem) {
        self.trackDuration.text = formatSecondsToString(duration)
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float){
        //        if let popupbar = self.popupContainerViewController.popupBar{
        //            popupbar.progress = percentageRead / 100
        //        }
        if let popupbar = MainTabBar.shared?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini{
            popupbar.circularView.setProgress(progress: CGFloat(percentageRead) / 100)
            if popupbar.artistTitle.text == "Loading...",
               let content = audioPlayer.currentItem?.contentData,
               percentageRead > 0{
                updateMiniPlayerInfo(content: content, tabBar: self.tabBarController)
            }
            if let playPauseBtnMini = (MainTabBar.shared?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini)?.playPauseBtn,
               !playPauseBtnMini.isEnabled,
               percentageRead > 0{
                self.audioPlayer(audioPlayer, didChangeStateFrom: .buffering, to: audioPlayer.state)
            }
        }
        playerSlider.value = percentageRead / 100
        playDurationLbl.text = formatSecondsToString(time)
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem) {
        
        guard let index = viewModel.audioItems.firstIndex(where: { song in
            song.contentId == item.contentId
        }) else {return}
        
        GPAudioViewModel.shared.selectedIndexInCarousel = index

        if iCarouselView.currentItemIndex >= 0 {
            iCarouselView.currentItemIndex = index
            Log.info("RC - \(index) \(item)")
            guard self.musicdata.count > self.iCarouselView.currentItemIndex else {return}
            self.songsChangeWithIndex(index: iCarouselView.currentItemIndex)
            self.playStartTime = getCurrentDateAndTime()
            self.userHistoryTracking(newIndex: index)
        }
        guard let content =  item.contentData else {return}
        updateMiniPlayerInfo(content: content, tabBar: self.tabBarController)
        
        NotificationCenter.default.post(
            name: .gpMusicItemChanged,
            object: nil,
            userInfo: ["index": index]
        )
    }
    
}

extension MusicPlayerV3 : PBPopupControllerDelegate,PBPopupBarDataSource{
    
    func popupController(_ popupController: PBPopupController, didOpen popupContentViewController: UIViewController) {
        UIView.animate(withDuration: 0.3) {
            self.iCarouselView.isHidden = false
            self.imageModule.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    func popupController(_ popupController: PBPopupController, willClose popupContentViewController: UIViewController) {
        UIView.animate(withDuration: 0.3) {
            self.iCarouselView.isHidden = true
            self.imageModule.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    func popupControllerPanGestureShouldBegin(_ popupController: PBPopupController, state: PBPopupPresentationState) -> Bool {
        if cardVisible{
            return false
        }
        return true
    }
}

extension MusicPlayerV3{
    func updateMiniPlayerInfo(content: CommonContentProtocol, tabBar: UITabBarController?){
        guard let popupbar = MainTabBar.shared?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini else {return}
        // MusicPlayerV3.shared.tabBar?.tabBar.isHidden = true
        popupbar.updateContent(content: content)
        
        if GPAudioViewModel.shared.goContentPlayingState == .pause {
            popupbar.playPauseBtn?.hideLoading()
            if let seekTo = GPAudioViewModel.shared.seekTo {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    AudioPlayer.shared.seek(to: seekTo)
                    GPAudioViewModel.shared.seekTo = nil
                })
            }
        }
        
    }
    
    func updateMiniFavorite(){
        guard let popupbar = MainTabBar.shared?.popupBar.customPopupBarViewController as? MusicPlayerV4Mini else {return}
        popupbar.checkFav()
    }
    
}

extension MusicPlayerV3 : MoreMenuDelegate{
    func openQueue() {
        let vc = MusicPlayerQueue.instantiateNib()
        //let vc = UserContentPlaylistAndQueueListVC()
        vc.viewTitle = "Queue"
        vc.userContentPlaylists = musicdata
        vc.currentPlayingIndex = songsIndex
        let navVC = UINavigationController(rootViewController: vc)
        
        present(navVC, animated: true, completion: nil)
        
        vc.didQueueListClicked { (destinationIndex,index,type) in
            if type == "move" {
                let movedObject = self.musicdata[index!]
                self.musicdata.remove(at: index!)
                self.musicdata.insert(movedObject, at: destinationIndex!)
                
                if self.iCarouselView.currentItemIndex == index! {
                    //MusicPlayerVC.audioPlayer.currentItem = self.audioItems[destinationIndex!]
                    
                    self.iCarouselView.scrollToItem(at: destinationIndex!, animated: true)
                    self.iCarouselView.currentItemIndex = destinationIndex!
                }else {
                    if let getIndex = self.musicdata.firstIndex(where: {$0.contentID == MusicPlayerV3.songContentID}) {
                        //MusicPlayerVC.audioPlayer.currentItem = self.audioItems[getIndex]
                        self.iCarouselView.scrollToItem(at: getIndex, animated: true)
                        self.iCarouselView.currentItemIndex = getIndex
                    }
                }
            }else if type == "delete"{
                
                //MusicPlayerVC.audioPlayer.removeItem(at: index!)
                self.musicdata.remove(at: index!)
                
                if self.iCarouselView.currentItemIndex == index! {
                    self.updateUI(withIndex: self.iCarouselView.currentItemIndex)
                    self.audioPlay(index: self.iCarouselView.currentItemIndex)
                }else if self.iCarouselView.currentItemIndex > index!{
                    
                    self.iCarouselView.scrollToItem(at: self.iCarouselView.currentItemIndex - 1, animated: true)
                }else {
                    //self.iCarouselView.scrollToItem(at: self.iCarouselView.currentItemIndex, animated: true)
                }
            }else {
                MusicPlayerV3.audioPlayer.play(items: self.viewModel.audioItems, startAtIndex: index!)
                self.iCarouselView.currentItemIndex = index!
                //self.iCarouselView.currentItemIndex = MusicPlayerV3.audioPlayer.currentItemIndexInQueue ?? 1
            }
        }
    }
    
    
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}
        
        guard checkProUser() else{
            return
        }
        var dataValue = musicdata[iCarouselView.currentItemIndex]
        if let playUrl =  dataValue.playUrl, playUrl.contains("http"){
            self.startDownload(dataValue: dataValue, playUrl: playUrl)
            return
        }
        ShadhinCore.instance.api.getDownloadUrl(dataValue) {
            url, error in
            guard let url = url else {return}
            dataValue.playUrl = url
            self.startDownload(dataValue: dataValue, playUrl: url)
        }
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        DatabaseContext.shared.deleteSong(where: content.contentID ?? "")
        if let playUrl = content.playUrl{
            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            self.view.makeToast("File Removed from Download")
        }
        downloadProgressView.isHidden = true
        downloadBtn.isHidden = false
        downloadBtn.setImage(UIImage(named: "ic_downloadv3",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
    }
    
    func onRemoveFromHistory(content: CommonContentProtocol) {
        
    }
    func addToFavourite() {
        self.favBtn.setImage(UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        self.isFav = true
    }
    func removeFromFavourite() {
        self.favBtn.setImage(UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        self.isFav = false
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        self.popupContainerViewController?.closePopup(animated: true)
        let vc = goArtistVC(content: content)
        if let nav = MainTabBar.shared?.selectedViewController as? UINavigationController{
            nav.pushViewController(vc, animated: true)
        }
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        self.popupContainerViewController?.closePopup(animated: true)
        let vc = goAlbumVC(isFromThreeDotMenu: true, content: content)
        if let nav = MainTabBar.shared?.selectedViewController as? UINavigationController{
            nav.pushViewController(vc, animated: true)
        }
    }
    
    func addToPlaylist(content: CommonContentProtocol) {
        //self.presentingViewController?.closePopup(animated: true)
        goAddPlaylistVC(content: content)
    }
    
    
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func onAirplay() {
        routePickerView.present()
    }
    
    func openSleepTimer() {
        SleepTimerVC.show()
    }
}

extension MusicPlayerV3 : AVRoutePickerViewDelegate{
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        
    }
    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        
    }
}
fileprivate extension AVRoutePickerView {
    func present() {
        let routePickerButton = subviews.first(where: { $0 is UIButton }) as? UIButton
        routePickerButton?.sendActions(for: .touchUpInside)
    }
}

extension Notification.Name {
    static let shouldMuteTeaser = Notification.Name("ShouldMuteTeaser")
}

extension Notification.Name {
    static let gpMusicItemChanged = Notification.Name("GPMusicItemChanged")
}
