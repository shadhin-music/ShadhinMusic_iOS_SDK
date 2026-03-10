//
//  TopItemMusicMoreV4.swift
//  Shadhin
//
//  Created by Joy on 15/3/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import Foundation
import UIKit

class TopItemMusicMoreV4 : UIView{
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var iconIV: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    
    var isSelected : Bool = false{
        didSet{
            if isSelected{
                self.titleLabel?.text = selectedText == nil ? self.titleLabel?.text : selectedText
                self.iconIV?.image = selectedIcon == nil ? self.iconIV?.image : selectedIcon
                self.titleLabel?.textColor = selectedTextColor
            }else{
                self.titleLabel?.text = normalText == nil ? self.titleLabel?.text  : normalText
                self.iconIV?.image = normalIcon == nil ? self.iconIV?.image : normalIcon
                self.titleLabel?.textColor = normalTextColor
            }
        }
    }
    private var selectedIcon : UIImage?
    private var normalIcon : UIImage?
    private var selectedText : String?
    private var normalText : String?
    private var normalTextColor : UIColor = .appWhite
    private var selectedTextColor : UIColor = .appWhite
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func commonInit(){
        Bundle.main.loadNibNamed("TopItemMusicMoreV4", owner: self,options: [:])
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        addSubview(contentView)
    
    }
    
    func setTitle(title : String?,state : UIControl.State){
        if state == .normal{
            self.normalText = title
            self.titleLabel?.text = title
        }else if state == .selected{
            self.selectedText = title
        }
    }
    func setIcon(icon : UIImage?,state : UIControl.State){
        if state == .normal{
            self.normalIcon = icon
            self.iconIV?.image = icon
        }else if state == .selected{
            self.selectedIcon = icon
        }
    }
    
    func setTextColor(color : UIColor, state : UIControl.State){
        if state == .normal{
            self.normalTextColor = color
            self.titleLabel?.textColor = color
        }else if state == .selected{
            self.selectedTextColor = color
        }
    }
    
}
