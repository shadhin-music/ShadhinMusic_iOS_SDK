//
//  MyRankCell.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit

class MyRankCell: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat {
        return 64 + 20
    }
    
    @IBOutlet weak var iconIV: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var myRankLabel : UILabel!
    
    @IBOutlet weak var bonusStackView: UIStackView!
    @IBOutlet weak var dailyBonusLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!
    
    private var gradient  = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 8
        
       gradient.colors = [

            UIColor(red: 0, green: 0.69, blue: 1, alpha: 1).cgColor,

            UIColor(red: 0.353, green: 0.784, blue: 0.98, alpha: 1).cgColor

        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradient.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 26.27, tx: 0, ty: -12.71))
        layer.insertSublayer(gradient, at: 0)
        
        //myRankLabel.adjustsFontSizeToFitWidth = true
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        iconIV.cornerRadius = min(iconIV.width, iconIV.height)/2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.bounds = self.bounds.insetBy(dx: -0.5*self.bounds.size.width, dy: -0.5*self.bounds.size.height)
        gradient.position = self.center
        iconIV.cornerRadius = min(iconIV.width, iconIV.height)/2
    }
    
    func bind(with rank : UserStreaming,isDaily : Bool = true){
        self.myRankLabel.text = rank.rank.toString
        self.nameLabel.text = rank.fullname
        self.numberLabel.text = rank.msisdn
        self.hourLabel.text = getUserStrimingTime(sec: rank.currentStreaming)
        self.iconIV.kf.setImage(with: URL(string: rank.imageUrl), placeholder: AppImage.userAvatar.uiImage)
    }
}
extension Int{
    ///int to string convert
    var toString : String{
        return String(self)
    }
}
