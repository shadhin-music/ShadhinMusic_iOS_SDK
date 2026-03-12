//
//  PaymentOptionAdapter.swift
//  Shadhin
//
//  Created by Maruf on 14/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit
import Foundation

class PaymentOptionAdapter:NSObject {
    private weak var delegate : SubscriptionAdapterProtocol?
    private var selectedPay: Plan
    private weak var vc: PaymentOptionsVCv3?
    private var planItemArray = [Item]()
    
    init(delegate: SubscriptionAdapterProtocol, selectedPay: Plan, vc: PaymentOptionsVCv3) {
        self.delegate = delegate
        self.selectedPay = selectedPay
        self.planItemArray = selectedPay.items
        self.vc = vc
        super.init()
        vc.collectionView.reloadData()
        
    }
}

extension PaymentOptionAdapter:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section == 0) ? 1 : planItemArray.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChooseAPlanCell.identifier, for: indexPath) as? ChooseAPlanCell else{
                fatalError()
            }
            cell.bindData(data: selectedPay, index: indexPath.item)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentOptionCell.identifier, for: indexPath) as? PaymentOptionCell else{
                fatalError()
            }
            cell.bind(data: planItemArray[indexPath.item])
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return ChooseAPlanCell.SIZE
        }  else {
            let width = (SCREEN_WIDTH - 32)
            return CGSize(width: width,height:60)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 8
       }
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 8
       }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section != 0{
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderViewCVSubscription", for: indexPath) as! HeaderViewCVSubscription
            headerView.planTitleLbl.text = "Choose your payment option"
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            return .zero
        }
        return CGSize(width: SCREEN_WIDTH, height:36)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if indexPath.section == 1 {
            let vc = OTPSentForRefferalVC.instantiateNib()
            vc.selectedItem = planItemArray[indexPath.item]
            vc.originalPlan = selectedPay
            getPlanDetails(vc: vc, index: indexPath.item)
        }
    }
    
    private func getPlanDetails(vc: OTPSentForRefferalVC, index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.vc?.view.lock()
        }
        ShadhinCore.instance.api.getPlanDetails(planId: "\(planItemArray[index].planId)") {[weak self] result in
            guard let self = self else{return}
            DispatchQueue.main.async {
                self.vc?.view.unlock()
                switch result {
                case .success(let success):
                    if let data = success.data {
                        if data.isOtpBased {
                            vc.planDetails = data
                            self.delegate?.getNavController().pushViewController(vc, animated: true)
                        } else if let checkOutUrl = data.checkOutUrl {
                            self.gotoWebViewForPayment(url: checkOutUrl, serviceId: data.serviceId)
                        } else {
                            //let appleSubscriptionProduct = data.serviceId == String(602) ? AppleProducts.store.yearlyAppleSubscription : AppleProducts.store.monthlyAppleSubscription
                            self.vc?.activateAppleSubscription(productId: data.serviceId, serviceName: data.serviceId)
                        }
                    }
                case .failure( let failure):
                    print(failure)
                    self.vc?.view.makeToast("We are experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                }
            }
        }
    }
    
    
    private func gotoWebViewForPayment(url: String, serviceId: String) {
        self.vc?.view.lock()
        let paymentStoryboard = UIStoryboard.init(name: "Payment", bundle: Bundle.ShadhinMusicSdk)
        let vc = paymentStoryboard.instantiateViewController(withIdentifier: "BkashPaymentVC") as! BkashPaymentVC
        vc.subscriptionSuccsessHandler = subscriptionSuccessHandlerOnWebView
        
        if url.contains("{SERVICE_ID}") {
            let modifiedUrl = url.replacingOccurrences(of: "{SERVICE_ID}", with: serviceId)
            vc.subscriptionUrl = modifiedUrl
            self.delegate?.getNavController().pushViewController(vc, animated: true)
            return
        }
        
        let body: [String : Any] = [
            "msisdn": "\(ShadhinCore.instance.defaults.userMsisdn)",
            "serviceId": serviceId,
            "userCode": "\(ShadhinCore.instance.defaults.userMsisdn)"
        ]
        
        ShadhinCore.instance.api.getWebViewUrl(body: body, url: url) {[weak self] responseModel in
            guard let self = self else {return}
            switch responseModel {
            case .success(let success):
                vc.subscriptionUrl = success.data.paymentUrl
                self.delegate?.getNavController().pushViewController(vc, animated: true)
            case .failure(let failure):
                print(failure)
            }
            self.vc?.view.unlock()
        }
    }
    
    private func subscriptionSuccessHandlerOnWebView() {
        GPSDKSubscription.getNewUserSubscriptionDetails { isSubscribed in
            self.vc?.navigationController?.popToRootViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                NotificationCenter.default.post(name: .newSubscriptionUpdate, object: nil)
            })
        }
    }
}
