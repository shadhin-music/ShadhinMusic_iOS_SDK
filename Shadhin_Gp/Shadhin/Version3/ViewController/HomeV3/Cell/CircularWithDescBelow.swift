//
//  PopularBandCell.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CircularWithDescBelow: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat {
        return 216
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var dataSource : [CommonContentProtocol] =  []
    var onItemClick : (CommonContentProtocol)-> Void = {_ in}
    var onSeeAll : ()-> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor =  .textColor
        collectionView.register(CircularCellCV.nib, forCellWithReuseIdentifier: CircularCellCV.identifier)
        collectionView.contentInset  = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @IBAction func onSeeAllPressed(_ sender: Any) {
        onSeeAll()
    }
    
    func bind(with title : String = "", _ dataSource : [CommonContentProtocol],isSeeAll : Bool = false){
        self.titleLabel.text = title
        self.dataSource = dataSource
        self.seeAllButton.isHidden = !isSeeAll
        collectionView.reloadData()
    }
}


extension CircularWithDescBelow : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let obj = dataSource[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CircularCellCV.identifier, for: indexPath) as? CircularCellCV else{
            fatalError()
        }
        cell.bind(with: obj.title ?? "", obj.image  ?? "")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onItemClick(dataSource[indexPath.row])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = collectionView.bounds.height - 16
        return .init(width: h - 20 - 4 - 4, height: h)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
