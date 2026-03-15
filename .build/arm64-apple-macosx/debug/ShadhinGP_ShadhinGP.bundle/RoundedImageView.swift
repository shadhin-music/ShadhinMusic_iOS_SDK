//
//  RoundedImageView.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/14/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
@IBDesignable
class RoundedImageView: UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
