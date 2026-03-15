//
//  MyMusicVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/24/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import CoreData

private enum MyMusicSection: Int, CaseIterable {
    case header = 0
    case ad
    case recent
}

class MyMusicVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adBannerMax: UIView!
    
    private var recentPlays = [CommonContent_V7]()
    private var serviceID: String?
    private var subsType: String?
    private var appleSubsType: String?
    private var referalData : ReferalObj?
    private var shareCampaignRunning = false
    private var isCouponRunning = false
    private var isReferRunning = false
    private var isUserBD = false
    let tagId = "d55d58a0"
    var cashBackStatus = "unknown"
    private var shouldShowVmaxAd: Bool = true
    private var adHeight: CGFloat = 0

    var promoArray : [String]?{
        didSet{
            checkIsCouponRunning()
            checkIsReferRunning()
        }
    }
    
    private var page : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBGColor()
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.showsVerticalScrollIndicator = false
        tableView.showsLargeContentViewer = false
        tableView.register(VmaxMyProfileTVCell.nib, forCellReuseIdentifier: VmaxMyProfileTVCell.identifier)
        getRunningPromos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        page = 1
        getData()
        getReferalData()
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
    }
    
    private func getRunningPromos(){
        ShadhinCore.instance.api.getRunningCampaigns {
            promoArray in
            if promoArray.count > 0{
                self.promoArray = promoArray
            }
        }
    }
    
    static func getViewController() -> MyMusicVC {
        let storyboard = UIStoryboard(name: "MyMusic", bundle: Bundle.ShadhinMusicSdk)
        return storyboard.instantiateViewController(withIdentifier: "MyMusicVC") as! MyMusicVC
    }
    
    private func checkIsCouponRunning(){
        if ShadhinCore.instance.isUserPro {
            isCouponRunning = false
            return
        }
        isCouponRunning = (promoArray?.contains("Coupon") ?? false)
        if isCouponRunning{
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }

    private func checkIsReferRunning(){
        isReferRunning = (promoArray?.contains("Referral") ?? false)
        if isReferRunning, referalData == nil{
            getReferalData()
        }
    }
    
    private func checkIsShareCampaignRunning(){
        shareCampaignRunning = (promoArray?.contains("UserPlayListShare") ?? false)
        if shareCampaignRunning{
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
    private func getReferalData(){
        if !isUserBD{
            return
        }
        ShadhinCore.instance.api.getReferalData { (data) in
            guard let data = data else {return}
            self.referalData = data
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
    func getCBackStatus(){
        ShadhinCore.instance.api.getCashBackStatus{ (value) in
            self.cashBackStatus = value
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
        }
    }
    
//    private func getData() {
//        do {
//            let data = try RecentlyPlayedDatabase.instance.getDataFromDatabase(fetchLimit: 50)
//            self.recentPlays.removeAll()
//            for item in data{
//                if !(item.contentType?.prefix(2).uppercased() == "PD") &&
//                    !(item.contentType?.prefix(2).uppercased() == "VD"){
//                    self.recentPlays.append(item)
//                }
//            }
//            //self.recentPlays = data
//            self.tableView.reloadData()
//        }catch {
//            print(error.localizedDescription)
//        }
//    }
    private func getData() {
        self.recentPlays.removeAll()
        do {
            let datas = try RecentlyPlayedDatabase.instance.getDataFromDatabase(fetchLimit: 15)
            self.recentPlays = datas.filter({ dcm in
                if  dcm.contentType!.uppercased().hasPrefix("VD")
//                        || dcm.contentType!.uppercased().hasPrefix("PD")
                {
                    return false
                }
                return true
            })
            self.tableView.reloadData()
        } catch {
            Log.error(error.localizedDescription)
        }
    }
//    private func getRecentPlayData(){
//        ShadhinCore.instance.api.recentlyPlayedGetAll(with: page) { result in
//            switch result{
//            case .success(let obj):
//                self.recentPlays.append(contentsOf: obj.data.map({ rpm in
//                    return rpm.getDatabaseContentModel()
//                }))
//                self.tableView.reloadData()
//            case .failure(let error):
//                Log.error(error.localizedDescription)
//                self.view.makeToast(error.localizedDescription)
//            }
//            self.view.isUserInteractionEnabled = true
//        }
//    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc func showAllRecentlyPlayedSong(sender: UIButton) {
        //self.performSegue(withIdentifier: "toRecentlyPlayedSongVC", sender: nil)
        self.navigationController?.pushViewController(RecentlyPlayedSongVCC(), animated: true)
    }
    
//    func openProfile(){
//        let vc = MyProfileVC()
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let settingVC = segue.destination as? SettingsVC else {return}
//        if let serviceID = serviceID, let subsType = subsType, let appleSubsType = appleSubsType {
//            settingVC.serviceID = serviceID
//            settingVC.subscriptionType = subsType
//            settingVC.appleSubsType = appleSubsType
//        }
    }
    
//    private func loadAds(){
//        if ShadhinCore.instance.isUserPro {
//            removeAd()
//            return
//        }
//        guard let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String else {
//            removeAd()
//            return
//        }
//        if useAdProvider == "google"{
//            loadGoogleAd()
//        }else if(useAdProvider == "applovin"){
//            loadApplovinAd()
//        }else{
//            removeAd()
//        }
//    }
    
//    private func removeAd(){
//        if !adBannerMax.subviews.isEmpty,
//            let adView = adBannerMax.subviews[0] as? MAAdView{
//            adView.stopAutoRefresh()
//            adView.isHidden = true
//        }
//        adBannerView.isHidden = true
//        adBannerMax.isHidden = true
//    }
    
    private func loadGoogleAd(){
//        adBannerView.isHidden = false
//        let screenWidth = UIScreen.main.bounds.size.width
//        adBannerView.adUnitID = SubscriptionService.instance.googleBannerAdId
//        adBannerView.rootViewController = self
//        adBannerView.adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(screenWidth)
//        adBannerView.load(GADRequest())
//        adBannerView.delegate = self
    }
//    
//    private func loadApplovinAd(){
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
    
//    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
//        adBannerView.isHidden =  true
//    }
    
}

// MARK: - Table View

extension MyMusicVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return activeSections.count
    }
    
    private var activeSections: [MyMusicSection] {
        
        var sections: [MyMusicSection] = [.header]
        
        if canShowAd() && shouldShowVmaxAd {
            sections.append(.ad)
        }
        
        sections.append(.recent)
        
        return sections
    }
    
    private func sectionType(for section: Int) -> MyMusicSection {
        return activeSections[section]
    }
    
    private func canShowAd() -> Bool {
        return ShadhinGP.shared.isVmaxInitialized &&
        !ShadhinCore.instance.isUserPro &&
        VMAX_AD_ITEM_DATA.contains(where: { $0.adId == tagId })
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        switch sectionType(for: section) {
            
        case .header:
            return 1
            
        case .ad:
            return 1
            
        case .recent:
            return recentPlays.isEmpty ? 1 : recentPlays.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch sectionType(for: indexPath.section) {
            
        case .header:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMusicViewCell") as! MyMusicViewCell
            // cell.checkAppleSubscription()
            if isUserBD && isReferRunning{
                //cell.referalViewHeight.constant = 56
                cell.referalView.isHidden = false
                if let data = referalData{
                    cell.referalPointsEarned.text = data.data.totalReferrals
                }
            }else{
                cell.referalView.isHidden = true
                //cell.referalViewHeight.constant = 0
            }
            //            cell.userImageView.setClickListener {
            //               // self.openProfile()
            //            }
            //            cell.userHolder.setClickListener {
            //                //self.openProfile()
            //            }
            cell.couponHolder.isHidden = !isCouponRunning
            
            cell.couponHolder.setClickListener {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CouponVC"){
                    
                    let height: CGFloat = 346
                    var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 0)
                    attributes.entryBackground = .color(color: .clear)
                    
                    attributes.border = .none
                    
                    let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
                    let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
                    attributes.positionConstraints.keyboardRelation = keyboardRelation
                    SwiftEntryKit.display(entry: vc, using: attributes)
                }
                
            }
            
            cell.referalView.setClickListener {
                let storyBoard = UIStoryboard(name: "Referal", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "ReferalMainVC")
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.didMyMusicViewClicked { (index) in
                if index == 22 {
                    self.serviceID = cell.bKashServiceID ?? ""
                    self.subsType  = cell.subsType ?? ""
                    self.appleSubsType =  cell.appleSubsType ?? ""
                    let story = UIStoryboard(name: "MyMusic", bundle: Bundle.ShadhinMusicSdk)
                    if let settingVC = story.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC{
                        if let serviceID = self.serviceID, let subsType = self.subsType, let appleSubsType = self.appleSubsType {
                            settingVC.serviceID = serviceID
                            settingVC.subscriptionType = subsType
                            settingVC.appleSubsType = appleSubsType
                            self.navigationController?.pushViewController(settingVC, animated: true)
                        }
                    }
                    
                } else {
                    self.goSubscriptionTypeVC()
                    //SubscriptionPopUpVC.show(self)
                }
            }
            
            cell.didMyMusicCategoriesClicked { (index) in
                self.countButtonTouch()
                switch index {
                case 1:
                    self.navigationController?.pushViewController(RecentlyPlayedSongVCC(), animated: true)
                case 15:
                    guard ShadhinCore.instance.isUserPro //&& LoginService.instance.isChangedLoggedIn == false
                    else {
                        //                        self.goSubscriptionTypeVC()
                        NavigationHelper.shared.navigateToSubscription(from: self)
                        return
                    }
                    self.navigationController?.pushViewController(DownloadVC.instantiateNib(), animated: true)
                    //self.performSegue(withIdentifier: "toDownloadsVC", sender: nil)
                case 16:
                    guard ShadhinCore.instance.isUserPro //&& LoginService.instance.isChangedLoggedIn == false
                    else {
                        //                        self.goSubscriptionTypeVC()
                        NavigationHelper.shared.navigateToSubscription(from: self)
                        return
                    }
                    
                    //#if DEBUG
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyPlaylistVC")
                    self.navigationController?.pushViewController(vc!, animated: true)
                    return
                    //#endif
                    
                    //self.performSegue(withIdentifier: "toPlaylistVC", sender: nil)
                case 17:
                    self.navigationController?.pushViewController(FavouriteVC(), animated: true)
                case 3:
                    //                    guard LoginService.instance.isUserSubscribed// && LoginService.instance.isChangedLoggedIn == false
                    //                        else {
                    //                        //self.goSubscriptionTypeVC()
                    //                        SubscriptionPopUpVC.show(self)
                    //                        return
                    //                    }
                    //#if DEBUG
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowingArtistVC")
                    self.navigationController?.pushViewController(vc!, animated: true)
                    return
                case 69:
                    self.goSubscriptionTypeVC()
                    SMAnalytics.gotoPro()
                    //SubscriptionPopUpVC.show(self)
                default
                    :
                    self.navigationController?.pushViewController(AlbumPlayedVC(), animated: true)
                    //self.performSegue(withIdentifier: MyMusicService.instance.myMusicSegueArray[index - 1], sender: nil)
                }
            }
            return cell
            
        case .ad:
            
            guard canShowAd() else {
                return tableView.dequeueReusableCell(withIdentifier: "MyMusicSongsAndFavEmptyCell")!
            }
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: VmaxMyProfileTVCell.identifier,
                for: indexPath
            ) as? VmaxMyProfileTVCell else {
                fatalError()
            }
            cell.setupCell(tagId: tagId)
            
            cell.onAdFailed = { [weak self] in
                guard let self = self else { return }
                self.shouldShowVmaxAd = false
                self.tableView.reloadData()
            }
            
            cell.onHeightChanged = { [weak self] height in
                guard let self = self else { return }
                self.adHeight = height
                self.shouldShowVmaxAd = true
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                }
            }
            
            return cell
            
        case .recent:
            if recentPlays.count == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "MyMusicSongsAndFavEmptyCell")!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMusicSongsAndFavCell") as! MyMusicSongsAndFavCell
            
            if recentPlays.count > 0 {
                let model = recentPlays[indexPath.row]
                cell.configureCell(model: model, isFav: false)
                cell.downloadMarkImageView.isHidden  = true
                cell.threeDotBtn.isHidden = true
                let type = SMContentType.init(rawValue: model.contentType)
                cell.songsImgView.cornerRadius = 5
                //  cell.songsDurationLbl.text = ""
                switch type {
                case .artist:
                    cell.songArtistLbl.text = "Artist"
                    cell.songsImgView.cornerRadius = 28
                case .album:
                    cell.songArtistLbl.text = model.artist?.isEmpty ?? true ? "Album" : model.artist
                case .song:
                    cell.songArtistLbl.text = model.artist?.isEmpty ?? true ? "Single" :  model.artist
                case .podcast:
                    cell.songArtistLbl.text = "Podcast"
                case .playlist:
                    cell.songArtistLbl.text = model.artist?.isEmpty ?? true ? "Playlist" :  model.artist
                default:
                    cell.songArtistLbl.text = ""
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sectionType(for: indexPath.section) {
        case .header:
            break
            
        case .ad:
            break
            
        case .recent:
            
            let obj = recentPlays[indexPath.row]
            switch SMContentType.init(rawValue: obj.contentType){
            case .song, .playlist:
                let vc = goPlaylistVC(content: obj)
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .artist:
                let vc = goArtistVC(content: obj)
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .album:
                let vc = goAlbumVC(isFromThreeDotMenu: false, content: obj)
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .podcast:
                let sb = UIStoryboard(name: "PodCast", bundle:Bundle.ShadhinMusicSdk)
                if let podcastVC = sb.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC, let type = obj.contentType, let episodId = obj.albumId{
                    
                    podcastVC.podcastCode = type
                    podcastVC.selectedEpisodeID = Int(episodId) ?? 0
                    self.navigationController?.pushViewController(podcastVC, animated: false)
                }
                break
                
            default:
                Log.error("Not configured \(String(describing: obj.contentType))")
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        guard sectionType(for: section) == .recent else {
            return nil
        }
        
        let container = UIView()
        
        if #available(iOS 13.0, *) {
            container.backgroundColor = .secondarySystemBackground
        }
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Recently Played"
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        if recentPlays.count > 0 {
            
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("VIEW ALL", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            
            if #available(iOS 13.0, *) {
                button.setTitleColor(.label, for: .normal)
                button.backgroundColor = UIColor.secondarySystemFill.withAlphaComponent(0.3)
            }
            
            button.layer.cornerRadius = 4
            button.addTarget(self,
                             action: #selector(showAllRecentlyPlayedSong),
                             for: .touchUpInside)
            
            container.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
                button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                button.heightAnchor.constraint(equalToConstant: 24),
                button.widthAnchor.constraint(equalToConstant: 70)
            ])
        }
        
        return container
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        
        switch sectionType(for: section) {
            
        case .recent:
            return 50
            
        default:
            return .leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch sectionType(for: indexPath.section) {
            
        case .header:
            return 350 + getReferalHeight() + getCouponHeight() + 56
            
        case .ad:
            return adHeight > 0 ? adHeight : .leastNormalMagnitude
            
        case .recent:
            return recentPlays.isEmpty ? 205 : 70
        }
    }
    
    func getCashbackHeight()-> CGFloat{
        switch cashBackStatus.lowercased(){
        case "failed", "pending":
            return 56
        default:
            return 0
        }
    }
    
    func getCampaignHeight() -> CGFloat{
        if shareCampaignRunning{
            return 56
        }else{
            return 0
        }
    }
    
    func getCouponHeight() -> CGFloat{
        if isCouponRunning{
            return 56
        }else{
            return 0
        }
    }
    
    func getReferalHeight() -> CGFloat{
        if isReferRunning{
            return 56
        }else{
            return 0
        }
    }
}
