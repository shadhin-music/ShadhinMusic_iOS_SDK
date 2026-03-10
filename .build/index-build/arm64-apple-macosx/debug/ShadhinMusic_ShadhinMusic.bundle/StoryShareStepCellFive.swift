//
//  StoryShareStepCellSeven.swift
//  ShadhinStory
//
//  Created by Maruf on 14/12/23.
//

import UIKit


class StoryShareStepCellFive: FSPagerViewCell {
  //  let buttonWidth = UIScreen.main.bounds.width/2
    static var identifier : String {
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    @IBOutlet var songNames: [UILabel]!
    @IBOutlet var topSongImage: [UIImageView]!
    @IBOutlet var topSongNames: [UILabel]!
    override func awakeFromNib() {
        super.awakeFromNib()
        topSongNames.forEach { item in
            item.numberOfLines = 0
        }
        topSongImage.forEach { item in
            item.layer.cornerRadius = 4
        }
        
        // Initialization code
//        shareButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
//        shareButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        shareButton.layer.cornerRadius = 20
    }
    
    func bindTopSong(songs: [TopStreammingElementModel]){
        for index in 0..<topSongNames.count {
            let songName = topSongNames[index]
            songName.isHidden = false
            if index < songs.count{
                songName.text = songs[index].contentName
            } else {
                songName.isHidden = true
                songNames[index].isHidden = true
            }
        }
    }
    
    func bindTopImage(songs:[TopStreammingElementModel]) {
        for index in 0..<topSongNames.count  {
            let topImage = topSongImage[index]
            topImage.isHidden = false
            if index < songs.count{
                let imgUrl = songs[index].imageURL?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
                topImage.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            } else {
                topImage.isHidden = true
            }
        }
    }
}
