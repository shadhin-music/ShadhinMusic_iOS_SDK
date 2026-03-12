//
//  Colors++.swift
//  Shadhin
//
//  Created by Admin on 20/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit


extension UIColor{
    static let appTintColor = UIColor(named: "tintColor") ?? UIColor(red: 0, green: 176, blue: 255)
    static let mostPopularBg = UIColor(named: "mostPopularBg") ?? UIColor(white: 0.95, alpha: 1)
    static let primaryBlack = UIColor(named: "primaryBlack") ?? UIColor.label
    static let generateBtnBg = UIColor(named: "generateBtnBg") ?? UIColor.systemBackground
    static let textColor = UIColor(named: "textColor",in: Bundle.ShadhinMusicSdk,compatibleWith: nil) ?? .black
    static let textColorSecoundery = UIColor(named : "textColorSecondury",in:Bundle.ShadhinMusicSdk,compatibleWith: nil) ?? .darkGray
    static let appTint = UIColor(named: "tintColor", in: Bundle.ShadhinMusicSdk, compatibleWith: nil) ?? UIColor(red: 0.00, green: 0.69, blue: 1.00, alpha: 1.00)
    
    static func customBGColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                // the color can be from your own color config struct as well.
                return trait.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
            }
        }
        else { return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1) }
    }
    
    static func customLabelColor(color: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                // the color can be from your own color config struct as well.
                return trait.userInterfaceStyle == .dark ? #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1) : color
            }
        }
        else { return color }
    }
    
    static func primaryTextColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        else { return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) }
    }
    
    static func primaryLableColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor.label
        }
        else { return  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) }
    }
    
    static func secondaryTextColor() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ? #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1) : #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1)
            }
        }
        else { return #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1) }
    }
    
    static func secondaryLabelColor() -> UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        }
        else { return #colorLiteral(red: 0.2588235294, green: 0.2588235294, blue: 0.2588235294, alpha: 1) }
    }
    
    static func ascentColorOne() -> UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                return trait.userInterfaceStyle == .dark ? #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1)
            }
        }
        else { return #colorLiteral(red: 0, green: 0.6901960784, blue: 1, alpha: 1) }
    }
    
    static func customIconColor(color: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor.init { (trait) -> UIColor in
                // the color can be from your own color config struct as well.
                return trait.userInterfaceStyle == .dark ? #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1) : color
            }
        }
        else { return color }
    }
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }

    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }
}
