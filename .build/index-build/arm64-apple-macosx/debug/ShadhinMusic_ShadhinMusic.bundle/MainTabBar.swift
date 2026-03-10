//
//  MainTabBar.swift
//  Shadhin
//
//  Created by Rezwan on 6/19/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class MainTabBar: UITabBarController , UITabBarControllerDelegate {
    static var shared : MainTabBar? =  nil
    var wasLoginSuccess = false
    private var webContainer: ShortsAndAudiobookContainerVC!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        setupTabs()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupTabs() {
        let homeNav      = makeNav(title: "Home",      imageName: "ic_home_1",       selectedImageName: "ic_home_2",      rootVC: HomeVCv3.instantiateNib())
        let myMusicNav   = makeMyMusicNav()
        let podcastNav   = makeNav(title: "Podcast",   imageName: "ic_radio_1",      selectedImageName: "ic_radio_2",     rootVC: PodcastViewControllerVersionTwo.instantiateNib())
        let audiobookNav = makeNav(title: "Audiobook", imageName: "ic_AudioBooksTab", selectedImageName: "ic_AudioBooksTab", rootVC: ShortsAndAudiobookContainerVC())
        let shortsNav    = makeNav(title: "Shorts",    imageName: "ic_Shorts",        selectedImageName: "ic_Shorts",      rootVC: ShortsAndAudiobookContainerVC())
        viewControllers = [homeNav, myMusicNav, podcastNav, audiobookNav, shortsNav]
    }

    private func makeNav(title: String, imageName: String, selectedImageName: String, rootVC: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootVC)
        nav.setNavigationBarHidden(true, animated: false)
        let bundle = Bundle.ShadhinMusicSdk
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: imageName, in: bundle, compatibleWith: nil),
            selectedImage: UIImage(named: selectedImageName, in: bundle, compatibleWith: nil)
        )
        return nav
    }

    private func makeMyMusicNav() -> UINavigationController {
        let storyboard = UIStoryboard(name: "MyMusic", bundle: Bundle.ShadhinMusicSdk)
        let nav = storyboard.instantiateInitialViewController() as? UINavigationController ?? UINavigationController()
        let bundle = Bundle.ShadhinMusicSdk
        nav.tabBarItem = UITabBarItem(
            title: "My Music",
            image: UIImage(named: "ic_music_1", in: bundle, compatibleWith: nil),
            selectedImage: UIImage(named: "ic_music_2", in: bundle, compatibleWith: nil)
        )
        return nav
    }

    override func viewDidLoad() {
        super.viewDidLoad()
            
        MainTabBar.shared = self
        self.delegate = self
        if #available(iOS 13.0, *) {
            UITabBar.appearance().barTintColor = .systemBackground
        } else {
            UITabBar.appearance().barTintColor = .white
        }
        UITabBar.appearance().tintColor = .tintColor
        UITabBar.appearance().isTranslucent = true
        
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = UITabBar.appearance().standardAppearance
        }

        Log.info("Tabbar didload")
        
        if let tabBarController = self.tabBarController {
            tabBarController.delegate = self
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        Log.info("Tabbar willappear")
    }

    //func to perform spring animation on imageview
    func performSpringAnimation(imgView: UIImageView) {

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {

            imgView.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)

            //reducing the size
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                imgView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { (flag) in
            }
        }) { (flag) in

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if wasLoginSuccess{
            showLoginSuccessNoti()
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let nav = viewController as? UINavigationController,
              let webVC = nav.viewControllers.first as? ShortsAndAudiobookContainerVC else {
            return true
        }
        
        if viewController == tabBarController.viewControllers?[3] {
            webVC.showAudiobook()
        } else if viewController == tabBarController.viewControllers?[4] {
            webVC.showShorts()
        }

        return true
    }

    
    func showLoginSuccessNoti(){
        // Generate top floating entry and set some properties
        var attributes = EKAttributes.topFloat
        //attributes.entryBackground = .gradient(gradient: .init(colors: [EKColor(.systemGreen), EKColor(.systemGreen)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.entryBackground = .color(color: EKColor(.init(rgb: 0x00B0FF)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)

        let title = EKProperty.LabelContent(text: "Success", style: .init(font: .boldSystemFont(ofSize: 16), color: .white))
        let description = EKProperty.LabelContent(text: "Login in successful", style: .init(font: .systemFont(ofSize: 12), color: .white))
        //let image = EKProperty.ImageContent(image: UIImage(named: imageName)!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: nil, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
        wasLoginSuccess = false
    }
    
    func showError(title: String, msg: String){
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .color(color: EKColor(.init(rgb: 0xEF5350)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.displayDuration = 2.6
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
        attributes.entryInteraction = .forward

        let title = EKProperty.LabelContent(text: title, style: .init(font: .boldSystemFont(ofSize: 16), color: .white))
        let description = EKProperty.LabelContent(text: msg, style: .init(font: .systemFont(ofSize: 12), color: .white))
        let simpleMessage = EKSimpleMessage(image: nil, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }

}

extension MainTabBar {
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Check if the selected view controller is a navigation controller
        if let navigationController = viewController as? UINavigationController {
            // Assuming your UITableView or UICollectionView is the root view controller of the navigation controller
            if let rootViewController = navigationController.viewControllers.first as? HomeVCv3 {
                // Scroll to the top
                rootViewController.collectionView?.setContentOffset(CGPoint.zero, animated: true)
            }
        }
        
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else {return}
        
        switch index {
        case 3, 4:
            closePlayer()
        default:
            showPlayer()
        }
    }
}
