//
//  EditAIMoodCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 21/5/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class EditAIMoodCell: UICollectionViewCell {
    var discoverModel: CommonContentProtocol!
    @IBOutlet weak var moodView: UIView!
    var isDark = false
    @IBOutlet weak var moodLbl: UILabel!
    @IBOutlet weak var dynamicGifBg: UIImageView!
    @IBOutlet weak var moodImageView: UIImageView!
    @IBOutlet weak var moodNameLabel: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    var selectedMoodId: String?
    var vc: HomeAdapterProtocol?
    
    @IBOutlet weak var generateButtonView: UIView!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGSize {
        let aspectRatio = 92.0/105.0 // aspectRatio = width/height
        let width = (SCREEN_WIDTH - 2*8-2*16-2*4)/3
        let height = width/aspectRatio
        return .init(width: width, height: height)
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
               moodViewColorSetUp()
                generateButtonView.isHidden = false
            } else {
                moodView.backgroundColor = UIColor.clear
                generateButtonView.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        generateButtonView.isHidden = true
        generateButtonView.setClickListener {
            if ConnectionManager.shared.isNetworkAvailable{
                if ShadhinCore.instance.isUserLoggedIn {
                    self.getAIGeneratedPlaylist()
                } else {
//                    let vc0 = SignInWithMsisddn()
//                    vc0.modalPresentationStyle = .fullScreen
//                    self.vc?.getNavController().viewControllers.first?.present(vc0, animated: true)
                }
            } else {
                Toast.show(message: "You are offline", inView: self)
            }
        }
    }
    func moodViewColorSetUp() {
        if isDark{
            moodView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            moodLbl.textColor = UIColor.white
        } else {
            moodView.backgroundColor = UIColor.white
            moodLbl.textColor = UIColor.black
        }
        // Set up shadow
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1) // Adjust the shadow offset as needed
        layer.shadowRadius = 2 // Adjust the shadow radius as needed
        layer.cornerRadius = 8
        layer.masksToBounds = false
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
                        self.vc?.homeVM?.frefreshAIPlaylists()
                        self.vc?.navigateToAIGeneratedContent(content: data, imageUrl: "", playlistName: "", playlistId: "")
                    case .failure(_): break
                        Toast.show(message: "Sometheing is wrong!", inView:self)
                    }
                })
            }
        } else {
           Toast.show(message: "Please select a Mood", inView:self)
        }
    }

    
    private func progressViewSetUp() {
        let vc =  GeneratedVC.instantiateNib()
        vc.isDark = isDark
        let height: CGFloat = 300
        var attributes = SwiftEntryKitAttributes.bottomAlertAttributesRound(height: height, offsetValue: 8)
        attributes.entryBackground = .color(color: .clear)
       // attributes.displayDuration.isDarkColor =
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
    
    private func setUpRandomBg(index: Int){
        let imageNo = index % 4 + 1
        dynamicGifBg.image = UIImage(named: "mood\(imageNo)_img",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        
    }
    
    func bind(data: MoodCategory, indexPath: IndexPath) {
        moodNameLabel.text = data.name
        let gifUrl = URL(string: data.gif)
        // moodImageView.kf.setImage(with: gifUrl)
        setUpRandomBg(index: indexPath.item)
        // Load the GIF image using Kingfisher
        if let gifUrl {
            loadGif(from: gifUrl)
        }
    }
    
    func loadGif(from url: URL) {
        moodImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { result in
            switch result {
            case .success(let value):
                // The image has been successfully loaded and set, Kingfisher handles the animation
                print("Successfully loaded GIF: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
    }


}
