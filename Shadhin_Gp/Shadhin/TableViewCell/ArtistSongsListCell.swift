//
//  ArtistSongsListCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/16/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import SwiftUI

class ArtistSongsListCell: UITableViewCell {
    
    @IBOutlet weak var welcomeTuneBtn: UIButton!
    @IBOutlet weak var badgeViewWithConstraints: NSLayoutConstraint!
    @IBOutlet weak var badgaeLbl: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var songsImgView: UIImageView!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var songArtistLbl: UILabel!
    @IBOutlet weak var songsDurationLbl: UILabel!
    @IBOutlet weak var threeDotBtn: UIButton!
    @IBOutlet weak var circularProgress: CircularProgress!
    @IBOutlet weak var rbtBtn: UIButton!
    @IBOutlet weak var downloadMarkImageView: UIImageView!
    
    private var threeDotMenuClick: (()->())?
    private let badgeTexts = ["Set","Welcome","Tune"]
    private var didTapWelcomeTune: (() -> ())?
    private var badgeIndex = 0
    private var badgeTimer: Timer?


    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopBadgeAnimation()
        initHide()
    }

    
    @IBAction func welcomeSetBtnAction(_ sender: Any) {
        didTapWelcomeTune?()
    }
    
    @IBAction func threeDotMenuAction(_ sender: Any) {
        threeDotMenuClick?()
    }
    
    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }
}

extension ArtistSongsListCell {

    func setupUI() {
        initHide()
        songTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        songsDurationLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        circularProgress.isHidden = true
        circularProgress.font = .systemFont(ofSize: 8)

        badgeView.layer.backgroundColor = UIColor.clear.cgColor
        badgeView.layer.borderWidth = 0.5
        badgeView.layer.borderColor = UIColor.appTint.cgColor
        badgeView.layer.cornerRadius = 12
        badgeView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner
        ]
        badgeView.clipsToBounds = true
        badgaeLbl.font = .systemFont(ofSize: 12, weight: .regular)
        badgaeLbl.textAlignment = .center
    }
    
    func didTappedWelcomeTuneSet(completion: @escaping (()->())) {
        didTapWelcomeTune = completion
    }
    
    func initHide() {
        self.welcomeTuneBtn.isHidden = true
        self.badgaeLbl.isHidden = true
        self.badgeView.isHidden = true
        songsDurationLbl.isHidden = true
    }
    
    func configureWelcomeTuneButton(operators: [String]?) {
        let hasGP = operators?.contains { op in
            op.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == "GP"
        } ?? false
        self.welcomeTuneBtn.isHidden = !hasGP
    }

    func configureCell(model: CommonContentProtocol, _ showCount: Bool = false, indexInSection: Int = 0) {
        songTitleLbl.text = model.title ?? ""
        songArtistLbl.text = model.artist ?? ""
        songsDurationLbl.text = formatSecondsToString(Double(model.duration ?? "") ?? 123)
        let imgUrl = ShadhinApi.getImageUrl(url: model.image ?? "", size: 300)
        songsImgView.kf.indicatorType = .activity
        songsImgView.kf.setImage(with: imgUrl, placeholder: UIImage(named: "default_song", in: Bundle.ShadhinMusicSdk, compatibleWith: nil))
        checkSongsIsDownloading(data: model)

        self.configureWelcomeTuneButton(operators: model.rbtOperators)

        let hasGP = model.rbtOperators?.containsGP() ?? false
        if hasGP && indexInSection == 0 {
            showBadgeAndStartAnimation()
        } else {
            stopBadgeAnimation()
            badgeView.isHidden = true
            badgaeLbl.isHidden = true
        }

        if DatabaseContext.shared.isSongExist(contentId: model.contentID ?? "") {
            if #available(iOS 13, *) {
                downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
            } else {
                downloadMarkImageView.image = AppImage.downloaded12.uiImage
            }
        } else {
            if #available(iOS 13, *) {
                downloadMarkImageView.image = AppImage.notDownload.uiImage
            } else {
                downloadMarkImageView.image = AppImage.nonDownload12.uiImage
            }
        }
    }

    func checkSongsIsDownloading(data: CommonContentProtocol) {
        
        let isDownloading = SDDownloadManager.shared.isDownloadInProgress(forKey: data.playUrl)
        self.threeDotBtn.isHidden = isDownloading
        self.circularProgress.isHidden = !isDownloading
        
        if isDownloading {
            guard let obj = SDDownloadManager.shared.currentDownload(forKey: data.playUrl) else {
                return
            }
            //for all download songs
            obj.progressBlock = { progress in
                Log.error("Progress : \(progress)")
                self.circularProgress.setProgress(progress: progress, animated: true)
                if progress == 1.0{
                    self.threeDotBtn.isHidden = false
                    self.circularProgress.isHidden = true
                    self.circularProgress.setProgress(progress: 0.0)
                    DatabaseContext.shared.addSong(content: data,isSingleDownload: obj.isSingle ?? true)
                    if #available(iOS 13, *){
                        self.downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
                    }else{
                        self.downloadMarkImageView.image = AppImage.downloaded12.uiImage
                    }
                    self.makeToast("File successfully downloaded.")
                }
            }
            
        }
    }
}

private extension ArtistSongsListCell {

    func showBadgeAndStartAnimation() {
        badgeView.isHidden = false
        badgaeLbl.isHidden = false
        badgaeLbl.alpha = 1
        startBadgeAnimationIfNeeded()
    }

    func startBadgeAnimationIfNeeded() {
        stopBadgeAnimation()
        badgeIndex = 0
        updateBadge(animated: false)

        badgeTimer = Timer.scheduledTimer(
            timeInterval: 2.5,
            target: self,
            selector: #selector(nextBadge),
            userInfo: nil,
            repeats: true
        )

        RunLoop.main.add(badgeTimer!, forMode: .common)
    }

    func stopBadgeAnimation() {
        badgeTimer?.invalidate()
        badgeTimer = nil
    }

    @objc func nextBadge() {
        badgeIndex = (badgeIndex + 1) % badgeTexts.count
        updateBadge(animated: true)
    }
    func updateBadge(animated: Bool) {
        guard let badgaeLbl = badgaeLbl,
              let badgeView = badgeView,
              let badgeWidthConstraint = badgeViewWithConstraints else {
            return
        }

        // ✅ Unhide here
        badgeView.isHidden = false
        badgaeLbl.isHidden = false

        let newText = badgeTexts[badgeIndex]

        badgaeLbl.text = newText
        let textWidth = badgaeLbl.intrinsicContentSize.width
        badgeWidthConstraint.constant = textWidth + 16
        layoutIfNeeded()

        guard animated else {
            badgaeLbl.alpha = 1
            badgaeLbl.transform = .identity
            badgeView.transform = .identity
            return
        }

        let height = badgaeLbl.bounds.height

        UIView.animate(
            withDuration: 0.35,
            animations: {
                badgeView.transform = CGAffineTransform(translationX: 0, y: -6)
                badgaeLbl.transform = CGAffineTransform(translationX: 0, y: -height)
                badgaeLbl.alpha = 0
            },
            completion: { _ in
                badgeView.transform = .identity  // ✅ reset badgeView
                badgaeLbl.transform = CGAffineTransform(translationX: 0, y: height)
                badgaeLbl.text = newText

                UIView.animate(withDuration: 0.35) {
                    badgaeLbl.transform = .identity
                    badgaeLbl.alpha = 1
                }
            }
        )
    }
}
