//
//  EmptyListView.swift
//  Shadhin
//
//  Created by Joy on 19/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

struct EmptyViewModel{
    let topIcon : AppImage
    let title : String
    let subtitle : String
}

class EmptyListView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
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
        Bundle.ShadhinMusicSdk.loadNibNamed("EmptyListView", owner: self, options: [:])
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        addSubview(self.contentView)
    }
    
    func setData(with obj : EmptyViewModel) {
        topIcon.image = obj.topIcon.uiImage
        titleLabel.text = obj.title
        subtitleLabel.text = obj.subtitle
    }
}
