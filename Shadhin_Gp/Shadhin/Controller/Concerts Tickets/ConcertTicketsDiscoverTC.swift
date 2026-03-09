//
//  ConcertTicketsDiscoverTC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/24/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ConcertTicketsDiscoverTC: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBOutlet weak var buyTicketBtn: UIButton!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    
    @IBOutlet var artistsImgs: [CircularImageView]!
    @IBOutlet weak var artistCount: UILabel!
    
    
    func bind(_ details: ConcertEventObj){
        let imgUrl = details.data.banner
        mainImg.kf.indicatorType = .activity
        mainImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_playlist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        eventDate.text = details.data.campaignDate
        eventTitle.text = details.data.name
        eventLocation.text = details.data.address

        for i in 0...5{
            if i < details.data.artist.count{
                let artist = details.data.artist[i]
                artistsImgs[i].isHidden = false
                let aImgUrl = artist.image.replacingOccurrences(of: "<$size$>", with: "300")
                artistsImgs[i].kf.setImage(with: URL(string: aImgUrl.safeUrl()))
            }else{
                artistsImgs[i].isHidden = true
            }
        }
        if details.data.artist.count > 6{
            artistCount.isHidden = false
            artistCount.text = "\(details.data.artist.count-6)+ Artists"
        }else{
            artistCount.isHidden = true
        }
    }
}
