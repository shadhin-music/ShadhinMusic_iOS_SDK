//
//  ConcertTicketsPurchaseVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/4/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

import CoreMedia

class ConcertTicketsPurchaseVC: UIViewController {
    
    static func show(_ vc: ConcertTicketsMainVC) {
        
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        let height = UIScreen.main.bounds.size.height - topPadding - bottomPadding
        let concertTicketsPurchaseVC = ConcertTicketsPurchaseVC()
        concertTicketsPurchaseVC.concertTicketsMainVC = vc
        var attri = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 0)
        if height > 797{
            attri.positionConstraints.size = .init(width: .fill, height: .constant(value: 797))
        }else{
            attri.positionConstraints.size = .init(width: .fill, height: .offset(value: topPadding))
        }
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 0, screenEdgeResistance: topPadding)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attri.positionConstraints.keyboardRelation = keyboardRelation
        attri.entryBackground = .clear
        SwiftEntryKit.display(entry: concertTicketsPurchaseVC, using: attri)
    }
    
    @IBOutlet var ticketTypeHolders: [UIView]!
    @IBOutlet var ticketTypeTitles: [UILabel]!
    @IBOutlet var ticketTypeCosts: [UILabel]!
    @IBOutlet var idTypeHolders: [UIStackView]!
    @IBOutlet var idTypeRadioImgs: [UIImageView]!
    @IBOutlet var idTypeLbls: [UILabel]!
    @IBOutlet weak var ticketTypeDescription: UILabel!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ticketQuantityLbl: UILabel!
    @IBOutlet weak var agreeTermsHolder: UIStackView!
    @IBOutlet weak var agreeTermsCheckImg: UIImageView!
    @IBOutlet weak var privacyLbl: UILabel!
    @IBOutlet weak var termsLbl: UILabel!
    @IBOutlet weak var userNameLbl: UITextField!
    @IBOutlet weak var userMsisdn: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userIdNumber: UITextField!
    @IBOutlet var paymentMethodHolders: [UIStackView]!
    @IBOutlet var paymentMethodImgs: [UIImageView]!
    @IBOutlet var paymentMethodLbls: [UILabel]!
    
    
    var concertTicketsMainVC: ConcertTicketsMainVC!
    var topPadding = CGFloat.zero
    var selectedTicketType = 0
    let selectedTicketTypeStr = ["ALL ACCESS", "VIP", "GENERAL"]
    var selectedIdType = 0
    let selectedIdTypeStr = ["NID", "PHOTOID", "BCERT"]
    var ticketQuantity = 1
    var selectedPlaymentMethod: Int = 0{
        didSet{
            updatePaymentMethod(index: selectedPlaymentMethod)
        }
    }
    private let maxTicketCount = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
        let window = UIApplication.shared.windows.first
        topPadding = window?.safeAreaInsets.top ?? 0
        ticketTypeHolders[0].setClickListener {
            self.ticketTypeSelection(position: 0)
            self.ticketTypeDescription.isHidden = false
        }
        ticketTypeHolders[1].setClickListener {
            self.ticketTypeSelection(position: 1)
            self.ticketTypeDescription.isHidden = true
        }
        ticketTypeHolders[2].setClickListener {
            self.ticketTypeSelection(position: 2)
            self.ticketTypeDescription.isHidden = true
        }
        idTypeHolders[0].setClickListener {
            self.idTypeSelection(position: 0)
        }
        idTypeHolders[1].setClickListener {
            self.idTypeSelection(position: 1)
        }
        idTypeHolders[2].setClickListener {
            self.idTypeSelection(position: 2)
        }
        privacyLbl.setClickListener {
         //   self.openWebview(tag: 1)
        }
        termsLbl.setClickListener {
         //   self.openWebview(tag: 0)
        }
        agreeTermsHolder.setClickListener {
            if self.agreeTermsHolder.tag == 0{
                self.agreeTermsHolder.tag = 1
                self.agreeTermsCheckImg.image = #imageLiteral(resourceName: "rbt_checkbox_checked.pdf")
            }else{
                self.agreeTermsHolder.tag = 0
                self.agreeTermsCheckImg.image = #imageLiteral(resourceName: "rbt_checkbox_unchecked.pdf")
            }
        }
        paymentMethodHolders[0].setClickListener {
            self.selectedPlaymentMethod = 0
        }
        paymentMethodHolders[1].setClickListener {
            self.selectedPlaymentMethod = 1
        }
        if !ShadhinCore.instance.defaults.userName.isEmpty{
            userNameLbl.text = ShadhinCore.instance.defaults.userName
        }
        if !ShadhinCore.instance.defaults.userMsisdn.isEmpty{
            userMsisdn.text = ShadhinCore.instance.defaults.userMsisdn
        }
        self.agreeTermsHolder.tag = 1
        self.agreeTermsCheckImg.image = #imageLiteral(resourceName: "rbt_checkbox_checked.pdf")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear), name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    @objc func keyboardDidAppear(_ notification: Notification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
            let offset = (view.frame.height + keyboardHeight + topPadding) - UIScreen.main.bounds.size.height
            self.viewBottomConstraint.constant = offset > 0 ? offset : 0
        
        }
    }
    
    func windowHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }

    @objc func keyboardWillDisappear() {
        self.viewBottomConstraint.constant = 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    func ticketTypeSelection(position: Int){
        for index in 0...2{
            if index == position{
                ticketTypeHolders[index].backgroundColor = UIColor.init(rgb: 0x00B0FF)
                ticketTypeHolders[index].borderWidth = 0
                ticketTypeTitles[index].textColor = .white
                ticketTypeCosts[index].textColor = .white
                selectedTicketType = index
            }else{
                ticketTypeHolders[index].backgroundColor = UIColor.clear
                ticketTypeHolders[index].borderWidth = 1
                ticketTypeTitles[index].textColor = .primaryLableColor()
                ticketTypeCosts[index].textColor = .primaryLableColor()
            }
        }
    }
    
    func idTypeSelection(position: Int){
        for index in 0...2{
            if index == position{
                idTypeLbls[index].textColor = .primaryLableColor()
                idTypeRadioImgs[index].image = #imageLiteral(resourceName: "rbt_radio_check.pdf")
                selectedIdType = index
            }else{
                idTypeLbls[index].textColor = .secondaryLabelColor()
                idTypeRadioImgs[index].image = #imageLiteral(resourceName: "rbt_radio_unchecked.pdf")
            }
        }
    }
    
    func updatePaymentMethod(index: Int){
        if index == 0{
            paymentMethodLbls[0].textColor = .primaryLableColor()
            paymentMethodImgs[0].image = #imageLiteral(resourceName: "rbt_radio_check.pdf")
            paymentMethodLbls[1].textColor = .secondaryLabelColor()
            paymentMethodImgs[1].image = #imageLiteral(resourceName: "rbt_radio_unchecked.pdf")
        }else{
            paymentMethodLbls[1].textColor = .primaryLableColor()
            paymentMethodImgs[1].image = #imageLiteral(resourceName: "rbt_radio_check.pdf")
            paymentMethodLbls[0].textColor = .secondaryLabelColor()
            paymentMethodImgs[0].image = #imageLiteral(resourceName: "rbt_radio_unchecked.pdf")
        }
    }
    
    @IBAction func decreaseQuantity(_ sender: Any) {
        guard ticketQuantity > 1 else {return}
        ticketQuantity -= 1
        ticketQuantityLbl.text = "\(ticketQuantity)"
    }
    
    @IBAction func increaseQuantity(_ sender: Any) {
        guard ticketQuantity < maxTicketCount else {return}
        ticketQuantity += 1
        ticketQuantityLbl.text = "\(ticketQuantity)"
    }
    
//    func openWebview(tag: Int){
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "SignInWebViewVC") as! SignInWebViewVC
//        vc.btnTag = tag
//        vc.modalPresentationStyle = .fullScreen
//        vc.modalTransitionStyle = .coverVertical
//        self.present(vc, animated: true, completion: nil)
//        
//    }
    
    func isDataValid() -> Bool{
        if userNameLbl.text?.isEmpty ?? true{
            view.makeToast("Name cannot be empty")
            return false
        }
        if userMsisdn.text?.isEmpty ?? true{
            view.makeToast("Phone Number cannot be empty")
            return false
        }
        if let msisdn = userMsisdn.text, !ShadhinCore.instance.isValidBangladeshNumber(msisdn){
            view.makeToast("Phone number must be a valid Bangladeshi number")
            return false
        }
//        if userEmail.text?.isEmpty ?? true{
//            view.makeToast("Email cannot be empty")
//            return false
//        }
        if let email = userEmail.text,
           !email.isEmpty,
           !ShadhinCore.instance.isValidEmail(email){
            view.makeToast("Email address must be valid")
            return false
        }
//        if userIdNumber.text?.isEmpty ?? true{
//            view.makeToast("ID number cannot be empty")
//            return false
//        }
        if agreeTermsHolder.tag == 0{
            view.makeToast("Must agree to our privacy policy & terms of use")
            return false
        }
        return true
    }
    
    @IBAction func proceedToPayment(_ sender: Any) {
        self.view.endEditing(true)
        guard isDataValid() else {return}
        self.view.lock()
        ShadhinCore.instance.api.getConcertTicketPurchaseUrl(
            userName: userNameLbl.text!,
            userEmail: userEmail.text ?? "",
            idType: selectedIdTypeStr[selectedIdType],
            idNumber: userIdNumber.text ?? "",
            ticketType: selectedTicketTypeStr[selectedTicketType],
            quantity: ticketQuantity,
            phoneNumber: userMsisdn.text!,
            paymentMethod: selectedPlaymentMethod) { data, err in
                self.view.unlock()
                if let gatewayPageURL = data?.data?.getUrl,
                   let purchaseCode = data?.data?.purchaseCode{
                    SwiftEntryKit.dismiss() {
                        self.concertTicketsMainVC.proceedToPayment(
                            gatewayPageURL: gatewayPageURL,
                            purchaseCode: purchaseCode,
                            paymentMethod: self.selectedPlaymentMethod)
                    }
                    return
                }else if let _err = data?.data?.errorMessage{
                    self.view.makeToast(_err)
                    return
                }else if let _err = data?.message{
                    self.view.makeToast(_err)
                    return
                }else{
                    self.view.makeToast(err)
                    return
                }
            }
    }
    
}
