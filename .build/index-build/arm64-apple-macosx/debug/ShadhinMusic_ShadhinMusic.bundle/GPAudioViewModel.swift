//
//  GPAudioViewModel.swift
//  Shadhin_Gp
//
//  Created by Maruf on 4/9/24.
//

import Foundation

class GPAudioViewModel {
    static let shared = GPAudioViewModel()

    // MARK: - Player Context
    enum PlayerContext {
        case widget
        case sdk
        case none
    }

    private(set) var activePlayerContext: PlayerContext = .none

    var gpMusicContents: [GPContent] = []
    var areWeInsideSDK = false

    var audioItems = [AudioItem]()
    var currentAudioItem: AudioItem?
    var seekTo: TimeInterval?

    var selectedIndexInCarousel: Int = 0
    var whichIndexIsPlayingInTrending: Int?
    var trendingState: PlayingState = .neverPlayed
    var trendingSongInteractionContentId: Int?
    var goContentPlayingState: PlayingState = .neverPlayed

    var changeTitle: () -> Void = {}
    var changeAllButtonsToImageName: [(PlayingState, Int?) -> Void] = []

    private init() {}

    // MARK: - Context Switching
    func switchContext(to context: PlayerContext) {
        let previous = activePlayerContext
        activePlayerContext = context

        switch context {
        case .widget:
            areWeInsideSDK = false
        case .sdk:
            areWeInsideSDK = true
        case .none:
            areWeInsideSDK = false
        }

        if previous != context {
            print("[GPAudioViewModel] Context switched: \(previous) → \(context)")
        }
    }

    // MARK: - Context Helpers
    var isWidgetContext: Bool {
        return activePlayerContext == .widget
    }

    var isSDKContext: Bool {
        return activePlayerContext == .sdk
    }

    // MARK: - UI Helpers
    func setPlayPauseImage(playPauseButton: UIButton, isPlaying: PlayingState) {
        let imageName: String
        switch isPlaying {
        case .neverPlayed:
            imageName = "stop_ic"
        case .playing:
            imageName = "play_pause"
        case .pause:
            imageName = "stop_ic"
        }
        DispatchQueue.main.async {
            playPauseButton.setImage(
                UIImage(named: imageName, in: Bundle.ShadhinMusicSdk, with: nil),
                for: .normal
            )
        }
    }

    // MARK: - Audio Control
    func startGPContentsAudio(index: Int) {
        guard !gpMusicContents.isEmpty else { return }
        AudioPlayer.shared.play(
            items: convertToAudioItems(from: gpMusicContents),
            startAtIndex: index
        )
    }

    public func startAudio() {
        guard let gpData = ShadhinCore.instance.defaults.gpExploreMusicList else { return }
        let gpContents = getAllContents(from: gpData)
        AudioPlayer.shared.play(
            items: convertToAudioItems(from: gpContents),
            startAtIndex: selectedIndexInCarousel
        )
    }

    public func playAudio() {
        AudioPlayer.shared.resume()
    }

    public func pauseAudio() {
        AudioPlayer.shared.pause()
    }

    public func stopAudio() {
        AudioPlayer.shared.stop()
    }

    // MARK: - Content Helpers
    func getAllContents(from model: GPExploreMusicModel) -> [GPContent] {
        var allContents: [GPContent] = []
        guard let patches = model.data else { return allContents }
        if let contents = patches.first?.contents {
            allContents.append(contentsOf: contents)
        }
        ShadhinCore.instance.defaults.gpMusicContentsCache = allContents
        return allContents
    }

    func convertToAudioItems(from gpContents: [GPContent]) -> [AudioItem] {
        return gpContents.compactMap { gpContent in
            var url: URL? = nil
            if let streamingUrlStr = gpContent.streamingUrl, !streamingUrlStr.isEmpty {
                url = URL(string: streamingUrlStr)
            }

            let audioItem = AudioItem(highQualitySoundURL: url)
            audioItem?.contentId = gpContent.contentId.map { String($0) }
            audioItem?.contentType = gpContent.contentType
            audioItem?.trackType = gpContent.track?.trackType
            audioItem?.title = gpContent.titleEn
            audioItem?.artist = gpContent.artists?.first?.name
            audioItem?.urlKey = gpContent.streamingUrl

            if let imgUrl = gpContent.imageUrl?.replacingOccurrences(of: "<$size$>", with: "300"),
               let artworkUrl = URL(string: imgUrl) {
                KingfisherManager.shared.downloader.downloadImage(with: artworkUrl) { result in
                    if case let .success(value) = result {
                        audioItem?.artworkImage = value.image
                    }
                }
            }

            return audioItem
        }
    }

    // MARK: - Reset
    func resetWidgetState() {
        switchContext(to: .widget)
        goContentPlayingState = .neverPlayed
        seekTo = nil
    }
}

// MARK: - PlayerContext Equatable
extension GPAudioViewModel.PlayerContext: Equatable {
    static func == (lhs: GPAudioViewModel.PlayerContext, rhs: GPAudioViewModel.PlayerContext) -> Bool {
        switch (lhs, rhs) {
        case (.widget, .widget): return true
        case (.sdk, .sdk): return true
        case (.none, .none): return true
        default: return false
        }
    }
}

