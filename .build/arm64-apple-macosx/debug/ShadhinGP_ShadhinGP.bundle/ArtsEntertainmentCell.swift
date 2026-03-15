//
//  Arts&EntertainmentCell.swift
//  Shadhin
//
//  Created by Maruf on 1/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ArtsEntertainmentCell: UICollectionViewCell {
    
    @IBOutlet weak var seeAllBtn: UIButton!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    var onSeeAll: (()->Void)?
    var onItemClick : (AudioPatchContent)-> Void = {_ in}
    var audioBookHome = [AudioPatchContent]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bgView: UIView!
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var size: CGSize {
        let aspectRatio = 360.0/355.0
        let width = SCREEN_WIDTH - 32
        let height = width/aspectRatio
        return CGSize(width: width, height: height)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        bgView.cornerRadius = 24
        collectionView.register(BookSubCell.nib, forCellWithReuseIdentifier: BookSubCell.identifier)
    }
    func bindAudioBookArtAndEntertainment(with patch:AudioPatchHome) {
        audioBookHome = patch.contents
        titleLbl.text = patch.patch.title
        subTitleLbl.text = patch.patch.description
        print("\(audioBookHome)")
    }
    
    @IBAction func seeAllClicked(_ sender: Any) {
        if let onSeeAll {
            onSeeAll()
        }
    }
    

}
extension ArtsEntertainmentCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        audioBookHome.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookSubCell.identifier, for: indexPath) as? BookSubCell else{
            fatalError("more menu cell load failed")
        }
        cell.bindDataArtAndEntertainment(content: audioBookHome[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        BookSubCell.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         onItemClick(audioBookHome[indexPath.item])
    }
}
