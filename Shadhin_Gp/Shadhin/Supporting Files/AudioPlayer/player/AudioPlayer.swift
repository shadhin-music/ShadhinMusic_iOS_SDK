//
//  AudioPlayer.swift
//  AudioPlayer
//
//  Created by Kevin DELANNOY on 26/04/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import UIKit
import AVFoundation
#if os(iOS) || os(tvOS)
    import MediaPlayer

#endif

/// An `AudioPlayer` instance is used to play `AudioPlayerItem`. It's an easy to use AVPlayer with simple methods to
/// handle the whole playing audio process.
///
/// You can get events (such as state change or time observation) by registering a delegate.
public class AudioPlayer: NSObject {
    // MARK: Handlers

    /// The background handler.
    let backgroundHandler = BackgroundHandler()

    /// Reachability for network connection.
    let reachability = try! Reachability()

    // MARK: Event producers

    /// The network event producer.
    lazy var networkEventProducer: NetworkEventProducer = {
        NetworkEventProducer(reachability: self.reachability)
    }()

    /// The player event producer.
    let playerEventProducer = PlayerEventProducer()

    /// The seek event producer.
    let seekEventProducer = SeekEventProducer()

    /// The quality adjustment event producer.
    var qualityAdjustmentEventProducer = QualityAdjustmentEventProducer()

    /// The audio item event producer.
    var audioItemEventProducer = AudioItemEventProducer()

    /// The retry event producer.
    var retryEventProducer = RetryEventProducer()
    
    var getPlayableUrlRequest: Request?

    // MARK: Player

    /// The queue containing items to play.
    var queue: AudioItemQueue?
    
    private var isNotInRetry = true
    
    var delayedItemChange = false
    var trackItemPlayedAndEnableRetry = false
    var timeToWaitBeforeRetry = 6
    var timeTracker = Timer()
    var pendingDelayedWork: DispatchWorkItem?
    var clearQueueWhenStopped = true
    
    static let shared = AudioPlayer()
    
