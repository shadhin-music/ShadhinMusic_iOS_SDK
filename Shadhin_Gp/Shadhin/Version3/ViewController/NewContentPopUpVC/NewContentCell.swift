//
//  NewContentCell.swift
//  Shadhin
//
//  Created by Joy on 18/7/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit


class NewContentCell: FSPagerViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if #available(iOS 13.0, *) {
            self.contentView.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        self.layer.cornerRadius = 8
        
    }

    func bind(content : CommonContentProtocol){
        if let img = content.image{
            ivImage.kf.setImage(with: URL(string: img))
        }
        titleLabel.text = content.title
        subtitleLabel.text = content.artist
        topLabel.isHidden = true
    }
}
