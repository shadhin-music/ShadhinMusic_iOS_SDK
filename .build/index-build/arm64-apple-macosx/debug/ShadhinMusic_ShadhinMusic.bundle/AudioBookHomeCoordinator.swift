//
//  AudioBookCordinator.swift
//  Shadhin
//
//  Created by Maruf on 2/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

protocol AudioBookCoordinator {
    var childCoordinators: [AudioBookCoordinator] { get set }
    var navigationController: UINavigationController { get set }

}
class AudioBookHomeCoordinator:NSObject, AudioBookCoordinator {
    var childCoordinators = [AudioBookCoordinator]()
    var navigationController: UINavigationController
    weak var tabBarController : UITabBarController?
    init(navigationController: UINavigationController, tabBar : UITabBarController?) {
        self.navigationController = navigationController
        self.tabBarController = tabBar
        super.init()
        self.navigationController.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
   
    func audioBookrouteToContent(content: AudioPatchContent, _ patch: AudioPatch? = nil){
        let contentType = SMContentTypeAudioBook(rawValue:content.contentType.rawValue)
        switch contentType {
        case .audioBook:
            goToAudioBook(content: content)
        case .unknown:
            break
        case .none:
            break
        }
    }
    
    func goToAudioBook(content: AudioPatchContent){
        let vc  = AudioBookDetailsVC()
        vc.selectedTrackID = String(content.contentID)
        vc.episodeId = String(content.contentID)
        vc.artistId = String(content.audioBook.authors.first?.id ?? 0)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func gotoSeeAll(patch : AudioPatchHome){
        let vc = HomeSeeAllVC.instantiateNib()
        vc.isAudioPatchData = true
        vc.isStreamingHistoryData = true
        vc.isAudioCatagoriesData = true
        vc.audioHomePatch = patch
        vc.audioHomeCoordinator = self
        push(vc: vc)
    }
    

}
extension AudioBookHomeCoordinator {
    func push(vc : UIViewController){
        self.navigationController.pushViewController(vc, animated: true)
    }
    func pop(){
        self.navigationController.popViewController(animated: true)
    }
}

extension AudioBookHomeCoordinator : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


enum SMContentTypeAudioBook: String, Decodable {
    case audioBook      = "BK"
    case unknown
    
    init(rawValue: String?){
        let value = rawValue?.uppercased() ?? "0"
        switch value {
        case "BK": self = .audioBook
        default  : self = .unknown
        }
    }
}
