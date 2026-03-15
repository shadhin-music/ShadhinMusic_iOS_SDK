//
//  PodcastMainVC.swift
//  Shadhin
//
//  Created by Rezwan on 8/3/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastMainVC: UIViewController {
    
    var podcastTabVC : UITabBarController?
    var currentTab = 0
    
    @IBOutlet var tabBtns: [UIButton]!
    @IBOutlet weak var adBannerMax: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     //   loadAds()
    }
    
    private func changeTab(index : Int){
        if (index == currentTab){
            return
        }
        tabBtns[currentTab].isSelected = false
        currentTab = index
        tabBtns[currentTab].isSelected = true
        podcastTabVC?.selectedIndex = currentTab
    }
    
    @IBAction func exploreBtnTapped(_ sender: Any) {
        changeTab(index: 0)
    }
    
    @IBAction func showBtnTapped(_ sender: Any) {
        changeTab(index: 1)
    }
    
    @IBAction func libraryBtnTapped(_ sender: Any) {
        changeTab(index: 2)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // you can set this name in 'segue.embed' in storyboard
        if segue.identifier == "podcastTabVCSegue" {
            let connectContainerViewController = segue.destination as! UITabBarController
            podcastTabVC = connectContainerViewController
        }
    }
//    
//    private func loadAds(){
//        if ShadhinCore.instance.isUserPro {
//            removeAd()
//            return
//        }
//        guard let useAdProvider = Bundle.main.object(forInfoDictionaryKey: "UseAdProvider") as? String else {
//            adBannerView.isHidden = true
//            return
//        }
//        if useAdProvider == "google"{
//                  loadGoogleAd()
//        }else if(useAdProvider == "applovin"){
//            loadApplovinAd()
//        }else{
//            removeAd()
//        }
//    }
//    
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
//        var size = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(screenWidth)
//        size.size.height = 50
//        adBannerView.adSize = size
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
//        adBannerView.isHidden = true
//    }
    
    

}
