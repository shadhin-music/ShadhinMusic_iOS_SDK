//
//  TopGenresSubCell.swift
//  Shadhin
//
//  Created by Joy on 18/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TwoRowSqrSub: UICollectionViewCell {
    
    @IBOutlet weak var genreImage: UIImageView!
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size : CGSize{
        return .init(width: 136, height: 136)
    }
    
    private let color : [UIColor] = [UIColor(red: 0.706, green: 0.863, blue: 0.918, alpha: 1), UIColor(red: 0.82, green: 0.892, blue: 0.803, alpha: 1),UIColor(red: 0.822, green: 0.932, blue: 0.967, alpha: 1),UIColor(red: 0.979, green: 0.884, blue: 0.689, alpha: 1),UIColor(red: 0.805, green: 0.807, blue: 0.933, alpha: 1),UIColor(red: 0.921, green: 0.779, blue: 0.881, alpha: 1) ]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func bindWith(obj : CommonContentProtocol){
        genreImage.kf.setImage(with: URL(string: obj.image?.image300 ?? ""))
    }
}
