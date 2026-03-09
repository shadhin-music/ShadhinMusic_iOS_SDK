//
//  FAQAnswerTVCell.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 5/11/25.
//

import UIKit
import AVKit

class FAQAnswerTVCell: UITableViewCell {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var videoBgView: UIView!
    @IBOutlet weak var videoHeightConstraint: NSLayoutConstraint!

    static var identifier: String {
        return String(describing: self)
    }
    private var player: AVPlayer?
    private var playerViewController: AVPlayerViewController?

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.sutupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        player = nil
        playerViewController?.view.removeFromSuperview()
        playerViewController = nil
    }

    func dataBindCell(_ data: FAQAnswerData) {
        let langData = ShadhinCore.instance.isBangla ? data.bn : data.en
        let descriptions = langData?.descriptionsArr ?? []
        descriptionTextView.attributedText = makeBulletList(from: descriptions)
        
        guard let urlString = data.imageUrl,
              let url = URL(string: urlString) else { return }

        if isVideoURL(url){
            self.loadVideo(from: url)
            self.videoBgView.isHidden = false
        } else {
            self.videoBgView.isHidden = true
        }
    }
}

// MARK: - Helpers
extension FAQAnswerTVCell {

    private func sutupCell() {
        selectionStyle = .none
        videoBgView.layer.cornerRadius = 12
        videoBgView.clipsToBounds = true
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.dataDetectorTypes = [.link]
        descriptionTextView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        descriptionTextView.delegate = self
    }
    
    private func makeBulletList(from items: [String]) -> NSAttributedString {
        let fullText = NSMutableAttributedString()

        for (index, item) in items.enumerated() {
            let bullet = "•"
            let bulletAttr = NSAttributedString(
                string: "\(bullet) ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                    .foregroundColor: UIColor.label
                ]
            )
            let textAttr = NSAttributedString(
                string: "\(item)\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                    .foregroundColor: UIColor.label
                ]
            )

            fullText.append(bulletAttr)
            fullText.append(textAttr)

            if index == items.count - 1 {
                fullText.append(NSAttributedString(string: "\n"))
            }
        }
        return fullText
    }
}


// MARK: - UITextViewDelegate (Link Click)
extension FAQAnswerTVCell : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}

// MARK: - Helpers
extension FAQAnswerTVCell {
    
    private func loadVideo(from url: URL) {
        player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        playerViewController?.showsPlaybackControls = true
        playerViewController?.view.frame = videoBgView.bounds
        playerViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let vcView = playerViewController?.view {
            videoBgView.addSubview(vcView)
        }
        
        player?.pause()
        updateVideoAspectRatio(for: url)
    }
    
    private func updateVideoAspectRatio(for url: URL) {
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else { return }
        let size = track.naturalSize.applying(track.preferredTransform)
        let aspectRatio = abs(size.height / size.width)
        let width = UIScreen.main.bounds.width - 32
        let newHeight = width * aspectRatio
        videoHeightConstraint.constant = newHeight
        layoutIfNeeded()
    }
}
