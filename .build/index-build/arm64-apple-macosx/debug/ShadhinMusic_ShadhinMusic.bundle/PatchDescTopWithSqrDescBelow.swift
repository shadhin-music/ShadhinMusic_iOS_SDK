//
//  TopArtistSongCell.swift
//  Shadhin
//
//  Created by Joy on 23/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PatchDescTopWithSqrDescBelow: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var height : CGFloat{
        return 240
    }
    
    @IBOutlet weak var imageIV: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var dataSource : [CommonContentProtocol] = []
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .textColorSecoundery
        
        collectionView.register(SquareV3Cell.nib, forCellWithReuseIdentifier: SquareV3Cell.identifier)
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func bind(with dataSource : [CommonContentProtocol]){
        self.dataSource = dataSource
        self.collectionView.reloadData()
    }
    func bind(with data : HomeV3Patch){
        self.titleLabel.text = data.patch.title
        self.subtitleLabel.text = data.patch.description
        self.dataSource = data.contents
        self.collectionView.reloadData()
        
        imageIV.kf.setImage(with: URL(string: data.contents.first?.image?.image300 ?? ""))
    }
}
extension PatchDescTopWithSqrDescBelow : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SquareV3Cell.identifier, for: indexPath) as? SquareV3Cell else{
            fatalError()
        }
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
