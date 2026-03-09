//
//  DiscoverVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class DiscoverVC: UIViewController,ShadhinCoreNotifications{
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBannerMax: UIView!
    //@IBOutlet weak var adBannerHeight: NSLayoutConstraint!
    
    
    private var discoverDataLists = [PatchDetailsObj]()
    private var discoverHeaderTitles = [String]()
    
    var recentList : PatchDetailsObj?
    var recentListIndex : IndexPath?
    
    var recentDownloadsList : PatchDetailsObj?
    var recentDownloadsListIndex : IndexPath?
    
    var concertEventObj : ConcertEventObj?
    var streamNwinCampaignResponse : StreamNwinCampaignResponse?
    private var rewindData : TopStreammingElementModelData?
    
    var willLoadAds = false
    
    var appFirstOpen = true
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        view.backgroundColor = .customBGColor()
        
        navigationController?.navigationBar.isHidden = true
        refreshControl.addTarget(self, action: #selector(tableViewRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(NewReleaseMain.nib, forCellReuseIdentifier: NewReleaseMain.identifier)
//        tableView.register(NativeAdMax.nib, forCellReuseIdentifier: NativeAdMax.identifier)
//        tableView.register(NavtiveLargeAdTCell.nib, forCellReuseIdentifier: NavtiveLargeAdTCell.identifier)
//        tableView.register(ConcertTicketsDiscoverTC.nib, forCellReuseIdentifier: ConcertTicketsDiscoverTC.identifier)
        tableView.register(WinNStreamCell.nib, forCellReuseIdentifier: WinNStreamCell.identifier)
        tableView.register(RewindStoryCell.nib,forCellReuseIdentifier: RewindStoryCell.identifier)
        if #available(iOS 13.0, *) {
            refreshControl.tintColor = .secondaryLabel
        }
        
        LoadingIndicator.initLoadingIndicator(view: self.view)
        
        getDataFromServer()
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.isUpdateAvailable(self)
        //AppDelegate.shared?.mainHome = self
        NotificationCenter.default.addObserver(self, selector: #selector(performTaskAfterSubscriptionCheck), name: .didTapBackBkashPayment, object: nil)
        if !ShadhinCore.instance.isUserLoggedIn ||
            (ShadhinCore.instance.isUserLoggedIn){
            self.performTaskAfterSubscriptionCheck()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    //this is including by Joy inspired by hungama
//    private func loadNativePopup(){
//        let vc = HungamaAdsVC.instantiateNib()
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: true)
//        
//        vc.onPro = {
//            SubscriptionPopUpVC.show(self)
//        }
//    }
    
    private func initAppLovinSDKWithConsent(){
#if DEBUG
        return
#else
//        guard InterstitialAdMax.instance.sdkNotInit else {
//            self.loadAds()
//            return
//        }
//        let settings = ALSdkSettings()
//        settings.consentFlowSettings.isEnabled = true
//        settings.consentFlowSettings.privacyPolicyURL = URL(string: "http://shadhin.co/Privacy_Policy.html")
//        settings.consentFlowSettings.termsOfServiceURL = URL(string: "http://shadhin.co/terms_and_conditions_global_free.html")
//        FBAdSettings.setDataProcessingOptions([])
//        settings.isMuted = true
//        let sdk = ALSdk.shared(with: settings)
//        sdk?.mediationProvider = "max"
//        sdk?.initializeSdk { (configuration: ALSdkConfiguration) in
//            InterstitialAdMax.instance.sdkNotInit = false
//            //print("check ->\(ASIdentifierManager.shared().advertisingIdentifier.uuidString)")
//            let status = configuration.appTrackingTransparencyStatus
//            DispatchQueue.main.async {
//                if status == .authorized{
//                    Settings.setAdvertiserTrackingEnabled(true)
//                    FBAdSettings.setAdvertiserTrackingEnabled(true)
//                }
//                else if status == .notDetermined{
//                    self.fallbackAskForConsent()
//                    return
//                }else{
//                    Settings.setAdvertiserTrackingEnabled(false)
//                    FBAdSettings.setAdvertiserTrackingEnabled(false)
//                }
//            }
//            DispatchQueue.main.async {
//                self.loadAds()
//            }
//        }
#endif
    }
//    
//    private func fallbackAskForConsent(){
//        if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                DispatchQueue.main.async {
//                    if status == .authorized{
//                        Settings.setAdvertiserTrackingEnabled(true)
//                        FBAdSettings.setAdvertiserTrackingEnabled(true)
//                    }else{
//                        Settings.setAdvertiserTrackingEnabled(false)
//                        FBAdSettings.setAdvertiserTrackingEnabled(false)
//                    }
//                }
//                DispatchQueue.main.async {
//                    self.loadAds()
//                }
//                
//            })
//        } else {
//            self.loadAds()
//        }
//    }
//    
//    private func initAppLovinSDK(){
//        guard InterstitialAdMax.instance.sdkNotInit else {
//            loadAds()
//            return
//        }
//        ALSdk.shared()?.mediationProvider = "max"
//        ALSdk.shared()?.settings.isMuted = true
//        ALSdk.shared()?.userIdentifier = ShadhinCore.instance.defaults.userIdentity
//        ALSdk.shared()?.initializeSdk { (configuration: ALSdkConfiguration) in
//            InterstitialAdMax.instance.sdkNotInit = false
//            let status = configuration.appTrackingTransparencyStatus
//            DispatchQueue.main.async {
//                if status == .authorized{
//                    Settings.setAdvertiserTrackingEnabled(true)
//                    FBAdSettings.setAdvertiserTrackingEnabled(true)
//                }else{
//                    Settings.setAdvertiserTrackingEnabled(false)
//                    FBAdSettings.setAdvertiserTrackingEnabled(false)
//                }
//            }
//            
//            self.loadAds()
//        }
//    }
    
    
    @objc private func tableViewRefresh() {
        currentPage = 1
        totalPage = 1
        noMoreData = false
        inProcess = false
        noMoreData = false
        recentList = nil
        recentListIndex = nil
        recentDownloadsListIndex = nil
        recentDownloadsList = nil
        discoverDataLists.removeAll()
        discoverDataLists = []
        self.tableView.reloadData()
        getDataFromServer()
        self.refreshControl.endRefreshing()
        
        
        if try! Reachability().connection == .unavailable {
            var style = ToastManager.shared.style
            style.messageFont = UIFont.systemFont(ofSize: 14)
            style.messageAlignment = .center
            self.view.makeToast("No network available.please check your WiFi or Data connection!" ,style: style)
        }
    }
    
    
    private func getDataFromServer() {
        LoadingIndicator.startAnimation()
        self.getPagedHomeContent()
    }
    
    private func addFooterIndicator(){
        var spinner: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            spinner = UIActivityIndicatorView(style: .medium)
        } else {
            spinner = UIActivityIndicatorView(style: .gray)
        }
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        
        self.tableView.tableFooterView = spinner
        self.tableView.tableFooterView?.isHidden = false
    }
    
    private func endLoading(){
        if self.currentPage == 1{
            LoadingIndicator.stopAnimation()
        }else{
            self.tableView.tableFooterView?.isHidden = true
        }
    }
    
    private var currentPage = 1
    private var totalPage = 1
    private var noMoreData = false
    private var inProcess = false
    
    private func getPagedHomeContent(){
        if noMoreData || inProcess || currentPage > totalPage{
            return
        }
        inProcess = true
        if currentPage != 1{
            addFooterIndicator()
        }
        ShadhinCore.instance.api.getHomePatchsBy(page: currentPage) {
            (data, error) in
            if let error = error {
                if Disk.exists("Discover\(self.currentPage).json", in: .caches) {
                    let discoverData = try? Disk.retrieve("Discover\(self.currentPage).json", from: .caches, as: DiscoverPatchesObj.self)
                    self.parseData(data: discoverData)
                }
                Log.error(error.localizedDescription)
                self.endLoading()
                self.inProcess = false
                return
            }
            self.parseData(data: data)
            try? Disk.save(data, to: .caches, as: "Discover\(self.currentPage).json")
        }
    }
    
    func parseData(data: DiscoverPatchesObj?){
        guard let data = data else{
            self.endLoading()
            self.inProcess = false
            return
        }
        if data.data.isEmpty{
            self.noMoreData = true
            self.inProcess = false
            self.endLoading()
            return
        }
        for var item in data.data{
            if item.data.isEmpty{
                return
            }
            if item.design == "Podcast"{
                item.data0 = item.data0!.sorted(by: {$0.playCount! > $1.playCount!})
            }
            
            if item.code == "P014" ||
                item.code == "P013" ||
                item.code == "P007" ||
                item.code == "P022" ||
                item.code == "P026" ||
                item.code == "P024" ||
                item.code == "P029" ||
                item.code == "P016" ||
                item.code == "P032" ||
                item.code == "P038" ||
                item.code == "P041" ||
                item.code == "P003" ||
                item.code == "P004"
            {
                item.data.shuffle()
            }
            self.discoverDataLists.append(item)
            
            self.discoverDataLists = self.discoverDataLists.sorted(by: {Float($0.sort)! < Float($1.sort)!})
        }
        
        self.tableView.reloadData()
        self.endLoading()
        if self.currentPage == 1{
            totalPage = data.total
            self.getRecentlyPlayed()
            self.getMadeForYou()
            self.getStory()
            self.checkIfCampaignRunning()
            //self.addDummyData()
            RecentlyPlayedDatabase.instance.refreshListener = {
                () in
                self.getRecentlyPlayed()
            }
            //self.getRecentlyPlayed()
        }
        self.currentPage += 1
        self.inProcess = false
    }
    
    private func byPassToOldCode( _ item : inout PatchDetailsObj) {
        if item.data.isEmpty{
            return
        }
        if item.design == "Podcast"{
            item.data0 = item.data0!.sorted(by: {$0.playCount! > $1.playCount!})
        }
        self.discoverDataLists.append(item)
        self.discoverDataLists = self.discoverDataLists.sorted(by: {Float($0.sort)! < Float($1.sort)!})
        self.tableView.reloadData()
    }
    
    
    private func getStory(){
        //call api data found ok then add patch
        
        ShadhinCore.instance.api.rewindData { result in
            switch result {
            case .success(let success):
                guard let data = success.data, !data.isEmpty else {return}
                self.rewindData = success
                let story = PatchDetailsObj(_sort: 1.9, name: "Rewind",design: "Story", data0: [])
                self.discoverDataLists.append(story)
                self.discoverDataLists = self.discoverDataLists.sorted(by: {Float($0.sort)! < Float($1.sort)!})
                self.tableView.reloadData()
            case .failure(let failure):
                Log.error(failure.localizedDescription)
            }
        }
        
        
    }
    
    private func getRecentlyPlayed(){
        
        do {
            let data = try RecentlyPlayedDatabase.instance.getDataFromDatabase(fetchLimit: 100)
            if data.count > 0{
                var recentlyPlayedList =  [CommonContent_V0]()
                for item in data{
                    
                    if (
                        //item.contentType?.prefix(2).uppercased() == "PD") &&
                        item.contentType?.prefix(2).uppercased() != "VD"
                    ){
                        let contentTypeData = CommonContent_V0(
                            contentID: item.contentID,
                            image: item.image,
                            title: item.title,
                            playUrl: item.playUrl,
                            artistId: item.artistId,
                            albumId: item.albumId,
                            duration0: item.duration,
                            contentType: item.contentType,
                            fav: item.fav,
                            bannerImg: nil,
                            newBannerImg: nil,
                            isPaid: item.isPaid,
                            _artist: item.artist)
                        recentlyPlayedList.append(contentTypeData)
                    }
                    
                    
                }
                if recentlyPlayedList.count < 1{
                    return
                }
                if recentList == nil{
                    recentList = PatchDetailsObj(_sort: 2.5, name: "Recently Played",design: "Recent", data0: recentlyPlayedList)
                    self.discoverDataLists.append(recentList!)
                    self.discoverDataLists = self.discoverDataLists.sorted(by: {Float($0.sort)! < Float($1.sort)!})
                    self.tableView.reloadData()
                    
                }else{
                    recentList = PatchDetailsObj(_sort: 2.5, name: "Recently Played",design: "Recent", data0: recentlyPlayedList)
                    recentList?.data0?.removeAll()
                    recentList?.data0?.append(contentsOf: recentlyPlayedList)
                    if let recentListIndex = recentListIndex{
                        self.discoverDataLists[recentListIndex.section] = recentList!
                        self.tableView.reloadSections(IndexSet(integer: recentListIndex.section), with: .automatic)
                    }
                }
            }
        } catch {
            Log.error(error.localizedDescription)
        }
        getRecentDownloads()
    }
    
    private func getRecentDownloads(){
        guard ShadhinCore.instance.isUserPro else {return}
        let data = DatabaseContext.shared.getRecentlyDownloadList()
        guard data.count > 0 else {return}
        var recentlyDownloadedList =  [CommonContent_V0]()
        for item in data{
            let contentTypeData = CommonContent_V0(
                contentID: item.contentID,
                image: item.image,
                title: item.title,
                playUrl: item.playUrl,
                artistId: item.artistId,
                albumId: item.albumId,
                duration0: item.duration,
                contentType: item.contentType,
                fav: item.fav,
                bannerImg: nil,
                newBannerImg: nil,
                isPaid: item.isPaid,
                _artist: item.artist)
            recentlyDownloadedList.append(contentTypeData)
        }
        if recentDownloadsList == nil{
            recentDownloadsList = PatchDetailsObj(_sort: 2.6, name: "Downloads",design: "Download", data0: recentlyDownloadedList)
            self.discoverDataLists.append(recentDownloadsList!)
            self.discoverDataLists = self.discoverDataLists.sorted(by: {Float($0.sort)! < Float($1.sort)!})
            self.tableView.reloadData()
            
        }else{
            recentDownloadsList = PatchDetailsObj(_sort: 2.6, name: "Downloadeds",design: "Download", data0: recentlyDownloadedList)
            recentDownloadsList?.data0?.removeAll()
            recentDownloadsList?.data0?.append(contentsOf: recentlyDownloadedList)
            if let recentDownloadIndex = recentDownloadsListIndex{
                self.discoverDataLists[recentDownloadIndex.section] = recentDownloadsList!
                self.tableView.reloadSections(IndexSet(integer: recentDownloadIndex.section), with: .automatic)
            }
        }
    }
    
    private func getMadeForYou(){ //4.5
        ShadhinCore.instance.api.getTopTenTrendingData(type: "s") { (dataModel, err) in
            if err == nil,  var items = dataModel?.data{
                var zeroItem = CommonContent_V0()
                zeroItem.contentID = "-1"
                zeroItem.image = ""
                zeroItem.contentType = "R"
                zeroItem.title = ""
                items.insert(zeroItem, at: 0)
                var madeForYou = PatchDetailsObj(_sort: 4.5, name: "Made Just For You",design: "MadeForYou", data0: items)
                self.byPassToOldCode(&madeForYou)
            }
            
        }
        
    }
    
    private func addDummyData(){
#if DEBUG
        var zeroItem = CommonContent_V0()
        zeroItem.contentID = "-1"
        zeroItem.image = ""
        zeroItem.contentType = "R"
        zeroItem.title = ""
        var madeForYou = PatchDetailsObj(_sort: 4.2, name: "Fun & Play",design: "Games", data0: [zeroItem, zeroItem, zeroItem, zeroItem, zeroItem])
        self.byPassToOldCode(&madeForYou)
#endif
    }
    
    private func checkIfCampaignRunning(){
        ShadhinCore.instance.api.getRunningCampaigns {
            campaigns in
            if campaigns.contains("MusicLiveEvent"){
                self.getConcertData()
            }
            if campaigns.contains("Stream_And_Win"){
                self.getStreamAndWinData()
            }
        }
    }
    
    private func getStreamAndWinData(){
        if self.streamNwinCampaignResponse != nil{
            self.insertStreamAndWinData()
            return
        }
        ShadhinCore.instance.api.getStreamAndWinCampaignData {
            result in
            switch result {
            case .success(let data):
                self.streamNwinCampaignResponse = data
                self.insertStreamAndWinData()
            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func insertStreamAndWinData(){
        var dummy = CommonContent_V0()
        dummy.contentID = "-1"
        dummy.image = ""
        dummy.contentType = "R"
        dummy.title = ""
        var concert = PatchDetailsObj(_sort: 2.4, name: "Stream and Win",design: "Stream_N_Win", data0: [dummy])
        self.byPassToOldCode(&concert)
    }
    
    private func getConcertData(){
        if self.concertEventObj != nil{
            insertConcertTicket()
            return
        }
        ShadhinCore.instance.api.getConcertEventsDetails { _eventData in
            guard let eventData = _eventData else {return}
            self.concertEventObj = eventData
            self.insertConcertTicket()
        }
    }
    
    private func insertConcertTicket(){
        var dummy = CommonContent_V0()
        dummy.contentID = "-1"
        dummy.image = ""
        dummy.contentType = "R"
        dummy.title = ""
        var concert = PatchDetailsObj(_sort: 1.5, name: "Live Concert",design: "LiveConcert", data0: [dummy])
        self.byPassToOldCode(&concert)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
//    
//    private func loadAds(){
//        AppDelegate.shared?.adConsentDone = true
//        guard let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String,
//              !ShadhinCore.instance.isUserPro else {
//            removeAd()
//            return
//        }
//        if useAdProvider == "google"{
//            loadGoogleAd()
//            InterstitialAdmob.instance.loadAd()
//        }else if useAdProvider == "applovin", !InterstitialAdMax.instance.sdkNotInit{
//            loadApplovinAd()
//            InterstitialAdMax.instance.startShowingAd()
//        }else{
//            removeAd()
//        }
//    }
//    
//    private func removeAd(){
//        if !adBannerMax.subviews.isEmpty,
//           let adView = adBannerMax.subviews[0] as? MAAdView{
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
    
    private func loadGoogleAd(){
        //        adBannerView.isHidden = false
        //        let screenWidth = UIScreen.main.bounds.size.width
        //        adBannerView.adUnitID = SubscriptionService.instance.googleBannerAdId
        //        adBannerView.rootViewController = self
        //        var size = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(screenWidth)
        //        size.size.height = 50
        //        adBannerView.adSize = size
        //        adBannerView.load(GADRequest())
        //        adBannerView.delegate = self
//        if !willLoadAds{
//            let shared = NativeAdLoader.shared(self.navigationController!)
//            shared.isReadyToLoadAds { success in
//                if success{
//                    self.willLoadAds = true
//                    self.tableView.reloadData()
//                }
//            }
//        }
    }
    
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
//    
    
//    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
//        Log.error(error.localizedDescription)
//        adBannerView.isHidden = true
//    }
    
    func openBillboardSeg(){
        //print("Press press")
    }
    
//    func openPodcast(episodeId: Int, podcastType: String){
//        let storyBoard = UIStoryboard(name: "PodCast", bundle: nil)
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
    
    func openEventTickets(){
        guard let _concertEventObj = concertEventObj else {return}
        let vc = ConcertTicketsMainVC()
        vc.concertEventObj = _concertEventObj
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func performTaskAfterSubscriptionCheck(){
//#if DEBUG
//        // guard appFirstOpen else {return}
//        //Added by Joy
//        //this is new design for new content show
//        ShadhinCore.instance.api.getPopUpData {
//            data, error in
//            guard let popUp = data,popUp.content.count > 0 else {return}
//
//            NewContentPopUpVC.show(from: self,content: popUp.content) { [self] content in
//                if content.contentType?.uppercased() == "SUBS"{
//                    if !ShadhinCore.instance.isUserLoggedIn{
//                        self.showNotUserPopUp(callingVC: self)
//                        return
//                    }else{
//                        SubscriptionPopUpVC.show(self)
//                    }
//
//                }else{
//                    openContent(content: content)
//                }
//            }
//        }
//
//        appFirstOpen = false
//#else
        guard let vc = MainTabBar.shared, appFirstOpen else {return}
        appFirstOpen = false
      //  PopUpUtil().handelePopUpTasks(vc, self)
//#endif
    }
    
    
    func openContent(content: CommonContentProtocol){
        let type = SMContentType.init(rawValue: content.contentType)
        switch type{
        case .artist:
            let vc = self.goArtistVC(content: content)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .album:
            let vc = self.goAlbumVC(isFromThreeDotMenu: false, content: content)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .song,
                .playlist:
            let vc = self.goPlaylistVC(content: content)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .podcast,
                .podcastVideo:
            let storyBoard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
            if let tabVC = MainTabBar.shared,
               let tabs = tabVC.viewControllers,
               tabs.count > 2,
               let nav = tabs[2] as? UINavigationController,
               let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC,
               let type = content.contentType,
               let contentId = Int(content.contentID ?? ""){
                
                podcastVC.podcastCode = type
                podcastVC.selectedEpisodeID = contentId
                nav.pushViewController(podcastVC, animated: false)
                tabVC.selectedIndex = 2
            }
            break
        case .video:
            break
        case .unknown,.subscription:
            break
        case .LK:
            break
        case .myPlayList:
            break
        case .audioBook:
            break
        case .link:
            break
        }
    }
}

// MARK: - table view

extension DiscoverVC: UITableViewDelegate,UITableViewDataSource {
    
    func isIndexAnAd(index : Int) -> Bool{
        if !willLoadAds{
            return false
        }
        let n = ((Double(index) + 1.0) / 4.0) - Double(getMultiplier(index: index+1))
        return (index > 2) && (n == 0)
    }
    
    func getAdAdjustedSectionIndex(section: Int) -> Int{
        if !willLoadAds{
            return section
        }
        let n = getMultiplier(index: section)
        let adjustedSection = n > 0 ? section - n : section
        return adjustedSection
    }
    
    func getMultiplier(index: Int) -> Int{
        let n = (Double(index) - 3) / 4.0
        return Int((floor(n) + 1))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return discoverDataLists.count + (willLoadAds ? (discoverDataLists.count / 3) : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if isIndexAnAd(index: section){
            return CGFloat.leastNormalMagnitude
        }
        
        let adjustedSection = getAdAdjustedSectionIndex(section: section)
        
        guard adjustedSection > 0 else{ return CGFloat.leastNormalMagnitude}
        
        switch discoverDataLists[adjustedSection].design {
        case "NewReleaseAudio",
            "Stream_N_Win":
            return CGFloat.leastNormalMagnitude
        case "Artist",
            "Playlist",
            "Release",
            "Track",
            "LargeVideo",
            "SmallVideo",
            "Recent",
            "Download",
            "Podcast",
            "PodcastVideo",
            "Spot",
            "Radio",
            "MadeForYou",
            "PDSG",
            "PDPS",
            "Games",
            "LiveConcert":
            return 50
        default:
            return CGFloat.leastNormalMagnitude
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if isIndexAnAd(index: section){
            return nil
        }
        
        let adjustedSection = getAdAdjustedSectionIndex(section: section)
        switch discoverDataLists[adjustedSection].design {
        case "NewReleaseAudio",
            "Stream_N_Win":
            return nil
        case "Artist",
            "Playlist",
            "Release",
            "Track",
            "LargeVideo",
            "SmallVideo",
            "Recent",
            "Download",
            "Podcast",
            "PodcastVideo",
            "Spot",
            "Radio",
            "MadeForYou",
            "PDSG",
            "PDPS",
            "Games",
            "LiveConcert":
            break
        default:
            return nil
        }
        
        let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
        let label = UILabel(frame: CGRect(x:14, y:18, width:tableView.frame.size.width, height:24))
        label.font = UIFont(name: "OpenSans-SemiBold", size: 18.0)
        label.text = self.discoverDataLists[adjustedSection].name ?? ""
        
        let button = UIButton(frame: CGRect(x: view.bounds.maxX - 62 - 8, y: 18, width: 62, height: 24))
        button.tag = adjustedSection
        
        button.titleLabel?.font = UIFont.systemFont(ofSize:12, weight: .medium) // Customize as needed
        button.setTitle("VIEW ALL", for: .normal)
        if #available(iOS 13.0, *) {
            button.setTitleColor(.label, for: .normal)
            button.backgroundColor = UIColor.secondarySystemFill.withAlphaComponent(0.1)
        } else {
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        }
        button.roundCorners(.allCorners, radius: 4)
        
        
        button.addTarget(self, action: #selector(arrowAtion(sender:)), for: .touchUpInside)
        if section != 0 && discoverDataLists[adjustedSection].design != "NewReleaseAudio" {
            view.addSubview(label)
            
        }
        if adjustedSection != 0 &&
            discoverDataLists[adjustedSection].design != "MadeForYou"    &&
            discoverDataLists[adjustedSection].design != "LiveConcert"   &&
            discoverDataLists[adjustedSection].design != "PDSG"          &&
            discoverDataLists[adjustedSection].design != "Podcast"       &&
            //discoverDataLists[adjustedSection].design != "PDPS"          &&
            discoverDataLists[adjustedSection].design != "PodcastVideo"  &&
            discoverDataLists[adjustedSection].design != "Radio"         &&
            discoverDataLists[adjustedSection].design != "Games"         &&
            discoverDataLists[adjustedSection].design != "NewReleaseAudio"{
            view.addSubview(button)
        }
        view.backgroundColor = .clear
        return view
        
    }
    
    @objc private func arrowAtion(sender: UIButton) {
        
        //        if !LoginService.instance.isLoggedIn{
        //            self.showNotUserPopUp(callingVC: self)
        //            return
        //        }
        
        switch discoverDataLists[sender.tag].design {
        case "SmallVideo","LargeVideo":
            let vc = storyboard?.instantiateViewController(withIdentifier: "DiscoverVideoDetailsVC") as! DiscoverVideoDetailsVC
            vc.videoDetailLists = discoverDataLists[sender.tag].data
            self.navigationController?.pushViewController(vc, animated: true)
        case "Spot":
            let vc = storyboard?.instantiateViewController(withIdentifier: "MusicArtistListVC") as! MusicArtistListVC
            vc.discoverModel = discoverDataLists[sender.tag].data[0]
            self.navigationController?.pushViewController(vc, animated: true)
        case "Recent":
            self.navigationController?.pushViewController(RecentlyPlayedSongVCC(), animated: true)
        case "Download":
            self.navigationController?.pushViewController(DownloadVC(), animated: true)
        default:
            let vc = storyboard?.instantiateViewController(withIdentifier: "DiscoverMusicDetailsVC") as! DiscoverMusicDetailsVC
            vc.songDetails = discoverDataLists[sender.tag].data
            vc.designName = discoverDataLists[sender.tag].design ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
            break
        }
        
    }
    
    //    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    //        print("section >= numberOfSections(in: self.tableView) - 2 :\(section) : \(numberOfSections(in: self.tableView) - 2)")
    //        if section >= numberOfSections(in: self.tableView) - 2{
    //            getPagedHomeContent()
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if isIndexAnAd(index: indexPath.section){
//            let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//            if useAdProvider == "google"{
//                let cell =  tableView.dequeueReusableCell(withIdentifier: NavtiveLargeAdTCell.identifier, for: indexPath) as! NavtiveLargeAdTCell
//                if let nav = self.navigationController, let ad = NativeAdLoader.shared(nav).getNativeAd(){
//                    cell.loadAd(nativeAd: ad)
//                }
//                return cell
//                
//            }else if useAdProvider == "applovin"{
//                let cell =  tableView.dequeueReusableCell(withIdentifier: NativeAdMax.identifier, for: indexPath) as! NativeAdMax
//                cell.tableview = self.tableView
//                return cell
//            }
//        }
        
        let adjustedSection = getAdAdjustedSectionIndex(section: indexPath.section)
        
        if adjustedSection == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BillboardTableViewCell", for: indexPath) as! BillboardTableViewCell
            
            guard !self.discoverDataLists.isEmpty else {return .init()}
            cell.configureCell(models: self.discoverDataLists[0].data)
            cell.openSeg = {
                self.openBillboardSeg()
            }
            cell.didTappedBillboardPage { (index) in
                let type = self.discoverDataLists[0].data[index].contentType?.uppercased() ?? ""
                
                if type == "A" {
                    let vc =  self.goArtistVC(content: self.discoverDataLists[0].data[index])
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if type == "P" {
                    
                    let vc = self.goPlaylistVC(content: self.discoverDataLists[0].data[index])
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if type.count > 3 &&
                            (type.prefix(2).uppercased() == "PD" || type.prefix(2).uppercased() == "VD"){
                    let storyBoard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
                    if let tabVC = MainTabBar.shared,
                       let tabs = tabVC.viewControllers,
                       tabs.count > 2,
                       let nav = tabs[2] as? UINavigationController,
                       let contentId = Int(self.discoverDataLists[0].data[index].contentID ?? ""),
                       let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
                        
                        podcastVC.podcastCode = type
                        podcastVC.selectedEpisodeID = contentId
                        nav.pushViewController(podcastVC, animated: false)
                        tabVC.selectedIndex = 2
                    }
                }else if type == "R" || type == "B"  {
                    var vc = UIViewController()
                    vc = self.goAlbumVC(isFromThreeDotMenu: false, content: self.discoverDataLists[0].data[index])
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if type == "V"{
                    self.openVideoPlayer(videoData: [self.discoverDataLists[0].data[index]], index: 0)
                }else if type == "SUBS"{
  
                    if let subscriptionPlatForm = self.discoverDataLists[0].data[index].trackType,
                       var subscriptionPlanName = self.discoverDataLists[0].data[index].type,
                       !subscriptionPlatForm.isEmpty{
                        if subscriptionPlanName.isEmpty{
                            subscriptionPlanName = "common"
                        }
                        self.goSubscriptionTypeVC(false, subscriptionPlatForm, subscriptionPlanName)
                    }
                }
                
            }
            return cell
        }else if discoverDataLists[adjustedSection].design == "NewReleaseAudio"{
            let cell = tableView.dequeueReusableCell(withIdentifier: NewReleaseMain.identifier, for: indexPath) as! NewReleaseMain
            cell.bind(array: discoverDataLists[adjustedSection].data)
            return cell
        }else if discoverDataLists[adjustedSection].design == "LiveConcert"{
            let cell = tableView.dequeueReusableCell(withIdentifier: ConcertTicketsDiscoverTC.identifier, for: indexPath) as! ConcertTicketsDiscoverTC
            if let _concertEvent = concertEventObj{
                cell.bind(_concertEvent)
                cell.buyTicketBtn.setClickListener {
                    self.openEventTickets()
                }
                cell.mainImg.setClickListener {
                    self.openEventTickets()
                }
            }
            return cell
        }else if discoverDataLists[adjustedSection].design == "Stream_N_Win" {
            let cell = tableView.dequeueReusableCell(withIdentifier: WinNStreamCell.identifier, for: indexPath) as! WinNStreamCell
            
            cell.onParticipant  = {[weak self] paymentMethods in
                guard let self = self else {return}
                self.particapetClick(payment: paymentMethods)
                
            }
            cell.gotoLeaderboard = { camapign in
                let leaderBoard = LeaderBoardVC.instantiateNib()
                leaderBoard.paymentMethod = camapign
                leaderBoard.campaignType = self.streamNwinCampaignResponse?.name ?? "Stream_N_Win"
                self.navigationController?.pushViewController(leaderBoard, animated: true)
            }
            if let data = streamNwinCampaignResponse?.data.first?.paymentMethods {
                cell.bind(with: data)
            }
            
            return cell
        }
        else if  discoverDataLists[adjustedSection].design == "Story"{
            let cell = tableView.dequeueReusableCell(withIdentifier: RewindStoryCell.identifier, for: indexPath) as! RewindStoryCell
            cell.setClickListener {
                let rewind = ShadhinRewindVC.instantiateNib()
                rewind.streamingData = self.rewindData?.data ?? []
                rewind.modalPresentationStyle = .fullScreen
                self.present(rewind, animated: true)
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section >= numberOfSections(in: self.tableView) - 2{
            getPagedHomeContent()
        }
        guard let tableViewCell = cell as? DiscoverCell else { return }
        let adjustedSection = getAdAdjustedSectionIndex(section: indexPath.section)
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: adjustedSection)
        tableViewCell.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if UIScreen.main.bounds.height > 667 {
                return 600 + 70
            }else if UIScreen.main.bounds.height > 568 {
                return 520 + 70
            }else {
                return 400 + 70
            }
        }else {
            
//            if isIndexAnAd(index: indexPath.section){
//                //return NativeAdMax.size
//                //                let screenWidth = UIScreen.main.bounds.size.width
//                //                return 136 + (2/3 * (screenWidth - 32))
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    return NavtiveLargeAdTCell.size
//                }else if useAdProvider == "applovin"{
//                    return NativeAdMax.size
//                }else{
//                    return .leastNormalMagnitude
//                }
//            }
            let adjustedSection = getAdAdjustedSectionIndex(section: indexPath.section)
            switch discoverDataLists[adjustedSection].design {
            case "Artist":
                return PopularArtistCell.size.height
            case "Playlist":
                return GenreAndFeaturePlaylistCell.sizePlayList.height
            case "Release","Track","LargeVideo", "SmallVideo":
                return  LatestAlbumCell.size.height
                //            case "SmallVideo":
                //                return 141
            case "Recent":
                recentListIndex = indexPath
                return RecentCell.size.height
            case "Download":
                recentDownloadsListIndex = indexPath
                return RecentCell.size.height
            case "Podcast":
                return PodcastCell.size.height
            case "PodcastVideo":
                return VideoPodcastCell.size.height
            case "Spot":
                return 140
            case "Radio":
                return 182
            case "MadeForYou":
                return MadeForYou.size.height
            case "PDSG":
                return  PodcastCell_2.size.height
            case "PDPS":
                return GenreAndFeaturePlaylistCell.sizePDPS.height * 2 + 5 * 3
            case "NewReleaseAudio":
                return  NewReleaseMain.height
            case "LiveConcert":
                return ConcertTicketsDiscoverTC.size
            case "Games":
                return GamesCCell.size.height
            case "Stream_N_Win":
                if let _ = streamNwinCampaignResponse?.data.first{
                    return WinNStreamCell.HEIGHT
                }
                return 0
            case "Story":
                return RewindStoryCell.HEIGHT
            default:
                return 0
            }
        }
    }
    
}

// MARK: - collection view

extension DiscoverVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return discoverDataLists[collectionView.tag].data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var design = discoverDataLists[collectionView.tag].design
        
        if discoverDataLists.count < collectionView.tag ||
            discoverDataLists[collectionView.tag].data.count < indexPath.item{
            design = "error"
        }
        
        switch design {
        case "Artist":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularArtistCell", for: indexPath) as! PopularArtistCell
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "Playlist":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreAndFeaturePlaylistCell", for: indexPath) as! GenreAndFeaturePlaylistCell
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "Release","Track":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestAlbumCell", for: indexPath) as! LatestAlbumCell
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "Podcast":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodcastCell.identifier, for: indexPath) as! PodcastCell
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "PDSG":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodcastCell_2.identifier, for: indexPath) as! PodcastCell_2
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "Recent", "Download":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCell.identifier, for: indexPath) as! RecentCell
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
            //        case "SmallVideo":
            //            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMusicVideoCell", for: indexPath) as! NewMusicVideoCell
            //            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            //            return cell
        case "LargeVideo", "SmallVideo":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingVideoCell", for: indexPath) as! TrendingVideoCell
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "PodcastVideo":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoPodcastCell", for: indexPath) as! VideoPodcastCell
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "Spot":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotLightCell", for: indexPath) as! SpotLightCell
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "Radio":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RadioCell", for: indexPath) as! RadioCell
            cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "MadeForYou":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MadeForYou.identifier, for: indexPath) as! MadeForYou
            if indexPath.row == 0{
                cell.initZeroCell()
            }else{
                cell.configureCell(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            }
            return cell
        case "PDPS":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreAndFeaturePlaylistCell", for: indexPath) as! GenreAndFeaturePlaylistCell
            cell.configureCellPD(model: discoverDataLists[collectionView.tag].data[indexPath.item])
            return cell
        case "Games":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GamesCCell.identifier, for: indexPath) as! GamesCCell
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //        if !LoginService.instance.isLoggedIn{
        //            self.showNotUserPopUp(callingVC: self)
        //            return
        //        }
        
        switch discoverDataLists[collectionView.tag].design {
        case "Artist","Spot":
            let vc1 = goArtistVC(content: discoverDataLists[collectionView.tag].data[indexPath.item])
            vc1.artistList = discoverDataLists[collectionView.tag].data
            vc1.selectedArtistList = indexPath.row
            navigationController?.pushViewController(vc1, animated: true)
            break
        case "SmallVideo","LargeVideo":
            if ConnectionManager.shared.isNetworkAvailable{
                openVideoPlayer(videoData: discoverDataLists[collectionView.tag].data, index: indexPath.item)
            }else{
                let vc = NoInternetPopUpVC.instantiateNib()
                vc.gotoDownload =  {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.songs, type: .None)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                }
                vc.retry = {[weak self] in
                    guard let self = self else {return}
                    openVideoPlayer(videoData: discoverDataLists[collectionView.tag].data, index: indexPath.item)
                    SwiftEntryKit.dismiss()
                }
                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
            }
            
            break
        case "PodcastVideo":
            let track = discoverDataLists[collectionView.tag].data[indexPath.row]
            if track.isPaid ?? false{
                if !ShadhinCore.instance.isUserPro{
                    //self.goSubscriptionTypeVC()
                    SubscriptionPopUpVC.show(self)
                    return
                }
            }
            
            if ConnectionManager.shared.isNetworkAvailable{
                PodcastYoutubeVC.openLivePodcast(self, track)
            }else{
                let vc = NoInternetPopUpVC.instantiateNib()
                vc.gotoDownload =  {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.songs, type: .None)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                }
                vc.retry = {[weak self] in
                    guard let self = self else {return}
                    PodcastYoutubeVC.openLivePodcast(self, track)
                    SwiftEntryKit.dismiss()
                }
                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
            }
        
            SMAnalytics.viewContent(contentName: track.title ?? "", contentID: track.contentID ?? "", contentType: track.contentType ?? "")
        case "Radio":
            if ConnectionManager.shared.isNetworkAvailable{
                ShadhinCore.instance.api.getAlbumOrPlaylistOrSingleDataById(
                    ContentID: discoverDataLists[collectionView.tag].data[indexPath.row].contentID ?? "",
                    mediaType: .playlist) { (playlists, err, image) in
                        guard let playlist = playlists else {return}
                        self.openMusicPlayerV3(musicData: playlist, songIndex: indexPath.row, isRadio: true)
                    }
            }else{
                let vc = NoInternetPopUpVC.instantiateNib()
                vc.gotoDownload =  {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.songs, type: .None)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                }
                vc.retry = {[weak self] in
                    guard let self = self else {return}
                    if ConnectionManager.shared.isNetworkAvailable{
                        ShadhinCore.instance.api.getAlbumOrPlaylistOrSingleDataById(
                            ContentID: discoverDataLists[collectionView.tag].data[indexPath.row].contentID ?? "",
                            mediaType: .playlist) { (playlists, err, image) in
                                guard let playlist = playlists else {return}
                                self.openMusicPlayerV3(musicData: playlist, songIndex: indexPath.row, isRadio: true)
                                SwiftEntryKit.dismiss()
                            }
                    }
                }
                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
            }
            
            break
        case "Podcast":
            let track = discoverDataLists[collectionView.tag].data[indexPath.row]
            if track.isPaid ?? false{
                if !ShadhinCore.instance.isUserPro{
                    //self.goSubscriptionTypeVC()
                    SubscriptionPopUpVC.show(self)
                    return
                }
            }
            
            if ConnectionManager.shared.isNetworkAvailable{
                self.openMusicPlayerV3(musicData: [track], songIndex: 0, isRadio: false,rootModel: track)
            }else{
                let vc = NoInternetPopUpVC.instantiateNib()
                vc.gotoDownload =  {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.audioPodcast, type: .PodCast)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                }
                vc.retry = {[weak self] in
                    guard let self = self else {return}
                    self.openMusicPlayerV3(musicData: [track], songIndex: 0, isRadio: false,rootModel: track)
                    SwiftEntryKit.dismiss()
                }
                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
            }
            
            
            break
        case "PDSG":
            let storyBoard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
            if let tabVC = MainTabBar.shared, let nav = tabVC.viewControllers?[2] as? UINavigationController, let contentId = Int(self.discoverDataLists[collectionView.tag].data[indexPath.item].contentID ?? ""),
               let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
                
                podcastVC.podcastCode = "PDSG"
                podcastVC.selectedEpisodeID = contentId
                nav.pushViewController(podcastVC, animated: false)
                tabVC.selectedIndex = 2
                
            }
            break
        case "Recent", "Download":
            let model = discoverDataLists[collectionView.tag].data[indexPath.item]
            switch SMContentType.init(rawValue: model.contentType){
            case .artist:
                let vc =  self.goArtistVC(content: model)
                self.navigationController?.pushViewController(vc, animated: true)
            case .album:
                let vc = self.goAlbumVC(isFromThreeDotMenu: false, content: model)
                self.navigationController?.pushViewController(vc, animated: true)
            case .podcast:
                let storyBoard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
                if let tabVC = MainTabBar.shared,
                   let tabs = tabVC.viewControllers,
                   tabs.count > 2,
                   let nav = tabs[2] as? UINavigationController,
                   let contentId = Int(model.albumId ?? ""),
                   let type = model.contentType?.uppercased(),
                   let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
                    
                    podcastVC.podcastCode = type
                    podcastVC.selectedEpisodeID = contentId
                    nav.pushViewController(podcastVC, animated: false)
                    tabVC.selectedIndex = 2
                    SMAnalytics.viewContent(contentName: model.title ?? "", contentID: String(contentId), contentType: type)
                }
            case .playlist, .song:
                let vc = self.goPlaylistVC(content: model)
                self.navigationController?.pushViewController(vc, animated: true)
            default :
                Log.info("content type \(String(describing: model.contentType)) not configured in recent")
            }
        case "Playlist","Track", "Release":
            if discoverDataLists[collectionView.tag].data[indexPath.item].contentType?.uppercased() == "R"{
                let vc3 = goAlbumVC(isFromThreeDotMenu: false, content: discoverDataLists[collectionView.tag].data[indexPath.item])
                navigationController?.pushViewController(vc3, animated: true)
            }else{
                let item = discoverDataLists[collectionView.tag].data[indexPath.item]
                var suggestedPlaylist : [CommonContentProtocol] = []
                for playlist in discoverDataLists[collectionView.tag].data{
                    if playlist.contentType?.uppercased() == "P"{
                        suggestedPlaylist.append(playlist)
                    }
                }
                let vc2 = goPlaylistVC(content: item, suggestedPlaylists: suggestedPlaylist)
                navigationController?.pushViewController(vc2, animated: true)
            }
            
            break
        case "MadeForYou":
            if indexPath.item == 0{
                let fv = FavouriteVC()
                navigationController?.pushViewController(fv, animated: true)
            }else{
                var list = discoverDataLists[collectionView.tag].data
                list.remove(at: 0)
                self.openMusicPlayerV3(musicData: list, songIndex: indexPath.row - 1, isRadio: false,rootModel: list[indexPath.row - 1])
            }
            break
        case "PDPS":
            let track = discoverDataLists[collectionView.tag].data[indexPath.row]
            guard let type = track.contentType, type.count > 3 else {
                return
            }
            let storyBoard = UIStoryboard(name: "PodCast", bundle: Bundle.ShadhinMusicSdk)
            if let tabVC = MainTabBar.shared,
               let tabs = tabVC.viewControllers,
               tabs.count > 2, let nav = tabs[2] as? UINavigationController,
               let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
                
                podcastVC.podcastCode = type
                nav.pushViewController(podcastVC, animated: false)
                tabVC.selectedIndex = 2
                
                SMAnalytics.viewContent(contentName: track.title ?? "", contentID: track.contentID ?? "", contentType: type)
            }
            break
        case "Games":
            let track = discoverDataLists[collectionView.tag].data[indexPath.row]
            let vc = GamesVC()
            vc.item = track
            self.present(vc, animated: true)
            break
        default:
            let vc3 = goAlbumVC(isFromThreeDotMenu: false, content: discoverDataLists[collectionView.tag].data[indexPath.item])
            navigationController?.pushViewController(vc3, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 11, bottom: 0, right: 11)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        cell.alpha = 0
        UIView.animate(withDuration: 0.4) {
            cell.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = UIScreen.main.bounds
        
        switch discoverDataLists[collectionView.tag].design {
        case "Artist":
            return PopularArtistCell.size
        case "Playlist":
            return GenreAndFeaturePlaylistCell.sizePlayList
        case "Release","Track":
            return LatestAlbumCell.size
        case "Recent", "Download":
            return RecentCell.size
        case "Podcast":
            return PodcastCell.size
        case "PodcastVideo":
            return VideoPodcastCell.size
        case "PDSG":
            return PodcastCell_2.size
            //        case "SmallVideo":
            //            return CGSize(width: 158, height: 141)
        case "LargeVideo", "SmallVideo":
            return CGSize(width: 290, height: 172)
        case "Spot":
            return CGSize(width: size.width - 22, height: 140)
        case "MadeForYou":
            return MadeForYou.size
        case "PDPS":
            return GenreAndFeaturePlaylistCell.sizePDPS
        case "Games":
            return GamesCCell.size
        default:
            return CGSize(width: 138, height: 165)
        }
    }
}


