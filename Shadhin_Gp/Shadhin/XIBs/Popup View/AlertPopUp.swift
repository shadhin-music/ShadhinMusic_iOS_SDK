//
//  AlertPopUp.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/11/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit

class AlertPopUp: UIViewController {
    
    static func show(_ vc: UIViewController? = nil,
                     _ id: Int = 0,
                     image: UIImage = #imageLiteral(resourceName: "fb_icon"),
                     tileString: String? = nil,
                     msgString: String,
                     positiveString : String? = nil,
                     negativeString : String? = nil,
                     buttonDelegate : ButtonDelegate? = nil){
        
        let myAlert = AlertPopUp(nibName: "AlertPopUp", bundle: nil)
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
        
        if vc == nil,
           var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(myAlert, animated: true, completion: nil)
        }else{
            vc?.present(myAlert, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var positiveBtn: UIButton!
    @IBOutlet weak var negativeBtn: UIButton!
    @IBOutlet var background: UIView!
    var instanceID: Int = 0
    
    enum State {
        case positive
        case negative
    }
    
    var image : UIImage = #imageLiteral(resourceName: "fb_icon")
    var tileString : String?
    var msgString : String = "Message"
    var positiveString : String?
    var negetiveString : String = "Close"
    var buttonDelegate : ButtonDelegate?
    
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
        self.dismiss(animated: true){
            self.buttonDelegate?.buttonTaped(.positive, self.instanceID)
        }
    }
    
    @IBAction func negetiveTap(_ sender: Any) {
        
        if msgString.lowercased().contains("insufficient balance") || msgString.lowercased().contains("subscription already exists"){
            openDeepLink(with: "https://mybl.digital/recharge")
        }
        
        self.dismiss(animated: true){
            self.buttonDelegate?.buttonTaped(.negative, self.instanceID)
        }
    }
    
    private func openDeepLink(with url: String) {
            guard let deepLinkURL = URL(string: url) else {
                return
            }
        
            if UIApplication.shared.canOpenURL(deepLinkURL) {
                UIApplication.shared.open(deepLinkURL, options: [:], completionHandler: nil)
            } else {
                print("Cannot open deep link")
            }
        }
    
}

protocol ButtonDelegate {
    func buttonTaped(_ state: AlertPopUp.State, _ instanceID: Int)
}


