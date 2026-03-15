//
//  PodcastYoutubeVC.swift
//  Shadhin
//
//  Created by Rezwan on 8/16/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit
import AVFoundation

class PodcastYoutubeVC: UIViewController {
    
    
    static func openLivePodcast(_ vc : UIViewController?, _ track : CommonContentProtocol){
        let storyBoard = UIStoryboard(name: "PodCast", bundle:Bundle.ShadhinMusicSdk)
        let podcastYoutube = storyBoard.instantiateViewController(withIdentifier: "PodcastYoutubeVC") as! PodcastYoutubeVC
        podcastYoutube.track = track
        podcastYoutube.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        podcastYoutube.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        vc?.navigationController?.present(podcastYoutube, animated: true)
    }
    
    @IBOutlet weak var noInternetView: NoInternetView!
    @IBOutlet weak var playerHolder: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var videoEndedImg: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var likeHolder: UIStackView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var commentRefreshBtn: UIButton!
    @IBOutlet weak var addCommentHolder: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var liveIcon: UIImageView!
    
    var track : CommonContentProtocol!{
        didSet{
            if track != nil, let playUrl = track.playUrl?.decryptUrl(){
                track.playUrl = playUrl
            }
        }
    }
    var observer: Any?
    var playedSec = 0
    var playIn: String = ""
    var player : AVPlayer?{
        didSet{
            observer = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
                guard let self = self else { return }
                if self.player?.currentItem?.status == .readyToPlay {
                    let currentTime = CMTimeGetSeconds(self.player!.currentTime())
                    self.playedSec = Int(currentTime)
                    self.durationLabel.text = NSString(format: "%d:%02d", self.playedSec/60, self.playedSec%60) as String
                }
            })
        }
    }
    var likeCount: PodcastAPI.PodcastLike?{
        didSet{
            if likeCount != nil && oldValue == nil{
                likeHolder.setClickListener { [weak self] in
                    self?.updateLikeServer()
                }
            }
            updateLike()
        }
    }
    
    
    var pendingRequestWorkItem0: DispatchWorkItem?
    var pendingRequestWorkItem1: DispatchWorkItem?
    var pendingRequestWorkItem2: DispatchWorkItem?
    
    var currentCommentPage = 0
    var userComments : CommentsObj? = nil
    var loadMoreComments : LoadMoreActivityIndicator?
    
    var cellHeightsDictionary: [IndexPath: CGFloat] = [:]
    
    var playerLayer : AVPlayerLayer?
    var isFullScreen = false
    let ratioNormal : CGFloat = 16/9
    var rationFull : CGFloat!
    @IBOutlet weak var playerRatio: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 32))
        tableView.tableFooterView  = view
        tableView.register(CommentCell.nib, forCellReuseIdentifier: CommentCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        AudioPlayer.shared.stop()
        //AppDelegate.shared?.mainHome?.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        MusicPlayerV3.shared.dismissPopup()
        playIn = getCurrentDateAndTime()
        likeImg.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16);
        
        noInternetView.isHidden = true
        noInternetView.tag = 101
        
        noInternetView.retry = {[weak self] in
            guard let self = self else {return}
            if ConnectionManager.shared.isNetworkAvailable{
                loadAll()
            }
        }
        noInternetView.gotoDownloadButton.isHidden = true
        noInternetView.gotoDownload = {[weak self] in
            guard let self = self else {return}
            if checkUser(){
                let vc = DownloadVC.instantiateNib()
                vc.selectedDownloadSeg = .init(title: ^String.Downloads.songs, type: .None)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ConnectionManager.shared.isNetworkAvailable{
            loadAll()
        }else{
            noInternetView.isHidden = false
            self.view.subviews.forEach { vv in
                if  vv.tag == 102, let btn = vv as? UIButton{
                    btn.tintColor =  .black
                }
                if vv.tag != 101 && vv.tag != 102{
                    vv.isHidden = true
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func loadAll(){
        self.noInternetView.isHidden = false
        self.view.subviews.forEach { vv in
            if  vv.tag == 102, let btn = vv as? UIButton{
                btn.tintColor =  .white
            }
            if vv.tag != 101 && vv.tag != 102{
                vv.isHidden = false
            }
        }
        LoadingIndicator.initLoadingIndicator(view: tableView)
        rationFull = UIScreen.main.bounds.height/UIScreen.main.bounds.width
        if player != nil{
            return
        }
        
        videoTitle.text = track.title
        commentRefreshBtn.addTarget(self, action: #selector(reloadComments), for: .touchUpInside)
        addCommentHolder.setClickListener {
            self.addComment()
        }
        
        getPlayUrl()
        getLikeCount()
    }
    
    func getPlayUrl(){
        ShadhinCore.instance.api.getPlayUrl(track) { [weak self] playUrl, error in
            guard let self = self, let playUrl = playUrl else {
                return
            }
            self.track.playUrl = playUrl
            self.tryToPlay()
        }
    }
    
    func tryToPlay(){
        if let type = track.contentType?.prefix(2).uppercased(),
           type == "VD",
           let urlStr = track.playUrl,
           let url = URL(string: urlStr),
           (track.trackType?.uppercased() != "LM" || track.playUrl?.starts(with: "http") ?? false)
        {
            LoadingIndicator.startAnimation()
            self.player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: self.player)
            playerLayer?.frame = self.playerHolder.bounds
            self.playerHolder.layer.addSublayer(playerLayer!)
            self.player?.play()
            self.liveIcon.isHidden = true
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
            
            self.playPauseBtn.setImage(UIImage(named:"ic_pause_1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            self.getComments()
            if track.trackType?.uppercased() != "LM"{
                self.addToRecent()
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlay), name: UIApplication.didEnterBackgroundNotification, object: nil)
            
        }else{
//            LoadingIndicator.startAnimation()
//            DispatchQueue.main.async {
//                let client = XCDYouTubeClient(languageIdentifier: "en")
//                client.getVideoWithIdentifier(self.track.playUrl) { (video, error) in
//                    guard let video = video,
//                          let streamURL = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else { return }
//                    self.openViaYoutube(streamURL: streamURL)
//                }
//            }
            
        }
    }
    
    func logFbEvent(){
        //let name = "myEvent"
        let parameters: [String: Any] = [
            "myParameter": "myParameterValue"
        ]
        
//        let event = AppEvents.Name.init(rawValue: "test")
        //AppEvents.logEvent(event, valueToSum: 1, parameters: parameters)
    }
    
    func openViaYoutube(streamURL: URL){
        self.player = AVPlayer(url: streamURL)
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer?.frame = self.playerHolder.bounds
        self.playerHolder.layer.addSublayer(self.playerLayer!)
        self.player?.play()
        self.liveIcon.isHidden = false
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        self.playPauseBtn.setImage(#imageLiteral(resourceName: "ic_pause_1"), for: .normal)
        self.getComments()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlay), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        if let observer = observer {
            player?.removeTimeObserver(observer)
        }
        player?.pause()
        player = nil
        NotificationCenter.default.removeObserver(self)
    }
    
//    func remoteControlReceivedWithEvent(event: UIEvent?) {
//        let rc = event!.subtype
//        print("does this work? \(rc.rawValue)")
//    }
    
    
    func updateLike(){
        guard let item = likeCount else {return}
        var color = UIColor.init(rgb: 0x3c3c43, a: 0.6)
        if #available(iOS 13.0, *) {
            color = UIColor.secondaryLabel
        }
        if item.data{
            color = UIColor.init(rgb: 0x00B0FF, a: 0.7)
        }
        likeImg.tintColor = color
        likeLabel.textColor = color
        likeLabel.text = "\(item.total)"
    }
    
    
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.playPauseBtn.setImage(#imageLiteral(resourceName: "ic_play_1"), for: .normal)
        self.player?.seek(to: .zero)
    }
    
    
    
    @IBAction func backBtnTapped(_ sender: Any) {
        if isFullScreen{
            fullscreenToggle(sender)
            return
        }
        addUserTracking()
        self.dismiss(animated: true)
        self.player?.pause()
        if observer != nil{
            player?.removeTimeObserver(observer!)
        }
        self.player = nil
        
    }
    
    @objc func updatePlay(){
        self.playPauseBtn.setImage(#imageLiteral(resourceName: "ic_play_1"), for: .normal)
    }
    
    
    @IBAction func playPauseBtn(_ sender: Any) {
        guard let player = player else {
            return
        }
        
        if player.rate == 1.0 {
            player.pause()
            self.playPauseBtn.setImage(UIImage(named:"ic_play_1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        } else {
            player.play()
            self.playPauseBtn.setImage(#imageLiteral(resourceName: "ic_pause_1"), for: .normal)
        }
    }
    
    func viewReply(_ comment : CommentsObj.Comment, _ index : IndexPath){
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.comment = comment
        vc.indexOfComment = index
        vc.podcastLive = self
        vc.podcastShowCode = String(track.contentType?.suffix(track.contentType!.count - 2) ?? "").uppercased()
        vc.podcastType = String(track.contentType?.prefix(2) ?? "").uppercased()
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    func addComment(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        //vc.contentId = Int(track.episodeID) ?? 0
        vc.contentId = Int(track.albumId ?? "0")!
        vc.podcastLive = self
        vc.podcastShowCode = String(track.contentType?.suffix(track.contentType!.count - 2) ?? "").uppercased()
        vc.podcastType = String(track.contentType?.prefix(2) ?? "").uppercased()
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func fullscreenToggle(_ sender: Any) {
        if isFullScreen{
            isFullScreen = false
           // DeviceOrinention.lockOrientation(.portrait, andRotateTo: .portrait)
            let newConstraint = playerRatio.constraintWithMultiplier(ratioNormal)
            view.removeConstraint(playerRatio)
            view.addConstraint(newConstraint)
            playerRatio = newConstraint
            self.playerLayer?.videoGravity = .resizeAspect
        }else{
            isFullScreen = true
         //   DeviceOrinention.lockOrientation(.landscape, andRotateTo: .landscapeRight)
            let newConstraint = playerRatio.constraintWithMultiplier(rationFull)
            view.removeConstraint(playerRatio)
            view.addConstraint(newConstraint)
            playerRatio = newConstraint
            self.playerLayer?.videoGravity = .resizeAspectFill
        }
        self.view.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playerLayer?.frame = self.playerHolder.bounds
        }
    }   
}

extension PodcastYoutubeVC : UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (userComments != nil ? (1 + userComments!.data.count) : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            //            let cell = tableView.dequeueReusableCell(withIdentifier: CommentHeaderCell.identifier, for: indexPath) as! CommentHeaderCell
            //            cell.totalCommentsLabel.text = "\(userComments?.totalData ?? 0)"
            //            cell.commentRefreshBtn.addTarget(self, action: #selector(reloadComments), for: .touchUpInside)
            //            cell.addCommentView.setClickListener {
            //                self.addComment()
            //            }
            commentCount.text = "Comments • \(userComments?.totalData ?? 0)"
            return UITableViewCell()
        default:
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
            if let comment = userComments?.data[indexPath.row - 1]{
                cell.userImg.kf.indicatorType = .activity
                cell.userImg.kf.setImage(with: URL(string: comment.userPic.safeUrl()),placeholder: UIImage(named: "ic_user_1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
                cell.userName.text = comment.userName
                cell.comment.text = comment.message
                cell.favCount.text = "\(comment.totalCommentFavorite)"
                if comment.totalReply > 0{
                    cell.replyCountBtn.isHidden = false
                    cell.replyCountBtn.setTitle("\(comment.totalReply) replies", for: .normal)
                    cell.replyCountBtn.setClickListener {
                        self.viewReply(comment, indexPath)
                    }
                }else{
                    cell.replyCountBtn.isHidden = true
                }
                cell.replyBtn.setClickListener {
                    self.viewReply(comment, indexPath)
                }
                if comment.commentFavorite{
                    cell.favImg.image = UIImage(named: "ic_mymusic_favorite",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                }else{
                    cell.favImg.image = UIImage(named: "ic_favorite_border",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
                }
                if comment.commentLike{
                    cell.likeBtn.setTitle("You liked", for: .normal)
                    cell.likeBtn.setTitleColor(UIColor.red.withAlphaComponent(0.7), for: .normal)
                }else{
                    cell.likeBtn.setTitle("Like", for: .normal)
                    if #available(iOS 13.0, *) {
                        cell.likeBtn.setTitleColor(.secondaryLabel, for: .normal)
                    } else {
                        cell.likeBtn.setTitleColor(.gray, for: .normal)
                    }
                }
                
                let dateFormatter = DateFormatter()
                //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                if let date =  dateFormatter.date(from: comment.createDate){
                    cell.timeAgo.text = timeAgoSince(date)
                }else{
                    cell.timeAgo.text = " "
                }
                
                cell.podcastLive = self
                cell.commentIndex = indexPath
                cell.initComment()
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0 :
            return .zero
            //return CommentHeaderCell.height
        default :
            return CommentCell.height
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadMoreComments?.start {
            self.getComments({self.loadMoreComments?.stop()})
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // print("Cell height: \(cell.frame.size.height)")
        self.cellHeightsDictionary[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height =  self.cellHeightsDictionary[indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }
    
    
    
}


extension PodcastYoutubeVC{
    
    func addToRecent(){
        
        ShadhinCore.instance.api.recentlyPlayedPost(
            with: "\(track.contentID ?? "")",
            contentType: String(track.contentType?.prefix(2) ?? ""))
        
        let isDatabaseRecordExits = RecentlyPlayedDatabase.instance.checkRecordExists(contentID: track.contentID ?? "")
        if isDatabaseRecordExits {
            RecentlyPlayedDatabase.instance.updateDataToDatabase(musicData: track)
        }else {
            RecentlyPlayedDatabase.instance.saveDataToDatabase(musicData: track)
        }
    }
    
    func addUserTracking(){
        guard playedSec > 1,
              let code = track.contentType,
              let id = track.contentID,
              code.prefix(2).uppercased() == "VD" else {return}        
        
//        Analytics.logEvent("sm_content_played",
//                           parameters: [
//                            "content_type"  : code.lowercased() as NSObject,
//                            "content_id"    : id as NSObject,
//                            "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
//                            "content_name"  : track.title?.lowercased() ?? "" as NSObject,
//                            "duration_sec"  : playedSec as NSObject,
//                            "platform"      : "ios" as NSObject
//                           ])
        SMAnalytics.viewContent(contentName: track.title?.lowercased() ?? "", contentID: id, contentType: code.lowercased())
        ShadhinCore.instance.api.trackUserHistory(
            contentID: id,
            type: code,
            playCount: "1",
            totalPlayInSeconds: playedSec,
            playInDate: playIn,
            playOutDate: getCurrentDateAndTime(),
            playlistId: "") {
                (success) in
        }
        ShadhinCore.instance.api.trackUserHistoryV6(
            contentID: id,
            type: code,
            playCount: "1",
            totalPlayInSeconds: playedSec,
            playInDate: playIn,
            playOutDate: getCurrentDateAndTime(),
            playlistId: "") {
                (success) in
        }

    }
    
    func getComments(_ completion: (() -> Void)? = nil) {
        pendingRequestWorkItem0?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.getCommentsFromServer(completion)})
        pendingRequestWorkItem0 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
    
    func getCommentsFromServer(_ completion : (() -> Void)? = nil){
        currentCommentPage += 1
        ShadhinCore.instance.api.getCommentsBy(
            String(track.contentType?.prefix(2) ?? ""),
            Int(track.albumId ?? "0") ?? 0,
            currentCommentPage,
            String(track.contentType?.suffix(track.contentType!.count - 2) ?? "")) {
                _data in
                guard let data = _data else {return}
                if data.data.count > 0{
                    self.updateComments(data: data)
                }else{
                    self.currentCommentPage -= 1
                }
                LoadingIndicator.stopAnimation()
                completion?()
            }
    }
    
    func getLikeCount(){
        guard let id = Int(track.contentID ?? "") else {return}
        ShadhinCore.instance.api.getPodcastLikedCount(
            podcastType: String(track.contentType?.prefix(2) ?? ""),
            contentID: id) { data in
                self.likeCount = data
            }
    }
    
    func updateLikeServer(){
        ShadhinCore.instance.api.likePodcastBy(
            contentID: "\(track.contentID ?? "")",
            podcastType: String(track.contentType?.prefix(2) ?? "")) { _data in
                guard let data = _data else {return}
                self.likeCount = data
            }
    }
    
    func updateComments(data : CommentsObj){
        if userComments == nil{
            userComments = data
            
            if loadMoreComments == nil{
                loadMoreComments = LoadMoreActivityIndicator(scrollView: tableView, spacingFromLastCell: -32, spacingFromLastCellWhenLoadMoreActionStart: 8)
            }
            loadMoreComments?.stop()
        }else{
            let comments = data.data
            userComments?.data.append(contentsOf: comments)
        }
        tableView.reloadData()
    }
    
    @objc func reloadComments(){
        currentCommentPage = 0
        userComments = nil
        pendingRequestWorkItem1?.cancel()
        pendingRequestWorkItem2?.cancel()
        tableView.reloadData()
        getComments()
        LoadingIndicator.startAnimation(true)
    }
    
    func updateFavouriteComment(_ index : IndexPath, _ completion : (() -> Void)? = nil){
        pendingRequestWorkItem1?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.updateFavouriteCommentServer(index, completion)})
        pendingRequestWorkItem1 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
    
    func updateLikeComment(_ index : IndexPath,  _ completion : (() -> Void)? = nil){
        pendingRequestWorkItem2?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.updateLikeCommentServer(index, completion)})
        pendingRequestWorkItem2 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
    
    private func updateFavouriteCommentServer(_ index : IndexPath, _ completion : (() -> Void)? = nil){
        guard let commentID = userComments?.data[index.row - 1].commentID,
              let commentBool = userComments?.data[index.row - 1].commentFavorite else{
            return
        }
        
        ShadhinCore.instance.api.toggleFavoriteComment(
            String(track.contentType?.prefix(2) ?? ""),
            commentID) { success in
                if success{
                    self.userComments?.data[index.row - 1].commentFavorite = !commentBool
                    if (self.userComments?.data[index.row - 1].commentFavorite)!{
                        self.userComments?.data[index.row - 1].totalCommentFavorite += 1
                    }else{
                        self.userComments?.data[index.row - 1].totalCommentFavorite -= 1
                    }
                    self.tableView.reloadRows(at: [index], with: .automatic)
                    completion?()
                }
            }
    }
    
    private func updateLikeCommentServer(_ index : IndexPath,  _ completion : (() -> Void)? = nil){
        guard let commentID = userComments?.data[index.row - 1].commentID,
              let likeBool = userComments?.data[index.row - 1].commentLike, !likeBool else{
            return
        }
        
        ShadhinCore.instance.api.likeComment(
            String(track.contentType?.prefix(2) ?? ""),
            commentID) { success in
                if success{
                    self.userComments?.data[index.row - 1].commentLike = !likeBool
                    self.tableView.reloadRows(at: [index], with: .automatic)
                    completion?()
                }
            }
    }
}
