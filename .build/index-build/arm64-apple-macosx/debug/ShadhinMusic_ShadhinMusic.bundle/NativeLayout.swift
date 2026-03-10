//
//  NativeLayout.swift
//  MyGP
//
//  Created by MD Murad Hossain on 15/02/26.
//  Copyright © 2025 GrammenPhone Limited. All rights reserved.
//

import UIKit
import VmaxNativeHelper

// MARK: -- Protocol
protocol NativeLayout {
    var contentView: UIView! { get }
    var nativeView: UIView! { get }
    var mediaView: UIView? { get }
    var adBadgeLabel: UILabel? { get }
    var titleLabel: UILabel? { get }
    var subTitleLabel: UILabel? { get }
    var buttonCTA: UIButton? { get }
    var actionButton: UIButton { get }
    var imageHeight: CGFloat { get }
    var height: CGFloat { get }
    func commonInit()
}

// MARK: -- Native View
extension NativeLayout where Self: UIView {
    
    var imageHeight: CGFloat {
        ((UIScreen.main.bounds.width - 32) * 0.43)
    }

    func commonInit() {
        adBadgeLabel?.textColor = .white
        adBadgeLabel?.font = .medium(14)
        
        titleLabel?.textColor = .black
        titleLabel?.font = .medium(14)
        
        subTitleLabel?.font = .normal(11)
        subTitleLabel?.textColor = UIColor(hex: "#4D4D4D")
        
        buttonCTA?.titleLabel?.font = .medium(14)
        buttonCTA?.setTitleColor(.black, for: .normal)
        
        actionButton.setTitleColor(.clear, for: .normal)
        addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: nativeView.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: nativeView.bottomAnchor),
            actionButton.leadingAnchor.constraint(equalTo: nativeView.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: nativeView.trailingAnchor)
        ])
        bringSubviewToFront(actionButton)
    }
    
    func addDropShadows() {
        if let content = self.nativeView {
            self.addCornerRadiusDropShadow(
                to: content,
                cornerRadius: 10,
                shadowOpacity: 0.25,
                shadowRadius: 4.0
            )
        }
        if let adBadge = self.adBadgeLabel {
            self.addCornerRadiusDropShadow(
                to: adBadge,
                cornerRadius: 8,
                shadowOpacity: 0,
                shadowRadius: 0
            )
        }
        if let mediaView = self.mediaView {
            self.addTopLeftTopRightCornerRadius(to: mediaView, cornerRadius: 10)
        }
        if let button = self.buttonCTA {
            self.addCornerRadiusDropShadow(
                to: button,
                cornerRadius: 6,
                shadowOpacity: 0,
                shadowRadius: 0
            )
        }
    }
    
    func addCornerRadiusDropShadow(
        to viewLayer: UIView,
        cornerRadius: CGFloat,
        shadowOffset: CGSize = CGSize(width: 0, height: 2),
        shadowOpacity: Float,
        shadowRadius: CGFloat
    ) {
        if cornerRadius > 0 {
            if viewLayer is UILabel {
                viewLayer.layer.masksToBounds = true
            } else {
                viewLayer.layer.masksToBounds = false
            }
            viewLayer.layer.cornerRadius = cornerRadius
        }
        viewLayer.layer.shadowColor = UIColor.black.cgColor
        viewLayer.layer.shadowOffset = shadowOffset
        viewLayer.layer.shadowOpacity = shadowOpacity
        viewLayer.layer.shadowRadius = shadowRadius
    }
    
    func addTopLeftTopRightCornerRadius(
        to viewLayer: UIView,
        cornerRadius: CGFloat
    ) {
        if cornerRadius > 0 {
            viewLayer.clipsToBounds = true
            viewLayer.layer.cornerRadius = cornerRadius
            viewLayer.layer.maskedCorners = [
                .layerMaxXMinYCorner, .layerMinXMinYCorner,
            ]
        }
    }
}


// MARK: --- Others Ex++
@discardableResult
func with<T>(_ object: T, _ configure: (T) -> Void) -> T {
    configure(object)
    return object
}


// MARK: -- UIFont Ex++
extension UIFont {

    static func medium(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func normal(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    static func semiBold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }
}


// MARK: -- UIColor Ex++
extension UIColor {

    convenience init?(hex: String) {
        var hexString = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        var rgbValue: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgbValue) else {
            return nil
        }

        switch hexString.count {
        case 3: // RGB (12-bit)
            let r = CGFloat((rgbValue & 0xF00) >> 8) / 15.0
            let g = CGFloat((rgbValue & 0x0F0) >> 4) / 15.0
            let b = CGFloat(rgbValue & 0x00F) / 15.0
            self.init(red: r, green: g, blue: b, alpha: 1)

        case 6: // RGB (24-bit)
            let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(rgbValue & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: 1)

        case 8: // RGBA (32-bit)
            let r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            let g = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            let b = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(rgbValue & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: a)

        default:
            return nil
        }
    }
}
