//
//  StepCellTwo.swift
//  ShadhinStory
//
//  Created by Maruf on 13/12/23.
//

import UIKit


class StoryShareStepCellTwo:FSPagerViewCell {
    @IBOutlet weak var userName: UILabel!
    
    static var identifier : String {
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let name = ShadhinCore.instance.defaults.userName
        userName.text = "Hello \(name)"
        // Initialization code
    }
}
