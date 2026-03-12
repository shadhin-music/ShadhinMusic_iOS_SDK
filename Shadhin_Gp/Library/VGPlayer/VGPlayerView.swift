//
//  VGPlayerView.swift
//  VGPlayer
//
//  Created by Vein on 2017/6/5.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import MediaPlayer

 protocol VGPlayerViewDelegate: AnyObject {
    
    /// Fullscreen
    ///
    /// - Parameters:
    ///   - playerView: player view
    ///   - fullscreen: Whether full screen
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen isFullscreen: Bool)
    
    /// Close play view
    ///
    /// - Parameter playerView: player view
    func vgPlayerView(didTappedClose playerView: VGPlayerView)
    
    /// Displaye control
    ///
    /// - Parameter playerView: playerView
    func vgPlayerView(didDisplayControl playerView: VGPlayerView)
    
}

// MARK: - delegate methods optional
 extension VGPlayerViewDelegate {
    
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool){}
    
    func vgPlayerView(didTappedClose playerView: VGPlayerView) {}
    
    func vgPlayerView(didDisplayControl playerView: VGPlayerView) {}
}

 enum VGPlayerViewPanGestureDirection: Int {
    case vertical
    case horizontal
}


 class VGPlayerView: UIView {
    
    weak  var vgPlayer : VGPlayer?
     var controlViewDuration : TimeInterval = 5.0  /// default 5.0
     fileprivate(set) var playerLayer : AVPlayerLayer?
     fileprivate(set) var isFullScreen : Bool = false
     fileprivate(set) var isTimeSliding : Bool = false
     fileprivate(set) var isDisplayControl : Bool = true {
        didSet {
            if isDisplayControl != oldValue {
                delegate?.vgPlayerView(didDisplayControl: self)
            }
        }
    }
     weak var delegate : VGPlayerViewDelegate?
    // top view
     var topView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
     var titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        return label
    }()
     var closeButton : UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    // bottom view
     var bottomView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
     var timeSlider = VGPlayerSlider ()
     var loadingIndicator = VGPlayerLoadingIndicator()
     var fullscreenButton : UIButton = UIButton(type: .custom)
     var timeLabel : UILabel = UILabel()
     var playButtion : UIButton = UIButton(type: .custom)
     var volumeSlider : UISlider!
     var replayButton : UIButton = UIButton(type: .custom)
     fileprivate(set) var panGestureDirection : VGPlayerViewPanGestureDirection = .horizontal
    fileprivate var isVolume : Bool = false
    fileprivate var sliderSeekTimeValue : TimeInterval = .nan
    fileprivate var timer : Timer = {
        let time = Timer()
        return time
    }()
    
    fileprivate weak var parentView : UIView?
    fileprivate var viewFrame = CGRect()
    
    // GestureRecognizer
     var singleTapGesture = UITapGestureRecognizer()
     var doubleTapGesture = UITapGestureRecognizer()
     var panGesture = UIPanGestureRecognizer()
    
    //MARK:- life cycle
     override init(frame: CGRect) {
        self.playerLayer = AVPlayerLayer(player: nil)
        super.init(frame: frame)
        addDeviceOrientationNotifications()
        addGestureRecognizer()
        configurationVolumeSlider()
        configurationUI()
    }
    
     convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required  init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer.invalidate()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
    }

     override func layoutSubviews() {
        super.layoutSubviews()
        updateDisplayerView(frame: bounds)
    }
    
     func setvgPlayer(vgPlayer: VGPlayer) {
        self.vgPlayer = vgPlayer
    }
    
     func reloadPlayerLayer() {
        playerLayer = AVPlayerLayer(player: self.vgPlayer?.player)
        layer.insertSublayer(self.playerLayer!, at: 0)
        updateDisplayerView(frame: self.bounds)
        timeSlider.isUserInteractionEnabled = vgPlayer?.mediaFormat != .m3u8
        reloadGravity()
    }
    
    
    /// play state did change
    ///
    /// - Parameter state: state
     func playStateDidChange(_ state: VGPlayerState) {
        playButtion.isSelected = state == .playing
        replayButton.isHidden = !(state == .playFinished)
        replayButton.isHidden = !(state == .playFinished)
        if state == .playing || state == .playFinished {
            setupTimer()
        }
        if state == .playFinished {
            loadingIndicator.isHidden = true
        }
    }
    
    /// buffer state change
    ///
    /// - Parameter state: buffer state
     func bufferStateDidChange(_ state: VGPlayerBufferstate) {
        if state == .buffering {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
        }
        
        var current = formatSecondsToString((vgPlayer?.currentDuration)!)
        if (vgPlayer?.totalDuration.isNaN)! {  // HLS
            current = "00:00"
        }
        if state == .readyToPlay && !isTimeSliding {
            timeLabel.text = "\(current + " / " +  (formatSecondsToString((vgPlayer?.totalDuration)!)))"
        }
    }
    
    /// buffer duration
    ///
    /// - Parameters:
    ///   - bufferedDuration: buffer duration
    ///   - totalDuration: total duratiom
     func bufferedDidChange(_ bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
        timeSlider.setProgress(Float(bufferedDuration / totalDuration), animated: true)
    }
    
    /// player diration
    ///
    /// - Parameters:
    ///   - currentDuration: current duration
    ///   - totalDuration: total duration
     func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        var current = formatSecondsToString(currentDuration)
        if totalDuration.isNaN {  // HLS
            current = "00:00"
        }
        if !isTimeSliding {
            timeLabel.text = "\(current + " / " +  (formatSecondsToString(totalDuration)))"
            timeSlider.value = Float(currentDuration / totalDuration)
        }
    }
    
     func configurationUI() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        configurationTopView()
        configurationBottomView()
        configurationReplayButton()
        setupViewAutoLayout()
    }
     func configurationTeaserUI() {
         backgroundColor = .black
        //configurationTopView()
//        configurationBottomView()
//        configurationReplayButton()
//        setupViewAutoTeaserLayout()
         teaserInitilize()
    }
    
     func reloadPlayerView() {
        playerLayer = AVPlayerLayer(player: nil)
        timeSlider.value = Float(0)
        timeSlider.setProgress(0, animated: false)
        replayButton.isHidden = true
        isTimeSliding = false
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        timeLabel.text = "--:-- / --:--"
        reloadPlayerLayer()
    }
    
    /// control view display
    ///
    /// - Parameter display: is display
     func displayControlView(_ isDisplay:Bool) {
        if isDisplay {
            displayControlAnimation()
        } else {
            hiddenControlAnimation()
        }
    }
}

