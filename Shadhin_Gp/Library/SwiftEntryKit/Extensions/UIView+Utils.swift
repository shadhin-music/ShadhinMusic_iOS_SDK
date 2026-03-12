//
//  UILabel+Message.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 04/14/2018.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit

extension UILabel {
    var style: EKProperty.LabelStyle {
        set {
            font = newValue.font
            textColor = newValue.color(for: traitCollection)
            textAlignment = newValue.alignment
            numberOfLines = newValue.numberOfLines
        }
        get {
            return EKProperty.LabelStyle(font: font,
                                         color: EKColor(textColor),
                                         alignment: textAlignment,
                                         numberOfLines: numberOfLines)
        }
    }
    
    var content: EKProperty.LabelContent {
        set {
            text = newValue.text
            accessibilityIdentifier = newValue.accessibilityIdentifier
            style = newValue.style
        }
        get {
            return EKProperty.LabelContent(text: text ?? "", style: style)
        }
    }
}

extension UIButton {
    var buttonContent: EKProperty.ButtonContent {
        set {
            setTitle(newValue.label.text, for: .normal)
            setTitleColor(newValue.label.style.color(for: traitCollection), for: .normal)
            titleLabel?.font = newValue.label.style.font
            accessibilityIdentifier = newValue.accessibilityIdentifier
            backgroundColor = newValue.backgroundColor.color(
                for: traitCollection,
                mode: newValue.displayMode
            )
        }
        get {
            fatalError("buttonContent doesn't have a getter")
        }
    }
}

extension UIImageView {
    var imageContent: EKProperty.ImageContent {
        set {
            stopAnimating()
            if newValue.images.count == 1 {
                image = newValue.images.first
            } else {
                animationImages = newValue.images.map {
                    $0.withRenderingMode(.alwaysTemplate)
                }
                animationDuration = newValue.imageSequenceAnimationDuration
            }
            
            contentMode = newValue.contentMode
            tintColor = newValue.tint?.color(for: traitCollection,
                                             mode: newValue.displayMode)
            accessibilityIdentifier = newValue.accessibilityIdentifier
            
            if let size = newValue.size {
                set(.width, of: size.width)
                set(.height, of: size.height)
            } else {
                forceContentWrap()
            }
            
            if newValue.makesRound {
                clipsToBounds = true
                if let size = newValue.size {
                    layer.cornerRadius = min(size.width, size.height) * 0.5
                } else {
                    layoutIfNeeded()
                    layer.cornerRadius = min(bounds.width, bounds.height) * 0.5
                }
            }
            
            startAnimating()
            
            if case .animate(duration: let duration,
                             options: let options,
                             transform: let transform) = newValue.animation {
                let options: UIView.AnimationOptions = [.repeat, .autoreverse, options]
                // A hack that forces the animation to run on the main thread,
                // on one of the next run loops
                DispatchQueue.main.async {
                    UIView.animate(withDuration: duration,
                                   delay: 0,
                                   options: options,
                                   animations: {
                        self.transform = transform
                    }, completion: nil)
                }
            }
        }
        get {
            fatalError("imageContent doesn't have a getter")
        }
    }
}

extension UITextField {
    
    var placeholderr: EKProperty.LabelContent {
        set {
            attributedPlaceholder = NSAttributedString(
                string: newValue.text,
                attributes: [
                    .font: newValue.style.font,
                    .foregroundColor: newValue.style.color(for: traitCollection)
                ]
            )
        }
        get {
            fatalError("placeholder doesn't have a getter")
        }
    }
    
    var textFieldContent: EKProperty.TextFieldContent {
        set {
            placeholderr = newValue.placeholder
            keyboardType = newValue.keyboardType
            textColor = newValue.textStyle.color(for: traitCollection)
            font = newValue.textStyle.font
            textAlignment = newValue.textStyle.alignment
            isSecureTextEntry = newValue.isSecure
            text = newValue.textContent
            tintColor = newValue.tintColor(for: traitCollection)
            accessibilityIdentifier = newValue.accessibilityIdentifier
        }
        get {
            fatalError("textFieldContent doesn't have a getter")
        }
    }
}

extension UIView {
    func applyGradient(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIView {
    func controller() -> UIViewController? {
        if let nextViewControllerResponder = next as? UIViewController {
            return nextViewControllerResponder
        }
        else if let nextViewResponder = next as? UIView {
            return nextViewResponder.controller()
        }
        else  {
            return nil
        }
    }
    func navigationController() -> UINavigationController? {
        if let controller = controller() {
            return controller.navigationController
        }
        else {
            return nil
        }
    }
}

class Toast {
    static func show(message: String, inView view: UIView, duration: Double = 3.0) {
        let toastContainer = UIView(frame: CGRect()) //showToastLblColor
        toastContainer.backgroundColor = UIColor(named: "showToastLblColor")
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 10
        toastContainer.clipsToBounds = true
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor(named: "toastBgColor")
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.clipsToBounds = true
        
        toastContainer.addSubview(toastLabel)
        view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 10),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -10),
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 10),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -10),
            
            toastContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toastContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toastContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}
