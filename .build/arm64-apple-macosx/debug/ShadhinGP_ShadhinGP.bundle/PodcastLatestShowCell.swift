//
//  PodcastLatestShowCell.swift
//  Shadhin
//
//  Created by Rezwan on 8/4/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PodcastLatestShowCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGFloat {
        return 316
    }

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var textPrimary: UILabel!
    @IBOutlet weak var textSecondary: UILabel!
    @IBOutlet weak var textDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(item : PatchShowItem){
        let imgUrl = item.imageURL.replacingOccurrences(of: "<$size$>", with: "225")
        img.kf.indicatorType = .activity
        img.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        
        textPrimary.text = item.showName
        textSecondary.text = item.presenter
        //textDescription.text = item.about.htmlToString
        
        item.about.attributedStringFromHTML(completionBlock: { attrStr in
            DispatchQueue.main.async { [weak self] in
                if let attrStr = attrStr{
                    //cell?.aboutLabel.attributedText = attrStr
                    self?.textDescription.attributedText = attrStr
                }else{
                    self?.textDescription.text = ""
                    self?.textDescription.textColor = .primaryLableColor()
                }
             }
        })
    }
    
}
