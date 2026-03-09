//
//  AudioItem.swift
//  AudioPlayer
//
//  Created by Kevin DELANNOY on 12/03/16.
//  Copyright © 2016 Kevin Delannoy. All rights reserved.
//

import AVFoundation

#if os(iOS) || os(tvOS)
    import UIKit
    import MediaPlayer

    public typealias Image = UIImage
#else
    import Cocoa

    public typealias Image = NSImage
#endif

// MARK: - AudioQuality

/// `AudioQuality` differentiates qualities for audio.
///
/// - low: The lowest quality.
/// - medium: The quality between highest and lowest.
/// - high: The highest quality.
public enum AudioQuality: Int {
    case low = 0
    case medium = 1
    case high = 2
}

// MARK: - AudioItemURL

/// `AudioItemURL` contains information about an Item URL such as its quality.
public struct AudioItemURL {
    /// The quality of the stream.
    public let quality: AudioQuality

    /// The url of the stream.
    public var url: URL

    /// Initializes an AudioItemURL.
    ///
    /// - Parameters:
    ///   - quality: The quality of the stream.
    ///   - url: The url of the stream.
    public init?(quality: AudioQuality, url: URL?) {
        guard let url = url else { return nil }

        self.quality = quality
        self.url = url
    }
}

// MARK: - AudioItem

/// An `AudioItem` instance contains every piece of information needed for an `AudioPlayer` to play.
///
/// URLs can be remote or local.
open class AudioItem: NSObject {
    /// Returns the available qualities.
    public let soundURLs: [AudioQuality: URL]
    
    
    
    var contentId: String?
    var contentType: String?
    var podcastShowCode: String?
    var trackType: String?
    var urlKey: String?
    var contentData: CommonContentProtocol?
    var rootData: CommonContentProtocol?
    var startDate: Date?
    var playedSeconds: Int = 0
    
    
    // MARK: Initialization

    /// Initializes an AudioItem. Fails if every urls are nil.
    ///
    /// - Parameters:
    ///   - highQualitySoundURL: The URL for the high quality sound.
    ///   - mediumQualitySoundURL: The URL for the medium quality sound.
    ///   - lowQualitySoundURL: The URL for the low quality sound.
    public convenience init?(highQualitySoundURL: URL? = nil,
                             mediumQualitySoundURL: URL? = nil,
                             lowQualitySoundURL: URL? = nil) {
        var URLs = [AudioQuality: URL]()
        if let highURL = highQualitySoundURL {
            URLs[.high] = highURL
        }
        if let mediumURL = mediumQualitySoundURL {
            URLs[.medium] = mediumURL
        }
        if let lowURL = lowQualitySoundURL {
            URLs[.low] = lowURL
        }
        self.init(soundURLs: URLs)
    }
    
    convenience init?(track : CommonContentProtocol){
        var url: URL? = nil
        if let decryptedUrlStr = track.playUrl?.decryptUrl(){
            let strUrl =  decryptedUrlStr.contains("http") ? decryptedUrlStr.replacingOccurrences(of: " ", with: "%20") : decryptedUrlStr
            url =  URL(string: strUrl)
        }
        if track.trackType?.lowercased() == "lm"{
            url = URL(string: "www.google.com/test.mp3")
        }
        self.init(highQualitySoundURL: url)
        title = track.title
        artist = track.artist
        if let imgUrl = track.image?.replacingOccurrences(of: "<$size$>", with: "300"),
           let url = URL(string: imgUrl.safeUrl()){
            KingfisherManager.shared.downloader.downloadImage(with: url) { result in
                if case let .success(value) = result{
                    self.artworkImage = value.image
                }
            }
        }
        if let _contentType = track.contentType {
            if _contentType.uppercased().contains("PD"){
                podcastShowCode = String(_contentType.suffix(_contentType.count - 2)).uppercased()
                contentType = String(_contentType.prefix(2)).uppercased()
            }else{
                contentType = _contentType
                podcastShowCode = ""
            }
        }else{
            contentType = "S"
            podcastShowCode = ""
        }
        trackType   = track.trackType ?? ""
        urlKey      = url?.absoluteString ?? ""
        contentId   = track.contentID ?? ""
        contentData = track
        
//#if DEBUG
//print("SHADHIN LOG Content play url -> \(url) contentType -> \(contentType) podcastShowCode -> \(podcastShowCode) trackType -> \(trackType) urlKey -> \(urlKey)")
//#endif
    }

