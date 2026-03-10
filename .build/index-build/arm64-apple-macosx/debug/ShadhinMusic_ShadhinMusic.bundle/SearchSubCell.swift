//
//  SearchCollectionViewCell.swift
//  Shadhin
//
//  Created by Maruf on 8/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit


class SearchSubCell: UICollectionViewCell {
    @IBOutlet weak var searchTitle: UILabel!
    @IBOutlet weak var searchListView: UIView!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func searchCatagoryModifed () {
        //
    }
    func titleBind() {
       //
    }
    
    override var isSelected: Bool {
        didSet {
            if traitCollection.userInterfaceStyle == .dark {
                if isSelected{
                    searchTitle.textColor = UIColor.white
                    layer.backgroundColor = UIColor.tintColor.cgColor
                    layer.borderWidth = 0
                    layer.borderColor = UIColor.clear.cgColor
                }
                else {
                    searchTitle.textColor = UIColor.gray
                    layer.borderColor = UIColor.gray.cgColor
                    layer.backgroundColor = UIColor.black.cgColor
                    layer.borderWidth = 1
                    layer.borderColor = UIColor.lightGray.cgColor
                }
            } else {
                if isSelected {
                    searchTitle.textColor = UIColor.white
                    layer.backgroundColor = UIColor.tintColor.cgColor
                    layer.borderWidth = 0
                    layer.borderColor = UIColor.clear.cgColor
                }
                else {
                    layer.borderWidth = 1
                    searchTitle.textColor = UIColor.gray
                    layer.borderColor = UIColor.gray.cgColor
                    layer.backgroundColor = UIColor.white.cgColor
                }
            }
        }
    }
}


