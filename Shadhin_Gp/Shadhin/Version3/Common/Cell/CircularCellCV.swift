//
//  CircularCellCV.swift
//  Shadhin-BL
//
//  Created by Joy on 22/8/22.
//

import UIKit
class CircularCellCV: UICollectionViewCell {

    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    override func draw(_ rect: CGRect) {
            super.draw(rect)
        if imageIV != nil{
            imageIV.layer.cornerRadius = self.frame.size.width / 2
        }
            
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor = .textColor
    }
    
    //for home cell load
    func bind(with title : String, _ image : String){
        titleLabel.text = title
        imageIV.kf.setImage(with: URL(string: image.imageURL.safeUrl()))
    }
    
}
//use this
//artist details
