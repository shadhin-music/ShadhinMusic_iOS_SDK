//
//  StoryShareStepCellNie.swift
//  ShadhinStory
//
//  Created by Maruf on 14/12/23.
//

import UIKit


class StoryShareStepCellSix: FSPagerViewCell {
    static var identifier : String {
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    @IBOutlet var podCastNumberLbl: [UILabel]!
    @IBOutlet var topPodcastImageNames: [UIImageView]!
    @IBOutlet var podCastNames: [UILabel]!
    override func awakeFromNib() {
        super.awakeFromNib()
        topPodcastImageNames.forEach { item in
            item.layer.cornerRadius = 4
        }

    }
    func bindTopPodcastData(podCast:[TopStreammingElementModel]) {
        for index in 0..<podCastNames.count  {
            let topPodcast = podCastNames[index]
            topPodcast.isHidden = false
            if index < podCast.count {
                topPodcast.text = podCast[index].contentName
            } else {
                topPodcast.isHidden = true
                podCastNumberLbl[index].isHidden = true
            }
        }
    }
    
    func bindTopPodcastImage(podCast:[TopStreammingElementModel]) {
        for index in 0..<topPodcastImageNames.count {
            let topPodcastImg = topPodcastImageNames[index]
            topPodcastImg.isHidden = false
            if index < podCast.count {
                let imgUrl = podCast[index].imageURL?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
                topPodcastImg.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_artist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
            } else {
                topPodcastImg.isHidden = true
            }
        }
        
    }
}
