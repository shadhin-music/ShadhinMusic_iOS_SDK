//
//  NativeAdLargeCell.swift
//  Shadhin
//
//  Created by Gakk Alpha on 12/12/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit


class NativeAdLargeCell: UICollectionViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var headlineView: UILabel!
    @IBOutlet weak var advertiser: UILabel!
    @IBOutlet weak var bodyView: UILabel!
    @IBOutlet weak var learnMore: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGSize {
        return .init(width: SCREEN_WIDTH - 32, height: 400)
    }
    
//    func loadAd(nativeAd: GADNativeAd){
//        iconView.image = nativeAd.icon?.image
//        headlineView.text = nativeAd.headline
//        advertiser.text = nativeAd.advertiser
//        //mediaView?.contentMode = .scaleAspectFill
//        mediaView?.mediaContent = nativeAd.mediaContent
//        bodyView.text = nativeAd.body
//        nativeAdView.callToActionView = learnMore
//        nativeAdView.callToActionView?.isUserInteractionEnabled = false
//        nativeAdView.nativeAd = nativeAd
//    }

}
