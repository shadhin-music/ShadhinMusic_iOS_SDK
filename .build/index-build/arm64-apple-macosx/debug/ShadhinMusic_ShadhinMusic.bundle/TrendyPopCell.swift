//
//  TrendyPopCell.swift
//  Shadhin
//
//  Created by Joy on 18/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class TrendyPopCell: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat{
        return 280
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageIV: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private var dataSource : [CommonContentProtocol] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .textColorSecoundery
        subtitleLabel.font = UIFont(name: "Inter-Regular", size: 12)
        
        collectionView.register(SquareV3Cell.nib, forCellWithReuseIdentifier: SquareV3Cell.identifier)
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
}
extension TrendyPopCell : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10//dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareV3Cell.identifier, for: indexPath) as? SquareV3Cell else{
            fatalError()
        }
        //cell.bindForFavouroteArtist(with: <#T##ContentDataProtocol#>)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SquareV3Cell.sizeForTrendyPop
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
