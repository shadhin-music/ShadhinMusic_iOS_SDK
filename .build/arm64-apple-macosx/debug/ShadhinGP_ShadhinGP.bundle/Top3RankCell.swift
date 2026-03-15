//
//  Top3RankCell.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit

class Top3RankCell: UICollectionViewCell {

    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    static var height : CGFloat{
        return  200 + 16
    }
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    
    @IBOutlet weak var icon1IV: UIImageView!
    @IBOutlet weak var icon3IV: UIImageView!
    @IBOutlet weak var icon2IV: UIImageView!
    
    @IBOutlet weak var hour1Label: UILabel!
    @IBOutlet weak var hour2Label: UILabel!
    @IBOutlet weak var hour3Label: UILabel!
    
    @IBOutlet weak var number1Label: UILabel!
    @IBOutlet weak var number2Label: UILabel!
    @IBOutlet weak var number3Label: UILabel!
    
    @IBOutlet weak var name1Label: UILabel!
    @IBOutlet weak var name2Label: UILabel!
    @IBOutlet weak var name3Label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view1.layer.cornerRadius = 12
        view1.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        view1.layer.shadowOpacity = 1
        view1.layer.shadowRadius = 2
        view1.layer.shadowOffset = CGSize(width: 1, height: 2)
        
        view2.layer.cornerRadius = 10
        view2.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        view2.layer.shadowOpacity = 1
        view2.layer.shadowRadius = 2
        view2.layer.shadowOffset = CGSize(width: 1, height: 2)
        
        
        view3.layer.cornerRadius = 10
        view3.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        view3.layer.shadowOpacity = 1
        view3.layer.shadowRadius = 2
        view3.layer.shadowOffset = CGSize(width: 1, height: 2)
        
        number1Label.adjustsFontSizeToFitWidth = true
        number2Label.adjustsFontSizeToFitWidth = true
        number3Label.adjustsFontSizeToFitWidth = true
        
        name1Label.adjustsFontSizeToFitWidth = true
        name2Label.adjustsFontSizeToFitWidth = true
        name3Label.adjustsFontSizeToFitWidth = true
        
        icon1IV.layer.borderWidth = 2
        icon2IV.layer.borderWidth = 2
        icon3IV.layer.borderWidth = 2
        
        icon1IV.layer.borderColor = UIColor(red: 0.961, green: 0.969, blue: 0.988, alpha: 1).cgColor
        icon2IV.layer.borderColor = UIColor(red: 0.961, green: 0.969, blue: 0.988, alpha: 1).cgColor
        icon3IV.layer.borderColor = UIColor(red: 0.961, green: 0.969, blue: 0.988, alpha: 1).cgColor
        
    }
    func bind(with ranks: [UserStreaming]) {
        if ranks.indices.contains(0) {
            name1Label.text = ranks[0].fullname
            number1Label.text = ranks[0].msisdn
            hour1Label.text = getStrimingTime(sec: ranks[0].totalStreaming)
            icon1IV.kf.setImage(with: URL(string: ranks[0].imageUrl), placeholder: AppImage.userAvatar.uiImage)
        } else {
            name1Label.text = nil
            number1Label.text = nil
            hour1Label.text = nil
            icon1IV.image = AppImage.userAvatar.uiImage
        }
        
        if ranks.indices.contains(1) {
            name2Label.text = ranks[1].fullname
            number2Label.text = ranks[1].msisdn
            hour2Label.text = getStrimingTime(sec: ranks[1].totalStreaming)
            icon2IV.kf.setImage(with: URL(string: ranks[1].imageUrl), placeholder: AppImage.userAvatar.uiImage)
        } else {
            name2Label.text = nil
            number2Label.text = nil
            hour2Label.text = nil
            icon2IV.image = AppImage.userAvatar.uiImage
        }
        
        if ranks.indices.contains(2) {
            name3Label.text = ranks[2].fullname
            number3Label.text = ranks[2].msisdn
            hour3Label.text = getStrimingTime(sec: ranks[2].totalStreaming)
            icon3IV.kf.setImage(with: URL(string: ranks[2].imageUrl), placeholder: AppImage.userAvatar.uiImage)
        } else {
            name3Label.text = nil
            number3Label.text = nil
            hour3Label.text = nil
            icon3IV.image = AppImage.userAvatar.uiImage
        }
    }
}

func getStrimingTime(sec : Int)-> String{
    
    if sec >= (60 * 60){
        return String(format: "%.1f hrs", Float(Float(sec) / 3600.0))
    }else if sec >= 60 {
        return String(format: "%.1f min",Float(Float(sec) / 60.0))
    }else{
        return "\(sec) sec"
    }
}
func getUserStrimingTime(sec : Int)-> String{
    
    if sec >= (60 * 60){
        let h = sec / (60 * 60)
        let min = (sec % (60 * 60)) / 60
        
        return "\(h)hrs \(min)min"
    }else if sec >= 60 {
        return String(format: "%.1f min",Float(Float(sec) / 60.0))
    }else{
        return "\(sec) sec"
    }
}
