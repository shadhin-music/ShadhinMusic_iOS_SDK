//
//  CollapsibleHeaderCell.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CollapsibleHeaderCell: UICollectionReusableView {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
        
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var selectionModeBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var layoutBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    
//    var vc : FollowingArtistVC?
    
}
