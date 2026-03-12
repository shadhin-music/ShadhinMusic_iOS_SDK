//
//  PopularArtistItemView.swift
//  Shadhin
//
//  Created by Joy on 24/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

@IBDesignable
class PopularArtistItemView: UIView {
    
    @IBInspectable
    var image : UIImage?{
        didSet{
            self.imageView.image =  image
        }
    }
    
    private lazy var imageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        imageView.cornerRadius = self.height  /  2
        self.cornerRadius = self.height / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //viewSetup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        viewSetup()
    }
    private func viewSetup(){
        imageView.translatesAutoresizingMaskIntoConstraints  = false
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.clipsToBounds = true
        backgroundColor = .clear
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1).cgColor
        
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor

        layer.shadowOpacity = 1

        layer.shadowRadius = 8

        layer.shadowOffset = CGSize(width: 2, height: 4)
    }
    func bind(with obj : CommonContentProtocol){
        imageView.kf.setImage(with: URL(string: obj.image?.image300 ?? ""))
    }
}
