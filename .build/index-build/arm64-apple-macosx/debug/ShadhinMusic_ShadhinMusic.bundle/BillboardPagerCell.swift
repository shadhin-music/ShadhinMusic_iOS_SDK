//
//  BillboardPagerCell.swift
//  Shadhin
//
//  Created by Gakk Alpha on 5/23/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit



class BillboardPagerCell: FSPagerViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var liveSeg: UIView!
    //@IBOutlet weak var liveSegAni: LottieAnimationView!
    @IBOutlet weak var videoHolder: UIView!
    

}
