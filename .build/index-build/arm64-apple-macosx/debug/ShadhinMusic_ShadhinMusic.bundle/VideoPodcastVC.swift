//
//  VideoPodcastVC.swift
//  Shadhin
//
//  Created by Joy on 19/6/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class VideoPodcastVC: UIViewController,NIBVCProtocol {

    static func openLivePodcast(_ vc : UIViewController?, _ track : CommonContentProtocol){
        
        let podcastYoutube = VideoPodcastVC.instantiateNib()
        podcastYoutube.track = track
        podcastYoutube.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        podcastYoutube.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        vc?.navigationController?.present(podcastYoutube, animated: true)
        
    }
    
    @IBOutlet weak var playerHolder: UIView!
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var playPauseBtn: UIButton!
    //@IBOutlet weak var videoEndedImg: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var likeHolder: UIStackView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var commentRefreshBtn: UIButton!
    @IBOutlet weak var addCommentHolder: UIView!
    //@IBOutlet weak var durationLabel: UILabel!
    //@IBOutlet weak var liveIcon: UIImageView!
    
    var track : CommonContentProtocol!{
        didSet{
            if track != nil, let playUrl = track.playUrl?.decryptUrl(){
                track.playUrl = playUrl
            }
        }
    }
    
    var likeCount: PodcastAPI.PodcastLike?{
        didSet{
            if likeCount != nil && oldValue == nil{
                likeHolder.setClickListener {
                    self.updateLikeServer()
                }
            }
            updateLike()
        }
    }
    
    var currentCommentPage = 0
    var userComments : CommentsObj? = nil
    var loadMoreComments : LoadMoreActivityIndicator?
    
    var cellHeightsDictionary: [IndexPath: CGFloat] = [:]
    
    var pendingRequestWorkItem0: DispatchWorkItem?
    var pendingRequestWorkItem1: DispatchWorkItem?
    var pendingRequestWorkItem2: DispatchWorkItem?
    
    private var  videoPlayer : VGPlayer!
    
    let storyBoard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
    
    deinit{
        videoPlayer.cleanPlayer()
        videoPlayer = nil
    }
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
        likeImg.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16);
        videoPlayer = VGPlayer(playerView: VGPlayerView())
        getComments()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LoadingIndicator.initLoadingIndicator(view: tableView)
        
        videoTitle.text = track.title
        commentRefreshBtn.addTarget(self, action: #selector(reloadComments), for: .touchUpInside)
        addCommentHolder.setClickListener {
            self.addComment()
        }
        
        getPlayUrl()
        getLikeCount()
        
    }

}

