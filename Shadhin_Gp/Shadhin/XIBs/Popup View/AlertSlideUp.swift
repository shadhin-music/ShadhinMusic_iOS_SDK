//
//  AlertSlideUp.swift
//  Shadhin
//
//  Created by Gakk Alpha on 6/1/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit


class AlertSlideUp: UIViewController {
    
    static func show(_ id: Int = 0,
                     image: UIImage = #imageLiteral(resourceName: "fb_icon"),
                     tileString: String? = nil,
                     msgString: String,
                     positiveString : String? = nil,
                     negativeString : String? = nil,
                     buttonDelegate : ButtonDelegate? = nil){
        
        let myAlert = AlertSlideUp(nibName: "AlertSlideUp", bundle:Bundle.ShadhinMusicSdk)
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        myAlert.image = image
        if (tileString != nil){
            myAlert.tileString = tileString
        }
        myAlert.msgString = msgString
        if (positiveString != nil){
            myAlert.positiveString = positiveString
        }
        if (negativeString != nil){
            myAlert.negetiveString = negativeString!
        }
        myAlert.buttonDelegate = buttonDelegate
        myAlert.instanceID = id

        
        var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 8)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        SwiftEntryKit.display(entry: myAlert, using: attribute)
    }
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var positiveBtn: UIButton!
    @IBOutlet weak var negativeBtn: UIButton!
    
    enum State {
        case positive
        case negative
    }
    
    var image = UIImage(resource:ImageResource(name: "fb_icon", bundle: Bundle.ShadhinMusicSdk))// #imageLiteral(resourceName: "fb_icon")
    var tileString : String?
    var msgString : String = "Message"
    var positiveString : String?
    var negetiveString : String = "Close"
    var buttonDelegate : ButtonDelegate?
    var instanceID: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        img.image = image
        if let titleStr = tileString{
            titleLabel.text = titleStr
        }else{
            titleLabel.isHidden = true
        }
        msgLabel.text = msgString
        if let positiveStr = positiveString{
            positiveBtn.setTitle(positiveStr, for: .normal)
        }else{
            positiveBtn.isHidden = true
        }
        negativeBtn.setTitle(negetiveString, for: .normal)
    }
    
    @IBAction func positiveTap(_ sender: Any) {
        SwiftEntryKit.dismiss {
            self.buttonDelegate?.buttonTaped(.positive, self.instanceID)
        }
    }
    
    @IBAction func negetiveTap(_ sender: Any) {
        SwiftEntryKit.dismiss {
            self.buttonDelegate?.buttonTaped(.negative, self.instanceID)
        }
    }
    
}



