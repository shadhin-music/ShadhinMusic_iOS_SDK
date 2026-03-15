//
//  PodcastVC.swift
//  Shadhin
//
//  Created by Rezwan on 2/10/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastVC: UITableViewController {
    
    var selectedTrackID = "" {
        didSet {
            // ✅ Only call checkIsFav if ID actually changed to a non-empty value
            guard !selectedTrackID.isEmpty else { return }
            self.checkIsFav()
        }
    }

    var favBtn: UIButton? {
        didSet {
            // ✅ Only call checkIsFav if we have a track selected
            guard !selectedTrackID.isEmpty else {
                favBtn?.isHidden = false // keep visible
                return
            }
            self.checkIsFav()
        }
    }
    var podcastCode: String = "PDBC"{
        didSet{
            podcastType = String(podcastCode.prefix(2)).uppercased()
            podcastShowCode = String(podcastCode.suffix(podcastCode.count - 2)).uppercased()
        }
    }
    var selectedEpisode = 0
    var selectedEpisodeID = 0
    var podcastShowCode = "BC" // or "nc"
    var podcastType = "PD"
    var selectedEpisodeCommentPaid = false
    var selectedTrack: CommonContentProtocol?
    var commingSoonView: UILabel?
    var gotData = false
    var shouldPlay = true
    var shouldShowEpisodes = false;
    var willLoadAds = false
    var cellHeightsDictionary: [IndexPath: CGFloat] = [:]
    private let downloadManager = SDDownloadManager.shared
    var currentCommentPage = 0
    var currentEpisode = -1
    var userComments : CommentsObj? = nil
    
    var headerImg: String?
    var headerTitle: String?
    var headerSubTitle: String?
    
    var headerAbout: String?{
        didSet{
            headerAbout?.stringFromHTML(completionBlock: { [weak self] _str in
                guard let this = self, let str = _str else { return }
                this.headerAboutStr = str
            })
        }
    }
    var headerAboutStr: String = ""
    var headerStarring: String?
    var headerProductedBy: String?
    var playBtn: UIButton?
    var loadMoreComments : LoadMoreActivityIndicator?
    var state: ReadMoreLessView.ReadMoreLessViewState = .collapsed
    
    var pendingRequestWorkItem0: DispatchWorkItem?
    var pendingRequestWorkItem1: DispatchWorkItem?
    var pendingRequestWorkItem2: DispatchWorkItem?
    var podcastModel: PodcastData?
    var tracksEpisode: PodcastData?
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }

    var noInternetView : NoInternetView = NoInternetView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewSetup()
        self.noInternetViewSetup()
        self.clickClouser()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldPlay = true
        playBtn?.setImage(UIImage(named: "ic_Play", in: Bundle.ShadhinMusicSdk, compatibleWith: nil),for: .normal)
        playBtn?.tag = 0
    }
    
    private func tableViewSetup() {
        let viewFooter = UIView(frame: CGRect(x: 0, y: 1, width: 1, height: (49 + (UIApplication.shared.currentWindow?.safeAreaInsets.top ?? 0) + 50)))
        tableView.tableFooterView  = viewFooter
        tableView.register(CommentCell.nib, forCellReuseIdentifier: CommentCell.identifier)
        
        let refreshView0 = KRPullLoadView()
//        refreshView0.delegate = self
        self.tableView.addPullLoadableView(refreshView0, type: .refresh)
        
        NotificationCenter.default.addObserver(forName: .init(rawValue: "FavDataUpdateNotify"), object: nil, queue: .main) { notificatio in
            self.checkIsFav()
        }
    }
    
    private func setupUI() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            LoadingIndicator.initLoadingIndicator(view: self.view)
            LoadingIndicator.startAnimation()

            guard ConnectionManager.shared.isNetworkAvailable else {
                self.noInternetView.isHidden = false
                LoadingIndicator.stopAnimation()
                return
            }
            let group = DispatchGroup()

            group.enter()
            self.getPodcastData {
                group.leave()
            }

            group.enter()
            self.getPodcastTracksData {
                group.leave()
            }

            group.notify(queue: .main) { [weak self] in
                LoadingIndicator.stopAnimation()
                guard let self = self else {return}
                guard let data = tracksEpisode else { return }
                let tracks = data.contents
                shouldShowEpisodes = tracks.count > 1
                commingSoonView?.removeFromSuperview()
                commingSoonView = nil
                initCustomVariable(track: data.parentContents.first)
                selectedTrackID = data.parentContents.first?.toCommonContent().contentID ?? ""
                selectedTrack = data.parentContents.first?.toCommonContent()
                gotData = true
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                
            }
        }
    }
    
    private func noInternetViewSetup() {
        self.view.addSubview(noInternetView)
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        noInternetView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        noInternetView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 20).isActive = true
        noInternetView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        noInternetView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive
         = true
        noInternetView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        noInternetView.isHidden = true
    }
    
    func checkIsFav() {
        guard !selectedTrackID.isEmpty else {
            favBtn?.isHidden = false
            return
        }
        let type: SMContentType = podcastType.uppercased() == "PD" ? .podcast : .podcastVideo
        ShadhinCore.instance.api.getAllFavoriteByType(type: type) { (data, error) in
            guard let data = data else { return }

            DispatchQueue.main.async {
                self.favBtn?.isHidden = false // ✅ Always show, never hide
                if data.contains(where: { $0.contentID == self.selectedTrackID }) {
                    self.favBtn?.tag = 1
                    self.favBtn?.setImage(UIImage(named: "ic_favorite_a", in: Bundle.ShadhinMusicSdk, compatibleWith: nil), for: .normal)
                } else {
                    self.favBtn?.tag = 0
                    self.favBtn?.setImage(UIImage(named: "ic_favorite_n", in: Bundle.ShadhinMusicSdk, compatibleWith: nil), for: .normal)
                }
            }
        }
    }

    private func clickClouser() {
        noInternetView.retry = {[weak self] in
            guard let self = self else {return}
            if ConnectionManager.shared.isNetworkAvailable{
                self.getPodcastData()
            }
            
        }
        noInternetView.gotoDownload = {[weak self] in
            guard let self = self else {return}
            if self.checkUser(){
                let vc = DownloadVC.instantiateNib()
                vc.selectedDownloadSeg = .init(title: ^String.Downloads.audioPodcast, type: .PodCast)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func initCustomVariable(track: PodcastContent?) {
        guard let track = track else {return}
        selectedEpisode = track.contentId
        selectedEpisodeID = track.contentId
        selectedEpisodeCommentPaid = track.podcast.isCommentPaid
        headerImg = track.imageUrl
        headerTitle = track.titleBn.isEmpty ? track.titleEn : track.titleBn
        headerAbout = track.details
        let hdrSubTitle = tracksEpisode?.contents.first?.artists?.first?.name
        headerSubTitle = self.makeSubtitleText(title: headerTitle, subTitle: hdrSubTitle, likeCount: track.likeCount == 0 ? track.streamingCount : track.likeCount)
        currentEpisode = track.contentId
        currentCommentPage = 0
        userComments = nil
        pendingRequestWorkItem1?.cancel()
        pendingRequestWorkItem2?.cancel()
        headerAbout = track.details
        self.getComments()
        SMAnalytics.viewContent(
            contentName: track.titleEn.lowercased(),
            contentID: String(selectedEpisodeID),
            contentType: podcastCode.lowercased()
        )
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
    
    func updateComments(data : CommentsObj){
        if userComments == nil{
            userComments = data
            if loadMoreComments == nil{
                loadMoreComments = LoadMoreActivityIndicator(scrollView: tableView, spacingFromLastCell: -(49 + (UIApplication.shared.currentWindow?.safeAreaInsets.top ?? 0) + 50), spacingFromLastCellWhenLoadMoreActionStart: 60)
            }
            loadMoreComments?.stop()
        }else{
            let comments = data.data
            userComments?.data.append(contentsOf: comments)
        }
        tableView.reloadData()
    }
    
    func share() {
        DeepLinks.createLinkTest(controller: self)
    }
    
    private func makeSubtitleText(
        title: String?,
        subTitle: String?,
        likeCount: Int?
    ) -> String {
        
        var parts: [String] = []
        
        if let subTitle, !subTitle.isEmpty {
            parts.append(" By \(subTitle)")
        }
        
        let likesText = "\(likeCount ?? 0) Likes"
        
        if parts.isEmpty {
            return likesText
        } else {
            return parts.joined(separator: " • ") + " • \(likesText)"
        }
    }

    func dismiss(){
        self.navigationController?.popViewController(animated: true)
    }

    func playMediaAtIndex(_ index: Int) {
        selectedParentContentID = tracksEpisode?.parentContents.first?.contentId ?? -1

        guard let tracks = tracksEpisode?.contents,
              index < tracks.count else { return }
        if podcastType == "VD" { return }
        let selected = tracks[index].toCommonContent()

        self.selectedTrack = selected
        let allTracks: [CommonContentProtocol]

        if ShadhinCore.instance.isUserPro {
            allTracks = tracks.map { $0.toCommonContent() }
        } else {
            allTracks = tracks
                .filter { !$0.isPaid}
                .map { $0.toCommonContent() }
        }
        
        let playIndex = allTracks.firstIndex { $0.contentID == selected.contentID } ?? 0
        self.openMusicPlayerV3(musicData: allTracks, songIndex: playIndex, isRadio: false, rootModel: selected)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.playBtn?.setImage(
                UIImage(named: "ic_Pause1", in: Bundle.ShadhinMusicSdk, compatibleWith: nil),
                for: .normal
            )
            self.playBtn?.tag = 1
            self.shouldPlay = false
            MusicPlayerV3.isAudioPlaying = false
            self.tableView.reloadData()
        }
    }
    
    func addComment(){
        if selectedEpisodeCommentPaid && !ShadhinCore.instance.isUserPro {
            DispatchQueue.main.async {
                SubscriptionPopUpVC.show(self)
                return
            }
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.contentId = selectedEpisodeID
        vc.podcastVC = self
        vc.podcastShowCode = podcastShowCode
        vc.podcastType = podcastType
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if var topController = UIApplication.shared.currentWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    func viewReply(_ comment : CommentsObj.Comment, _ index : IndexPath){
        
        if selectedEpisodeCommentPaid && !ShadhinCore.instance.isUserPro {
            SubscriptionPopUpVC.show(self)
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.comment = comment
        vc.indexOfComment = index
        vc.podcastVC = self
        vc.podcastShowCode = podcastShowCode
        vc.podcastType = podcastType
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if var topController = UIApplication.shared.currentWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    func addDeleteFav(){
        if favBtn?.tag == 1{
            deleteFav()
        }else{
            addFav()
        }
    }
    
    func addFav(){
        guard let track = selectedTrack else {return}
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: track,
            action: .add) { (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.favBtn?.tag = 1
                    self.favBtn?.setImage(UIImage(named: "ic_favorite_a",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }
    }
    
    func deleteFav(){
        guard let track = selectedTrack else {return}
        ShadhinCore.instance.api.addOrRemoveFromFavorite(
            content: track,
            action: .remove) { (err) in
                if err != nil {
                    ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                }else {
                    self.favBtn?.tag = 0
                    self.favBtn?.setImage(UIImage(named: "ic_favorite_n",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
                }
            }
    }
    
    func viewAllEpisodes() {
        guard let episodes = podcastModel?.contents else { return }
        let storyBoard = UIStoryboard(name: "Discover", bundle: Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DiscoverMusicDetailsVC") as! DiscoverMusicDetailsVC
        let episodesCommon = episodes.map { episode -> CommonContentProtocol in
            var epi = episode.toCommonContent()
            epi.artist = tracksEpisode?.contents.first?.artists?.first?.name
            return epi
        }
        vc.songDetails = episodesCommon
        vc.titleLblText = "More Episodes"
        vc.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PodcastVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = podcastModel?.contents.count ?? 0
        return max(0, count - 1)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodcastEpisodeItem.identifier, for: indexPath) as! PodcastEpisodeItem

        let actualIndex = indexPath.item + 1
        guard let episode = podcastModel?.contents[safe: actualIndex] else { return cell }

        var imageType = "300"
        if podcastType == "VD" {
            imageType = "1280"
        }
        let imgUrl = episode.imageUrl.replacingOccurrences(of: "<$size$>", with: imageType)
        cell.episodeImg.kf.indicatorType = .activity
        cell.episodeImg.kf.setImage(
            with: URL(string: imgUrl.safeUrl()),
            placeholder: UIImage(named: "default_radio", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
        )
        cell.episodeTitle.startLabelMarquee(text: episode.titleBn.isEmpty ? episode.titleEn : episode.titleBn)
        cell.setClickListener { [weak self] in
            guard let self = self else { return }

            if ConnectionManager.shared.isNetworkAvailable {
                self.didSelectPodcastItem(content: episode)
            } else {
                let vc = NoInternetPopUpVC.instantiateNib()
                vc.retry = { [weak self] in
                    guard let self = self else { return }
                    if ConnectionManager.shared.isNetworkAvailable {
                        self.didSelectPodcastItem(content: episode)
                    }
                }
                
                vc.gotoDownload = { [weak self] in
                    guard let self = self else { return }
                    if self.checkUser() {
                        let vc = DownloadVC.instantiateNib()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.audioPodcast, type: .PodCast)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                }
                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
            }
        }

        return cell
    }
    
    func didSelectPodcastItem(content: PodcastContent) {
        let storyboard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC else {
            return
        }
        let episodeID = getActualContentId(content: content)
        vc.podcastCode = content.contentType
        vc.selectedEpisode = episodeID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getActualContentId(content: PodcastContent) -> Int {
        let subType = content.podcast.contentSubType.uppercased()
        if subType == "TRACK" {
            return content.release?.id ?? 0
        } else if subType == "EPISODE" {
            return content.contentId
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if podcastType == "VD"{
            return PodcastEpisodeItem.size_vd
        }else{
            return PodcastEpisodeItem.size_pd
        }
    }
}

//MARK: mennu delegate
extension PodcastVC: MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        guard try! Reachability().connection != .unavailable else {return}
        
        guard checkProUser() else{
            return
        }
        AnalyticsEvents.downloadEvent(with: content.contentType, contentID: content.contentID, contentTitle: content.title)
        ShadhinApi().downloadCompletePost(model: content)
        
        guard let url = URL(string: content.playUrl?.decryptUrl() ?? "") else {
            return self.view.makeToast("Unable to get Download file Url")
        }
        
        self.view.makeToast("Downloading \(String(describing: content.title ?? ""))")
        
        let request = URLRequest(url: url)
        let _ = self.downloadManager.downloadFile(withRequest: request, onCompletion: { error, url in
            if error != nil{
                self.view.makeToast(error?.localizedDescription)
            }else{
                self.view.makeToast("File successfully downloaded.")
                //save song
                DatabaseContext.shared.addPodcast(content: content)
                //send download info to server
                ShadhinApi().downloadCompletePost(model: content)
                self.tableView.reloadData()
            }
        })
        tableView.reloadData()
        
        
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        DatabaseContext.shared.removePodcast(with: content.contentID  ?? "")
        if let playUrl = content.playUrl{
            SDFileUtils.removeItemFromDirectory(urlName: playUrl)
            self.view.makeToast("File Removed from Download")
        }
        tableView.reloadData()
    }
    
    func onRemoveFromHistory(content: CommonContentProtocol) {
    }
    
    func gotoArtist(content: CommonContentProtocol) {
    }
    
     func gotoAlbum(content: CommonContentProtocol) {
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



extension PodcastVC : KRPullLoadViewDelegate{
    
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        
        // print("state->\(state)  type->\(type)")
        if type == .refresh{
            switch state {
            case let .loading(completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                    
                    //LoadingIndicator.initLoadingIndicator(view: self.view)
                    LoadingIndicator.startAnimation(true)
                    self.view.isUserInteractionEnabled = false
                    self.getPodcastData()
                    completionHandler()
                }
                
            default: break
            }
            return
        }
        
    }
}

extension PodcastVC: ButtonDelegate{
    func buttonTaped(_ state: AlertPopUp.State, _ instanceID: Int) {
        if state == .positive{
            self.goSubscriptionTypeVC()
        }
    }
    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60

        if h > 0 {
            return "\(h)h \(m)m \(s)s"
        } else if m > 0 {
            return "\(m)m \(s)s"
        } else {
            return "\(s)s"
        }
    }
}

