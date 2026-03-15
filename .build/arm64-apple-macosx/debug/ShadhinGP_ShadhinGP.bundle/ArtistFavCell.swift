//
//  PlaylistListCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/7/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit



class ArtistFavCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGFloat {
        return 192
    }
    
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var artlistNameL: UILabel!
    
//    func configureCell(model: PlaylistsObj.PlaylistDetails) {
//       
//    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