// MARK: - 
extension VGPlayerView {
    
     func updateDisplayerView(frame: CGRect) {
        playerLayer?.frame = frame
    }
    
     func reloadGravity() {
        if vgPlayer != nil {
            switch vgPlayer!.gravityMode {
            case .resize:
                playerLayer?.videoGravity = .resize
            case .resizeAspect:
                playerLayer?.videoGravity = .resizeAspect
            case .resizeAspectFill:
                playerLayer?.videoGravity = .resizeAspectFill
            }
        }
    }

     func enterFullscreen() {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation == .portrait, parentView == nil{
            parentView = (self.superview)!
            viewFrame = self.frame
        }
        if #available(iOS 16.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))

        }else{
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            //UIApplication.shared.setStatusBarHidden(false, with: .fade)
        }
        
    }
    
     func exitFullscreen() {
        if #available(iOS 16.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))

        }else{
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        
    }
    
    /// play failed
    ///
    /// - Parameter error: error
     func playFailed(_ error: VGPlayerError) {
        // error
    }
    
     func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN{
            return "00:00"
        }
        let interval = Int(seconds)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let min = interval / 60
        return String(format: "%02d:%02d", min, sec)
    }
}

// MARK: - private
extension VGPlayerView {
    
    internal func play() {
        playButtion.isSelected = true
    }
    
