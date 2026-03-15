//
//  AppleSubscription.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 15/8/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit
import StoreKit


class AppleSubscriptionManager: NSObject {
    
    weak var delegate: AppleSubscribable?
    static var shared = AppleSubscriptionManager()
    
    var productID: String = ""
    var serviceName: String = ""
    
    private var product: SKProduct?
    
    private override init() {}
    
    func updateProduct(delegate: AppleSubscribable, productID: String, serviceName: String) {
        self.delegate = delegate
        self.productID = productID
        self.serviceName = serviceName
    }
    
    // Request product information and initiate purchase if available
    func requestAndPurchaseProduct() {
        delegate?.showActivityIndicator()
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
    }
    
    public func restorePurchases() {
      SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func checkSubscriptionStatus() {
        GPSDKSubscription.getNewUserSubscriptionDetails { isSubscribed in
            if isSubscribed {
                self.delegate?.vc.navigationController?.popToRootViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    NotificationCenter.default.post(name: .newSubscriptionUpdate, object: nil)
                })
            }
        }
    }
    
    func sendReceiptDataToBackEnd(completion: @escaping (Bool)-> Void){
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                ShadhinCore.instance.api.sendTransactionToken(receiptData: receiptString, serviceName: serviceName, completion: { isSuccess in
                    completion(isSuccess)
                })
            }
            catch {
                Log.error("Couldn't read receipt data with error: " + error.localizedDescription)
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    func successHandler() {
        sendReceiptDataToBackEnd { [weak self] isSuccess in
            self?.delegate?.hideActivityIndicator()
            if isSuccess {
                self?.checkSubscriptionStatus()
            }else {
                self?.delegate?.vc.view.makeToast("Something is wrong!")
            }
        }
    }
    
    func failedHandler() {
        DispatchQueue.main.async {
            self.delegate?.vc.view.makeToast("Transaction failed. Please try again.")
            self.delegate?.showAlert(title: "Error", message: "Transaction failed. Please try again.")
            self.delegate?.hideActivityIndicator()
        }
    }
}

extension AppleSubscriptionManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        product = response.products.first { $0.productIdentifier == productID }
        if let product = product {
            // Product is available, proceed to purchase
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            // Product not found
            delegate?.showAlert(title: "Error", message: "Product not available.")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        delegate?.hideActivityIndicator()
        delegate?.showAlert(title: "Error", message: "Failed to load product. Please check your network connection and try again.")
    }
}

extension AppleSubscriptionManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Mark the product as purchased
                AppleProducts.store.setProductPurchased(transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                successHandler()
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                AppleProducts.store.removeProductPurchased(transaction.payment.productIdentifier)
                failedHandler()
                
            case .restored:
                // Mark the product as restored (purchased)
                AppleProducts.store.setProductPurchased(transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                successHandler()
            case .purchasing:
                break
                
            default:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            }
            
        }
    }
}

protocol AppleSubscribable: AnyObject {
    var vc: UIViewController { get }
    func showActivityIndicator()
    func hideActivityIndicator()
    func showAlert(title: String, message: String)
    func updateSubscriptionStatus(isActive: Bool)
    func activateAppleSubscription(productId: String, serviceName: String)
}

struct AppleProducts {
    var monthlyAppleSubscription = "com.gakkmedia.Shadhin.monthlySub"
    var yearlyAppleSubscription = "com.gakkmedia.Shadhin.yearlySub"
    static let store = AppleProducts()
    
    func isProductPurchased(_ productIdentifier: String) -> Bool {
        return UserDefaults.standard.bool(forKey: productIdentifier)
    }
    
    func setProductPurchased(_ productIdentifier: String) {
        UserDefaults.standard.set(true, forKey: productIdentifier)
    }
    
    func removeProductPurchased(_ productIdentifier: String) {
        UserDefaults.standard.removeObject(forKey: productIdentifier)
    }
}
