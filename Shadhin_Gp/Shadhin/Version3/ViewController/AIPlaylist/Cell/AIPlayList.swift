//
//  AIPlayList.swift
//  Shadhin
//
//  Created by Maruf on 12/5/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AIPlayList: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var generateBtn: UIView!
    
    var selectedMoodId: String?
    var vc: HomeAdapterProtocol?
    
    var aiMoods = [MoodCategory]()
    
    static var identifier : String{
        return String(describing: self)
    }
    
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size : CGSize{
        return .init(width: 296, height: 87)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AIPlayListSubCell.nib, forCellWithReuseIdentifier: AIPlayListSubCell.identifier)
        generateBtn.setClickListener {
            if ConnectionManager.shared.isNetworkAvailable{
                self.getAIGeneratedPlaylist()
            } else {
                Toast.show(message: "You are offline", inView: self)
            }
        }
        self.getMoods()
    }
    
    private func progressViewSetUp() {
        let vc =  GeneratedVC.instantiateNib()
        vc.isDark = traitCollection.userInterfaceStyle == .dark
        let height: CGFloat = 300
        var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
        attributes.entryBackground = .color(color: .clear)
        attributes.border = .none
        attributes.scroll = .disabled
        attributes.screenInteraction = .absorbTouches
        var ekAttributes = EKAttributes()
        ekAttributes.entryInteraction = .absorbTouches
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 16, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        SwiftEntryKit.dismiss()
        SwiftEntryKit.display(entry: vc, using: attributes)
    }
    
//    private func goToSubscriptionVC() {
//        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.checkUserSubscription()
//        //let storyBoard = UIStoryboard(name: "Payment", bundle: nil)
//      //  let vc = SubscriptionV2VC.instantiateNib() //storyBoard.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
////        let navVC = UINavigationController(rootViewController: vc)
////        navVC.isNavigationBarHidden = true
////        navVC.modalPresentationStyle = .fullScreen
////        navVC.modalTransitionStyle = .coverVertical
//        //vc.isInBD = ShadhinCore.instance.userInBD()
//        if var top = UIApplication.shared.keyWindow?.rootViewController {
//            while let presentedViewController = top.presentedViewController {
//                top = presentedViewController
//            }
//          //  top.present(navVC, animated: true, completion: nil)
//        }
//    }
    
    private func getMoods(){
        ShadhinApi.getAIMoods {[weak self] moodResponse in
            guard let self = self else {return}
            switch moodResponse {
            case .success(let success):
                self.aiMoods = success.data
                self.collectionView.reloadData()
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func getAIGeneratedPlaylist() {
       // guard let selectedMoodId = selectedMoodId else {return}
        if let selectedMoodId = selectedMoodId {
            self.progressViewSetUp()
            ShadhinApi.getAIGeneratedPlayList(moodId: selectedMoodId, userCode: ShadhinCore.instance.defaults.userIdentity) {[weak self] aiGeneratedPlaylistResponse in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    SwiftEntryKit.dismiss()
                    guard let self = self else {return}
                    switch aiGeneratedPlaylistResponse {
                    case .success(let data):
                        if self.vc?.homeAdapter?.aiPlaylists == nil {
                            self.vc?.refreshHome()
                        }
                        self.vc?.navigateToAIGeneratedContent(content: data, imageUrl: "", playlistName: "", playlistId: "")
                    case .failure(let error):
                        print(error)
                        Toast.show(message: "Sometheing is wrong!", inView:self)
                    }
                })
            }
        } else {
            /// show tost
            Toast.show(message: "Please select a Mood", inView:self)
        }
    }
}

extension AIPlayList : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        aiMoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIPlayListSubCell.identifier, for: indexPath) as? AIPlayListSubCell else{
            fatalError()
        }
        cell.bind(data: aiMoods[indexPath.item], indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dynamicWidth = aiMoods[indexPath.item].name.widthOfAttributedString(withFont: .init(name: "OpenSans-Regular", size: 12.0) ?? .init()) + 8
        let width = max(64, dynamicWidth)
        return .init(width: width, height: 87.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         setGradientBackground()
        infoView.isHidden  = true
        selectedMoodId = String(aiMoods[indexPath.item].id)
    }
    
    private func setGradientBackground() {
        generateBtn.backgroundColor = .clear
        let gradientColors = [UIColor.init(red: 84, green: 51, blue: 255, a: 1),UIColor.init(red: 32, green: 189, blue: 255, a: 1),UIColor.init(red: 165, green: 254, blue: 203, a: 1)]
        generateBtn.applyGradient(colours: gradientColors, gradient: CAGradientLayer())
    }
}

