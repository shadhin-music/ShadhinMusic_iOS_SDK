//
//  MusicListCell.swift
//  Shadhin_Gp
//
//  Created by Maruf on 1/8/24.
//

import UIKit

class MusicListCell: UIView {
    
    @IBOutlet weak var catagoryImgView: UIImageView!
    var imgName: String = ""
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        dataBind(image: imgName)
        // Initialization code
    }
    func dataBind(image:String) {
        self.catagoryImgView.kf.indicatorType = .activity
        self.catagoryImgView.kf.setImage(
            with: URL(string: image.image300),
            placeholder: UIImage(named: "")
        )
    }
}
