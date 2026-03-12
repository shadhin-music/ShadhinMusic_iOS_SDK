//
//  MusicSongsListCell.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/13/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class MusicSongsListCell: UITableViewCell {
    private let badgeTexts = ["Set","Welcome","Tune"]
    private var badgeIndex = 0
    private var badgeTimer: Timer?
    
    @IBOutlet weak var welcomeTuneBtn: UIButton!
    @IBOutlet weak var badgeWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var badgeLbl: UILabel!
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
    private var didTapWelcomeTune: (() -> ())?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopBadgeAnimation()  // ✅ add this
        self.initHide()
    }

    @IBAction func threeDotMenuAction(_ sender: Any) {
        threeDotMenuClick?()
    }

    @IBAction func welcomeTuneSetAction(_ sender: Any) {
        didTapWelcomeTune?()
    }

    func didTappedWelcomeTuneSet(completion: @escaping (()->())) {
        didTapWelcomeTune = completion
    }

    func didThreeDotMenuTapped(completion: @escaping (()->())) {
        threeDotMenuClick = completion
    }
}


extension MusicSongsListCell {

    func setupUI() {
        initHide()
        songTitleLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        songsDurationLbl.textColor = .customLabelColor(color: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1))
        circularProgress.isHidden = true
        circularProgress.font = .systemFont(ofSize: 8)
        songTitleLbl.adjustsFontSizeToFitWidth =  true
        songArtistLbl.adjustsFontSizeToFitWidth = true
        
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
        badgeLbl.font = .systemFont(ofSize: 12, weight: .regular)
        badgeLbl.textAlignment = .center
    }
    
    func initHide() {
        self.welcomeTuneBtn.isHidden = true
        self.badgeLbl.isHidden = true
        self.badgeView.isHidden = true  // ✅ was false, should be true
        songsDurationLbl.isHidden = true
    }

    func configureWelcomeTuneButton(operators: [String]?) {
        let hasGP = operators?.contains { op in
            op.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == "GP"
        } ?? false
        self.welcomeTuneBtn.isHidden = !hasGP
    }
    
    func configureCell(model: CommonContentProtocol, contentType: String, indexInSection: Int = 0) {
        
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        songsImgView.kf.indicatorType = .activity
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        songTitleLbl.text = model.title ?? ""
        self.configureWelcomeTuneButton(operators: model.rbtOperators)
        let hasGP = model.rbtOperators?.containsGP() ?? false
        if hasGP && indexInSection == 0 {
            showBadgeAndStartAnimation()
        } else {
            stopBadgeAnimation()
            badgeView.isHidden = true
            badgeLbl.isHidden = true
        }
        songArtistLbl.text = model.artist ?? ""
        
        songsDurationLbl.text = formatSecondsToString(Double(model.duration ?? "") ?? 123)
        checkSongsIsDownloading(data: model)
        if DatabaseContext.shared.isSongExist(contentId: model.contentID!){
            if #available(iOS 13, *){
                downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
            }else{
                downloadMarkImageView.image = AppImage.downloaded12.uiImage
            }
        }else{
            if #available(iOS 13, *){
                downloadMarkImageView.image = AppImage.notDownload.uiImage
            }else{
                downloadMarkImageView.image = AppImage.nonDownload12.uiImage
            }
        }
    }
    
    func configureTrackCell(model: CommonContentProtocol) {
        songArtistLbl.isHidden = true
        let imgUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
        songsImgView.kf.indicatorType = .activity
        songsImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_song",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        songTitleLbl.text = model.title ?? ""
        self.configureWelcomeTuneButton(operators: model.rbtOperators)
        let hasGP = model.rbtOperators?.containsGP() ?? false
           if hasGP {
               showBadgeAndStartAnimation()
           } else {
               stopBadgeAnimation()
               badgeView.isHidden = true
               badgeLbl.isHidden = true
           }
        songArtistLbl.text = model.artist ?? ""

        songsDurationLbl.text = formatSecondsToString(Double(model.duration ?? "") ?? 0)

        checkSongsIsDownloading(data: model)
        if DatabaseContext.shared.isSongExist(contentId: model.contentID!){
            if #available(iOS 13, *){
                downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
            }else{
                downloadMarkImageView.image = AppImage.downloaded12.uiImage
            }
        }else{
            if #available(iOS 13, *){
                downloadMarkImageView.image = AppImage.notDownload.uiImage
            }else{
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
            //work it when download all song
            obj.progressBlock = { progress in
                self.circularProgress.setProgress(progress: progress, animated: true)
                if progress == 1.0{
                    self.threeDotBtn.isHidden = false
                    self.circularProgress.isHidden = true
                    self.circularProgress.setProgress(progress: 0.0)
                    //save to database
                    DatabaseContext.shared.addSong(content: data,isSingleDownload: obj.isSingle ?? true)
                    //get rootview controller
                    self.makeToast("File successfully downloaded.")
                    //check download mark
                    if #available(iOS 13, *){
                        self.downloadMarkImageView.image = AppImage.checkCircelFill.uiImage
                    }else{
                        self.downloadMarkImageView.image = AppImage.downloaded12.uiImage
                    }
                }
            }

        }
    }
}

extension MusicSongsListCell {

    func showBadgeAndStartAnimation() {
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
        guard let badgeLbl = badgeLbl,
              let badgeView = badgeView,
              let badgeWidthConstraint = badgeWidthConstraint else {
            return
        }

        // ✅ Unhide here
        badgeView.isHidden = false
        badgeLbl.isHidden = false

        let newText = badgeTexts[badgeIndex]

        badgeLbl.text = newText
        let textWidth = badgeLbl.intrinsicContentSize.width
        badgeWidthConstraint.constant = textWidth + 16
        layoutIfNeeded()

        guard animated else {
            badgeLbl.alpha = 1
            badgeLbl.transform = .identity
            badgeView.transform = .identity
            return
        }

        let height = badgeLbl.bounds.height

        UIView.animate(
            withDuration: 0.35,
            animations: {
                badgeView.transform = CGAffineTransform(translationX: 0, y: -6)
                badgeLbl.transform = CGAffineTransform(translationX: 0, y: -height)
                badgeLbl.alpha = 0
            },
            completion: { _ in
                badgeView.transform = .identity  // ✅ reset badgeView
                badgeLbl.transform = CGAffineTransform(translationX: 0, y: height)
                badgeLbl.text = newText

                UIView.animate(withDuration: 0.35) {
                    badgeLbl.transform = .identity
                    badgeLbl.alpha = 1
                }
            }
        )
    }

}

extension Array where Element == String {
    func containsGP() -> Bool {
        return self.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
             .uppercased() == "GP"
        }
    }
}
