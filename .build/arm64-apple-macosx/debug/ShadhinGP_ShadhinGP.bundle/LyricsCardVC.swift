//
//  LyricsCardVC.swift
//  Shadhin
//
//  Created by Rezwan on 8/9/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class LyricsCardVC: UIViewController {

    @IBOutlet weak var handleAreaLyrics: UIView!
    @IBOutlet weak var stateImg: UIImageView!
    @IBOutlet weak var lyrics_bg: UIImageView!
    @IBOutlet weak var lyricsTv: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    
    var lyrics = ""
    var frame: CGRect = .zero
    var tapGestureRecognizer: UITapGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let randomImg = Int.random(in: 1...14)
        //lyrics_bg.image = #imageLiteral(resourceName: "lyrics_bg_\(randomImg)")
        let attribute = lyrics.htmlToAttributedString
        attribute?.addAttribute(.foregroundColor, value: UIColor.primaryLableColor(), range: NSRange(location: 0, length: attribute?.length ?? 0))
        lyricsTv.attributedText = attribute
        
        //lyricsTv.textColor = .white
        lyricsTv.font = UIFont(name: "OpenSans-Regular", size: 16.0)
        
        if lyrics.isEmpty{
            availableLabel.text = "Unavailable"
            availableLabel.textColor = .textColorSecoundery
            stateImg.tintColor = .textColorSecoundery
        }else{
            availableLabel.text = "Available"
            availableLabel.textColor = .appTintColor
            stateImg.tintColor = .appTintColor
        }

        self.view.frame = frame
        self.view.clipsToBounds = true
        self.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        self.handleAreaLyrics.addGestureRecognizer(tapGestureRecognizer)
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func update(str : String){
        self.lyrics = str
        let attribute = str.htmlToAttributedString
            attribute?.addAttribute(.foregroundColor, value: UIColor.primaryLableColor(), range: NSRange(location: 0, length: attribute?.length ?? 0))
        lyricsTv.attributedText = attribute
        //lyricsTv.textColor = .white
        lyricsTv.font = UIFont(name: "OpenSans-Regular", size: 16.0)
        
        if lyrics.isEmpty{
            availableLabel.text = "Unavailable"
            availableLabel.textColor = .textColorSecoundery
            stateImg.tintColor = .textColorSecoundery
        }else{
            availableLabel.text = "Available"
            availableLabel.textColor = .appTintColor
            stateImg.tintColor = .appTintColor
        }
    }
}
