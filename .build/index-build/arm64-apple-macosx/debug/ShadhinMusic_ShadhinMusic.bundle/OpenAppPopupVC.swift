//
//  OpenAppPopVC.swift
//  Shadhin_Gp
//
//  Created by Maruf on 9/6/24.
//

import Foundation

class OpenAppPopupVC: UIViewController {
    
    static func show(_ vc: UIViewController?, _ discoverVC: HomeVCv3?, _ content: PopUpObj.Content){
        let popUp = OpenAppPopupVC(nibName: "OpenAppPopupVC", bundle:Bundle.ShadhinMusicSdk)
        popUp.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        popUp.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        popUp.content = content
        popUp.discoverVC = discoverVC
        //vc?.present(popUp, animated: true, completion: nil)
    }
    
    @IBOutlet weak var displayImg: UIImageView!
    @IBOutlet weak var btnImg: UIImageView!
    @IBOutlet weak var btnLbl: UILabel!
    @IBOutlet weak var btnHolder: UIView!
    
    weak var discoverVC: HomeVCv3?
    var content: PopUpObj.Content!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if var imageUrl = content.image, !imageUrl.isEmpty{
            imageUrl = imageUrl.replacingOccurrences(of: " ", with: "%20")
            displayImg.kf.indicatorType = .activity
            displayImg.kf.setImage(with: URL(string: imageUrl.safeUrl()))
        }
        var contentType = content.contentType ?? "unknown"
        contentType = contentType.uppercased()
    
        if contentType == "A"{
            btnLbl.text = "Go to Artist"
            btnImg.image = UIImage(named: "ic_play_popup",in: Bundle.ShadhinMusicSdk,compatibleWith:nil)
            btnHolder.setClickListener {
                self.dismiss(animated: true) {
                    self.content.artistId = self.content.contentID
                    let vc =  self.goArtistVC(content: self.content)
                    self.discoverVC?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else if contentType == "P"{
            btnLbl.text = "Go to Playlist"
            btnImg.image = UIImage(named: "ic_play_popup",in: Bundle.ShadhinMusicSdk,compatibleWith:nil)
            btnHolder.setClickListener {
                self.dismiss(animated: true) {
                    let vc = self.goPlaylistVC(content: self.content)
                    self.discoverVC?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else if contentType.count > 3 &&
                    (contentType.prefix(2) == "PD" || contentType.prefix(2) == "VD"){
            btnLbl.text = "Go to Podcast"
            btnHolder.setClickListener {
                self.dismiss(animated: true) {
                    let storyBoard = UIStoryboard(name: "PodCast", bundle:Bundle.ShadhinMusicSdk)
                    if let tabVC = MainTabBar.shared,
                       let tabs = tabVC.viewControllers,
                       tabs.count > 2,
                       let nav = tabs[2] as? UINavigationController,
                       let contentId = Int(self.content.contentID ?? ""),
                       let podcastVC = storyBoard.instantiateViewController(withIdentifier: "PodcastVC") as? PodcastVC{
                        
                        podcastVC.podcastCode = contentType
                        podcastVC.selectedEpisodeID = contentId
                        nav.pushViewController(podcastVC, animated: false)
                        tabVC.selectedIndex = 2
                    }
                }
            }
        }else if contentType == "R" || contentType == "B"  {
            btnLbl.text = "Go to Album"
            btnImg.image = UIImage(named: "ic_play_popup",in: Bundle.ShadhinMusicSdk,compatibleWith:nil)
            btnHolder.setClickListener {
                self.dismiss(animated: true) {
                    self.content.albumId = self.content.contentID
                    let vc = self.goAlbumVC(isFromThreeDotMenu: false, content: self.content)
                    self.discoverVC?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else if contentType == "V"{
            btnLbl.text = "Open Video"
            btnImg.image  = UIImage(named: "ic_play_popup",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            btnHolder.setClickListener {
                self.dismiss(animated: true) {
                    self.discoverVC?.openVideoPlayer(videoData: [self.content], index: 0)
                }
            }
        }else if contentType == "SUBS"{
            btnLbl.text = "Go Pro"
            btnImg.image  = UIImage(named: "ic_crown_popup",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
            btnHolder.setClickListener {
                self.dismiss(animated: true) {
                    if let subscriptionPlatForm = self.content.trackType,
                       var subscriptionPlanName = self.content.type,
                       !subscriptionPlatForm.isEmpty{
                        if subscriptionPlanName.isEmpty{
                            subscriptionPlanName = "common"
                        }
                        self.discoverVC?.goSubscriptionTypeVC(false, subscriptionPlatForm, subscriptionPlanName)
                    }
                }
            }
        }else{
            btnLbl.text = "Close"
            btnImg.image = nil
            btnHolder.setClickListener {
                self.dismiss(animated: true) {
                }
            }
        }
    }

    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

}
