//
//  RecommendedSubCell.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TwoRowSqrWithDescLeftSub: UICollectionViewCell {
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat{
        return 56
    }
    
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .textColorSecoundery
    }

    func bind(with content : CommonContentProtocol){
        self.titleLabel.text = content.title
        self.subtitleLabel.text = content.artist
        if let imageUrlStr = content.image?.image300.safeUrl(){
            self.imageIV.kf.setImage(with: URL(string: imageUrlStr))
        }
    }
}