    internal func pause() {
        playButtion.isSelected = false
    }
    
    internal func displayControlAnimation() {
        bottomView.isHidden = false
        topView.isHidden = false
        isDisplayControl = true
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 1
            self.topView.alpha = 1
        }) { (completion) in
            self.setupTimer()
        }
    }
    internal func hiddenControlAnimation() {
        timer.invalidate()
        isDisplayControl = false
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 0
            self.topView.alpha = 0
        }) { (completion) in
            self.bottomView.isHidden = true
            self.topView.isHidden = true
        }
    }
    internal func setupTimer() {
        timer.invalidate()
        timer = Timer.vgPlayer_scheduledTimerWithTimeInterval(self.controlViewDuration, block: {  [weak self]  in
            guard let strongSelf = self else { return }
            strongSelf.displayControlView(false)
        }, repeats: false)
    }
    internal func addDeviceOrientationNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationWillChange(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
    }
    
    internal func configurationVolumeSlider() {
        let volumeView = MPVolumeView()
        if let view = volumeView.subviews.first as? UISlider {
            volumeSlider = view
        }
    }
}


// MARK: - GestureRecognizer
extension VGPlayerView {
    
    internal func addGestureRecognizer() {
        singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onSingleTapGesture(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        singleTapGesture.delegate = self
        addGestureRecognizer(singleTapGesture)
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture.delegate = self
        addGestureRecognizer(doubleTapGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension VGPlayerView: UIGestureRecognizerDelegate {
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view as? VGPlayerView != nil) {
            return true
        }
        return false
    }
}

// MARK: - Event
extension VGPlayerView {
    
    @objc internal func timeSliderValueChanged(_ sender: VGPlayerSlider) {
        isTimeSliding = true
        if let duration = vgPlayer?.totalDuration {
            let currentTime = Double(sender.value) * duration
            timeLabel.text = "\(formatSecondsToString(currentTime) + " / " +  (formatSecondsToString(duration)))"
        }
    }
    
    @objc internal func timeSliderTouchDown(_ sender: VGPlayerSlider) {
        isTimeSliding = true
        timer.invalidate()
    }
    
    @objc internal func timeSliderTouchUpInside(_ sender: VGPlayerSlider) {
        isTimeSliding = true
        
        if let duration = vgPlayer?.totalDuration {
            let currentTime = Double(sender.value) * duration
            vgPlayer?.seekTime(currentTime, completion: { [weak self] (finished) in
                guard let strongSelf = self else { return }
                if finished {
                    strongSelf.isTimeSliding = false
                    strongSelf.setupTimer()
                }
            })
            timeLabel.text = "\(formatSecondsToString(currentTime) + " / " +  (formatSecondsToString(duration)))"
        }
    }
    
    @objc internal func onPlayerButton(_ sender: UIButton) {
        if !sender.isSelected {
            vgPlayer?.play()
        } else {
            vgPlayer?.pause()
        }
    }
    
    @objc internal func onFullscreen(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isFullScreen = sender.isSelected
        if isFullScreen {
            enterFullscreen()
        } else {
            exitFullscreen()
        }
    }
    
    
    /// Single Tap Event
    ///
    /// - Parameter gesture: Single Tap Gesture
    @objc  func onSingleTapGesture(_ gesture: UITapGestureRecognizer) {
        isDisplayControl = !isDisplayControl
        displayControlView(isDisplayControl)
    }
    
    /// Double Tap Event
    ///
    /// - Parameter gesture: Double Tap Gesture
    @objc  func onDoubleTapGesture(_ gesture: UITapGestureRecognizer) {
        
        guard vgPlayer == nil else {
            switch vgPlayer!.state {
            case .playFinished:
                break
            case .playing:
                vgPlayer?.pause()
            case .paused:
                vgPlayer?.play()
            case .none:
                break
            case .error:
                break
            }
            return
        }
    }
    
    /// Pan Event
    ///
    /// - Parameter gesture: Pan Gesture
    @objc  func onPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let location = gesture.location(in: self)
        let velocity = gesture.velocity(in: self)
        switch gesture.state {
        case .began:
            let x = abs(translation.x)
            let y = abs(translation.y)
            if x < y {
                panGestureDirection = .vertical
                if location.x > bounds.width / 2 {
                    isVolume = true
                } else {
                    isVolume = false
                }
            } else if x > y{
                guard vgPlayer?.mediaFormat == .m3u8 else {
                    panGestureDirection = .horizontal
                    return
                }
            }
        case .changed:
            switch panGestureDirection {
            case .horizontal:
                if vgPlayer?.currentDuration == 0 { break }
                sliderSeekTimeValue = panGestureHorizontal(velocity.x)
            case .vertical:
                panGestureVertical(velocity.y)
            }
        case .ended:
            switch panGestureDirection{
            case .horizontal:
                if sliderSeekTimeValue.isNaN { return }
                self.vgPlayer?.seekTime(sliderSeekTimeValue, completion: { [weak self] (finished) in
                    guard let strongSelf = self else { return }
                    if finished {
                        
                        strongSelf.isTimeSliding = false
                        strongSelf.setupTimer()
                    }
                })
            case .vertical:
                isVolume = false
            }
            
        default:
            break
        }
    }
    
    internal func panGestureHorizontal(_ velocityX: CGFloat) -> TimeInterval {
        displayControlView(true)
        isTimeSliding = true
        timer.invalidate()
        let value = timeSlider.value
        if let _ = vgPlayer?.currentDuration ,let totalDuration = vgPlayer?.totalDuration {
            let sliderValue = (TimeInterval(value) *  totalDuration) + TimeInterval(velocityX) / 100.0 * (TimeInterval(totalDuration) / 400)
            timeSlider.setValue(Float(sliderValue/totalDuration), animated: true)
            return sliderValue
        } else {
            return TimeInterval.nan
        }
        
    }
    
    internal func panGestureVertical(_ velocityY: CGFloat) {
        isVolume ? (volumeSlider.value -= Float(velocityY / 10000)) : (UIScreen.main.brightness -= velocityY / 10000)
    }

    @objc internal func onCloseView(_ sender: UIButton) {
        delegate?.vgPlayerView(didTappedClose: self)
    }
    
    @objc internal func onReplay(_ sender: UIButton) {
        vgPlayer?.replaceVideo((vgPlayer?.contentURL)!)
        vgPlayer?.play()
    }
    
    @objc internal func deviceOrientationWillChange(_ sender: Notification) {
        if #available(iOS 16, *) {
            return deviceOrientationWillChange_IOS16(sender)
        }
        let orientation = UIDevice.current.orientation
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation == .portrait{
            if superview != nil {
                parentView = (superview)!
                viewFrame = frame
            }
        }
        switch orientation {
        case .unknown:
            break
        case .faceDown:
            break
        case .faceUp:
            break
        case .landscapeLeft:
            onDeviceOrientation(true, orientation: .landscapeLeft)
        case .landscapeRight:
            onDeviceOrientation(true, orientation: .landscapeRight)
        case .portrait:
            onDeviceOrientation(false, orientation: .portrait)
        case .portraitUpsideDown:
            onDeviceOrientation(false, orientation: .portraitUpsideDown)
        @unknown default:
            break
        }
    }
    internal func onDeviceOrientation(_ fullScreen: Bool, orientation: UIInterfaceOrientation) {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if orientation == statusBarOrientation {
            if orientation == .landscapeLeft || orientation == .landscapeLeft {
                let rectInWindow = convert(bounds, to: UIApplication.shared.keyWindow)
                removeFromSuperview()
                frame = rectInWindow
                UIApplication.shared.keyWindow?.addSubview(self)
                //deactivate previous height and width constraint
                deactivateWidthAndHeight()
                self.translatesAutoresizingMaskIntoConstraints = false
                self.widthAnchor.constraint(equalToConstant: self.superview!.bounds.height).isActive = true
                self.heightAnchor.constraint(equalToConstant: self.superview!.bounds.width).isActive = true
                self.updateConstraints()
                self.layoutIfNeeded()
            }
        } else {
            if orientation == .landscapeLeft || orientation == .landscapeRight {
                let rectInWindow = convert(bounds, to: UIApplication.shared.keyWindow)
                removeFromSuperview()
                frame = rectInWindow
                UIApplication.shared.keyWindow?.addSubview(self)
                //deactivate previous height and width constraint
                deactivateWidthAndHeight()
                self.translatesAutoresizingMaskIntoConstraints = false
                self.widthAnchor.constraint(equalToConstant: self.superview!.bounds.height).isActive = true
                self.heightAnchor.constraint(equalToConstant: self.superview!.bounds.width).isActive = true
                self.updateConstraints()
                self.layoutIfNeeded()
                //print(self.superview!.bounds)

            } else if orientation == .portrait{
                if parentView == nil { return }
                removeFromSuperview()
                parentView!.addSubview(self)
                let frame = parentView!.convert(viewFrame, to: UIApplication.shared.keyWindow)
                self.translatesAutoresizingMaskIntoConstraints = false

                self.center =  .init(x: viewFrame.midX, y: viewFrame.midY)
                //deactivate previous height and width constraint
                deactivateWidthAndHeight()
                self.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
                self.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
                self.updateConstraints()
                self.layoutIfNeeded()
                viewFrame = CGRect()
                parentView = nil
            }
        }
        isFullScreen = fullScreen
        fullscreenButton.isSelected = fullScreen
        delegate?.vgPlayerView(self, willFullscreen: isFullScreen)
        
    }
    
