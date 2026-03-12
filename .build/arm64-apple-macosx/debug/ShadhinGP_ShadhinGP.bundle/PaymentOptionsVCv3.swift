//
//  PaymentOptionsVCv3.swift
//  Shadhin
//
//  Created by Maruf on 14/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit
import StoreKit

class PaymentOptionsVCv3: UIViewController,NIBVCProtocol {
    private var paymentOptionAdapter : PaymentOptionAdapter!
    var appleSubscriptionManager = AppleSubscriptionManager.shared
   
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedPay: Plan!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        SKPaymentQueue.default().remove(appleSubscriptionManager)
    }
}

extension PaymentOptionsVCv3 {
    func viewSetup() {
        paymentOptionAdapter = PaymentOptionAdapter(delegate: self, selectedPay: selectedPay, vc: self)
        collectionView.register(ChooseAPlanCell.nib, forCellWithReuseIdentifier:ChooseAPlanCell.identifier)
        collectionView.register(PaymentOptionCell.nib, forCellWithReuseIdentifier: PaymentOptionCell.identifier)
        collectionView.register(UINib(nibName: "HeaderViewCVSubscription", bundle: Bundle.ShadhinMusicSdk), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewCVSubscription")
        collectionView.delegate = paymentOptionAdapter
        collectionView.dataSource = paymentOptionAdapter 
        
    }
}

extension PaymentOptionsVCv3: SubscriptionAdapterProtocol {
    func getNavController() -> UINavigationController {
        self.navigationController!
    }
}

extension PaymentOptionsVCv3: AppleSubscribable {
    
    var vc: UIViewController {
        return self
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.view.lock()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.view.unlock()
        }
    }
    
    func showAlert(title: String, message: String) {
        print("ALERT, TITLE: \(title). Message: \(message)")
    }
    
    func updateSubscriptionStatus(isActive: Bool) {
        print("SUBSCRIPTION STATUS: \(isActive)")
    }
    
    func activateAppleSubscription(productId: String, serviceName: String) {
        appleSubscriptionManager.updateProduct(
            delegate: self,
            productID: productId,
            serviceName: serviceName
        )
        SKPaymentQueue.default().add(appleSubscriptionManager)
        appleSubscriptionManager.requestAndPurchaseProduct()
    }
}
