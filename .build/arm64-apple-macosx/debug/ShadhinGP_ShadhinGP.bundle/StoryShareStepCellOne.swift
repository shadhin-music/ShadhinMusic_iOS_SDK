//
//  StepCellOne.swift
//  ShadhinStory
//
//  Created by Maruf on 13/12/23.
//

import UIKit

class StoryShareStepCellOne: FSPagerViewCell {
    
    static var identifier : String {
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
