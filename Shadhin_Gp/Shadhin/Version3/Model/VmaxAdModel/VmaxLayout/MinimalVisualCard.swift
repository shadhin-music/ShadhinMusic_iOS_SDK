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

class MinimalVisualCard: UIView, NativeLayout {
    
    // MARK: -- Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nativeView: UIView!
    @IBOutlet weak var mediaView: UIView?
    @IBOutlet weak var adBadgeLabel: UILabel?
    
    // MARK: -- Properties
    var titleLabel: UILabel?
    var subTitleLabel: UILabel?
    var buttonCTA: UIButton?
    let actionButton = with(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        do {
            try setUpNib()
            commonInit()
            addDropShadows()
       
           
        } catch let error {
            log("\(error)", .error)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        do {
            try setUpNib()
            commonInit()
            addDropShadows()
       
        } catch let error {
            log("\(error)", .error)
        }
    }

    var layoutHeight: CGFloat {
        imageHeight + 32
    }
}


// MARK: -- VmaxNativeLayout Delegate
extension MinimalVisualCard: VmaxNativeLayout {
    func set(delegate: VmaxLayoutDelegate) {
    }

    func getParentContainer() -> UIView? {
        return self.contentView
    }

    func setUpInitialState() {

    }

    func getTitle() -> UILabel? {
        return nil
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
