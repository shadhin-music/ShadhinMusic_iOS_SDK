//
//  OTPSentForRefferalVC.swift
//  Shadhin
//
//  Created by MacBook Pro on 29/1/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class OTPSentForRefferalVC: UIViewController,NIBVCProtocol {
    var selectedItem: Item!
    var originalPlan: Plan!
    var planDetails: PlanDetailResponseData?
    @IBOutlet weak var otplengthLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var tf1: UITextField!
    @IBOutlet weak var tf2: UITextField!
    @IBOutlet weak var tf3: UITextField!
    @IBOutlet weak var tf4: UITextField!
    @IBOutlet weak var tf5: UITextField!
    @IBOutlet weak var tf6: UITextField!
    @IBOutlet weak var viewTitle: UILabel!
    
    @IBOutlet weak var tfView1: UIView!
    @IBOutlet weak var tfView2: UIView!
    @IBOutlet weak var tfView3: UIView!
    @IBOutlet weak var tfView4: UIView!
    @IBOutlet weak var tfView5: UIView!
    @IBOutlet weak var tfView6: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var otpLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var otpTrailingConstraint: NSLayoutConstraint!
    var isForNewSubscription = false
    var otpLength = 6
    private var timer : Timer?
    private var count : Int = 59
    private var otp : String = ""
    var phoneNumber : String = ""
    var refferalCode : String = ""
    var password : String = ""
    var isSocialLogin : Bool = false
    var otpRequestUrl: String?
    var verifyOTPUrl: String?
    var serviceId: String?
    var transactionId: String?
    private var zeros = [Character]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  IQKeyboardManager.shared.enable = true
        otpRequestUrl = planDetails?.checkOutUrl
        verifyOTPUrl = planDetails?.otpCheckUrl
        serviceId = planDetails?.serviceId
        otpLength = planDetails?.otpLength ?? 6
        phoneNumber = ShadhinCore.instance.defaults.userMsisdn
        isForNewSubscription = true
        self.phoneNumberLabel.text = phoneNumber
        otplengthLabel.text = "Enter the \(otpLength) digit OTP we just sent to"
        viewTitle.text = isForNewSubscription ? "Verify OTP" : "Verify Referral Code"
        otpTextField.delegate = self
        hideOtpViewsBasedOnOtpLength()
        zeros = .init(repeating: "0", count: otpLength)
        let space = otpTextSpace(str: String(zeros))
        otpTextField.defaultTextAttributes.updateValue( space,
             forKey: NSAttributedString.Key.kern)
        let attributedString = NSMutableAttributedString(string: String(zeros))
        attributedString.addAttribute(.kern, value: space, range: NSRange(location: 0, length: (otpLength-1)))
        otpTextField.attributedPlaceholder = attributedString
        
        submitButton.setBackgroundColor(color: .lightGray, forState: .disabled)
        submitButton.setBackgroundColor(color: .systemBlue, forState: .normal)
        submitButton.isEnabled = false
        resendButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isSocialLogin{
            ShadhinCore.instance.addNotifier(notifier: self)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isForNewSubscription {
            requestForOtp()
        } else {
            ShadhinCore.instance.api.sendOtpLocal(self, phoneNumber) { isSent in
                if isSent{
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerStart), userInfo: nil, repeats: true)
                }else{
                    self.resendButton.isEnabled = true
                }
                
            }
        }
    }
    
    private func hideOtpViewsBasedOnOtpLength(){
        switch otpLength {
        case 4:
            tfView5.isHidden = true
            tfView6.isHidden = true
        case 5:
            tfView6.isHidden = true
        default:
            break
        }
    }
    
    private func otpCheck(url: String, parameters: [String: String], isVerify: Bool) {
        // show loading screen
        let myAlert = SubscriptionProcessVC.instantiateNib()
        myAlert.goBackToCurrentPlan = gobackTocurrentPlan
        
        if isVerify {
            showSubscriptionProcess(myAlert: myAlert)
        }
        
        ShadhinCore.instance.api.requestOtp(url: url, parameter: parameters ) {[weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let success):
                
                if success.statusCode == 200 {
                    if isVerify {
                        myAlert.showSucces()
                    } else {
                        self.transactionId = success.data?.transactionId ?? ""
                        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerStart), userInfo: nil, repeats: true)
                    }
                } else {
                    if isVerify {
                        myAlert.showFailed(message: success.message, okAction: subscriptionFailedOkButtonPressed)
                    } else {
                        self.view.makeToast(success.message)
                        self.resendButton.isEnabled = true
                    }
                }
                
            case .failure(let failure):
                if isVerify {
                    print(failure)
                    myAlert.showFailed(message: failure.localizedDescription, okAction: subscriptionFailedOkButtonPressed)
                } else {
                    self.view.makeToast(failure.localizedDescription)
                    self.resendButton.isEnabled = true
                }
            }
        }
    }
    
    func gobackTocurrentPlan() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func subscriptionFailedOkButtonPressed(){
        SwiftEntryKit.dismiss()
        otpTextField.text = ""
    }
    
    func showSubscriptionProcess(myAlert: SubscriptionProcessVC){
        var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 8)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        attribute.positionConstraints.size = .init(width: .fill, height: .constant(value:328))
        SwiftEntryKit.display(entry: myAlert, using: attribute)
    }
    
    private func requestForOtp() {
        if let otpRequestUrl = otpRequestUrl, let serviceId = serviceId{
            let msiddn = ShadhinCore.instance.defaults.userMsisdn
            otpCheck(url: otpRequestUrl, parameters: ["msisdn": msiddn , "serviceId":serviceId], isVerify: false)
        } else {
            view.makeToast("OTP Url is not provided")
        }
    }
    
    private func verifyOtp() {
        if let verifyOTPUrl = verifyOTPUrl, let serviceId = serviceId, let otp = otpTextField.text, let transectionId = self.transactionId{
            let msiddn = ShadhinCore.instance.defaults.userMsisdn
            otpCheck(url: verifyOTPUrl, parameters: ["msisdn": msiddn , "serviceId":serviceId, "otp" : otp, "transactionId" : transectionId, "ConsentNo": otp], isVerify: true)
        } else {
            view.makeToast("OTP Url is not provided")
        }
    }
    
    @IBAction func resendButtonClicked(_ sender: UIButton) {
        if isForNewSubscription {
            requestForOtp()
        } else {
            self.view.lock()
            ShadhinCore.instance.api.sendOtpLocal(self, phoneNumber) { isSent in
                self.view.unlock()
                if isSent{
                    self.resendButton.isEnabled = false
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerStart), userInfo: nil, repeats: true)
                }
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        ShadhinCore.instance.removeNotifier(notifier: self)
    }
    
    @objc
    private func timerStart(){
        count -= 1
        timerLabel.text = "\(count) Sec"
        if count == 0{
            resetCount()
            return
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    private func resetCount(){
        count = 59
        timer?.invalidate()
        resendButton.isEnabled = true
    }
    
    @IBAction func onSubmitePressed(_ sender: Any) {
        otpTextField.resignFirstResponder()
        if isForNewSubscription {
            verifyOtp()
        } 
        /*else {
            self.view.lock()
            #if DEBUG
            self.view.unlock()
            self.view.lock()
            if self.isSocialLogin{
                AuthHelper.shared.updateMsisdn(vc: self, msisdn: self.phoneNumber, referral: self.refferalCode)
            }else{
                ShadhinCore.instance.api.registation(
                    userLoginId: self.phoneNumber,
                    password: self.password,
                    registerWith: .mobile,
                    otpCode: self.otp,
                    referralCode: self.refferalCode,
                    userName: "",
                    msisdn: self.phoneNumber)
            }
            return
            #endif
            ShadhinCore.instance.api.checkOTPLocal(self, phoneNumber, otp) { isOtp in
                guard let isOtp = isOtp else {return}
                self.view.unlock()
                if isOtp{
                    //singup
                    self.view.lock()
                    if self.isSocialLogin{
                        AuthHelper.shared.updateMsisdn(vc: self, msisdn: self.phoneNumber, referral: self.refferalCode)
                    }else{
                        ShadhinCore.instance.api.registation(
                            userLoginId: self.phoneNumber,
                            password: self.password,
                            registerWith: .mobile,
                            otpCode: self.otp,
                            referralCode: self.refferalCode,
                            userName: "",
                            msisdn:  self.phoneNumber)
                    }
                    
                }
            }
        }*/
    }
    
}

extension OTPSentForRefferalVC : UITextFieldDelegate{
    
    func otpTextSpace(str : String = "000000")-> CGFloat{
        let font: UIFont = .systemFont(ofSize: 24)
        //otpTextField.backgroundColor = .red
        let screenWidth = SCREEN_WIDTH
        let totalCharecterWidth = str.size(OfFont: font).width
        let perCharecterWidth = CGFloat(totalCharecterWidth / CGFloat(otpLength))
        let dashWidth = ((screenWidth - 32 - CGFloat((otpLength - 1) * 16)) / CGFloat(otpLength))
        
        let leadingSpace = (dashWidth - perCharecterWidth)/2
        
        let spaceBetweenTwoCharecter = (dashWidth + 16 - perCharecterWidth)*1.09
        
        otpTextField.setPadding(left: leadingSpace)
        return spaceBetweenTwoCharecter
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let currentCharacterCount = textField.text?.count ?? 0
        submitButton.isEnabled = currentCharacterCount == otpLength
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        return newLength <= (otpLength)
    }
    
    
}

extension OTPSentForRefferalVC: ShadhinCoreNotifications {
    
//    func registationResponseV5(response: NewAuthResponseModel?) {
//        self.view.unlock()
//        if let data = response?.userData {
//            AuthHelper.shared.userLoginData = data
//            self.navigationController?.pushViewController(FavoriteGenresOnBoardingViewController(), animated: true)
//            
//        } else {
//            if let message =  response?.error{
//                self.view.endEditing(true)
//                self.view.makeToast(message.message)
//            }
//        }
//    }
}


