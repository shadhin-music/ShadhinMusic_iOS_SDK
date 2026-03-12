//
//  CurrentPlanCell.swift
//  Shadhin
//
//  Created by Maruf on 17/4/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CurrentPlanCell: UICollectionViewCell {
    
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var changeAmount: UILabel!
    @IBOutlet weak var paymentStatusString: UILabel!
    @IBOutlet weak var operatorName: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var durationInDay: UILabel!
    @IBOutlet weak var renewButton: UIButton!
    
    static var identifier : String{
        String(describing: self)
    }
    
    static var nib : UINib{
        UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var SIZE: CGSize {
        let aspectRatio = 328.0/150.0
        let width = SCREEN_WIDTH - 32.0
        let height = width/aspectRatio
        return .init(width: width, height: height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind() {
        if let subscriptionDetails = ShadhinCore.instance.defaults.newSubscriptionDetails {
            serviceName.text = subscriptionDetails.serviceName
            
            if let amount = subscriptionDetails.chargeAmount, let currencySymbol = subscriptionDetails.currencySymbol {
                changeAmount.text = currencySymbol + amount.getPriceDecidingDecimalPart
            } else {
                changeAmount.text = ""
            }
            
            if let duration = subscriptionDetails.durationInDay, duration > 0 {
                durationInDay.text = "/\(duration) \(duration > 1 ? "days" : "day")"
            } else {
                durationInDay.text = ""
            }
            
            if let operatorname = subscriptionDetails.operator {
                operatorName.text = "Payment Method: \(operatorname)"
            } else {
                operatorName.text = ""
            }
            
            if let expireDate = subscriptionDetails.expiryUnixTimestamp {
                let cancelled = subscriptionDetails.planStatus?.lowercased() == "cancelled" ? ", Auto-renewal cancelled." : ""
                paymentStatusString.text = "Plan active till \(expireDate.toDateString())\(cancelled)"
            }
            
            if let cancelSubscriptionUrl = subscriptionDetails.cancelSubscriptionUrl, !cancelSubscriptionUrl.isEmpty {
                cancelButton.isHidden = false
            } else {
                cancelButton.isHidden = true
            }
            
            if let renewSubscriptionUrl = subscriptionDetails.renewSubscriptionUrl, !renewSubscriptionUrl.isEmpty, subscriptionDetails.isExpired == true {
                renewButton.isHidden = false
            } else {
                renewButton.isHidden = true
            }
        }
    }

    @IBAction func onRenewButtonTap(_ sender: Any) {
        lock()
        guard let renewSubscriptionUrl = ShadhinCore.instance.defaults.newSubscriptionDetails?.renewSubscriptionUrl, let serviceId = ShadhinCore.instance.defaults.newSubscriptionDetails?.serviceId else {return}
        
        let body : [String : Any] = [
            "MSISDN": ShadhinCore.instance.defaults.userMsisdn,
            "ServiceId": serviceId,
            "userCode" : ShadhinCore.instance.defaults.userIdentity,
        ]
        
        ShadhinCore.instance.api.renewSubscription(body: body, url: renewSubscriptionUrl) {[weak self] response in
            guard let self = self else {return}
            self.unlock()
            switch response {
            case .success(let success):
                self.updateSubscriptionAndNotify()
                self.makeToast(success.message)
            case .failure(let failure):
                self.makeToast(failure.localizedDescription)
            }
        }
    }
    
    @IBAction func onCancelButtonTap(_ sender: Any) {
        
        guard let url = ShadhinCore.instance.defaults.newSubscriptionDetails?.cancelSubscriptionUrl, let serviceId = ShadhinCore.instance.defaults.newSubscriptionDetails?.serviceId else { return }
        
        lock()
        
        let body: [String : Any] = [
            "MSISDN": ShadhinCore.instance.defaults.userMsisdn,
            "ServiceId": serviceId,
            "userCode" : ShadhinCore.instance.defaults.userIdentity,
        ]
        
        if let isAPICallForCancel = ShadhinCore.instance.defaults.newSubscriptionDetails?.isApiCallForCancel, isAPICallForCancel {
            ShadhinCore.instance.api.cancelSubscription(body: body, url: url ) {[weak self] response in
                guard let self = self else {return}
                switch response {
                case .success(let success):
                    self.makeToast(success.message)
                    self.updateSubscriptionAndNotify()
                case .failure(let failure):
                    self.makeToast(failure.localizedDescription)
                    self.unlock()
                }
            }
        } else {
            gotoWebViewForCancel(mobileNo: ShadhinCore.instance.defaults.userMsisdn, serviceId: serviceId)
        }
    }
    
    private func gotoWebViewForCancel(mobileNo: String, serviceId: String) {
        let paymentStoryboard = UIStoryboard.init(name: "Payment", bundle: nil)
        let vc = paymentStoryboard.instantiateViewController(withIdentifier: "BkashPaymentVC") as! BkashPaymentVC
        vc.subscriptionUrl = "http://27.131.15.19/ShandhinCelcomPaymentAPI/ShadhinUMobile/UnSubscription/?mobileNo=\(mobileNo)&serviceId=\(serviceId)"
       // self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateSubscriptionAndNotify() {
        GPSDKSubscription.getNewUserSubscriptionDetails {[weak self] isSuccess in
            guard let self = self else {return}
            NotificationCenter.default.post(name: .newSubscriptionUpdate, object: nil)
            self.unlock()
        }
    }
}

extension UICollectionViewCell {
    var parentCollectionView: UICollectionView? {
        var view = self.superview
        while view != nil && !(view is UICollectionView) {
            view = view?.superview
        }
        return view as? UICollectionView
    }
}

extension UIView {
//    func findViewController() -> UIViewController? {
//        if let nextResponder = self.next as? UIViewController {
//            return nextResponder
//        } else if let nextResponder = self.next as? UIView {
//            return nextResponder.findViewController()
//        } else {
//            return nil
//        }
//    }
}

extension UICollectionViewCell {
//    var navigationController: UINavigationController? {
//        return self.findViewController()?.navigationController
//    }
}

extension Int {
    /// Converts the Unix timestamp (in milliseconds) to a formatted date string.
    /// - Parameter format: The date format you want the output string to be in.
    /// - Returns: A formatted date string.
    func toDateString(format: String = "dd MMM, yyyy") -> String {
        // Convert Unix timestamp to seconds and create a Date object
        let date = Date(timeIntervalSince1970: TimeInterval(self) / 1000)
        
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        // Convert the Date to a String
        return dateFormatter.string(from: date)
    }
}

extension String {
    func toFormattedDate(from inputFormat: String = "yyyy-MM-dd'T'HH:mm:ss", to outputFormat: String = "dd MMM, yyyy") -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        
        if let date = inputFormatter.date(from: self) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = outputFormat
            return outputFormatter.string(from: date)
        }
        return nil
    }
}
