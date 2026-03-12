//
//  ShadhinMusicView.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain on 1/8/24.
//

import UIKit
import iCarousel

@IBDesignable
public class ShadhinMusicView: UIView {
    
    // MARK: -- Outlets --
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var songLbl: UILabel!
    @IBOutlet weak var shortsTitleLbl: UILabel!
    @IBOutlet weak var shortsTitleLblHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var shortsTitleLblTopLayout: NSLayoutConstraint!
    @IBOutlet weak var playDurationLbl: UILabel!
    @IBOutlet weak var trackDuration: UILabel!
    @IBOutlet weak var iCarouselLeftConst: NSLayoutConstraint!
    @IBOutlet weak var shortsCVHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var shortsCVTopLayout: NSLayoutConstraint!
    @IBOutlet weak var exploreMoreViewTopLayout: NSLayoutConstraint!
    @IBOutlet weak var visualEffectHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var blurImage: UIImageView!
    @IBOutlet weak var shadhinLogo: UIImageView!
    @IBOutlet weak var gpPlayerSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var exploreMoreView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var seeAllBtn: UIView!
    @IBOutlet weak var gpCaroselMusicView: iCarousel!
    @IBOutlet weak var mainViewBg: UIView!
    @IBOutlet weak var exploreBgview: UIView!
    @IBOutlet weak var shadowBgView: UIView!
    
