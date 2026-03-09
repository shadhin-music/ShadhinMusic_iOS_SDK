//
//  UIViewControllerExt.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/16/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//


import UIKit

private var countTapped = 0
private let discoverStoryboard = UIStoryboard(name: "Discover", bundle:Bundle.ShadhinMusicSdk)
private let paymentStoryboard = UIStoryboard.init(name: "Payment", bundle: Bundle.ShadhinMusicSdk)

extension UIViewController {

    func openVideoPlayer(videoData: [CommonContentProtocol],index: Int) {
        let vc = VideoPlayerVC.instantiateNib()
        vc.index = index
        vc.videoList = videoData
        vc.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(vc, animated: true)
        SMAnalytics.viewContent(content: videoData[index])
    }
    
    
//    func showNotUserPopUp(callingVC: UIViewController?){
//        let vc0 = SignInWithMsisddn()
//        let navVC = UINavigationController(rootViewController: vc0)
//        navVC.isNavigationBarHidden = true
//        navVC.modalPresentationStyle = .fullScreen
//        navVC.modalTransitionStyle = .coverVertical
//        callingVC?.present(navVC, animated: true)
//        return
//////        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//////        let vc = storyBoard.instantiateViewController(withIdentifier: "AskToSignInVC") as! AskToSignInVC
////        vc.callingVC = callingVC
////        var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 8)
////        attribute.entryBackground = .color(color: .clear)
////        attribute.border = .none
////        attribute.positionConstraints.size.width = .fill
////        SwiftEntryKit.layoutIfNeeded()
////        SwiftEntryKit.display(entry: vc, using: attribute)
//    }
    

     func goSubscriptionTypeVC(_ useParent:Bool = false,
                              _ subscriptionPlatForm :String = "common",
                              _ subscriptionPlanName :String = "common") {
        if let navigationController = self.navigationController {
            // Push to the navigation stack
            let anotherViewController = SubscriptionVCv3.instantiateNib()
            navigationController.navigationItem.hidesBackButton = true
            navigationController.setNavigationBarHidden(true, animated: true)
            navigationController.pushViewController(anotherViewController, animated: true)
        } else {
            // Present modally with a new navigation controller
            let anotherViewController = SubscriptionVCv3.instantiateNib()
            let navController = UINavigationController(rootViewController: anotherViewController)
            navController.modalPresentationStyle = .fullScreen
            navController.navigationItem.hidesBackButton = true
            navController.setNavigationBarHidden(true, animated: true)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func goAlbumVC(isFromThreeDotMenu: Bool,content: CommonContentProtocol)-> MusicAlbumListVC {
        let vc = discoverStoryboard.instantiateViewController(withIdentifier: "MusicAlbumListVC") as! MusicAlbumListVC
        vc.discoverModel = content
        vc.isFromThreeDotMenu = isFromThreeDotMenu
        vc.hidesBottomBarWhenPushed = false
//        Analytics.logEvent("sm_content_viewed",
//                           parameters: [
//                            "content_type"  : "r" as NSObject,
//                            "content_id"    : content.contentID?.lowercased() ?? "" as NSObject,
//                            "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
//                            "content_name"  : content.title?.lowercased() ?? "" as NSObject,
//                            "platform"      : "ios" as NSObject
//                           ])
        SMAnalytics.viewContent(content: content)
        return vc
    }
    
    func goArtistVC(content: CommonContentProtocol)-> MusicArtistListVC {
        let vc = discoverStoryboard.instantiateViewController(withIdentifier: "MusicArtistListVC") as! MusicArtistListVC
        vc.discoverModel = content
        vc.hidesBottomBarWhenPushed = false
//        Analytics.logEvent("sm_content_viewed",
//                           parameters: [
//                            "content_type"  : "a" as NSObject,
//                            "content_id"    : content.contentID?.lowercased() ?? "" as NSObject,
//                            "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
//                            "content_name"  : content.title?.lowercased() ?? "" as NSObject,
//                            "platform"      : "ios" as NSObject
//                           ])
        SMAnalytics.viewContent(content: content)
        return vc
    }
    
    func goPlaylistVC(
        content: CommonContentProtocol,
        suggestedPlaylists : [CommonContentProtocol] = []
    )-> PlaylistOrSingleDetailsVC {
        let vc = discoverStoryboard.instantiateViewController(withIdentifier: PlaylistOrSingleDetailsVC.identifier) as! PlaylistOrSingleDetailsVC
        vc.discoverModel = content
        vc.suggestedPlaylists = suggestedPlaylists
        vc.hidesBottomBarWhenPushed = false
//        Analytics.logEvent("sm_content_viewed",
//                           parameters: [
//                            "content_type"  : content.contentType?.lowercased() ?? "p" as NSObject,
//                            "content_id"    : content.contentID?.lowercased() ?? "" as NSObject,
//                            "user_type"     : ShadhinCore.instance.defaults.shadhinUserType.rawValue  as NSObject,
//                            "content_name"  : content.title?.lowercased() ?? "" as NSObject,
//                            "platform"      : "ios" as NSObject
//                           ])
        SMAnalytics.viewContent(content: content)
        return vc
    }
    
    func goAddPlaylistVC(content: CommonContentProtocol) {
        guard checkProUser() else { 
            return
        }
                   
        let storyBoard = UIStoryboard(name: "MyMusic", bundle:Bundle.ShadhinMusicSdk)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlaylistsVC") as! PlaylistsVC
        vc.fromThreeDotMenu = true
        vc.addPlaylistData = content
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .custom
        self.present(navVC, animated: true, completion: nil)
    }
    
    func countButtonTouch() {
        guard ShadhinCore.instance.isUserPro else {
            countTapped += 1
            if countTapped > 9 {
                countTapped = 0
                NavigationHelper.shared.navigateToSubscription(from: self)
            }
            return
        }
    }
    func resetCountButtonTouch() {
        countTapped = 0
    }
    
    //Tap to hide keyboard.
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //user status
      func checkProUser()-> Bool{
            if ShadhinCore.instance.isUserPro{
                return true
            }else{
                NavigationHelper.shared.navigateToSubscription(from: self)
            }
        return false
    }
    
    
    func shareAppLink() {
        
        let appStoreLink = "https://apps.apple.com/app/id1481808365"
        let shareText = "Shadhin Music is here for you! Play Songs, Podcasts, Audiobooks & Shorts."
        let activityVC = UIActivityViewController(activityItems: [shareText,appStoreLink], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                        y: self.view.bounds.midY,
                                        width: 0,
                                        height: 0)
            popover.permittedArrowDirections = []
        }
        
        self.present(activityVC, animated: true, completion: nil)
    }

    //user status
    func checkUser()-> Bool{
        if ShadhinCore.instance.isUserPro{
            return true
        }else{
            SubscriptionPopUpVC.show(self)
        }
        return false
    }
    
    func closePlayer(){
        MusicPlayerV3.shared.adPlayer?.pause()
        MusicPlayerV3.audioPlayer.pause()
        MusicPlayerV3.isAudioPlaying = false
        MainTabBar.shared?.hidePopupBar(animated: true)
    }
    
    func showPlayer(){
        MainTabBar.shared?.showPopupBar(animated: true)
    }
}
