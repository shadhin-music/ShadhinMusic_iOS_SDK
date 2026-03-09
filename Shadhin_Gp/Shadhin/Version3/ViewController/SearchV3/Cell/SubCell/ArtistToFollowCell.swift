//
//  SearchRecentPlayedCollectionViewCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 6/3/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ArtistToFollowCell: UICollectionViewCell {
    var vc: SearchMainV3?
    var content: CommonContentProtocol?
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var flowNumberLbl: UILabel!
    @IBOutlet weak var artistNameLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        let width = 136.0
        let height = 240.0
        return CGSize(width: width, height: height)
    }
    // 2*width = screen width - 48
 //    width =  (screen width - 48)/2
    static var sizeForArtist: CGSize {
       let width = (SCREEN_WIDTH - 48)/2
        let height = 240.0
        return CGSize(width: width, height: height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        followButtonSetUp()
    }
    
    private func followButtonSetUp() {
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
        followButton.setTitleColor(.tintColor, for: .normal)
        followButton.setTitleColor(.textColorSecoundery, for: .selected)
        followButton.layer.cornerRadius = 12
        followButton.layer.borderWidth = 1
        
        if self.traitCollection.userInterfaceStyle == .dark{
            self.followButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3)
                .cgColor
        }else{
            self.followButton.layer.borderColor = UIColor.black.withAlphaComponent(0.1)
                .cgColor
        }
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                if self.traitCollection.userInterfaceStyle == .light {
                    // Code to execute in light mode
                    self.followButton.layer.borderColor = UIColor.black.withAlphaComponent(0.1)
                        .cgColor
                }else {
                    // Code to execute in dark mode
                    print("App switched to dark mode")
                    self.followButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3)
                        .cgColor
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    func bindData(data: SearchV2Content) {
        let imgUrlString = data.imageUrl.replacingOccurrences(of: "<$size$>", with: "300")
        let imgUrl = URL(string: imgUrlString)
        imageView.kf.setImage(with: imgUrl)
        artistNameLbl.text = data.artist
        flowNumberLbl.text = data.albumId
        content = data.toCommonContent(shoudlHistoryAPICall: false)
        if let content = content {
            self.followButton.isSelected = FavoriteCacheDatabase.intance.isFav(content: content)
        }
    }
    
    func incrementStringInteger(_ numberString: String?, value: Int) -> String? {
        guard let numberString = numberString else {return nil}
        // Check if the input string can be converted to an integer
        guard let number = Int(numberString) else {
            // If the string is not a valid integer, return nil
            return nil
        }
        
        // Increment the integer by one
        let incrementedNumber = number + value
        
        // Convert the incremented number back to a string and return it
        return String(incrementedNumber)
    }
    
    @IBAction func followOrUnfollowPressed(_ sender: Any) {
        if !ShadhinCore.instance.isUserLoggedIn {
//            let loginVC  = SignInWithMsisddn()
//            if let vc = vc {
//                vc.modalPresentationStyle = .fullScreen
//                vc.present(loginVC, animated: true, completion: nil)
//                return
//            }
        }
        guard let content = content else {return}
        if  FavoriteCacheDatabase.intance.isFav(content: content){
            flowNumberLbl.text = incrementStringInteger(flowNumberLbl.text, value: -1)
            ShadhinCore.instance.api.addOrRemoveFromFavorite(content: content, action: .remove) {[weak self] error in
                guard let self = self else {return}
                if error == nil{
                    FavoriteCacheDatabase.intance.deleteContent(content: content)
                    self.followButton.isSelected = false
                } else {
                    self.flowNumberLbl.text = self.incrementStringInteger(self.flowNumberLbl.text, value: 1)
                }
            }
        }else{
            flowNumberLbl.text = incrementStringInteger(flowNumberLbl.text, value: 1)
            ShadhinCore.instance.api.addOrRemoveFromFavorite(content: content, action: .add) {[weak self] error in
                guard let self = self else {return}
                if error == nil{
                    FavoriteCacheDatabase.intance.addContent(content: content)
                    self.followButton.isSelected = true
                    
                } else {
                    self.flowNumberLbl.text = self.incrementStringInteger(self.flowNumberLbl.text, value: -1)
                }
            }
        }
    }
    
    
}
