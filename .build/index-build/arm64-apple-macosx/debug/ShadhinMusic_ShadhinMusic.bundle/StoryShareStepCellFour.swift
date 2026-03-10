//
//  StoryShareStepCellFive.swift
//  ShadhinStory
//
//  Created by Maruf on 13/12/23.
//

import UIKit


class StoryShareStepCellFour: FSPagerViewCell {
    private var topStreamingPatchData  : TopStreammingElementModel!
 //   let buttonWidth = UIScreen.main.bounds.width/2
    static var identifier : String {
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
//    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet var songNumbers: [UILabel]!
    @IBOutlet var artistNames: [UILabel]!
    @IBOutlet var topArtistImageNames: [UIImageView]!
    override func awakeFromNib() {
        super.awakeFromNib()
        topArtistImageNames.forEach { item in
            item.layer.cornerRadius = 4
        }
//        shareButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
//        shareButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        shareButton.layer.cornerRadius = 20
    }
    
    func bindData(artists: [TopStreammingElementModel]){
        for index in 0..<artistNames.count{
            let artistLbl = artistNames[index]
            artistLbl.isHidden = false
            if index < artists.count {
                artistLbl.text = artists[index].contentName
            }else{
                artistLbl.isHidden = true
                songNumbers[index].isHidden = true
            }
        }
    }
    
    func bindArtistImage(artists:[TopStreammingElementModel]) {
        for index in 0..<topArtistImageNames.count{
            let artistImg = topArtistImageNames[index]
            artistImg.isHidden = false
            if index < artists.count {
                let imgUrl = artists[index].imageURL?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
                artistImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            }else{
                artistImg.isHidden = true
            }
        }
    }
    
}

