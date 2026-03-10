//
//  TopPopularItemCell.swift
//  Shadhin
//
//  Created by Joy on 24/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CircularWithFavBtnSub: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size : CGSize{
        return .init(width: 135, height: 212)
    }
    
    @IBOutlet weak var imageIV: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var favCountLabel: UILabel!
    
    var content : CommonContentProtocol?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        imageIV.cornerRadius = imageIV.height / 2
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        followButton.cornerRadius = 12
        followButton.borderWidth = 1

        titleLabel.textColor = .textColor
        favCountLabel.textColor = .textColorSecoundery

        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)

        followButton.setTitleColor(.tintColor, for: .normal)
        followButton.setTitleColor(.textColorSecoundery, for: .selected)
        favCountLabel.isHidden = true
        followButton.layer.borderColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.3)
            : UIColor.black.withAlphaComponent(0.1)
        }.cgColor
    }
    
    private func updateBorderColor() {
        followButton.layer.borderColor =
        traitCollection.userInterfaceStyle == .dark
        ? UIColor.white.withAlphaComponent(0.3).cgColor
        : UIColor.black.withAlphaComponent(0.1).cgColor
    }


    func bind(obj : CommonContentProtocol){
        self.content = obj
        self.titleLabel.text = obj.title
        self.favCountLabel.text = obj.followers
        self.favCountLabel.isHidden = obj.followers == nil || Int(obj.followers ?? "") == 0
        self.imageIV.kf.setImage(with: URL(string: obj.image?.image300 ?? ""),placeholder: AppImage.artistPlaceholder.uiImage)
        self.followButton.isSelected = FavoriteCacheDatabase.intance.isFav(content: obj)
    }

    @IBAction func onFollowPressed(_ sender: Any) {
        guard let content = content else {return}
        if  FavoriteCacheDatabase.intance.isFav(content: content){
            ShadhinCore.instance.api.addOrRemoveFromFavorite(content: content, action: .remove) { error in
                if error == nil{
                    FavoriteCacheDatabase.intance.deleteContent(content: content)
                    self.followButton.isSelected = false

                }
            }
        }else{
            ShadhinCore.instance.api.addOrRemoveFromFavorite(content: content, action: .add) { error in
                if error == nil{
                    FavoriteCacheDatabase.intance.addContent(content: content)
                    self.followButton.isSelected = true

                }
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updateBorderColor()
    }
}