    /// Initializes an `AudioItem`.
    ///
    /// - Parameter soundURLs: The URLs of the sound associated with its quality wrapped in a `Dictionary`.
    public init?(soundURLs: [AudioQuality: URL]) {
        self.soundURLs = soundURLs
        super.init()

        if soundURLs.isEmpty {
            return nil
        }
    }

    // MARK: Quality selection

    /// Returns the highest quality URL found or nil if no URLs are available
    open var highestQualityURL: AudioItemURL {
        //swiftlint:disable force_unwrapping
        return (AudioItemURL(quality: .high, url: soundURLs[.high]) ??
            AudioItemURL(quality: .medium, url: soundURLs[.medium]) ??
            AudioItemURL(quality: .low, url: soundURLs[.low]))!
    }

    /// Returns the medium quality URL found or nil if no URLs are available
    open var mediumQualityURL: AudioItemURL {
        //swiftlint:disable force_unwrapping
        return (AudioItemURL(quality: .medium, url: soundURLs[.medium]) ??
            AudioItemURL(quality: .low, url: soundURLs[.low]) ??
            AudioItemURL(quality: .high, url: soundURLs[.high]))!
    }

    /// Returns the lowest quality URL found or nil if no URLs are available
    open var lowestQualityURL: AudioItemURL {
        //swiftlint:disable force_unwrapping
        return (AudioItemURL(quality: .low, url: soundURLs[.low]) ??
            AudioItemURL(quality: .medium, url: soundURLs[.medium]) ??
            AudioItemURL(quality: .high, url: soundURLs[.high]))!
    }

    /// Returns an URL that best fits a given quality.
    ///
    /// - Parameter quality: The quality for the requested URL.
    /// - Returns: The URL that best fits the given quality.
    func url(for quality: AudioQuality) -> AudioItemURL {
        switch quality {
        case .high:
            return highestQualityURL
        case .medium:
            return mediumQualityURL
        default:
            return lowestQualityURL
        }
    }

    // MARK: Additional properties

    /// The artist of the item.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var artist: String?

    /// The title of the item.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var title: String?

    /// The album of the item.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var album: String?

    ///The track count of the item's album.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var trackCount: NSNumber?

    /// The track number of the item in its album.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    @objc open dynamic var trackNumber: NSNumber?

    /// The artwork image of the item.
    open var artworkImage: Image? {
        get {
            #if os(OSX)
                return artwork
            #else
                return artwork?.image(at: imageSize ?? CGSize(width: 512, height: 512))
            #endif
        }
        set {
            #if os(OSX)
                artwork = newValue
            #else
                imageSize = newValue?.size
                artwork = newValue.map { image in
                return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            }
            #endif
        }
    }

    /// The artwork image of the item.
    ///
    /// This can change over time which is why the property is dynamic. It enables KVO on the property.
    #if os(OSX)
    @objc open dynamic var artwork: Image?
    #else
    @objc open dynamic var artwork: MPMediaItemArtwork?

    /// The image size.
    private var imageSize: CGSize?
    #endif

    // MARK: Metadata

    /// Parses the metadata coming from the stream/file specified in the URL's. The default behavior is to set values
    /// for every property that is nil. Customization is available through subclassing.
    ///
    /// - Parameter items: The metadata items.
    open func parseMetadata(_ items: [AVMetadataItem]) {
        items.forEach {
            if let commonKey = $0.commonKey {
                switch commonKey {
                case AVMetadataKey.commonKeyTitle where title == nil:
                    title = $0.value as? String
                case AVMetadataKey.commonKeyArtist where artist == nil:
                    artist = $0.value as? String
                case AVMetadataKey.commonKeyAlbumName where album == nil:
                    album = $0.value as? String
                case AVMetadataKey.id3MetadataKeyTrackNumber where trackNumber == nil:
                    trackNumber = $0.value as? NSNumber
                case AVMetadataKey.commonKeyArtwork where artwork == nil:
                    artworkImage = ($0.value as? Data).flatMap { Image(data: $0) }
                default:
                    break
                }
            }
        }
    }
}
