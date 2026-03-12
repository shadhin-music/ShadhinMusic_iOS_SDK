//
//  VideoVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/18/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

let videoVCViewImgs = ["ic_video_favorite","ic_video_watch_later","ic_video_history", "ic_download_video_active"]
let videoVCViewTitles = ["Favorite","Watch Later","History", "Download"]


class VideoVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var adBannerMax: UIView!

    private var videoModel = [PatchDetailsObj]()
    
    private let storyBoard = UIStoryboard(name: "Discover", bundle:Bundle.ShadhinMusicSdk)
    
    private var refreshControl = UIRefreshControl()
    
    var willLoadAds = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .customBGColor()
//        tableView.register(NavtiveLargeAdTCell.nib, forCellReuseIdentifier: NavtiveLargeAdTCell.identifier)
//        tableView.register(NativeAdMax.nib, forCellReuseIdentifier: NativeAdMax.identifier)
        refreshControl.addTarget(self, action: #selector(tableViewRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.contentInsetAdjustmentBehavior = .never
        
        LoadingIndicator.initLoadingIndicator(view: self.view)
        
        dataWithCache()
    }
    
    @objc private func tableViewRefresh() {
        videoModel.removeAll()
        dataWithCache()
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
        
        if try! Reachability().connection == .unavailable {
            var style = ToastManager.shared.style
            style.messageFont = UIFont.systemFont(ofSize: 14)
            style.messageAlignment = .center
            self.view.makeToast("No network available.please check your WiFi or Data connection!" ,style: style)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
       // loadAds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func dataWithCache() {
        if try! !(Reachability().connection == .unavailable) {
            if Disk.exists("Videos/VideoData.json", in: .caches) {
                try? Disk.remove("Videos/VideoData.json", from: .caches)
            }
            getDataFromServer()
        }else {
            if Disk.exists("Videos/VideoData.json", in: .caches) {
                let videoData = try! Disk.retrieve("Videos/VideoData.json", from: .caches, as: [PatchDetailsObj].self)
                self.videoModel = videoData
                self.tableView.reloadData()
                LoadingIndicator.stopAnimation()
            }else {
                getDataFromServer()
            }
        }
    }
    
    private func getDataFromServer() {
        LoadingIndicator.startAnimation()
        ShadhinCore.instance.api.getVideoPatches{ (data, error) in
            if let err = error {
                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                LoadingIndicator.stopAnimation()
            }
            
            data?.forEach({ (data) in
                self.getCategoryByContentType(name: data.name,code: data.code, type: data.contentType, sort: data.sort)
            })
        }
    }
    
    private func getCategoryByContentType(name: String,code: String,type: String,sort: String) {
        ShadhinCore.instance.api.getPatchDetailsBy(code: code, contentType: type, completion: { (typeData, err) in
            
            if err != nil {
                ConnectionManager.shared.networkErrorHandle(err: err, view: self.view)
                LoadingIndicator.stopAnimation()
            } else {
                
                guard let alldata = typeData,!alldata.isEmpty else {return}
                self.videoModel.append(PatchDetailsObj(_sort: Float(sort)!, name: name,design: nil, data1: alldata))
                self.videoModel = self.videoModel.sorted(by: {$0._sort! < $1._sort!})
                self.tableView.reloadData()
                
                try? Disk.save(self.videoModel, to: .caches, as: "Videos/VideoData.json")
                LoadingIndicator.stopAnimation()
            }
        })
    }
    
    /*private func loadAds(){
        if ShadhinCore.instance.isUserPro {
            removeAd()
            return
        }
        guard let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String else {
            adBannerView.isHidden = true
            return
        }
        if useAdProvider == "google"{
                  loadGoogleAd()
        }else if(useAdProvider == "applovin"){
            loadApplovinAd()
        }else{
            removeAd()
        }
    }*/
    
   /* private func removeAd(){
        if !adBannerMax.subviews.isEmpty,
            let adView = adBannerMax.subviews[0] as? MAAdView{
            adView.stopAutoRefresh()
            adView.isHidden = true
        }
        adBannerView.isHidden = true
        adBannerMax.isHidden = true
        if willLoadAds{
            willLoadAds = false
            tableView.reloadData()
        }
    }*/
    
   /* private func loadGoogleAd(){
//        adBannerView.isHidden = false
//        let screenWidth = UIScreen.main.bounds.size.width
//        adBannerView.adUnitID = SubscriptionService.instance.googleBannerAdId
//        adBannerView.rootViewController = self
//        var size = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(screenWidth)
//        size.size.height = 50
//        adBannerView.adSize = size
//        adBannerView.load(GADRequest())
//        adBannerView.delegate = self
        if !willLoadAds{
            NativeAdLoader.shared(self.navigationController!).isReadyToLoadAds { success in
                if success{
                    self.willLoadAds = true
                    self.tableView.reloadData()
                }
            }
        }
    } */
    
   /* private func loadApplovinAd(){
        if !willLoadAds{
            willLoadAds = true
            tableView.reloadData()

        }
        guard adBannerMax.subviews.isEmpty else {return}
        let adView = MAAdView(adUnitIdentifier: AdConfig.maxBannerAdId)
        adView.delegate = self
        let height: CGFloat = 50
        let width: CGFloat = UIScreen.main.bounds.width
        adView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        adBannerMax.addSubview(adView)
        adView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.top.equalTo(strongSelf.adBannerMax.snp.top)
            make.left.equalTo(strongSelf.adBannerMax.snp.left)
            make.right.equalTo(strongSelf.adBannerMax.snp.right)
            make.bottom.equalTo(strongSelf.adBannerMax.snp.bottom)
        }
        adView.loadAd()
    }*/
    
//    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
//        adBannerView.isHidden = true
//    }
}

