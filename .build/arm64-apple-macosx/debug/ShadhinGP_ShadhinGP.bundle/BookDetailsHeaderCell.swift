//
//  BookDetailsHeaderCell.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 6/6/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit
 
class BookDetailsHeaderCell: UICollectionViewCell {
    var seekToInterval: TimeInterval = 0 // Default value
    var seektoCurrentCursor = 0
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var readMoreView: UIStackView!
    @IBOutlet weak var bookBlurImage: UIImageView!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var ratingHoursLabel: UILabel!
    @IBOutlet weak var readMoreIconImage: UIImageView!
    @IBOutlet weak var readMoreLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIImageView!
    @IBOutlet weak var shareImage: UIImageView!
    var onTap:() -> Void = {}
    var selectedTrack: CommonContentProtocol?
    let audioPlayer = AudioPlayer.shared
    static var extraHeight = 0.0
    weak var vc: AudioBookDetailsVC?
    weak var authorDetailsVC: AuthorAndNarratorDetailsVC?
    static var isExpanded = false
    var dismiss: ()-> Void = {}
    var ratingString = "" {
        didSet {
            if ratingString.isEmpty {
                ratingHoursLabel.text = "No Rating Yet" + hourString
            } else {
                ratingHoursLabel.text = ratingString + hourString
            }
        }
    }
    var shouldSeekToSavedPosition: Bool {
        return self.seekToInterval > 0
    }
    
    var hourString = ""{
        didSet{
            ratingHoursLabel.text = ratingString + hourString
        }
    }
    var authors: String = ""
    
    @IBOutlet weak var summaryHeight: NSLayoutConstraint!
    
    static var identifier: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var size: CGSize {
        // let aspectRatio = 360.0/530.0
        let width = SCREEN_WIDTH
        let height = 600.0
        return CGSize(width: width, height: height)
    }
    