    @IBOutlet weak var noInternetBgView: UIView!
    @IBOutlet weak var noInternettitleLabel: UILabel!
    @IBOutlet weak var noInternetMessageLbl: UILabel!
    @IBOutlet weak var retryBtb: UIButton!
    
    
    // MARK: -- Properties --
    var onClick : (GPExploreMusicModel)-> Void = {_ in}
    public var exPlore : (() -> Void)?
    var isFspagerDirection = false
    private var pathData: GPPatchData?
    private var exploreMusicData: GPExploreMusicModel?
    private var gradientLayer : CAGradientLayer!
    let viewModel = GPAudioViewModel.shared
    var view: UIView!
    var isPlaying: PlayingState = .neverPlayed
    var accessToken: String?
    var vc: UIViewController?
    public var goToSdk: (String)->Void = {_ in}
    public var gpDeletegate: ShadhinMusicViewDelegate? = nil
    var shortsResponseData : [ReelsContent]?
    var shortsSelectPatchID = 0
    private var unmuteIndices: Set<Int> = Set<Int>()
    public static var pendingShortsURL: String? = nil
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.nibSetup()
        self.setupUI()
        self.viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: isPlaying)
        self.seeAllBtn.setClickListener {
            self.clickListenerForMsisdn()
        }
        self.exploreMoreView.setClickListener {
            self.clickListenerForMsisdn()
        }
        self.viewModel.changeAllButtonsToImageName.append(setButtonImage)
        self.audioViewShow(isshow: false)
        self.shortsViewShow(isshow: false)
        self.exploreBgview.isHidden = true
        self.noInternetBgViewSetup()
        self.fetchDataFromGpExploreMusic()
    }

    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow == nil {
            ConnectionManager.shared.stopObserveReachability()
            NotificationCenter.default.removeObserver(self)
            
            collectionView.visibleCells.forEach { cell in
                (cell as? WidgetShortsCell)?.pause()
            }
        } else {
            GPAudioViewModel.shared.areWeInsideSDK = false

            if !viewModel.areWeInsideSDK {
                setUpViewIfComingBackFromAPlayerInSDK()
                if viewModel.gpMusicContents.isEmpty {
                    fetchDataFromGpExploreMusic()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        ConnectionManager.shared.stopObserveReachability()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        ConnectionManager.shared.observeReachability()
        self.mainViewShadowSetup()
        self.shadowBgView.applyTopClearBottomSystemBgGradient()
        self.applyGradientToSlider()
        if !ConnectionManager.shared.isNetworkAvailable {
            self.showNoInternetView()
        }
    }
    
    public func clickListenerForMsisdn() {
        self.exPlore?()
    }
    
    public func gotoShadhinSDK() {
        if ConnectionManager.shared.isNetworkAvailable {
            GPAudioViewModel.shared.goContentPlayingState = isPlaying
            GPAudioViewModel.shared.areWeInsideSDK = true
            GPAudioViewModel.shared.switchContext(to: .sdk)
            self.gpDeletegate?.gotoShadhinSDK(completionHandler: { vc, accessToken in
                self.vc = vc
                self.accessToken = accessToken
                ShadhinGP.shared.gotoShadhinMusic(parentVC: vc, accesToken: accessToken)
            })
        } else {
            self.view.makeToast("Please check your internet connection and try again", position: .center)
        }
    }
        
    private func noInternetBgViewSetup() {
        self.noInternetBgView.applySystemBgGradient()
        self.noInternetBgView.isHidden = true
        self.visualEffectHeightLayout.constant = 200
    }
    
    private func shortsViewShow(isshow: Bool) {
        if isshow {
            shortsTitleLbl.isHidden = false
            collectionView.isHidden = false
            shortsCVTopLayout.constant = 12
            shortsCVHeightLayout.constant = 320
            exploreMoreViewTopLayout.constant = 15
            shortsTitleLblHeightLayout.constant = 20
        } else {
            shortsTitleLbl.isHidden = true
            collectionView.isHidden = true
            shortsCVTopLayout.constant = 0
            shortsCVHeightLayout.constant = 0
            shortsTitleLblHeightLayout.constant = 0
            exploreMoreViewTopLayout.constant = 12
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func audioViewShow(isshow: Bool) {
        if isshow {
            visualEffect.isHidden = false
            visualEffectHeightLayout.constant = 240
            shortsTitleLblTopLayout.constant = 2
        } else {
            visualEffect.isHidden = true
            visualEffectHeightLayout.constant = 0
            shortsTitleLblTopLayout.constant = 15
        }
    }
    
    private func updateUIAfterDataLoad(hasAudio: Bool, hasReels: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.exploreBgview.isHidden = false
            self.noInternetBgView.isHidden = true

            if hasAudio && hasReels {
                self.audioViewShow(isshow: true)
                self.shortsViewShow(isshow: true)
            }
            else if hasAudio {
                self.audioViewShow(isshow: true)
                self.shortsViewShow(isshow: false)
            }
            else if hasReels {
                self.audioViewShow(isshow: false)
                self.shortsViewShow(isshow: true)
            }

            self.layoutIfNeeded()
        }
    }

    private func showNoInternetView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.noInternetBgView.isHidden = false
            self.audioViewShow(isshow: false)
            self.shortsViewShow(isshow: false)
            self.exploreBgview.isHidden = true
            self.visualEffectHeightLayout.constant = 200
            LoadingIndicator.stopAnimation()
            self.layoutIfNeeded()
        }
    }
    
    @objc private func sliderTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let duration = AudioPlayer.shared.currentItemDuration, duration > 0 else { return }
        
        let point = gestureRecognizer.location(in: gpPlayerSlider)
        let percentage = Float(point.x / gpPlayerSlider.bounds.width)
        let sliderValue = percentage
        gpPlayerSlider.setValue(sliderValue, animated: true)
        let seekTime = TimeInterval(sliderValue) * duration
        playDurationLbl.text = formatTimeToMinutesAndSeconds(seekTime)
        
        AudioPlayer.shared.seek(to: seekTime)
        viewModel.seekTo = seekTime
    }
    
    private func applyGradientToSlider() {
        let gradientColors = [
            UIColor.hash(string: "#5AC8FA").cgColor,
            UIColor.hash(string: "#9394FF").cgColor
        ]
        let gradientImage = gradientImage(colors: gradientColors, size: CGSize(width: gpPlayerSlider.bounds.width, height: 1.8), cornerRadius: 0)
        let grayImage = UIImage(color: UIColor.systemGray.withAlphaComponent(0.33), size: CGSize(width: gpPlayerSlider.bounds.width, height: 1.8), cornerRadius: 0)
        let normalThumb = UIImage(color: UIColor.systemGray.withAlphaComponent(0), size: CGSize(width: 0.2, height: 0.2), cornerRadius: 0)
        let highlightedThumb = UIImage(color: UIColor.label, size: CGSize(width: 4.5, height: 4.5), cornerRadius: 4.5/2)
        gpPlayerSlider.setMinimumTrackImage(gradientImage, for: .normal)
        gpPlayerSlider.setMaximumTrackImage(grayImage, for: .normal)
        gpPlayerSlider.setThumbImage(normalThumb, for: .normal)
        gpPlayerSlider.setThumbImage(highlightedThumb, for: .highlighted)
    }

    private func setupUI() {
        self.exploreBgview.layer.cornerRadius = 16
        self.exploreBgview.layer.maskedCorners = [ .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.exploreBgview.clipsToBounds = true
        self.visualEffect.layer.cornerRadius = 16
        self.visualEffect.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.visualEffect.clipsToBounds = true
        self.exploreMoreView.layer.cornerRadius = self.exploreMoreView.bounds.height/2
        self.exploreMoreView.layer.borderColor = UIColor.systemGray4.cgColor
        self.exploreMoreView.layer.borderWidth = 1
        self.exploreMoreView.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:)))
        gpPlayerSlider.addGestureRecognizer(tapGesture)
    }
    
    var isActiveInWindow: Bool {
        guard let window = self.window else {
            return false
        }
        
        return !self.isHidden && self.alpha > 0 && self.isUserInteractionEnabled && window.bounds.intersects(self.convert(self.bounds, to: window))
    }
    
    private func setUpViewIfComingBackFromAPlayerInSDK() {
        AudioPlayer.shared.delegate = self
        viewModel.gpMusicContents = viewModel.audioItems.map({$0.toGpContent()}) + ShadhinCore.instance.defaults.gpMusicContentsCache
        
        gpCaroselMusicView.reloadData()
        
        let index = viewModel.audioItems.firstIndex(where: {$0.contentId == AudioPlayer.shared.currentItem?.contentId})
        
        if let index {
            viewModel.selectedIndexInCarousel = index
            setArtistLbl(index: index)
            gpCaroselMusicView.scrollToItem(at: index, animated: false)
            if AudioPlayer.shared.state.isPlaying {
                isPlaying = .playing
            } else {
                isPlaying = .pause
            }
            viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: isPlaying)
        }
    }

    func setButtonImage(playingState: PlayingState, contentId: Int?) {
        viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: playingState)
        isPlaying = playingState
    }
    
    @IBAction func retryBtnAction(_ sender: UIButton) {
        self.noInternetBgView.isHidden = true
        LoadingIndicator.initLoadingIndicator(view: self.mainViewBg)
        LoadingIndicator.startAnimation()
        self.fetchDataFromGpExploreMusic()
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        goToNextItem()
    }
    
    @IBAction func previousTapped(_ sender: Any) {
        goToPreviousItem()
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.playPauseActionHandler()
        }
    }
    
    func playPauseActionHandler() {
        if viewModel.gpMusicContents.count > 0 {
            switch isPlaying {
            case .neverPlayed:
                viewModel.startAudio()
                isPlaying = .playing
            case .playing:
                viewModel.pauseAudio()
                isPlaying = .pause
            case .pause:
                viewModel.playAudio()
                isPlaying = .playing
            }
            
            viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: isPlaying)
            rememberDataToPlayAgainInSDK()
            
        }
    }
    
    private func updateVisibleVideoMuteState(isAudioPlaying: Bool) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint),
              let visibleCell = collectionView.cellForItem(at: visibleIndexPath) as? WidgetShortsCell else {
            return
        }
        
        let shouldBeUnmuted = !isAudioPlaying && unmuteIndices.contains(visibleIndexPath.item)
        visibleCell.isMuted = !shouldBeUnmuted
    }
    
    func rememberDataToPlayAgainInSDK() {
        viewModel.goContentPlayingState = isPlaying
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setArtistLbl(index: Int) {
        guard viewModel.gpMusicContents.count > index else{return}
        viewModel.selectedIndexInCarousel = index
        let artistText = viewModel.gpMusicContents[index].artists?.compactMap({$0.name}).joined(separator: ", ") ?? ""
        let songTitleText = viewModel.gpMusicContents[index].titleEn ?? ""
        self.artistLbl.startLabelMarquee(text: artistText)
        self.songLbl.startLabelMarquee(text: songTitleText)
        let urlString = viewModel.gpMusicContents[index].imageUrl?.image300 ?? ""
        if let url = URL(string: urlString) {
            blurImage.kf.setImage(with: url)
        }
    }
    
    private func fetchDataFromGpExploreMusic() {
        DispatchQueue.main.async {
            self.noInternetBgView.isHidden = true
            LoadingIndicator.initLoadingIndicator(view: self.mainViewBg)
            LoadingIndicator.startAnimation()
        }

        guard ConnectionManager.shared.isNetworkAvailable else {
            DispatchQueue.main.async {
                self.showNoInternetView()
                LoadingIndicator.stopAnimation()
            }
            return
        }

        var audioResult: Result<GPExploreMusicModel, AFError>?
        var reelsResult: Result<ReelsResponseObject, AFError>?

        let group = DispatchGroup()

        group.enter()
        ShadhinCore.instance.api.getHomeGpExplorePatchItem { result in
            audioResult = result
            group.leave()
        }

        group.enter()
        ShadhinCore.instance.api.getReelsResponseContents { result in
            reelsResult = result
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            LoadingIndicator.stopAnimation()

            var hasAudioSuccess = if case .success = audioResult { true } else { false }
            var hasReelsSuccess = if case .success = reelsResult { true } else { false }
            if !hasAudioSuccess && !hasReelsSuccess {
                self.noInternetMessageLbl.text = "Something went wrong! Please try again."
                self.showNoInternetView()
                return
            }

            if case .success(let data) = audioResult {
                self.viewModel.gpMusicContents = self.viewModel.getAllContents(from: data)
                ShadhinCore.instance.defaults.gpExploreMusicList = data
                hasAudioSuccess = self.viewModel.gpMusicContents.isEmpty ? false : true
                DispatchQueue.main.async {
                    self.gpCaroselMusicView.reloadData()
                }
                self.setArtistLbl(index: 0)
            }

            if case .success(let response) = reelsResult {
                if let contents = response.data?.first?.contents {
                    self.shortsResponseData = response.data?.first?.isShuffle ?? false ? contents.shuffled() : contents
                    self.shortsSelectPatchID = response.data?.first?.id ?? 0
                    hasReelsSuccess = contents.isEmpty ? false : true
                }
            }

            self.updateUIAfterDataLoad(hasAudio: hasAudioSuccess, hasReels: hasReelsSuccess)
        }
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        view = loadViewFromNib()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = true
        if #available(iOS 13.0, *) {
            view.overrideUserInterfaceStyle = .light
        }
        viewSetupMusicCatagoryList()
        recommendedCellSetup()
        addSubview(view)
    }
    
    private func viewSetupMusicCatagoryList() {
        gpCaroselMusicView.contentMode  = .scaleAspectFill
        gpCaroselMusicView.type = .linear
        gpCaroselMusicView.scrollSpeed = 0.2
        gpCaroselMusicView.dataSource = self
        gpCaroselMusicView.delegate = self
        gpCaroselMusicView.reloadData()
        gpCaroselMusicView.currentItemIndex = 0
        AudioPlayer.shared.delegate = self
    }
    
    private func recommendedCellSetup() {
        collectionView.register(WidgetShortsCell.nib, forCellWithReuseIdentifier: WidgetShortsCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = false
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func mainViewShadowSetup() {
        mainViewBg.layer.masksToBounds = false
        mainViewBg.layer.cornerRadius = 15
        mainViewBg.layer.shadowColor = UIColor.label.cgColor
        mainViewBg.layer.shadowOffset = CGSize(width: 3, height: 3)
        mainViewBg.layer.shadowOpacity = 0.5
        mainViewBg.layer.shadowRadius = 5
    }
        
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    func goToNextItem() {
        let currentIndex = gpCaroselMusicView.currentItemIndex
        let nextIndex = (currentIndex + 1) % gpCaroselMusicView.numberOfItems
        gpCaroselMusicView.scrollToItem(at: nextIndex, animated: true)
        let artistText = viewModel.gpMusicContents[nextIndex].artists?.compactMap({$0.name}).joined(separator: ", ") ?? ""
        let songTitleText = viewModel.gpMusicContents[nextIndex].titleEn ?? viewModel.gpMusicContents[nextIndex].titleBn ?? ""
        self.artistLbl.startLabelMarquee(text: artistText)
        self.songLbl.startLabelMarquee(text: songTitleText)

        let urlString = viewModel.gpMusicContents[nextIndex].imageUrl?.image300 ?? ""
        if let url = URL(string: urlString) {
            blurImage.kf.setImage(with: url)
        }
    }

    func goToPreviousItem() {
        let currentIndex = gpCaroselMusicView.currentItemIndex
        let previousIndex = (currentIndex - 1 + gpCaroselMusicView.numberOfItems) % gpCaroselMusicView.numberOfItems
        gpCaroselMusicView.scrollToItem(at: previousIndex, animated: true)
        let artistText =  viewModel.gpMusicContents[previousIndex].artists?.compactMap({$0.name}).joined(separator: ", ") ?? ""
        let songTitleText = viewModel.gpMusicContents[previousIndex].titleEn ?? viewModel.gpMusicContents[previousIndex].titleBn ?? ""
        self.artistLbl.startLabelMarquee(text: artistText)
        self.songLbl.startLabelMarquee(text: songTitleText)

        let urlString = viewModel.gpMusicContents[previousIndex].imageUrl?.image300 ?? ""
        if let url = URL(string: urlString) {
            blurImage.kf.setImage(with: url)
        }
    }
    
    private func updateAllVisibleCellsMuteState() {
        for cell in collectionView.visibleCells {
            if let shortsCell = cell as? WidgetShortsCell,
               let indexPath = collectionView.indexPath(for: shortsCell) {
                let shouldBeUnmuted = unmuteIndices.contains(indexPath.item)
                shortsCell.isMuted = !shouldBeUnmuted
            }
        }
    }

    func formatTimeToMinutesAndSeconds(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    @IBAction func playerSliderAction(_ sender: UISlider) {
        let value = Float(AudioPlayer.shared.currentItemDuration ?? 1) * sender.value
        AudioPlayer.shared.seek(to: TimeInterval(value))
    }
}

extension ShadhinMusicView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shortsResponseData?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WidgetShortsCell.identifier, for: indexPath) as? WidgetShortsCell else {
            fatalError("WidgetShortsCell not registered")
        }
        
        let item = shortsResponseData?[indexPath.item]
        cell.muteUnmuteBtn.tag = indexPath.item
        cell.configure(with: item)
        
        let shouldBeUnmuted = unmuteIndices.contains(indexPath.item)
        cell.isMuted = !shouldBeUnmuted
        
        cell.didTapMuteUnmute = { [weak self] index, currentMuteState in
            guard let self = self else { return }
            
            let isAudioPlaying = AudioPlayer.shared.state.isPlaying
            
            if currentMuteState {
                if isAudioPlaying {
                    self.viewModel.pauseAudio()
                    self.isPlaying = .pause
                    self.viewModel.setPlayPauseImage(playPauseButton: self.playPauseButton, isPlaying: .pause)
                }
                
                self.unmuteIndices.insert(index)
                
            } else {
                self.unmuteIndices.remove(index)
            }
            
            if let currentVisibleCell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? WidgetShortsCell {
                let shouldBeUnmuted = !AudioPlayer.shared.state.isPlaying && self.unmuteIndices.contains(index)
                currentVisibleCell.isMuted = !shouldBeUnmuted
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let shortsData = shortsResponseData?[indexPath.item] else { return }
        
        let token = ShadhinCore.instance.defaults.userSessionToken
        let isDark = !ShadhinCore.instance.defaults.isLighTheam
        let contentType = shortsData.contentType?.rawValue ?? "SV"
        let contentID = shortsData.id ?? 0
        let urlString = "https://shadhinmusic.com/shorts/player/\(contentType)/\(contentID)/\(shortsSelectPatchID)?type=SHORTS_VIDEO&token=\(token)&source=ios&isDarkTheme=\(isDark)"
        
        self.clickListenerForMsisdn()
        ShadhinMusicView.pendingShortsURL = urlString
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === collectionView else { return }
        playVisibleVideo()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playVisibleVideo()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            playVisibleVideo()
        }
    }
        
    private func playVisibleVideo() {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        let isAudioPlaying = AudioPlayer.shared.state.isPlaying
        
        for cell in collectionView.visibleCells {
            if let shortsCell = cell as? WidgetShortsCell,
               let indexPath = collectionView.indexPath(for: shortsCell) {
                
                if indexPath == visibleIndexPath {
                    shortsCell.play()
                    let shouldBeUnmuted = !isAudioPlaying && unmuteIndices.contains(indexPath.item)
                    shortsCell.isMuted = !shouldBeUnmuted
                    
                } else {
                    shortsCell.pause()
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 220, height: 320)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

extension ShadhinMusicView: AudioPlayerDelegate {
    public func audioPlayer(_ audioPlayer: AudioPlayer, didFindDuration duration: TimeInterval, for item: AudioItem) {
        self.trackDuration.text = formatSecondsToString(duration)
        if let itemIndex = viewModel.gpMusicContents.firstIndex(where: {String($0.contentId ?? 0) == item.contentId}){
            gpCaroselMusicView.scrollToItem(at: itemIndex, animated: true)
            let artistText =  viewModel.gpMusicContents[itemIndex].artists?.compactMap({$0.name}).joined(separator: ", ") ?? ""
            let songTitleText = viewModel.gpMusicContents[itemIndex].titleEn ?? ""
            self.artistLbl.startLabelMarquee(text: artistText)
            self.songLbl.startLabelMarquee(text: songTitleText)
        }
    }
    
    public func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        let isAudioPlaying = state.isPlaying
        if case .stopped = state {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isPlaying = .playing
                self.goToNextItem()
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateVisibleVideoMuteState(isAudioPlaying: isAudioPlaying)
        }
    }
    
    public func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float){
        playDurationLbl.text = formatTimeToMinutesAndSeconds(time)
        gpPlayerSlider.value = Float(percentageRead/100)
        viewModel.seekTo = time
    }
}

// MARK: -- Carousel DataSource & Delegate --
extension ShadhinMusicView: iCarouselDataSource, iCarouselDelegate {
    public func numberOfItems(in carousel: iCarousel) -> Int {
        return viewModel.gpMusicContents.count
    }
    
    public func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        if let view = view as? UIImageView {
            itemView = view
        } else {
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 116, height: 116))
            itemView.contentMode = .scaleAspectFill
            itemView.cornerRadius = 16
            itemView.clipsToBounds = true
        }
        
        let urlString = viewModel.gpMusicContents[index].imageUrl?.image300 ?? ""
        if let url = URL(string: urlString) {
            itemView.kf.setImage(with: url)
        }
        
        return itemView
    }
    
    public func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform: CATransform3D) -> CATransform3D {
        let scaleFactor: CGFloat = 0.75
        let distanceFromCenter = abs(offset)
        let scale = max(scaleFactor, 1 - distanceFromCenter * 0.25)
        let transform = CATransform3DScale(baseTransform, scale, scale, 1)
        return transform
    }
    
    public func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        
        let newIndex = carousel.currentItemIndex
        guard viewModel.selectedIndexInCarousel != newIndex else { return }
        guard viewModel.gpMusicContents.indices.contains(newIndex) else { return }
        
        viewModel.selectedIndexInCarousel = newIndex
        setArtistLbl(index: newIndex)
        
        guard let audioItem = viewModel.gpMusicContents[newIndex].convertToAudioItem() else { return }
        self.rememberDataToPlayAgainInSDK()
        self.isPlaying = .playing
        if isPlaying == .playing {
            AudioPlayer.shared.play(item: audioItem)
            viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: .playing)
        } else {
            AudioPlayer.shared.currentItem = audioItem
            viewModel.setPlayPauseImage(playPauseButton: playPauseButton, isPlaying: isPlaying)
        }
    }
}

enum PlayingState {
    case neverPlayed
    case playing
    case pause
}

public protocol ShadhinMusicViewDelegate {
    func gotoShadhinSDK(completionHandler: @escaping (UIViewController, String)-> Void)
}
