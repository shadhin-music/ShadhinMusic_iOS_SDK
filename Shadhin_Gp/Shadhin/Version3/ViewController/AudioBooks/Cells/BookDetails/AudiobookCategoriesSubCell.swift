//
//  AudiobookCategoriesSubCell.swift
//  Shadhin
//
//  Created by Maruf on 1/10/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AudiobookCategoriesSubCell: UICollectionViewCell {

    @IBOutlet weak var catagoriesName: UILabel!
    @IBOutlet weak var catagoriesImg: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    private var content: AudioPatchContent?
    private var contents: HomeV3Content?
    
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        let aspectRatio = 70.0 / 120.0
        let width = (SCREEN_WIDTH - 32) / 4
        let height = (width / aspectRatio) / 2.0
        return CGSize(width: width, height: height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 22
        bgView.clipsToBounds = true
    }
    
    // MARK: - Public Bind Method
    func bindDataBasedOnType(content: Any) {
        if let audioContent = content as? AudioPatchContent {
            bindData(content: audioContent)
        } else if let homeV3Content = content as? HomeV3Content {
            bindV3(content: homeV3Content)
        } else {
            print("Unsupported content type")
        }
    }
    
    // MARK: - Bind for AudioPatchContent
    func bindData(content: AudioPatchContent) {
        self.content = content
        updateImageAppearance()
        catagoriesName.text = content.titleEn
        catagoriesName.adjustsFontSizeToFitWidth = true
        catagoriesName.minimumScaleFactor = 0.7
        catagoriesName.numberOfLines = 2
    }
    
    // MARK: - Bind for HomeV3Content
    func bindV3(content: HomeV3Content) {
        self.contents = content
        updateImageAppearanceV3()
        catagoriesName.text = content.title
        catagoriesName.adjustsFontSizeToFitWidth = true
        catagoriesName.minimumScaleFactor = 0.7
        catagoriesName.numberOfLines = 2
    }
    
    // MARK: - Image Appearance for HomeV3
    private func updateImageAppearanceV3() {
        guard let content = contents else { return }
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        if let imageURLString = content.imageModes?.compactMap({ $0.darkModeImage }).joined(separator: " "),
           let url = URL(string: imageURLString) {
            
            // ✅ Load PNG/JPG/WebP only
            catagoriesImg.kf.setImage(with: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        // Always render as template for tint color
                        self.catagoriesImg.image = value.image.withRenderingMode(.alwaysTemplate)
                        self.catagoriesImg.contentMode = .scaleAspectFit
                        self.catagoriesImg.tintColor = isDarkMode ? .white : .black
                    }
                case .failure(let error):
                    print("Image load failed: \(error.localizedDescription)")
                }
            }
        } else {
            // Fallback: default icon (e.g. SF Symbol)
            catagoriesImg.image = UIImage(systemName: "book.fill")?.withRenderingMode(.alwaysTemplate)
            catagoriesImg.tintColor = isDarkMode ? .white : .black
        }
    }
    
    // MARK: - Image Appearance for AudioPatchContent
    private func updateImageAppearance() {
        guard let content = content else { return }
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        if let imageURLString = content.imageModes.first?.darkModeImage,
           let url = URL(string: imageURLString) {
            
            catagoriesImg.kf.setImage(with: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.catagoriesImg.image = value.image.withRenderingMode(.alwaysTemplate)
                        self.catagoriesImg.contentMode = .scaleAspectFit
                        self.catagoriesImg.tintColor = isDarkMode ? .white : .black
                    }
                case .failure(let error):
                    print("Image load failed: \(error.localizedDescription)")
                }
            }
        } else {
            // Fallback to SF Symbol if image not found
            catagoriesImg.image = UIImage(systemName: "music.note.list")?.withRenderingMode(.alwaysTemplate)
            catagoriesImg.tintColor = isDarkMode ? .white : .black
        }
    }
    
    // MARK: - Handle Dark/Light Mode Change
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if content != nil {
                    updateImageAppearance()
                } else if contents != nil {
                    updateImageAppearanceV3()
                }
            }
        }
    }
}
