//
//  StepCellThree.swift
//  ShadhinStory
//
//  Created by Maruf on 13/12/23.
//

import UIKit


class StoryShareStepCellThree: FSPagerViewCell {
    private var topStreamingPatchData : TopStreammingElementModel!
    let buttonWidth = UIScreen.main.bounds.width/2
    static var identifier : String {
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    @IBOutlet weak var timeSpentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        timeSpentLabel.layer.cornerRadius = 8
        timeSpentLabel.clipsToBounds = true 
    }
}
