//
//  TracksHiddenSegmentTC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 7/25/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TracksHiddenSegmentTC: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBOutlet var trackImgCollection: [CircularImageView]!
    @IBOutlet weak var moreTrackHolder: CircularShadowView!
    @IBOutlet weak var moreTrackLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var seeAll: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let attrStr : NSMutableAttributedString = .init(string: "")
//        let songName = "This is a song name"
//        let songArtist = "artist name"
//        for i in 1...3 {
//            print(i)
//            let myAttribute0 = [
//                NSAttributedString.Key.foregroundColor: UIColor.blue,
//                NSAttributedString.Key.font: UIFont(name: "OpenSans-Regular", size: 14.0)! ]
//            let myAttrString0 = NSAttributedString(string: songName, attributes: myAttribute0)
//            attrStr.append(myAttrString0)
//            let myAttribute1 = [
//                NSAttributedString.Key.foregroundColor: UIColor.yellow,
//                NSAttributedString.Key.font: UIFont(name: "OpenSans-Regular", size: 12.0)! ]
//            let myAttrString1 = NSAttributedString(string: songArtist, attributes: myAttribute1)
//            attrStr.append(myAttrString1)
//        }
//        self.descriptionLbl.attributedText = attrStr
    }
    
    
    func setData(contents: [CommonContentProtocol]){
        let des : NSMutableAttributedString = .init(string: "")
        let songNameAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.primaryLableColor()
//            NSAttributedString.Key.font: UIFont(name: "OpenSans-Regular", size: 14.0)!
        ]
        let artistNameAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabelColor()
//            NSAttributedString.Key.font: UIFont(name: "OpenSans-Regular", size: 12.0)!
        ]
        for i in 0...4{
            if i < contents.count{
                trackImgCollection[i].isHidden = false
                let imgUrl = contents[i].image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
                trackImgCollection[i].kf.indicatorType = .activity
                trackImgCollection[i].kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
                if let name = contents[i].title{
                    let attrStr = NSAttributedString(string: name, attributes: songNameAttributes)
                    des.append(attrStr)
                }
                if let artist = contents[i].artist{
                    let attrStr = NSAttributedString(string: "  \(artist)\( i < 4 ? "  •  " : "")", attributes: artistNameAttributes)
                    des.append(attrStr)
                }
            }else{
                trackImgCollection[i].isHidden = true
            }
            if contents.count > 5{
                let count = contents.count - 5
                moreTrackHolder.isHidden = false
                moreTrackLbl.text = "+\(count)"
            }else{
                moreTrackHolder.isHidden = true
            }
            
        }
        descriptionLbl.attributedText = des
        
    }
    
}
