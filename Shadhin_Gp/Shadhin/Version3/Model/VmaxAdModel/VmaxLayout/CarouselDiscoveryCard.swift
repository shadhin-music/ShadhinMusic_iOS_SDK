//
//  HeadlineFirstCard.swift
//  Shadhin_GP
//
//  Created by MD Murad Hossain on 15/02/26.
//  Copyright © 2025 GrammenPhone Limited. All rights reserved.
//

import UIKit
import Vmax
import VmaxNativeHelper

class CarouselDiscoveryCard: UIView, NativeLayout {
    
    // MARK: -- Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nativeView: UIView!
    @IBOutlet weak var mediaView: UIView?
    @IBOutlet weak var adBadgeLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var buttonCTA: UIButton?
    
    // MARK: -- Properties
    var subTitleLabel: UILabel?
    let actionButton = with(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        do {
            try setUpNib()
            commonInit()
        } catch let error {
            log("\(error)", .error)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        do {
            try setUpNib()
            commonInit()
        } catch let error {
            log("\(error)", .error)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 10
        layer.masksToBounds = false

        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 12
        ).cgPath
    }

    var layoutHeight: CGFloat {
        imageHeight + 82
    }
    
}

// MARK: -- VmaxNativeLayout Delegate

extension CarouselDiscoveryCard: VmaxNativeLayout {

    func set(delegate: VmaxLayoutDelegate) {
    }

    func getParentContainer() -> UIView? {
        return self.contentView
    }

    func setUpInitialState() {
        titleLabel?.font = .medium(14)
    }

    func getTitle() -> UILabel? {
        return self.titleLabel
    }

    func setDescription(text: String?) {
        self.subTitleLabel?.text = text
    }

    func getCTA() -> UIButton? {
        return self.actionButton
    }

    func setCTA(text: String?) {
        self.buttonCTA?.setTitle(String(text?.prefix(16) ?? ""), for: .normal)
    }

    func getMediaView() -> UIView? {
        return mediaView
    }

    func getAdLayoutSize() -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: layoutHeight)
    }

    func setMainImageContentMode() -> UIView.ContentMode {
        return UIView.ContentMode.scaleAspectFill
    }
}