//
//extension DiscoverVC: MAAdViewAdDelegate{
//    func didExpand(_ ad: MAAd) {
//        //ignore
//    }
//    
//    func didCollapse(_ ad: MAAd) {
//        //ignore
//    }
//    
//    func didLoad(_ ad: MAAd) {
//        adBannerMax.isHidden = false
//        //ignore
//    }
//    
//    func didDisplay(_ ad: MAAd) {
//        //ignore
//    }
//    
//    func didHide(_ ad: MAAd) {
//        //ignore
//    }
//    
//    func didClick(_ ad: MAAd) {
//        //ignore
//    }
//    
//    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
//        adBannerMax.removeAllSubviews()
//        adBannerMax.isHidden = true
//        Log.error(error.message)
//    }
//    
//    func didFail(toDisplay ad: MAAd, withError error: MAError) {
//        adBannerMax.removeAllSubviews()
//        adBannerMax.isHidden = true
//        Log.error(error.message)
//    }
//}

extension DiscoverVC{
    func particapetClick(payment : PaymentMethod){
        if ShadhinCore.instance.isUserPro{
            if let telco = PaymentGetwayType(rawValue: payment.name.uppercased()){
                if telco == .ROBI{
                    ShadhinCore.instance.api.showAlert(title: "Stream and Win", msg: "This campaign only for Robi and Airtel subscribed users")
                }else{
                    ShadhinCore.instance.api.showAlert(title: "Stream and Win", msg: "This campaign only for \(telco.rawValue) subscribed users")
                }
                
            }
            
        }else if ShadhinDefaults().userMsisdn.count > 0{
            if let telco = PaymentGetwayType(rawValue: payment.name.uppercased()){
                if telco == .ROBI && ShadhinCore.instance.isRobi() || telco == .GP && ShadhinCore.instance.isGP() || telco == .BL && ShadhinCore.instance.isBanglalink(){
                    //subscription pop up show for telco
                    if telco == .ROBI{
                        self.goSubscriptionTypeVC(false,"robi_airtel")
                    }else if telco == .GP{
                        self.goSubscriptionTypeVC(false,"gp")
                    }else if telco == .BL{
                        self.goSubscriptionTypeVC(false,"banglalink")
                    }
                    
                }else if telco == .Bkash{
                    //subscription pop up show bkash
                    self.goSubscriptionTypeVC(false,"bkash")
                }else if telco == .SSL{
                    //subscription pop up ssl
                    self.goSubscriptionTypeVC(false,"ssl")
                }else if telco == .Nagad{
                    //subscription pop up show nagad
                    //self.goSubscriptionTypeVC(false,"gp")
                }else{
                    ShadhinCore.instance.api.showAlert(title: "Stream and Win", msg: "This campaign only for \(telco.rawValue) subscribed users")
                }
            }
        }else if ShadhinDefaults().userMsisdn.count == 0{
            //number input pop up show
            if let telco = PaymentGetwayType(rawValue: payment.name.uppercased()){
                if telco == .ROBI || telco == .GP  || telco == .BL {
                    //show number input field
               //     LinkMsisdnVC.show("Phone number is required to proceed with BD subscriptions...")
                }
            }
        }
    }
}