    @available(iOS 13.0, *)
    @objc internal func deviceOrientationWillChange_IOS16(_ sender: Notification) {
        let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .portrait

        switch orientation {
        case .unknown:
            break
        case .landscapeLeft:
            onDeviceOrientation_IOS16(true, orientation: .landscapeLeft)
        case .landscapeRight:
            onDeviceOrientation_IOS16(true, orientation: .landscapeRight)
        case .portrait:
            onDeviceOrientation_IOS16(false, orientation: .portrait)
        case .portraitUpsideDown:
            onDeviceOrientation_IOS16(false, orientation: .portraitUpsideDown)
        }
    }
    internal func onDeviceOrientation_IOS16(_ fullScreen: Bool, orientation: UIInterfaceOrientation) {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            let rectInWindow = convert(bounds, to: UIApplication.shared.keyWindow)
            removeFromSuperview()
            frame = rectInWindow
            UIApplication.shared.keyWindow?.addSubview(self)
            deactivateWidthAndHeight()
            self.translatesAutoresizingMaskIntoConstraints = false
            self.widthAnchor.constraint(equalToConstant: self.superview!.bounds.height).isActive = true
            self.heightAnchor.constraint(equalToConstant: self.superview!.bounds.width).isActive = true
            self.layoutIfNeeded()
        } else if orientation == .portrait{
            if parentView == nil { return }
            removeFromSuperview()
            parentView!.addSubview(self)
            self.translatesAutoresizingMaskIntoConstraints = false
            self.leadingAnchor.constraint(equalTo: parentView!.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: parentView!.trailingAnchor).isActive = true
            self.topAnchor.constraint(equalTo: parentView!.topAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: parentView!.bottomAnchor).isActive = true
            self.layoutIfNeeded()
        }
        