// MARK: - Table View

extension VideoVC: UITableViewDelegate,UITableViewDataSource {
    
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
        var count = videoModel.count + 1
        if willLoadAds{
            let adsCountInt = count / 3
            count += adsCountInt
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.zero
        }else {
            if isIndexAnAd(index: section){
                return CGFloat.zero
            }
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !(section == 0) {
            
            if isIndexAnAd(index: section){
                return nil
            }
            let adjustedSection = getAdAdjustedSectionIndex(section: section)
            
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:50))
            let label = UILabel(frame: CGRect(x:14, y:10, width:tableView.frame.size.width, height:30))
            label.font = UIFont.boldSystemFont(ofSize: 20)
            
            let button = UIButton(frame: CGRect(x: view.bounds.maxX - 62 - 8, y: 18, width: 62, height: 24))
            button.tag = adjustedSection - 1
         //   button.titleLabel?.font =  UIFont(name:"", size: 12)
            button.titleLabel?.font = UIFont.systemFont(ofSize:12, weight: .medium) // Customize as needed
            button.setTitle("VIEW ALL", for: .normal)
            
            if #available(iOS 13.0, *) {
                button.setTitleColor(.label, for: .normal)
                button.backgroundColor = UIColor.secondarySystemFill.withAlphaComponent(0.1)
            } else {
                // Fallback on earlier versions
                button.setTitleColor(.black, for: .normal)
                button.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
            button.roundCorners(.allCorners, radius: 4)
            button.addTarget(self, action: #selector(arrowAtion(sender:)), for: .touchUpInside)
            label.text = self.videoModel[adjustedSection - 1].name ?? ""
            view.addSubview(label)
            view.addSubview(button)
            view.backgroundColor = .clear
            return view
        }else {
            return nil
        }
    }
    
    @objc private func arrowAtion(sender: UIButton) {
        let vc = storyBoard.instantiateViewController(withIdentifier: "DiscoverVideoDetailsVC") as! DiscoverVideoDetailsVC
        vc.videoDetailLists = videoModel[sender.tag].data
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isIndexAnAd(index: indexPath.section){
           // let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//            if useAdProvider == "google"{
//                let cell =  tableView.dequeueReusableCell(withIdentifier: NavtiveLargeAdTCell.identifier, for: indexPath) as! NavtiveLargeAdTCell
//                if let nav = self.navigationController, let ad = NativeAdLoader.shared(nav).getNativeAd(){
//                    cell.loadAd(nativeAd: ad)
//                }
//                return cell
//
//            }else if useAdProvider == "applovin"{
//                let cell =  tableView.dequeueReusableCell(withIdentifier: NativeAdMaxSmall.identifier, for: indexPath) as! NativeAdMaxSmall
//                cell.tableview = self.tableView
//                return cell
//            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoVCCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? VideoVCCell else { return }
        let adjustedSection = getAdAdjustedSectionIndex(section: indexPath.section)
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: adjustedSection)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 260
        default:
//            if isIndexAnAd(index: indexPath.section){
//                let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String
//                if useAdProvider == "google"{
//                    return NavtiveLargeAdTCell.size
//                }else if useAdProvider == "applovin"{
//                    return NativeAdMaxSmall.size
//                }else{
//                    return .leastNormalMagnitude
//                }
//            }
            return 230
        }
    }
}

