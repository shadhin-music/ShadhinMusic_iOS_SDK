//
//  ChipCell.swift
//  Shadhin
//
//  Created by Admin on 20/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ChipCell: UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    @IBOutlet weak var crossImageView: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if #available(iOS 13, *){
            let img = AppImage.close.uiImage(with: 10, tintColor: UIColor.secondaryLabelColor())
            crossImageView.setImage(img, for: .normal)
        }else{
            crossImageView.setImage(AppImage.close12.uiImage, for: .normal)
        }
        crossImageView.isHidden = true
        crossImageView.isUserInteractionEnabled = false
        self.titleLabel.textColor = UIColor.secondaryLabelColor()
        layer.borderColor = UIColor.secondaryLabelColor().cgColor
    }

    override var isSelected: Bool{
        didSet{
            if isSelected{
                self.backgroundColor = .appTintColor
                self.titleLabel.textColor = .white
                layer.borderColor = UIColor.appTintColor.cgColor
            }else{
                self.backgroundColor = .clear
                self.titleLabel.textColor = UIColor.secondaryLabelColor()
                layer.borderColor = UIColor.secondaryLabelColor().cgColor
            }
        }
    }
    //MARK: create nib for access this view
    static func nib()-> UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
}
extension ChipCell{
    func setData(with obj : DownloadChipModel){
        if obj.type == .None{
            titleLabel.isHidden = true
            crossImageView.isHidden = false
        }else{
            titleLabel.isHidden = false
            crossImageView.isHidden = true
            titleLabel.text = obj.title
        }
        
    }
}
