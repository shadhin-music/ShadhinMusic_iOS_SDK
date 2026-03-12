//
//  CouponVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 11/23/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import UIKit


class CouponVC: UIViewController {
    
    
    
    @IBOutlet weak var titleImg: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var couponTF: UITextField!
    @IBOutlet weak var mainBtn: UIButton!
    @IBOutlet weak var successBg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        couponTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        mainBtn.setClickListener {
            self.handleMainButtonClick()
        }
    }
    
    private func handleMainButtonClick(){
        switch mainBtn.tag{
        case 1:
            //todo success
            SwiftEntryKit.dismiss(){
               // AppDelegate.shared?.checkUserSubscription()
            }
            break
        case 2:
            SwiftEntryKit.dismiss()
            break
        default:
            if couponTF.text?.count ?? 0 < 6{
                return
            }
            self.addCouponToMyAccount()
        }
    }
    
    private func showSuccess(msg : String){
        mainBtn.tag = 1
        successBg.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.couponTF.alpha = 0
            self.successBg.alpha = 1
            self.mainTitle.text = "Congratulation!"
            self.subTitle.text = msg
            self.titleImg.image = #imageLiteral(resourceName: "ic_coupon_s.pdf")
            self.mainBtn.setTitle("Enjoy Shadhin!", for: .normal)
        }, completion:  {
            (value: Bool) in
            self.couponTF.isHidden = true
        })
    }
    
    private func showFailed(msg : String){
        mainBtn.tag = 2
        
        UIView.animate(withDuration: 0.3, animations: {
            self.couponTF.alpha = 0
            self.successBg.alpha = 1
            self.mainTitle.text = "Activation Failed!"
            self.subTitle.text = msg
            self.titleImg.image = #imageLiteral(resourceName: "ic_coupon_e.pdf")
            self.mainBtn.setTitle("Close", for: .normal)
        }, completion:  {
            (value: Bool) in
            self.couponTF.isHidden = true
        })
    }

}

extension CouponVC: UITextFieldDelegate{
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count ?? 0 > 5{
            mainBtn.backgroundColor = UIColor.init(rgb: 0x00B0FF)
        }else{
            mainBtn.backgroundColor = UIColor.init(rgb: 0xBEBEBE)
        }
    }
    
}

extension CouponVC{
    
    func addCouponToMyAccount(){
        activityStartAnimating()
        let couponCode = couponTF.text ?? ""
        ShadhinCore.instance.api.redeemCoupon(
            couponCode) {
                success, msg in
                self.activityStopAnimating()
                if success{
                    self.showSuccess(msg: msg)
                }else{
                    self.showFailed(msg: msg)
                }
            }
    }
}

extension CouponVC{

    func activityStartAnimating() {
        let backgroundView = UIView()
        
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        backgroundView.backgroundColor = .clear
        backgroundView.tag = 475647
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        backgroundView.addSubview(activityIndicator)

        self.view.addSubview(backgroundView)
    }

    func activityStopAnimating() {
        if let background = self.view.viewWithTag(475647){
            background.removeFromSuperview()
        }
        self.view.isUserInteractionEnabled = true
    }
}
