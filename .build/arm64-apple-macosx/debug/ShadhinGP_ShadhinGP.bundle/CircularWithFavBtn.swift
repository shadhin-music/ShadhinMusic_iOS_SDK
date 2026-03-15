//
//  TopPopularArtistCell.swift
//  Shadhin
//
//  Created by Joy on 24/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CircularWithFavBtn: UICollectionViewCell{

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var height : CGFloat{
        return 260
    }
    
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var dataSource : [CommonContentProtocol]  = []
    
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
   // var onFollow : (CommonContentProtocol)-> Void = {_ in}
    var onSeeAllClick : ()-> Void = {}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(CircularWithFavBtnSub.nib, forCellWithReuseIdentifier: CircularWithFavBtnSub.identifier)
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dataSource.removeAll()
    }
    
    @IBAction func onSeeAllPressed(_ sender: Any) {
        onSeeAllClick()
    }
    
    func bind(title : String, data : [CommonContentProtocol],isSeeAll : Bool = false){
        self.titleLabel.text = title
        self.dataSource = data
        collectionView.reloadData()
        seeAllButton.isHidden = !isSeeAll
        
    }

}
extension CircularWithFavBtn : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircularWithFavBtnSub.identifier, for: indexPath) as? CircularWithFavBtnSub else{
            fatalError()
        }
        let obj = dataSource[indexPath.row]
        cell.bind(obj: obj)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemClick(dataSource[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CircularWithFavBtnSub.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

