//
//  ChapterHeaderCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 13/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ChapterHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var chapterLbl: UILabel!
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        let aspectRatio = 360.0/48.0
        let width = SCREEN_WIDTH
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindForAuthor(authors:Author) {
        chapterLbl.text = authors.name
    }
    func bindForNarrator(narrator: Narrator){
        chapterLbl.text = narrator.name
        
    }
    
}
