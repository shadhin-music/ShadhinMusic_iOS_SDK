//
//  PopularArtistsCell.swift
//  Shadhin
//
//  Created by Maruf on 6/12/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SingleItemWithSeeAll: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var height : CGFloat{
        return 230
    }
    
    @IBOutlet weak var v1: PopularArtistItemView!
    
    @IBOutlet weak var v5: PopularArtistItemView!
    @IBOutlet weak var v4: PopularArtistItemView!
    @IBOutlet weak var v3: PopularArtistItemView!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var v2: PopularArtistItemView!
    
    private var dataSource : [CommonContentProtocol]  = []
    
    var onSeeAll : ()-> Void = {}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(with data : [CommonContentProtocol]){
        self.dataSource = data
        v1.isHidden = true
        v2.isHidden = true
        v3.isHidden = true
        v4.isHidden = true
        v5.isHidden = true
        
        if dataSource.count == 1{
            v1.bind(with: dataSource[0])
            v1.isHidden = false
            v2.isHidden = true
            v3.isHidden = true
            v4.isHidden = true
            v5.isHidden = true
        }else if dataSource.count == 2{
            v1.bind(with: dataSource[0])
            v2.bind(with: dataSource[1])
            v1.isHidden = false
            v2.isHidden = false
            v3.isHidden = true
            v4.isHidden = true
            v5.isHidden = true
        }else if dataSource.count == 3{
            v1.bind(with: dataSource[0])
            v2.bind(with: dataSource[1])
            v3.bind(with: dataSource[2])
            v1.isHidden = false
            v2.isHidden = false
            v3.isHidden = false
            v4.isHidden = true
            v5.isHidden = true
            
        }else if dataSource.count == 4{
            v1.bind(with: dataSource[0])
            v2.bind(with: dataSource[1])
            v3.bind(with: dataSource[2])
            v4.bind(with: dataSource[3])
            v1.isHidden = false
            v2.isHidden = false
            v3.isHidden = false
            v4.isHidden = false
            v5.isHidden = true
            
        }else if dataSource.count >= 5{
            v1.bind(with: dataSource[0])
            v2.bind(with: dataSource[1])
            v3.bind(with: dataSource[2])
            v4.bind(with: dataSource[3])
            v5.bind(with: dataSource[4])
            v1.isHidden = false
            v2.isHidden = false
            v3.isHidden = false
            v4.isHidden = false
            v5.isHidden = false
        }
    }
    @IBAction func onSeeAllPressed(_ sender: Any) {
        onSeeAll()
    }
}

