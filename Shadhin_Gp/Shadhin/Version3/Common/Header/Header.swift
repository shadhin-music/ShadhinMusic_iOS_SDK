//
//  Header.swift
//  Shadhin
//
//  Created by Joy on 27/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class Header: UICollectionReusableView {
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    @IBOutlet weak var ttitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
