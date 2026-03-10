//
//  LatestVideoSubCell.swift
//  Shadhin
//
//  Created by Joy on 19/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TwoRowRecDescBelowSub: UICollectionViewCell {
    private var patch : HomeV3Patch!
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size : CGSize {
        return .init(width: 290, height: 210)
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var subtitlelabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        playButton.isUserInteractionEnabled = false
        titleLabel.textColor = .textColor
        subtitlelabel.textColor = .textColorSecoundery
    }

    func bind(with content : HomeV3Content){
        imageIV.kf.indicatorType = .activity
        let imageUrlStr =  content.image?.image1280 ?? ""
        imageIV.kf.setImage(with: URL(string: imageUrlStr),
                                        placeholder: UIImage(named: "tmp",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        self.titleLabel.text = content.title
        self.subtitlelabel.text = "\(content.artist ?? "") • \("0000") Views"
        //let img = content.image?.imageURL, let url = URL(string: img ?? ""){
            //imageIV.kf.setImage(with: url)
        //}
    }
}
