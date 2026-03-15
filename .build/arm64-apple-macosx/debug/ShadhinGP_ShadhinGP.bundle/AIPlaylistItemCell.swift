//
//  AIPlaylistItemCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 14/5/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AIPlaylistItemCell: UICollectionViewCell{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var aiPlaylists: [NewContent] = []
    
    static var identifier : String{
        return String(describing: self)
    }
    
    var vc: HomeAdapterProtocol?
    
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AIPlaylistItemSubCell.nib, forCellWithReuseIdentifier: AIPlaylistItemSubCell.identifier)
    }

    @IBAction func editAIPlaylist(_ sender: Any) {
        if ShadhinCore.instance.isUserPro {
            showAIMoods()
        } else {
            NavigationHelper.shared.navigateToSubscription(from: self.vc as? UIViewController)
        }
        //self.vc as? UIViewController
    }

    private func showAIMoods() {
        let vc =  EditAIMoodVC.instantiateNib()
        vc.vc = self.vc
        let height: CGFloat = 498.0
        var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
        attributes.entryBackground = .color(color: .clear)
        attributes.border = .none
       // attributes.scroll = .disabled
        //attributes.screenInteraction = .absorbTouches
        var ekAttributes = EKAttributes()
        //ekAttributes.entryInteraction = .absorbTouches
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 16, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        SwiftEntryKit.dismiss()
        SwiftEntryKit.display(entry: vc, using: attributes)
    }

}
extension AIPlaylistItemCell: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        aiPlaylists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIPlaylistItemSubCell.identifier, for: indexPath) as? AIPlaylistItemSubCell else{
            fatalError()
        }
        cell.bind(data: aiPlaylists[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return AIPlaylistItemSubCell.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: -
        if !ShadhinCore.instance.isUserPro {
            NavigationHelper.shared.navigateToSubscription(from: self.vc as? UIViewController)
        } else if ConnectionManager.shared.isNetworkAvailable{
            vc?.navigateToAIGeneratedContent(content: nil, imageUrl: aiPlaylists[indexPath.item].imageUrl, playlistName: aiPlaylists[indexPath.item].titleEn, playlistId: String(aiPlaylists[indexPath.item].contentId))
        } else{
            Toast.show(message: "You are offline", inView: self)
        }
       
    }
    
}
