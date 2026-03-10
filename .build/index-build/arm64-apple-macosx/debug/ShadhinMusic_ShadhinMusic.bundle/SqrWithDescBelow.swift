//
//  FavouritePlaylistCell.swift
//  Shadhin
//
//  Created by Joy on 18/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class SqrWithDescBelow: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var height : CGFloat{
        return 216
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    private var dataSource : [CommonContentProtocol] = []
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    var onSeeAll : ()-> Void = {}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(SquareV3Cell.nib, forCellWithReuseIdentifier: SquareV3Cell.identifier)
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func bind(with patch : HomeV3Patch){
        self.dataSource = patch.contents
        self.titleLabel.text = patch.patch.title
        self.seeAllButton.isHidden = (patch.patch.isSeeAllActive) ? false : true
        self.collectionView.reloadData()
    }
    
    @IBAction func onSeeAllPressed(_ sender: Any) {
        onSeeAll()
    }
}
extension SqrWithDescBelow : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareV3Cell.identifier, for: indexPath) as? SquareV3Cell else{
            fatalError()
        }
        //cell.bindForFavouroteArtist(with: <#T##ContentDataProtocol#>)
        cell.bind(with: dataSource[indexPath.row])
        cell.subtitleLabel.isHidden = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemClick(dataSource[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SquareV3Cell.sizeForFevouritePlaylist
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
