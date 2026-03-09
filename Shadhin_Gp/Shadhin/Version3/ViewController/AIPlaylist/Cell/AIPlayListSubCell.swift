//
//  AIPlayListSubCell.swift
//  Shadhin
//
//  Created by Maruf on 12/5/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AIPlayListSubCell: UICollectionViewCell {
    
    @IBOutlet weak var moodLbl: UILabel!
    @IBOutlet weak var moodImageView: AnimatedImageView!
    @IBOutlet weak var moodNameLabel: UILabel!
    @IBOutlet weak var moodView: UIView!
    @IBOutlet weak var dynamicGifBg: UIImageView!
    override var isSelected: Bool{
       didSet{
           if isSelected {
               moodViewColorSetUp()
           } else {
               moodView.backgroundColor = UIColor.clear
           }
       }
   }
    
    static var identifier : String{
        return String(describing: self)
    }
    
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moodLbl.textColor = UIColor(named: "progressImgBgColor", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
    }

    func moodViewColorSetUp() {
        moodView.backgroundColor = UIColor(named: "procressViewBgColor",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
     //   moodView.backgroundColor = UIColor.red
        moodLbl.textColor = UIColor(named: "progressImgBgColor", in: Bundle.ShadhinMusicSdk, compatibleWith: nil)
        // Set up shadow
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1) // Adjust the shadow offset as needed
        layer.shadowRadius = 2 // Adjust the shadow radius as needed
        layer.cornerRadius = 8
        layer.masksToBounds = false
    }
    
    private func setUpRandomBg(index: Int){
        let imageNo = index % 4 + 1
        dynamicGifBg.image = UIImage(named: "mood\(imageNo)_img",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        
    }
    
    func bind(data: MoodCategory, indexPath: IndexPath) {
        moodNameLabel.text = data.name
        let gifUrl = URL(string: data.gif)
        // moodImageView.kf.setImage(with: gifUrl)
        setUpRandomBg(index: indexPath.item)
        // Load the GIF image using Kingfisher
        if let gifUrl {
            loadGif(from: gifUrl)
        }
    }
    
    func loadGif(from url: URL) {
        moodImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { result in
            switch result {
            case .success(let value):
                // The image has been successfully loaded and set, Kingfisher handles the animation
                print("Successfully loaded GIF: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
          super.traitCollectionDidChange(previousTraitCollection)
          
      }
}


