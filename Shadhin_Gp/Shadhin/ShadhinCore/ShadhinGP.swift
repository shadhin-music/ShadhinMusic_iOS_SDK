//
//  ShadhinGP.swift
//  Shadhin_Gp
//
//  Created by Maruf on 5/6/24.
//

import UIKit

@objc
public final class ShadhinGP: NSObject {
    public static let shared = ShadhinGP()
    
    var coordinator : HomeCoordinator!
    public weak var eventDelegate: ShadhinGPEventDelegate?
    public var isVmaxInitialized : Bool = false
    
    @objc private override init() {
        super.init()
    }
    
    func gotoShadhinMusic(parentVC: UIViewController, accesToken: String) {
        UserInfoViewModel.shared.userInfo = nil
        ShadhinCore.instance.defaults.userSessionToken = ""
        ShadhinCore.instance.defaults.userMsisdn = ""
        ShadhinCore.instance.defaults.userCode = ""
        ShadhinCore.instance.defaults.userSessionToken = accesToken
        ShadhinCore.instance.api.getUserInfo(token: accesToken) { response in
            switch response {
            case .success(let success):
                UserInfoViewModel.shared.userInfo = success.data
                ShadhinCore.instance.defaults.userCode = success.data?.userCode ?? ""
                ShadhinCore.instance.defaults.userMsisdn = success.data?.phoneNumber ?? ""
            case .failure(let error):
                print("❌ User Info Failed:", error)
            }
            
            DispatchQueue.main.async {
                let tabbar = MainTabBar(nibName: nil, bundle: nil)
                if let pendingURL = ShadhinMusicView.pendingShortsURL {
                    tabbar.selectedIndex = 4
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if let nav = tabbar.viewControllers?[4] as? UINavigationController,
                           let webVC = nav.viewControllers.first as? ShortsAndAudiobookContainerVC {
                            webVC.openShortsPlayer(url: pendingURL)
                            print("✅ Opened pending shorts: \(pendingURL)")
                        }
                    }
                    
                    ShadhinMusicView.pendingShortsURL = nil
                } else {
                    tabbar.selectedIndex = 0
                }
                
                if let nav = parentVC.navigationController {
                    nav.pushViewController(tabbar, animated: true)
                } else {
                    parentVC.present(tabbar, animated: true)
                }
                
                
                let vm = GPAudioViewModel.shared
                let hasGPContent = !vm.gpMusicContents.isEmpty
                let hasEverPlayed = vm.goContentPlayingState == .playing || vm.goContentPlayingState == .pause

                if hasGPContent && hasEverPlayed {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Self.setupSDKPlayer(in: tabbar)
                    }
                }
            }
        }
    }
    
    private static func setupSDKPlayer(in tabbar: MainTabBar) {
        let vm = GPAudioViewModel.shared
        guard !vm.gpMusicContents.isEmpty else { return }
        
        let syncIndex: Int
        if let currentId = AudioPlayer.shared.currentItem?.contentId,
           let matchedIndex = vm.gpMusicContents.firstIndex(where: { String($0.contentId ?? 0) == currentId }) {
            syncIndex = matchedIndex
        } else {
            syncIndex = max(0, min(vm.selectedIndexInCarousel, vm.gpMusicContents.count - 1))
        }
        vm.selectedIndexInCarousel = syncIndex
        
        guard syncIndex < vm.gpMusicContents.count else { return }
        let content = vm.gpMusicContents[syncIndex].toCommonContentV4()
        let popVC = MusicPlayerV3.shared
        
        popVC.loadViewIfNeeded()
        popVC.songsIndex = syncIndex
        popVC.musicdata = vm.gpMusicContents.compactMap({ $0.toCommonContentV4() })
        MusicPlayerV3.audioPlayer.delegate = popVC
        
        tabbar.popupController.delegate = popVC
        
        if let popupBar = tabbar.popupBar {
            popupBar.dataSource = popVC
            popupBar.progressViewStyle = .bottom
            popupBar.pbBackgroundColor = .appTintColor
            popupBar.progressView.tintColor = .red
            if !(popupBar.customPopupBarViewController is MusicPlayerV4Mini) {
                popupBar.customPopupBarViewController = MusicPlayerV4Mini.instantiateNib()
            }
        }
        
        if let container = tabbar.popupContentView {
            container.popupPresentationStyle = .fullScreen
            container.popupCloseButtonStyle = .none
        }
        
        let popupState = tabbar.popupController.popupPresentationState
        if popupState == .hidden || popupState == .dismissing {
            tabbar.presentPopupBar(withPopupContentViewController: popVC, animated: true, completion: nil)
        }
        
        popVC.iCarouselView?.scrollToItem(at: syncIndex, animated: false)
        popVC.updateMiniPlayerInfo(content: content, tabBar: tabbar)
        
        if let duration = AudioPlayer.shared.currentItemDuration,
           duration > 0,
           let currentTime = AudioPlayer.shared.currentItemProgression {
            let percentage = Float(currentTime / duration) * 100
            if let miniPlayer = tabbar.popupBar.customPopupBarViewController as? MusicPlayerV4Mini {
                miniPlayer.circularView.setProgress(progress: CGFloat(percentage) / 100)
            }
            popVC.playerSlider?.value = percentage / 100
            popVC.playDurationLbl?.text = formatSecondsToString(currentTime)
            popVC.trackDuration?.text = formatSecondsToString(duration)
        }
    }
    
    private static func setupSDKPlayer2(in tabbar: MainTabBar) {
        let vm = GPAudioViewModel.shared
        guard !vm.gpMusicContents.isEmpty else { return }
        
        guard let homeNav = tabbar.viewControllers?.first as? UINavigationController,
              let homeVC = homeNav.viewControllers.first as? HomeVCv3 else { return }
        homeVC.openGPMusicsInMiniPlayer()
    }
}

class UserInfoViewModel {
    static let shared = UserInfoViewModel()
    private init () {
        
    }
    var userInfo: UserData?
}


extension UIViewController {
    func sendEmail() {
        if let url = URL(string: "mailto:support@shadhin.co?subject=Feedback%20about%20Shadhin") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Unable to open Mail app.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }
    
    func sendMessenger2() {
        if let url = URL(string: "https://m.me/shadhin.co") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Unable to open Messenger or App Store.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }
    
    func sendMessenger() {
        let messengerAppURL = URL(string: "fb-messenger://user-thread/shadhin.co")!
        let messengerWebURL = URL(string: "https://m.me/shadhin.co")!
        
        if UIApplication.shared.canOpenURL(messengerAppURL) {
            UIApplication.shared.open(messengerAppURL)
        } else {
            UIApplication.shared.open(messengerWebURL)
        }
    }
}
