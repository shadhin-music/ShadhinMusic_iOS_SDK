//
//  SuggestedPlaylistsTC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/31/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SuggestedPlaylistsTC: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBOutlet weak var image0: UIImageView!
    @IBOutlet weak var image1: UIImageView!
    
    func setData(
        items : (CommonContentProtocol, CommonContentProtocol?),
        playlistSelection : @escaping (_ playlist:CommonContentProtocol) -> Void){
            let item0 = items.0
            let imgUrl0 = item0.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
            image0.kf.indicatorType = .activity
            image0.kf.setImage(with: URL(string: imgUrl0.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            image0.setClickListener {
                playlistSelection(item0)
            }
            guard let item1 = items.1 else {return}
            let imgUrl1 = item1.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
            image1.kf.indicatorType = .activity
            image1.kf.setImage(with: URL(string: imgUrl1.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            image1.setClickListener {
                playlistSelection(item1)
            }
    }
    
}
