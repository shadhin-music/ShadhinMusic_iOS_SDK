//
//  PodcastHeaderTwoViewCell.swift
//  Shadhin
//
//  Created by Rezwan on 2/10/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit


class PodcastHeaderTwoViewCell: UITableViewCell {


    
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return UITableView.automaticDimension

    }
    
    @IBOutlet weak var aboutLabel: ReadMoreLessView!
    @IBOutlet weak var adBannerMax: UIView!
    
    
    override func awakeFromNib() {
    }

}
