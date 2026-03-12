//
//  BhootHomeSubCell.swift
//  Shadhin
//
//  Created by Joy on 20/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PatchDescTopWithRecPortDescBelowSub: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var sizeForBhoot : CGSize{
        return .init(width: 136, height: 246)
    }
    
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor = .textColor
    }

    func bind(with obj : HomeV3Content){
        self.titleLabel.text = obj.title
        self.imageIV.kf.setImage(with: URL(string: obj.image?.image450 ?? ""))
    }

    func bind2(with obj : HomeV3Content){
        self.titleLabel.text = obj.titleBn
        self.imageIV.kf.setImage(with: URL(string: obj.image?.image450 ?? ""))
    }

}
