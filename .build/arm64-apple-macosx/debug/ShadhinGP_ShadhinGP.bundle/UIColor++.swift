//
//  UIColor++.swift
//  Shadhin
//
//  Created by Joy on 6/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit
import CoreImage
import Foundation

extension UIColor{
    static let tintColor = UIColor(red: 0.00, green: 0.69, blue: 1.00, alpha: 1.00)
    static let appWhite = UIColor(white: 1, alpha: 1)
    static let appBlack = UIColor(white: 0, alpha: 1.0)
    static let robiTint = UIColor(red: 0.886, green: 0.024, blue: 0.071, alpha: 1)
}


extension UIImage {
    convenience init?(color: UIColor, size: CGSize, cornerRadius: CGFloat = 0) {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.setFillColor(color.cgColor)
        path.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

func gradientImage(colors: [CGColor], size: CGSize, cornerRadius: CGFloat = 0) -> UIImage? {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = colors
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    gradientLayer.frame = CGRect(origin: .zero, size: size)
    gradientLayer.cornerRadius = cornerRadius

    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    gradientLayer.render(in: context)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image
}

extension UIColor {
    static func hash(string hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        guard cString.count == 6 else {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