        isFullScreen = fullScreen
        fullscreenButton.isSelected = fullScreen
        delegate?.vgPlayerView(self, willFullscreen: isFullScreen)
    }
    
    private func deactivateWidthAndHeight(){
        self.constraints.forEach { consraint in
            if consraint.firstAttribute == .width{
                NSLayoutConstraint.deactivate([consraint])
            }
            if consraint.firstAttribute == .height{
                NSLayoutConstraint.deactivate([consraint])
            }
        }
    }
}

//MARK: - UI autoLayout
extension VGPlayerView {

    internal func configurationReplayButton() {
        addSubview(self.replayButton)
        let replayImage = VGPlayerUtils.imageResource("VGPlayer_ic_replay")
        replayButton.setImage(VGPlayerUtils.imageSize(image: replayImage!, scaledToSize: CGSize(width: 30, height: 30)), for: .normal)
        replayButton.addTarget(self, action: #selector(onReplay(_:)), for: .touchUpInside)
        replayButton.isHidden = true
    }
    
    internal func configurationTopView() {
        addSubview(topView)
        titleLabel.text = "this is a title."
        topView.addSubview(titleLabel)
        let closeImage = VGPlayerUtils.imageResource("VGPlayer_ic_nav_back")
        closeButton.setImage(VGPlayerUtils.imageSize(image: closeImage!, scaledToSize: CGSize(width: 15, height: 20)), for: .normal)
        closeButton.addTarget(self, action: #selector(onCloseView(_:)), for: .touchUpInside)
        topView.addSubview(closeButton)
    }
    
    internal func configurationBottomView() {
        addSubview(bottomView)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged(_:)),
                             for: .valueChanged)
        timeSlider.addTarget(self, action: #selector(timeSliderTouchUpInside(_:)), for: .touchUpInside)
        timeSlider.addTarget(self, action: #selector(timeSliderTouchDown(_:)), for: .touchDown)
        loadingIndicator.lineWidth = 1.0
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
        bottomView.addSubview(timeSlider)
        
        let playImage = VGPlayerUtils.imageResource("VGPlayer_ic_play")
        let pauseImage = VGPlayerUtils.imageResource("VGPlayer_ic_pause")
        playButtion.setImage(VGPlayerUtils.imageSize(image: playImage!, scaledToSize: CGSize(width: 15, height: 15)), for: .normal)
        playButtion.setImage(VGPlayerUtils.imageSize(image: pauseImage!, scaledToSize: CGSize(width: 15, height: 15)), for: .selected)
        playButtion.addTarget(self, action: #selector(onPlayerButton(_:)), for: .touchUpInside)
        bottomView.addSubview(playButtion)
        
        timeLabel.textAlignment = .center
        timeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        timeLabel.font = UIFont.systemFont(ofSize: 12.0)
        timeLabel.text = "--:-- / --:--"
        bottomView.addSubview(timeLabel)
        
        let enlargeImage = VGPlayerUtils.imageResource("VGPlayer_ic_fullscreen")
        let narrowImage = VGPlayerUtils.imageResource("VGPlayer_ic_fullscreen_exit")
        fullscreenButton.setImage(VGPlayerUtils.imageSize(image: enlargeImage!, scaledToSize: CGSize(width: 15, height: 15)), for: .normal)
        fullscreenButton.setImage(VGPlayerUtils.imageSize(image: narrowImage!, scaledToSize: CGSize(width: 15, height: 15)), for: .selected)
        fullscreenButton.addTarget(self, action: #selector(onFullscreen(_:)), for: .touchUpInside)
        bottomView.addSubview(fullscreenButton)
        
    }
    
    internal func setupViewAutoLayout() {
        replayButton.translatesAutoresizingMaskIntoConstraints = false
        replayButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        replayButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        replayButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        replayButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        // top view layout
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        closeButton.translatesAutoresizingMaskIntoConstraints  = false
        closeButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 10).isActive = true
        closeButton.topAnchor.constraint(equalTo: self.topView.topAnchor, constant: 28).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
        

        // bottom view layout
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 52).isActive = true

        playButtion.translatesAutoresizingMaskIntoConstraints =  false
        playButtion.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor,constant: 20).isActive = true
        playButtion.heightAnchor.constraint(equalToConstant: 25).isActive = true
        playButtion.widthAnchor.constraint(equalToConstant: 25).isActive = true
        playButtion.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.trailingAnchor.constraint(equalTo: fullscreenButton.leadingAnchor, constant: -10).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: playButtion.centerYAnchor).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        timeSlider.centerYAnchor.constraint(equalTo: playButtion.centerYAnchor).isActive
         = true
        timeSlider.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor
                                             , constant: -10).isActive = true
        timeSlider.leadingAnchor.constraint(equalTo: playButtion.trailingAnchor, constant: 25).isActive = true
        timeSlider.heightAnchor.constraint(equalToConstant: 25).isActive = true