// MARK: - Collection View

extension VideoVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 0 {
            return videoVCViewImgs.count
        }
        
        return videoModel[collectionView.tag - 1].data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoVCViewCell", for: indexPath) as! VideoVCViewCell
            cell.imgView.image = UIImage(named: videoVCViewImgs[indexPath.item],in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            cell.viewLbl.text = videoVCViewTitles[indexPath.item]
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LargeVideoCell", for: indexPath) as! LargeVideoCell
            cell.configureCell(model: videoModel[collectionView.tag - 1].data[indexPath.item])
            //this never call added for previous version has this
            cell.didThreeDotMenuTapped {
                let menu = MoreMenuVC()
                menu.openForm = .Video
                menu.menuType = .Video
                menu.data = self.videoModel[collectionView.tag - 1].data[indexPath.item]
                menu.delegate = self
                
                let height = MenuLoader.getHeightFor(vc: .Video, type: .Video, operators: [])
                var attribute = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                attribute.entryBackground = .color(color: .clear)
                attribute.border = .none

                SwiftEntryKit.display(entry: menu, using: attribute)
                
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        cell.alpha = 0
        UIView.animate(withDuration: 0.4) {
            cell.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 0:
            switch indexPath.item {
            case 0:
                // TODO: -
                let vc = storyboard?.instantiateViewController(withIdentifier: "VideoFavVC") as! VideoFavVC
                navigationController?.pushViewController(vc, animated: true)
            case 1:
                goWatchLaterAndHistoryVC(title: "Watch Later", isHistory: false)
            case 2:
                goWatchLaterAndHistoryVC(title: "History", isHistory: true)
            case 3:
                goVideoDownloadVC(title: "Download")
            default:
                break
            }
        default:
            if ConnectionManager.shared.isNetworkAvailable{
                openVideoPlayer(videoData: videoModel[collectionView.tag - 1].data, index: indexPath.row)
            }else{
                let vc = NoInternetPopUpVC.instantiateNib()
                vc.gotoDownload =  {[weak self] in
                    guard let self = self else {return}
                    if self.checkProUser(){
                        let vc = DownloadVC.instantiateNib()
                        vc.selectedDownloadSeg = .init(title: ^String.Downloads.songs, type: .None)
                        self.navigationController?.pushViewController(vc, animated: true)
                        SwiftEntryKit.dismiss()
                    }
                }
                vc.retry = {[weak self] in
                    guard let self = self else {return}
                    openVideoPlayer(videoData: videoModel[collectionView.tag - 1].data, index: indexPath.row)
                    SwiftEntryKit.dismiss()
                }
                SwiftEntryKit.display(entry: vc, using: SwiftEntryKitAttributes.bottomAlertAttributes(viewHeight: NoInternetPopUpVC.HEIGHT))
            }
        }
    }
    
    private func goWatchLaterAndHistoryVC(title: String,isHistory: Bool) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WatchLaterAndHistoryVC") as! WatchLaterAndHistoryVC
        vc.viewTitle = title
        vc.isHistory = isHistory
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goVideoDownloadVC(title: String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "VideoDownloadVC") as! VideoDownloadVC
        vc.viewTitle = title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return .init()}
        
        let size = UIScreen.main.bounds
        switch collectionView.tag {
        case 0:
            layout.scrollDirection = .vertical
            let cellDimension = size.width - 22
            return CGSize(width: cellDimension, height: 60)
        default:
            layout.scrollDirection = .horizontal
            return CGSize(width: 320, height: 230)
        }
    }
}

//this delegate never called
extension VideoVC : MoreMenuDelegate{
    func onDownload(content: CommonContentProtocol, type: MoreMenuType) {
        
    }
    
    func onRemoveDownload(content: CommonContentProtocol, type: MoreMenuType) {
        
    }
    
    func onRemoveFromHistory(content: CommonContentProtocol) {
        
    }
    
    func gotoArtist(content: CommonContentProtocol) {
        
    }
    
    func gotoAlbum(content: CommonContentProtocol) {
        
    }
    
    func addToPlaylist(content: CommonContentProtocol) {
        
    }
    
    func shareMyPlaylist(content: CommonContentProtocol) {
        
    }
    
    func openQueue() {
        
    }
    
    func openSleepTimer() {
    
    }
}