    func newInstance() -> AudioPlayer{
        return AudioPlayer()
    }
    /// The audio player.
    var player: AVPlayer? {
        didSet {
            if #available(OSX 10.11, *) {
                player?.allowsExternalPlayback = false
            }
            player?.allowsExternalPlayback = true
            player?.volume = volume
            player?.rate = rate
            updatePlayerForBufferingStrategy()

            if let player = player {
                playerEventProducer.player = player
                audioItemEventProducer.item = currentItem
                playerEventProducer.startProducingEvents()
                networkEventProducer.startProducingEvents()
                audioItemEventProducer.startProducingEvents()
                qualityAdjustmentEventProducer.startProducingEvents()
            } else {
                playerEventProducer.player = nil
                audioItemEventProducer.item = nil
                playerEventProducer.stopProducingEvents()
                networkEventProducer.stopProducingEvents()
                audioItemEventProducer.stopProducingEvents()
                qualityAdjustmentEventProducer.stopProducingEvents()
            }
        }
    }

    /// The current item being played.
    public internal(set) var currentItem: AudioItem? {
        didSet {
            if let currentItem = currentItem {
                //Stops the current player
                player?.rate = 0
                player = nil
                currentItem.startDate = Date()
                currentItem.playedSeconds = 0
                //Ensures the audio session got started
                setAudioSession(active: true)
                if delayedItemChange{
                    cancelPreviousRequest()
                    let requestWorkItem = DispatchWorkItem(block: {self.getPlayableUrlAndPlay(item: currentItem, oldValue: oldValue)})
                    pendingDelayedWork = requestWorkItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: requestWorkItem)
                }else{
                    getPlayableUrlAndPlay(item: currentItem, oldValue: oldValue)
                }
                
            } else {
                stop()
            }
            if let oldValue = oldValue, trackItemPlayedAndEnableRetry, oldValue.playedSeconds > 0{
                delegate?.audioPlayer(finishedPlaying: oldValue)
            }
        }
    }
    
    public func cancelPreviousRequest(){
        getPlayableUrlRequest?.cancel()
        pendingDelayedWork?.cancel()
    }
    
    public func getPlayableUrlAndPlay(item : AudioItem, oldValue : AudioItem?){
        guard let contentid = item.contentId else {return}
        let isPdocast = item.contentType?.prefix(2).uppercased() == "PD" ? true : false
        if let _item =  isPdocast ? DatabaseContext.shared.getPodcastBy(id : contentid) : DatabaseContext.shared.getSongBy(id: contentid),
           let playUrl =  _item.playUrl,playUrl != "empty" {
            self.playUrl(url: playUrl, isLocal: true, isNewItem: item != oldValue)
            return
        }
        getPlayableUrlRequest = ShadhinCore.instance.api.getPlayUrl(
            item.contentType!,
            item.podcastShowCode!,
            item.trackType!,
            item.urlKey!,
            true)
        { playUrl, error in
            
//#if DEBUG
//            self.playUrl(url: "https://edge.mixlr.com/channel/rbhqh", isNewItem: item != oldValue)
//#endif
            guard let playUrl = playUrl,
                  self.currentItem?.contentId == item.contentId else {
                if(playUrl == nil){
                    self.getPlayUrlRetry(item.contentType!,
                                    item.podcastShowCode!,
                                    item.trackType!,
                                    item.urlKey!)
                }
                return
            }
            self.playUrl(url: playUrl, isNewItem: item != oldValue)
        }
    }
    
    public func getPlayUrlRetry(_ cType: String, _ pCode: String, _ tType: String, _ url: String){
        getPlayableUrlRequest = ShadhinCore.instance.api.getPlayUrl(
            cType,
            pCode,
            tType,
            url,
            false)
        { playUrl, error in
            //#if DEBUG
            //            self.playUrl(url: "https://edge.mixlr.com/channel/rbhqh", isNewItem: item != oldValue)
            //#endif
            guard let playUrl = playUrl else {return}
            self.playUrl(url: playUrl, isNewItem: true)
        }
    }

    
    public func playUrl(url: String, isLocal: Bool = false, isNewItem: Bool,currentTime : CMTime = .zero){
        guard let currentItem = currentItem else {return}
        if isLocal{
            state = .playing
            backgroundHandler.beginBackgroundTask()
        }else{
            if try! Reachability().connection != .unavailable {
                state = .buffering
                backgroundHandler.beginBackgroundTask()
            } else {
                stateWhenConnectionLost = .buffering
                state = .waitingForConnection
                backgroundHandler.beginBackgroundTask()
                return
            }
        }
        self.pausedForInterruption = false
        let url = URL(string: url)!
        let playerItem = AVPlayerItem(url: url)
        if #available(iOS 10.0, tvOS 10.0, OSX 10.12, *) {
            playerItem.preferredForwardBufferDuration = self.preferredForwardBufferDuration
        }
        self.player = AVPlayer(playerItem: playerItem)
        self.setUpNowPlayingInfoCenter()
        self.updateNowPlayingInfoCenter()
        if isNewItem {
            self.delegate?.audioPlayer(self, willStartPlaying: currentItem)
        }else if currentItem.trackType?.lowercased() != "lm" {
            self.player?.seek(to: currentTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        self.player?.rate = self.rate
        
        Log.info("self.rate:\(self.rate), state:\(state), self.rate:\(self.rate)")
    }
    
    public func retryContentPlay(){
        guard let item = currentItem, isNotInRetry else {return}
        isNotInRetry = false
        let currentTime = player?.currentTime()
        player?.rate = 0
        player = nil
        Log.warning("fired retry on contentId -> \(String(describing: item.contentId)) with current time -> \(String(describing: currentTime))")
        getPlayableUrlRequest = ShadhinCore.instance.api.getPlayUrl(
            item.contentType!,
            item.podcastShowCode!,
            item.trackType!,
            item.urlKey!)
        { playUrl, error in
            if let playUrl = playUrl,
               self.currentItem?.contentId == item.contentId{
                self.playUrl(url: playUrl, isNewItem: false,currentTime: currentTime ?? .zero)
            }
            self.isNotInRetry = true
        }
    }
    
    
    public var totalDurationWatched: TimeInterval {
        get {
            var totalDurationWatched = 0.0
            if let accessLog = player?.currentItem?.accessLog(), accessLog.events.isEmpty == false {
                for event in accessLog.events where event.durationWatched > 0 {
                    totalDurationWatched += event.durationWatched
                }
            }
            return totalDurationWatched
        }
    }
    


    // MARK: Public properties

    /// The delegate that will be called upon events.
    public weak var delegate: AudioPlayerDelegate?

    /// Defines the maximum to wait after a connection loss before putting the player to Stopped mode and cancelling
    /// the resume. Default value is 60 seconds.
    public var maximumConnectionLossTime = TimeInterval(60)

    /// Defines whether the player should automatically adjust sound quality based on the number of interruption before
    /// a delay and the maximum number of interruption whithin this delay. Default value is `true`.
    public var adjustQualityAutomatically = true

    /// Defines the default quality used to play. Default value is `.medium`
    public var defaultQuality = AudioQuality.medium

    /// Defines the delay within which the player wait for an interruption before upgrading the quality. Default value
    /// is 10 minutes.
    public var adjustQualityTimeInternal: TimeInterval {
        get {
            return qualityAdjustmentEventProducer.adjustQualityTimeInternal
        }
        set {
            qualityAdjustmentEventProducer.adjustQualityTimeInternal = newValue
        }
    }

    /// Defines the maximum number of interruption to have within the `adjustQualityTimeInterval` delay before
    /// downgrading the quality. Default value is 5.
    public var adjustQualityAfterInterruptionCount: Int {
        get {
            return qualityAdjustmentEventProducer.adjustQualityAfterInterruptionCount
        }
        set {
            qualityAdjustmentEventProducer.adjustQualityAfterInterruptionCount = newValue
        }
    }

    /// The maximum number of interruption before putting the player to Stopped mode. Default value is 10.
    public var maximumRetryCount: Int {
        get {
            return retryEventProducer.maximumRetryCount
        }
        set {
            retryEventProducer.maximumRetryCount = newValue
        }
    }

    /// The delay to wait before cancelling last retry and retrying. Default value is 10 seconds.
    public var retryTimeout: TimeInterval {
        get {
            return retryEventProducer.retryTimeout
        }
        set {
            retryEventProducer.retryTimeout = newValue
        }
    }

    /// Defines whether the player should resume after a system interruption or not. Default value is `true`.
    public var resumeAfterInterruption = true

    /// Defines whether the player should resume after a connection loss or not. Default value is `true`.
    public var resumeAfterConnectionLoss = true

    /// Defines the mode of the player. Default is `.Normal`.
    public var mode = AudioPlayerMode.normal {
        didSet {
            queue?.mode = mode
        }
    }

    /// Defines the volume of the player. `1.0` means 100% and `0.0` is 0%.
    public var volume = Float(1) {
        didSet {
            player?.volume = volume
        }
    }

    /// Defines the rate of the player. Default value is 1.
    public var rate = Float(1) {
        didSet {
            if case .playing = state {
                player?.rate = rate
                updateNowPlayingInfoCenter()
            }
        }
    }
    
    /// Defines the buffering strategy used to determine how much to buffer before starting playback
    public var bufferingStrategy: AudioPlayerBufferingStrategy = .defaultBuffering {
        didSet {
            updatePlayerForBufferingStrategy()
        }
    }
    
    /// Defines the preferred buffer duration in seconds before playback begins. Defaults to 60.
    /// Works on iOS/tvOS 10+ when `bufferingStrategy` is `.playWhenPreferredBufferDurationFull`.
    public var preferredBufferDurationBeforePlayback = TimeInterval(60)
    
    /// Defines the preferred size of the forward buffer for the underlying `AVPlayerItem`.
    /// Works on iOS/tvOS 10+, default is 0, which lets `AVPlayer` decide.
    public var preferredForwardBufferDuration = TimeInterval(0)

    /// Defines how to behave when the user is seeking through the lockscreen or the control center.
    ///
    /// - multiplyRate: Multiples the rate by a factor.
    /// - changeTime:   Changes the current position by adding/substracting a time interval.
    public enum SeekingBehavior {
        case multiplyRate(Float)
        case changeTime(every: TimeInterval, delta: TimeInterval)

        func handleSeekingStart(player: AudioPlayer, forward: Bool) {
            switch self {
            case .multiplyRate(let rateMultiplier):
                if forward {
                    player.rate = player.rate * rateMultiplier
                } else {
                    player.rate = -(player.rate * rateMultiplier)
                }

            case .changeTime:
                player.seekEventProducer.isBackward = !forward
                player.seekEventProducer.startProducingEvents()
            }
        }

        func handleSeekingEnd(player: AudioPlayer, forward: Bool) {
            switch self {
            case .multiplyRate(let rateMultiplier):
                if forward {
                    player.rate = player.rate / rateMultiplier
                } else {
                    player.rate = -(player.rate / rateMultiplier)
                }

            case .changeTime:
                player.seekEventProducer.stopProducingEvents()
            }
        }
    }

    /// Defines the rate behavior of the player when the backward/forward buttons are pressed. Default value
    /// is `multiplyRate(2)`.
    public var seekingBehavior = SeekingBehavior.multiplyRate(2) {
        didSet {
            if case .changeTime(let timerInterval, _) = seekingBehavior {
                seekEventProducer.intervalBetweenEvents = timerInterval
            }
        }
    }
    
    
    private var currentTimeChangeValue : CMTime = .zero
    private var waitedForFileToPlayTick = 0
    // MARK: Readonly properties

    /// The current state of the player.
    public internal(set) var state = AudioPlayerState.stopped {
        didSet {
            Log.info("Player state change")
            updateNowPlayingInfoCenter()
            if state != oldValue {
                if case .buffering = state {
                    backgroundHandler.beginBackgroundTask()
                } else if case .buffering = oldValue {
                    backgroundHandler.endBackgroundTask()
                }
                if trackItemPlayedAndEnableRetry{
                    self.timeTracker.invalidate()
                    switch state{
                    case .playing:
                        self.timeTracker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
                            self?.currentItem?.playedSeconds += 1
                            self?.checkIfFileExpired()
                        })
                    case .buffering,
                         .waitingForConnection:
                        self.timeTracker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
                            self?.checkIfFileExpired()
                        })
                    case .failed(let error):
                        if case .foundationError(let err) = error,
                           err._code == -1002,
                           currentItem?.contentType?.uppercased() != "LM"{
                            self.retryContentPlay()
                        }else{
                            self.timeTracker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
                                self?.checkIfFileExpired()
                            })
                        }
                    default:
                        break
                    }
                }
                delegate?.audioPlayer(self, didChangeStateFrom: oldValue, to: state)
            }
        }
    }

    /// The current quality being played.
    public internal(set) var currentQuality: AudioQuality

    // MARK: Private properties

    /// A boolean value indicating whether the player has been paused because of a system interruption.
    var pausedForInterruption = false

    /// A boolean value indicating if quality is being changed. It's necessary for the interruption count to not be
    /// incremented while new quality is buffering.
    var qualityIsBeingChanged = false

    /// The state before the player went into .Buffering. It helps to know whether to restart or not the player.
    var stateBeforeBuffering: AudioPlayerState?

    /// The state of the player when the connection was lost
    var stateWhenConnectionLost: AudioPlayerState?

    // MARK: Initialization

    /// Initializes a new AudioPlayer.
    private override init() {
        currentQuality = defaultQuality
        super.init()

        playerEventProducer.eventListener = self
        networkEventProducer.eventListener = self
        audioItemEventProducer.eventListener = self
        qualityAdjustmentEventProducer.eventListener = self
    }

    /// Deinitializes the AudioPlayer. On deinit, the player will simply stop playing anything it was previously
    /// playing.
    deinit {
        ShadhinCore.instance.api.releaseServerLock()
        stop()
    }
    
    func checkIfFileExpired(){
        let _currentTime = player?.currentItem?.currentTime() ?? .zero
        if currentTimeChangeValue.seconds != _currentTime.seconds{
            currentTimeChangeValue = _currentTime
            waitedForFileToPlayTick = 0
            return
        }
        waitedForFileToPlayTick += 1
        Log.info(" currentTimeChangeValue:\(currentTimeChangeValue.seconds), _currentTime:\(_currentTime.seconds), bool:\(currentTimeChangeValue.seconds != _currentTime.seconds), waitedForFileToPlayTick:\(waitedForFileToPlayTick)")
        guard waitedForFileToPlayTick > timeToWaitBeforeRetry else {return}
        waitedForFileToPlayTick = 0
        retryContentPlay()
    }
    

    func setUpNowPlayingInfoCenter(){
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled =  true
        commandCenter.playCommand.addTarget { event in
            self.player?.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled =  true
        commandCenter.pauseCommand.addTarget { event in
            self.player?.pause()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled =  true
        commandCenter.nextTrackCommand.addTarget { event in
            self.next()
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled =  true
        commandCenter.previousTrackCommand.addTarget { event in
            self.previous()
            return .success
        }
        
        let changePlaybackPositionCommand = commandCenter.changePlaybackPositionCommand
        changePlaybackPositionCommand.isEnabled = true
        changePlaybackPositionCommand.addTarget { event in
            let seconds = (event as? MPChangePlaybackPositionCommandEvent)?.positionTime ?? 0
            let time = CMTime(seconds: seconds, preferredTimescale: 1)
            self.player?.seek(to: time)
            return .success
        }
    }

    // MARK: Utility methods

    /// Updates the MPNowPlayingInfoCenter with current item's info.
    func updateNowPlayingInfoCenter() {
        #if os(iOS) || os(tvOS)
            if let item = currentItem {
                MPNowPlayingInfoCenter.default().ap_update(
                    with: item,
                    duration: currentItemDuration,
                    progression: currentItemProgression,
                    playbackRate: player?.rate ?? 0)
            } else {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            }
        #endif
    }

    /// Enables or disables the `AVAudioSession` and sets the right category.
    ///
    /// - Parameter active: A boolean value indicating whether the audio session should be set to active or not.
    func setAudioSession(active: Bool) {
        #if os(iOS) || os(tvOS)
            _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            _ = try? AVAudioSession.sharedInstance().setActive(active)
        #endif
    }

    // MARK: Public computed properties

    /// Boolean value indicating whether the player should resume playing (after buffering)
    var shouldResumePlaying: Bool {
        return !state.isPaused &&
            (stateWhenConnectionLost.map { !$0.isPaused } ?? true) &&
            (stateBeforeBuffering.map { !$0.isPaused } ?? true)
    }

    // MARK: Retrying

    /// This will retry to play current item and seek back at the correct position if possible (or enabled). If not,
    /// it'll just play the next item in queue.
    func retryOrPlayNext() {
        guard !state.isPlaying else {
            retryEventProducer.stopProducingEvents()
            return
        }

        let cip = currentItemProgression
        let ci = currentItem
        currentItem = ci
        if let cip = cip {
            //We can't call self.seek(to:) in here since the player is new
            //and `cip` is probably not in the seekableTimeRanges.
            player?.seek(to: CMTime(timeInterval: cip))
        }
    }
    
    /// Updates the current player based on the current buffering strategy.
    /// Only has an effect on iOS 10+, tvOS 10+ and macOS 10.12+
    func updatePlayerForBufferingStrategy() {
        if #available(iOS 10.0, tvOS 10.0, OSX 10.12, *) {
            player?.automaticallyWaitsToMinimizeStalling = self.bufferingStrategy != .playWhenBufferNotEmpty
        }
    }
    
    /// Updates a given player item based on the `preferredForwardBufferDuration` set.
    /// Only has an effect on iOS 10+, tvOS 10+ and macOS 10.12+
    func updatePlayerItemForBufferingStrategy(_ playerItem: AVPlayerItem) {
        //Nothing strategy-specific yet
        if #available(iOS 10.0, tvOS 10.0, OSX 10.12, *) {
            playerItem.preferredForwardBufferDuration = self.preferredForwardBufferDuration
        }
    }
}

extension AudioPlayer: EventListener {
    /// The implementation of `EventListener`. It handles network events, player events, audio item events, quality
    /// adjustment events, retry events and seek events.
    ///
    /// - Parameters:
    ///   - event: The event.
    ///   - eventProducer: The producer of the event.
    func onEvent(_ event: Event, generetedBy eventProducer: EventProducer) {
       
        if let event = event as? NetworkEventProducer.NetworkEvent {
            
            handleNetworkEvent(from: eventProducer, with: event)
        } else if let event = event as? PlayerEventProducer.PlayerEvent {
            handlePlayerEvent(from: eventProducer, with: event)
        } else if let event = event as? AudioItemEventProducer.AudioItemEvent {
            handleAudioItemEvent(from: eventProducer, with: event)
        } else if let event = event as? QualityAdjustmentEventProducer.QualityAdjustmentEvent {
            handleQualityEvent(from: eventProducer, with: event)
        } else if let event = event as? RetryEventProducer.RetryEvent {
            handleRetryEvent(from: eventProducer, with: event)
        } else if let event = event as? SeekEventProducer.SeekEvent {
            handleSeekEvent(from: eventProducer, with: event)
        }
    }
}
