//
//  StoryShareStepCellTen.swift
//  ShadhinStory
//
//  Created by Maruf on 14/12/23.
//

import UIKit


class StoryShareStepCellSeven: FSPagerViewCell {
   // let buttonWidth = UIScreen.main.bounds.width/2
    static var identifier : String {
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    @IBOutlet var topArtistNames: [UILabel]!
    @IBOutlet weak var totalTimeSpent: UILabel!
    @IBOutlet var topPodCastNames: [UILabel]!
    @IBOutlet var topSongNames: [UILabel]!
    var total = [UILabel]()
    @IBOutlet weak var shareButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        topSongNames.forEach { item in
         //   item.font = UIFont(name: "Inter-Regular", size: 8)
        }
    }
    
    func bindTopArtistData(artist:[TopStreammingElementModel]) {
        for index in 0..<topArtistNames.count {
            let topArtist = topArtistNames[index]
            var count = 1
            count += index
            topArtist.isHidden = false
            if index < artist.count {
                topArtist.text = "\(count) \(artist[index].contentName ?? "")"
            } else  {
                topArtist.isHidden = true
                topArtistNames[index].isHidden = true
            }
        }
    }
    
    func bindTopSongData(song:[TopStreammingElementModel]) {
        for index in 0..<topSongNames.count {
            var count = 1
            count += index
            let topSong = topSongNames[index]
            topSong.isHidden = false
            if  index < song.count {
                topSong.text = "\(count) \(song[index].contentName ?? "")"
            } else {
                topSong.isHidden = true
                topSongNames[index].isHidden = true
            }
        }
    }
    
    func bindTopPodcastData(podcast:[TopStreammingElementModel]) {
        for index in 0..<topPodCastNames.count {
            var count = 1
            count += index
            let topPodCast = topPodCastNames[index]
            topPodCast.isHidden = false
            if index < podcast.count {
                topPodCast.text = "\(count) \(podcast[index].contentName ?? "")"
            } else {
                topPodCast.isHidden = true
                topPodCastNames[index].isHidden = true
            }
        }
    }
    
}