    static var sizeExpanded: CGSize {
        // let aspectRatio = 360.0/530.0
        let width = SCREEN_WIDTH
        let height = 600.0 + extraHeight - 35
        return CGSize(width: width, height: height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        BookDetailsHeaderCell.isExpanded = false
        
        readMoreView.setClickListener {[weak self] in
            self?.resizeReadMore()
        }
        
        shareImage.setClickListener {
            self.shareAudiobookHandler()
        }
        favBtn.setClickListener {
            self.favButtonHandler()
        }
        
        playPauseButton.setClickListener {
            if ConnectionManager.shared.isNetworkAvailable{
                if ShadhinCore.instance.isUserLoggedIn && ShadhinCore.instance.isUserPro {
                    self.playPauseHandler()
                } else if !ShadhinCore.instance.isUserPro {
                    SubscriptionPopUpVC.show(self.vc)
                }
            }
        }
        
        if doEpisodesContainCurrentAudio(){
            playPauseSetImageHandler()
        }
        
        addAudioObserver()
    }
    
    func favButtonHandler() {
        onTap()
    }
    
    func shareAudiobookHandler() {
        if let commonContent = vc?.parentBook?.toCommonContent(), let vc {
            DeepLinks.createDeepLink(model: commonContent, controller: vc, vcType: "Audio Book")
        }
    }
    
    func playPauseHandler() {
        switch audioPlayer.state {
        case .buffering:
            setBufferingImage()
            playPauseSetImageHandler()
        case .playing:
            if doEpisodesContainCurrentAudio() {
                audioPlayer.pause()
                setPlayImage()
            } else {
                startAudioFrom(index: 0, startAudioFrom: 0)
                setPauseImage()
            }
        case .paused:
            if doEpisodesContainCurrentAudio() {
                audioPlayer.resume()
                playPauseSetImageHandler()
            } else {
                startAudioFrom(index: 0, startAudioFrom: seektoCurrentCursor)
                playPauseSetImageHandler()
            }
        case .stopped, .failed(_):
            /// This state does not happen
            if doEpisodesContainCurrentAudio() {
                // do nothing
            } else {
                startAudioFrom(index:0, startAudioFrom:seektoCurrentCursor)
                playPauseSetImageHandler()
            }
            
        case .waitingForConnection:
            setBufferingImage()
        }
    }
    
    func doEpisodesContainCurrentAudio() -> Bool {
        if let currentAuioContentId = audioPlayer.currentItem?.contentId {
            let currentlyPlayingEpisode = vc?.episodes.first(where: { audioBookContent in
                if let episodeContentId = audioBookContent.contentId  {
                    return String(episodeContentId) == currentAuioContentId
                }
                return false
            })
            
            if currentlyPlayingEpisode != nil {
                return true
            }
        }
        
        return false
    }
    
    func startAudioFrom(index: Int,startAudioFrom:Int) {
        seekToInterval = TimeInterval(startAudioFrom)
        print("Set seekToInterval: \(seekToInterval)") // Debugging
        if doEpisodesContainCurrentAudio() {
            // seek to
            audioPlayer.playItem(at: index)
        } else {
            // play with the list
            if var episodeContents = vc?.episodes.compactMap({$0.toCommonContent()}) {
                for (index,_) in episodeContents.enumerated() {
                    episodeContents[index].artist = authors
                }
                self.vc?.openMusicPlayerV3(musicData: episodeContents, songIndex: index, isRadio: false)
                setPauseImage()
            }
        }
    }
    
    func playPauseSetImageHandler() {
        guard doEpisodesContainCurrentAudio() else { return }
        switch audioPlayer.state {
        case .buffering:
            setBufferingImage()
        case .playing:
            setPauseImage()
        case .paused:
            setPlayImage()
        case .stopped:
            setPlayImage()
        case .waitingForConnection:
            setBufferingImage()
        case .failed(_):
            setPlayImage()
        }
    }
    
    func setPlayImage() {
        setBufferingImage(isBuffering: false)
        playPauseButton.image = VGPlayerUtils.imageResource("ic_Play")
    }
    
    func setPauseImage() {
        print("Seeking to: \(self.seekToInterval)") // Debugging
        setBufferingImage(isBuffering: false)
        playPauseButton.image = VGPlayerUtils.imageResource("ic_Pause1")
        // Only seek if this is a "continue listening" case
          if shouldSeekToSavedPosition {
              print("Seeking to saved position: \(self.seekToInterval)")
              self.audioPlayer.seek(to: TimeInterval(self.seekToInterval))
          } else {
              print("Skipping seek operation")
          }
     
    }


    func setBufferingImage(isBuffering: Bool = true) {
        if isBuffering {
            // Create and set up an activity indicator
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.center = CGPoint(x: playPauseButton.bounds.midX, y: playPauseButton.bounds.midY)
            activityIndicator.tag = 100  // Assign a tag to retrieve and remove it later
            
            // Add the activity indicator over the playPauseButton
            playPauseButton.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            // Optionally, disable the button interaction during buffering
            playPauseButton.isUserInteractionEnabled = false
        } else {
            // Stop the activity indicator and remove it
            if let activityIndicator = playPauseButton.viewWithTag(100) as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
            
            // Re-enable button interaction after buffering
            playPauseButton.isUserInteractionEnabled = true
        }
    }
    
    func bind(data: ParentContent) {
        let url = URL(string: (data.imageUrl ?? "").image450)
        bookBlurImage.kf.setImage(with: url)
        bookImage.kf.setImage(with: url)
        bookName.text = data.titleBn
        summaryLabel.text = data.details
        hourString = removeSeconds((data.audioBook?.duration ?? 0).formatTime())
    }
    
    func removeSeconds(_ time: String)->String {
        if let index = time.firstIndex(of: "m") {
            return String(time.prefix(upTo: time.index(after: index)))
        }
        return time
    }
    
    func bindReviewData(data: ReviewRatingCount) {
        ratingString = "\(data.ratingAverage ?? 0) (\(data.reviewCount ?? 0)) • "
    }
    
    func addAudioObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioPlayNotification(_:)), name: .audioPlayNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioPauseNotification(_:)), name: .audioPauseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioBufferingNotification(_:)), name: .audioBufferingNotification, object: nil)
    }
    
    @objc func handleAudioPlayNotification(_ notification: Notification) {
        if let contentId = notification.userInfo?["contentId"] as? String {
            print("Audio play notification received with contentId: \(contentId)")
            if doEpisodesContainCurrentAudio() {
                setPauseImage()
            } else {
                setPlayImage()
            }
        }
    }
    
    @objc func handleAudioPauseNotification(_ notification: Notification) {
        if let contentId = notification.userInfo?["contentId"] as? String {
            print("Audio pause notification received with contentId: \(contentId)")
            setPlayImage()
        }
    }
    
    @objc func handleAudioBufferingNotification(_ notification: Notification) {
        if let contentId = notification.userInfo?["contentId"] as? String {
            print("Audio pause notification recieved with contentId: \(contentId)")
            setBufferingImage()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss()
    }
    
    private func resizeReadMore(){
        BookDetailsHeaderCell.isExpanded.toggle()
        if BookDetailsHeaderCell.isExpanded {
            BookDetailsHeaderCell.extraHeight = getHeightOfSummary()
            vc?.isSummaryExpanded = true
            vc?.collectionView.reloadSections(.init(arrayLiteral: 0))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                self.summaryHeight.constant = BookDetailsHeaderCell.extraHeight
                self.summaryHeight.isActive = true
                self.readMoreLabel.text = "Read Less"
                self.readMoreIconImage.transform = self.readMoreIconImage.transform.rotated(by: .pi)
                self.vc?.collectionView.reloadSections(.init(arrayLiteral: 0))
            })
        }else {
            vc?.isSummaryExpanded = false
            vc?.collectionView.reloadSections(.init(arrayLiteral: 0))
            self.summaryHeight.constant = 35
            self.summaryHeight.isActive = true
            self.readMoreLabel.text = "Read More"
            self.readMoreIconImage.transform = self.readMoreIconImage.transform.rotated(by: .pi)
            
        }
    }
    
    func getHeightOfSummary()->CGFloat {
        let attributedString = NSAttributedString(
            string: summaryLabel.text ?? "",
            attributes: [
                .font: UIFont(name: "OpenSans-Regular", size: 12.0)!, // Customize your font and other attributes here
                .foregroundColor: UIColor.black // Customize your color and other attributes here
            ]
        )
        
        // Step 2: Define the maximum width
        let maxWidth = CGFloat(SCREEN_WIDTH - 32) // Set the width of your container
        
        // Step 3: Calculate the bounding rect
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let boundingRect = attributedString.boundingRect(with: size, options: options, context: nil)
        
        // The height of the bounding rect is the height needed to display the attributed string
        return ceil(boundingRect.height)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .audioPlayNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .audioPauseNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .audioBufferingNotification, object: nil)
    }
}
