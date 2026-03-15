//
//  SquareImageCell.swift
//  Shadhin
//
//  Created by Joy on 16/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
//
class SquareImageCell: UICollectionViewCell {
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var heightForHome : CGFloat{
        return 136
    }
    
    @IBOutlet weak var imageIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        clipsToBounds = true
        cornerRadius = 8
    }

    func bind(with content : CommonContentProtocol){
        guard let img = content.image?.image300, let url = URL(string: img) else {return}
        imageIV.kf.setImage(with: url,placeholder: AppImage.songPlaceholder.uiImage)
    }
}
