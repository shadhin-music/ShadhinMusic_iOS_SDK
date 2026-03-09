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

class HeadlineFirstCard: UIView, NativeLayout {
    
    // MARK: -- Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nativeView: UIView!
    @IBOutlet weak var mediaView: UIView?
    @IBOutlet weak var adBadgeLabel: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var buttonCTA: UIButton?
    
    // MARK: -- Properties
    let actionButton = with(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    var subTitleLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        do {
            try setUpNib()
            initializer()
            addDropShadows()
        } catch let error {
            log("\(error)", .error)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        do {
            try setUpNib()
            initializer()
            addDropShadows()
        } catch let error {
            log("\(error)", .error)
        }
    }

    func initializer() {
        commonInit()
        buttonCTA?.contentHorizontalAlignment = .left
        buttonCTA?.setTitleColor(UIColor(hex: "#007AD0"), for: .normal)
    }

    var layoutHeight: CGFloat {
        imageHeight + 112
    }
}

// MARK: -- VmaxNativeLayout Delegate
extension HeadlineFirstCard: VmaxNativeLayout {

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
        self.buttonCTA?.setTitle(text, for: .normal)
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
