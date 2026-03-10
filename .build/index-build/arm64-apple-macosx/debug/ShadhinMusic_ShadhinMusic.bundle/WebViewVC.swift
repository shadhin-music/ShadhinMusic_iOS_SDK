//
//  WebViewVC.swift
//  Shadhin
//
//  Created by Joy on 29/5/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit
import WebKit

enum WebViewOpenType{
    case Stripe
    case SSL
    case none
}

class WebViewVC: UIViewController,NIBVCProtocol {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    
    
    var titleString : String?
    var url : URL?
    
    var from : WebViewOpenType = .none
    
    private let STRIPE_SUCCESS = "https://stripe.payment-app.info/views/success"
    private let SSL_SUCCESS = "https://ssl.payment-app.info/api/SuccessStatus"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = titleString
        
        guard let url = url else {return}
        let urlRequest = URLRequest(url: url)
        webView.navigationDelegate = self
        webView.load(urlRequest)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
extension WebViewVC : WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else {return}
        Log.info(url.absoluteString)
        if from == .Stripe{
            if url.absoluteString.contains(STRIPE_SUCCESS){
                self.view.lock()
                ShadhinApi.StripeSubscription.getStripSubscriptionStatus { result in
                    self.view.unlock()
                    switch result {
                    case .success(let success):
                        if let item = success.data.first{
                            ShadhinCore.instance.defaults.stripeSSLDetails = item
                            ShadhinCore.instance.defaults.isStripeSubscriptionUser = true
                            ShadhinCore.instance.defaults.subscriptionIDForStripeAndSSL  = item.subscriptionID
                            ShadhinCore.instance.defaults.subscriptionServiceID = item.productID
                            ShadhinCore.instance.defaults.shadhinUserType = .Pro
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.navigationController?.dismiss(animated: true)
                            }
                        }
                    case .failure(let failure):
                        Log.error(failure.localizedDescription)
//                        self.view.makeToast(failure.localizedDescription) { didTap in
//
//                        }
                        
                    }
                }
            }
        }else if from == .SSL{
            if url.absoluteString.contains(SSL_SUCCESS){
                self.view.lock()
                ShadhinApi.SSLSubscription.getSSLSubscriptionStatus { result in
                    self.view.unlock()
                    switch result {
                    case .success(let success):
                        if let item = success.data{
                            ShadhinCore.instance.defaults.stripeSSLDetails =  StripeStatus(status: item.status, productID: item.serviceID, subscriptionID: item.subscriptionID)
                            ShadhinCore.instance.defaults.isSSLSubscribedUser = true
                            ShadhinCore.instance.defaults.subscriptionIDForStripeAndSSL  = item.subscriptionID
                            ShadhinCore.instance.defaults.subscriptionServiceID = item.serviceID
                            ShadhinCore.instance.defaults.shadhinUserType = .Pro
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.navigationController?.dismiss(animated: true)
                            }
                        }
                    case .failure(let failure):
                        Log.error(failure.localizedDescription)
                        self.view.makeToast(failure.localizedDescription) { didTap in

                        }
                        
                    }
                }
                
            }
        }
        
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {return}
        Log.info(url.absoluteString)
    }
}
