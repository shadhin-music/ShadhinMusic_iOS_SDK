//
//  HomeCoordinator.swift
//  Shadhin
//
//  Created by Gakk Alpha on 12/10/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class HomeCoordinator : NSObject,Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var tabBarController : UITabBarController?
    
    init(navigationController: UINavigationController, tabBar : UITabBarController?) {
        self.navigationController = navigationController
        self.tabBarController = tabBar
        super.init()
        self.navigationController.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    func start() {
    }
    
    func routeToContent(content: CommonContentProtocol, _ patch: HomeV3Patch? = nil){
        let contentType = SMContentType(rawValue: content.contentType)
        switch contentType{
        case .artist:
            goToArtist(content: content)
        case .album:
            goToAlbum(content: content)
        case .song:
            let suggestion = patch?.contents.filter({$0.contentType?.lowercased()=="s"}) ?? []
            goToSingle(content: content, suggestion)
        case .podcast:
            
            if IS_RECENTPLAY {
                self.navigationController.openMusicPlayerV3(musicData: [content], songIndex: 0, isRadio: false, rootModel: content)
                return
            }
            
            if content.isPaid ?? false && !ShadhinCore.instance.isUserPro {
                goToSubscription(content: content)
            } else {
                if let data = patch?.contents, let indx = data.firstIndex(where: {$0.contentID == content.contentID}) {
                    if data[indx].track != nil {
                        self.navigationController.openMusicPlayerV3(musicData: data, songIndex: indx, isRadio: false, rootModel: content)
                    } else {
                        goToPodcast(content: content)
                    }
                    
                } else {
                    goToPodcast(content: content)
                }
            }
            
        case .podcastVideo:
            goToVideoPodcast(content: content)
        case .video:
            var contents : [CommonContentProtocol] = patch?.contents.filter({$0.contentType?.lowercased()=="v" && $0.contentID != content.contentID}) ?? []
            contents.insert(content, at: 0)
            playVideo(contents: contents, index: 0)
        case .playlist:
            let suggestion = patch?.contents.filter({$0.contentType?.lowercased()=="p"}) ?? []
            goToPlaylist(content: content, suggestion)
        case .subscription:
            goToSubscription(content: content)
        case .LK:
            //let suggestion = patch?.contents.filter({$0.contentType?.uppercased()=="LK"}) ?? []
            gotoTeasereUrl(content: content)
        case .myPlayList:
            goToMyPlaylist(content: content)
        case .audioBook:
            goToAudioBook(content: content)
        case .unknown:
            break
        case .link:
            openLinkInBrowser(urlString: content.playUrl)
        }
    }
    
    func openLinkInBrowser(urlString: String?) {
        guard let urlString = urlString else { return }
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Invalid URL or cannot open URL")
            }
        } else {
            print("URL string is not valid")
        }
    }
    
    func navigateToChannel(viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: true)
    }
        
    func routeToAIPlayList(content: AIPlaylistResponseModel?, imageUrl: String = "", playlistName: String = "", playlistId: String = ""){
        goToAIPlaylist(content: content, imageUrl: imageUrl, playlistName: playlistName, playlistId: playlistId)
    }
    
    
    func routeToSeeAll(patch : HomeV3Patch){
        
    }
    
    func goToArtist(content: CommonContentProtocol){
        let storyBoard = UIStoryboard(name: "Discover", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MusicArtistListVC") as! MusicArtistListVC
        vc.discoverModel = content
        vc.hidesBottomBarWhenPushed = false
        SMAnalytics.viewContent(content: content)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToAlbum(content: CommonContentProtocol){
        let storyBoard = UIStoryboard(name: "Discover", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MusicAlbumListVC") as! MusicAlbumListVC
        vc.discoverModel = content
        vc.isFromThreeDotMenu = false
        vc.hidesBottomBarWhenPushed = false
        SMAnalytics.viewContent(content: content)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToSingle(content: CommonContentProtocol,_ suggestion: [CommonContentProtocol] = []){
        let storyBoard = UIStoryboard(name: "Discover", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: PlaylistOrSingleDetailsVC.identifier) as! PlaylistOrSingleDetailsVC
        vc.discoverModel = content
        vc.suggestedPlaylists = suggestion
        vc.hidesBottomBarWhenPushed = false
        SMAnalytics.viewContent(content: content)
        navigationController.pushViewController(vc, animated: true)
    }
    func gotoTeasereUrl(content: CommonContentProtocol) {
        // here view  integrate
        guard let url = content.teaserUrl else {return}
        let vc = WebViewVC()
        vc.url = URL(string:url)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func goToPodcast(content: CommonContentProtocol){
        let storyBoard = UIStoryboard(name: "PodCast", bundle:Bundle.ShadhinMusicSdk)
        if let tabVC = MainTabBar.shared,
           let tabs = tabVC.viewControllers,
           tabs.count > 2,
           let nav = tabs[2] as? UINavigationController,
           let contentId = Int(content.contentID ?? ""),
           let contentType = content.contentType,
           let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
            podcastVC.podcastCode = contentType
            if let trackType = content.trackType, trackType.uppercased().elementsEqual("EPISODE"){
                podcastVC.selectedEpisodeID = contentId
            } else {
                podcastVC.selectedEpisodeID = contentId
//                podcastVC.selectedEpisodeID = 0
            }
            nav.pushViewController(podcastVC, animated: true)
            tabVC.selectedIndex = 2
        }
    }
    
    func goToVideoPodcast(content: CommonContentProtocol){
        let storyBoard = UIStoryboard(name: "PodCast", bundle:Bundle.ShadhinMusicSdk)
        if let tabVC = MainTabBar.shared,
           let tabs = tabVC.viewControllers,
           tabs.count > 2,
           let nav = tabs[2] as? UINavigationController,
           let contentId = Int(content.contentID ?? ""),
           let contentType = content.contentType,
           let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
            podcastVC.podcastCode = contentType
            podcastVC.selectedEpisodeID = contentId
            nav.pushViewController(podcastVC, animated: true)
            tabVC.selectedIndex = 2
        }
    }
    
    func playVideo(contents: [CommonContentProtocol], index: Int) {
        let vc = VideoPlayerVC()
        vc.index = index
        vc.videoList = contents
        vc.hidesBottomBarWhenPushed = false
        navigationController.pushViewController(vc, animated: true)
        SMAnalytics.viewContent(content: contents[index])
    }
    
    func goToPlaylist(content: CommonContentProtocol,_ suggestion: [CommonContentProtocol] = []){
        let storyBoard = UIStoryboard(name: "Discover", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: PlaylistOrSingleDetailsVC.identifier) as! PlaylistOrSingleDetailsVC
        vc.discoverModel = content
        vc.suggestedPlaylists = suggestion
        vc.hidesBottomBarWhenPushed = false
        SMAnalytics.viewContent(content: content)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToMyPlaylist(content: CommonContentProtocol){
        let storyBoard = UIStoryboard(name: "MyMusic", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlaylistSongsVC") as! PlaylistSongsVC
        guard let contentID = content.contentID else {
            return
        }
        vc.playlistID = contentID
        if let title = content.title{
            vc.playlistName = title
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func gotoNarratorDetails(id: String,content:[SimilerBooksData]){
        let vc  = AuthorAndNarratorDetailsVC()
        vc.authorId = id
        vc.youMightLikeBooksData = content
        vc.isNarratorVisible = true
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToAIPlaylist(content: AIPlaylistResponseModel?, imageUrl: String = "", playlistName: String = "", playlistId: String = ""){
        let storyBoard = UIStoryboard(name: "MyMusic", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlaylistSongsVC") as! PlaylistSongsVC
        if let content {
            vc.playlistName = content.data.parentContents.first?.titleEn ?? content.data.parentContents.first?.titleBn ?? ""
            vc.aiMoodImageURL = content.data.parentContents.first?.imageUrl ?? ""
            vc.userContentPlaylists = content.data.contents.compactMap({$0.toCommonContentProtocol()})
            vc.isAIPlaylist = true
        } else {
            vc.isAIPlaylist = false
            vc.aiMoodImageURL = imageUrl
            vc.playlistName = playlistName
            vc.playlistID = playlistId
        }
        vc.hidesBottomBarWhenPushed = false
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToAudioBook(content: CommonContentProtocol) {
        guard let tabBar = MainTabBar.shared else { return }
        tabBar.selectedIndex = 3
        
        DispatchQueue.main.async {
            guard let nav = tabBar.viewControllers?[3] as? UINavigationController,
                  let containerVC = nav.viewControllers.first as? ShortsAndAudiobookContainerVC else {
                return
            }
            containerVC.showAudiobookDetails(contentType: content.contentType ?? "BK", contentID: content.contentID ?? "")
        }
    }
    
    func goToSubscription(content: CommonContentProtocol){
        let subscriptionPlatForm = content.trackType ?? "common"
        let subscriptionPlanName = content.albumId ?? "common"
        goToSubscription(false, subscriptionPlatForm, subscriptionPlanName)
    }
    
    func goToSubscription(_ useParent:Bool = false,
                          _ subscriptionPlatForm :String = "common",
                          _ subscriptionPlanName :String = "common") {
        let storyBoard = UIStoryboard(name: "Payment", bundle: Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionTypeVC") as! SubscriptionTypeVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.isNeedSubs = true
        vc.subscriptionPlatForm = subscriptionPlatForm
        vc.subscriptionPlanName = subscriptionPlanName
        if useParent{
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(vc, animated: true, completion: nil)
            }
        }else{
            navigationController.present(vc, animated: true, completion: nil)
        }
    }
    
    func gotoLeaderBoard2(method : PaymentMethod,campaignType : String){
        let leaderBoard = LeaderBoardVC.instantiateNib()
        leaderBoard.paymentMethod = method
        leaderBoard.campaignType = campaignType
        push(vc: leaderBoard)
    }
    
    func gotoLeaderBoard(data : CampaignWrapper, campaignType : String) {
        let leaderBoard = LeaderBoardVC.instantiateNib()
        leaderBoard.campaignWrapper = data
        leaderBoard.adapter?.campaignWrapper = data
        leaderBoard.campaignType = campaignType
        push(vc: leaderBoard)
    }
    
//    func gotoSearch(){
//        let ss = UIStoryboard.init(name: "Search", bundle: .main)
//        if let vc = ss.instantiateViewController(withIdentifier: "SearchVC") as? SearchVC{
//            push(vc: vc)
//        }
//        
//    }
    
    func gotoDownload(with type : DownloadChipType){
        let download = DownloadVC.instantiateNib()
        download.downloadType = type
        push(vc: download)
    }
    func gotoRecentlyPlayed(){
        let recent = RecentlyPlayedSongVCC()
        push(vc: recent)
    }
    func gotoSeeAll(patch : HomeV3Patch){
        if patch.patch.designType == 6{
            gotoDownload(with: .None)
        } else if patch.patch.designType == 5{
            gotoRecentlyPlayed()
        }
        else{
            let vc = HomeSeeAllVC.instantiateNib()
            vc.patch = patch
            vc.coordinator = self
            push(vc: vc)
        }
    }
    func gotoRewind(rewindData : [TopStreammingElementModel]){
        let rewind = ShadhinRewindVC.instantiateNib()
        rewind.streamingData = rewindData
        rewind.modalPresentationStyle = .fullScreen
        self.navigationController.present(rewind, animated: true)
    }
}
extension HomeCoordinator {
    func push(vc : UIViewController){
        self.navigationController.pushViewController(vc, animated: true)
    }
    func pop(){
        self.navigationController.popViewController(animated: true)
    }
}

extension HomeCoordinator : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