        fullscreenButton.translatesAutoresizingMaskIntoConstraints =  false
        fullscreenButton.centerYAnchor.constraint(equalTo: playButtion.centerYAnchor).isActive = true
        fullscreenButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor,constant: -10).isActive = true
        fullscreenButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        fullscreenButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loadingIndicator.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loadingIndicator.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    func teaserInitilize(){
        //full screen view setup
        let enlargeImage = VGPlayerUtils.imageResource("VGPlayer_ic_fullscreen")
        let narrowImage = VGPlayerUtils.imageResource("VGPlayer_ic_fullscreen_exit")
        fullscreenButton.setImage(VGPlayerUtils.imageSize(image: enlargeImage!, scaledToSize: CGSize(width: 16, height: 16)), for: .normal)
        fullscreenButton.setImage(VGPlayerUtils.imageSize(image: narrowImage!, scaledToSize: CGSize(width: 16, height: 16)), for: .selected)
        fullscreenButton.addTarget(self, action: #selector(onFullscreen(_:)), for: .touchUpInside)
        self.addSubview(fullscreenButton)
        
        fullscreenButton.translatesAutoresizingMaskIntoConstraints =  false
        fullscreenButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true
        fullscreenButton.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -12).isActive = true
        fullscreenButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        fullscreenButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        let playImage = VGPlayerUtils.imageResource("VGPlayer_ic_play")
        let pauseImage = VGPlayerUtils.imageResource("VGPlayer_ic_pause")
        playButtion.setImage(VGPlayerUtils.imageSize(image: playImage!, scaledToSize: CGSize(width: 30, height: 30)), for: .normal)
        playButtion.setImage(VGPlayerUtils.imageSize(image: pauseImage!, scaledToSize: CGSize(width: 30, height: 30)), for: .selected)
        playButtion.addTarget(self, action: #selector(onPlayerButton(_:)), for: .touchUpInside)
        
        self.addSubview(playButtion)
        playButtion.translatesAutoresizingMaskIntoConstraints = false
        
        playButtion.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playButtion.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onSingleTapGestureForTeaser(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        singleTapGesture.delegate = self
        addGestureRecognizer(singleTapGesture)
    }
    ///
    /// - Parameter gesture: Single Tap Gesture
    @objc  func onSingleTapGestureForTeaser(_ gesture: UITapGestureRecognizer) {
        isDisplayControl = !isDisplayControl
        displayControlViewForTeaser(isDisplayControl)
    }
    
    func displayControlViewForTeaser(_ isDisplay:Bool) {
       if isDisplay {
           displayControlAnimationForTeaser()
       } else {
           hiddenControlAnimationForTeaser()
       }
    }
    
    internal func displayControlAnimationForTeaser() {
        playButtion.isHidden = false
        isDisplayControl = true
        UIView.animate(withDuration: 0.5, animations: {
            self.playButtion.alpha = 1
        }) { (completion) in
            self.setupTimer()
        }
    }
    internal func hiddenControlAnimationForTeaser() {
        timer.invalidate()
        isDisplayControl = false
        UIView.animate(withDuration: 0.5, animations: {
            self.playButtion.alpha = 0
        }) { (completion) in
            self.playButtion.isHidden = true
        }
    }
}