extension VideoPodcastVC{
    func getPlayUrl(){

        ShadhinCore.instance.api.getPlayUrl(track) { playUrl, error in
            guard let playUrl = playUrl else {
                return
            }
            self.track.playUrl = playUrl
            //self.track.playUrl = "RcJx3uTA4Dk"
            //self.track.playUrl  = "https://live.liveapi.com/62454818fa1bec744c836f27/lv_cd016be0b0be11ec83b7d159fcdc3008/index.m3u8"
            //self.track.trackType = "LM"
            //self.track.playUrl = "https://shadhinmusiccontent.sgp1.digitaloceanspaces.com/Podcast/VideoFile/CatchTheBeat_BappaMazumder_Full/index.m3u8"
            //self.tryToPlay()
            self.playVideo(url: playUrl)
        }
    }
    private func playVideo(url : String){
        guard let videoUrl = URL(string: url) else {
            return
        }
        self.videoPlayer.cleanPlayer()
        
        if self.videoPlayer.displayView.superview == nil{
            playerHolder.removeAllSubviews()
            self.videoPlayer.displayView.frame = playerHolder.bounds
            playerHolder.addSubview(self.videoPlayer.displayView)
            
            self.videoPlayer.delegate = self
            self.videoPlayer.displayView.delegate = self
            
            self.videoPlayer.displayView.titleLabel.isHidden = true
            //self.videoPlayer.displayView.closeButton.isHidden = true
            
            self.videoPlayer.displayView.snp.makeConstraints { [weak self] (make) in
                guard let strongSelf = self else { return }
                make.top.equalTo(strongSelf.playerHolder.snp.top)
                make.left.equalTo(strongSelf.playerHolder.snp.left)
                make.right.equalTo(strongSelf.playerHolder.snp.right)
                make.bottom.equalTo(strongSelf.playerHolder.snp.bottom)
            }
            
        }
        self.videoPlayer.replaceVideo(videoUrl)
        self.videoPlayer.play()
        
        if track.trackType?.uppercased() != "LM"{
            addToRecent()
        }
        
    }
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
    func getLikeCount(){
        guard let id = Int(track.contentID ?? "") else {return}
        ShadhinCore.instance.api.getPodcastLikedCount(
            podcastType: String(track.contentType?.prefix(2) ?? ""),
            contentID: id) { data in
                self.likeCount = data
            }
    }
    func addComment(){
        let vc = storyBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        //vc.contentId = Int(track.episodeID) ?? 0
        vc.contentId = Int(track.albumId ?? "0")!
        vc.podcastLive1 = self
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
    func updateLikeServer(){
        ShadhinCore.instance.api.likePodcastBy(
            contentID: "\(track.contentID ?? "")",
            podcastType: String(track.contentType?.prefix(2) ?? "")) { _data in
                guard let data = _data else {return}
                self.likeCount = data
            }
    }
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
    func updateLikeComment(_ index : IndexPath,  _ completion : (() -> Void)? = nil){
        pendingRequestWorkItem2?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.updateLikeCommentServer(index, completion)})
        pendingRequestWorkItem2 = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: requestWorkItem)
    }
    func updateFavouriteComment(_ index : IndexPath, _ completion : (() -> Void)? = nil){
        pendingRequestWorkItem1?.cancel()
        let requestWorkItem = DispatchWorkItem(block: {self.updateFavouriteCommentServer(index, completion)})
        pendingRequestWorkItem1 = requestWorkItem
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
    func viewReply(_ comment : CommentsObj.Comment, _ index : IndexPath){
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.comment = comment
        vc.indexOfComment = index
        vc.podcastLive1 = self
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
}

extension VideoPodcastVC : UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (userComments != nil ? (1 + userComments!.data.count) : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
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
                
                cell.podcastLive1 = self
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

extension VideoPodcastVC : VGPlayerDelegate{
    
    func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError) {
        //print("check007 -> \(error.description)")
    }
    
    
    ///needs to work here for play next song automatically
    ///just fire a delegate and capture from VideoPlayerVC
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        //print("player State ",state)
        if state == .playFinished {
            
        }
    }
    
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {
        //print("buffer State --> \(state)")
    }
    
    func vgPlayer(_ player: VGPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
    }
    
}
extension VideoPodcastVC : VGPlayerViewDelegate{
    
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {
        if fullscreen {
            self.videoPlayer.displayView.titleLabel.isHidden = true
            self.videoPlayer.displayView.closeButton.isHidden = true
        }else {
            self.videoPlayer.displayView.titleLabel.isHidden = true
            self.videoPlayer.displayView.closeButton.isHidden = true
        }
    }
    
    func vgPlayerView(didTappedClose playerView: VGPlayerView) {
        Log.error("is full screen")
        if playerView.isFullScreen {
            playerView.exitFullscreen()
        }
        videoPlayer.cleanPlayer()
        self.dismiss(animated: true)
        
    }
    
    func vgPlayer(_ player: VGPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {
        ////print(currentDuration)
        
    }
    
    func vgPlayerView(didDisplayControl playerView: VGPlayerView) {
        //print("didDisplayControl - \(playerView.isDisplayControl)")
        
    }
}
