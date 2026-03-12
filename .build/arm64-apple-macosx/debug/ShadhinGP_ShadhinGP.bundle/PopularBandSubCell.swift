//
//  PopularBandSubCell.swift
//  Shadhin
//
//  Created by Joy on 16/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PopularBandSubCell: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: .main)
    }
    static var height : CGFloat{
        return 212
    }
    
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var followWidthConstraint: NSLayoutConstraint!
    private let FOLLOW_MIN_WIDTH = 70
    private let FOLLOW_MAX_WIDTH = 80
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.imageIV.cornerRadius = self.imageIV.width / 2
        self.followButton.cornerRadius = self.followButton.height / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor =  .textColor
        followerCountLabel.textColor = .textColorSecoundery
    }

    func bind(with content : CommonContentProtocol){
        self.titleLabel.text = content.title
        self.followerCountLabel.text = content.followers
        //check is following or not
        //followButton.text = follow
        //followButton.text = following
    }
    
    @IBAction func onFollowPressed(_ sender: Any) {
    }
    
}

