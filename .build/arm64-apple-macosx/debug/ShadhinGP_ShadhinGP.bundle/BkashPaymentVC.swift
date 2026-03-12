//
//  BkashPaymentVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 12/19/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import WebKit


class BkashPaymentVC: UIViewController {
    
    @IBOutlet weak var webKit: WKCookieWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var subscriptionUrl = ""
    var timerDelay : TimeInterval = 0
    var secondaryCloseHandler : (()->Void)?
    
    var subscriptionSuccsessHandler: () -> Void = {}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = .white
        webKit.navigationDelegate = self
        webKit.allowsLinkPreview = false
        spinner.startAnimating()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .lightContent
        }
    }
    
    func makeToastAndRemoveSwiftEntryKit(msg: String) {
        self.view?.makeToast(msg, duration: 3, position: .bottom, title: nil, image: nil, style: .init()) { (success) in
            SwiftEntryKit.dismiss()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.subscriptionsPlan()
    }
    
    
    private func subscriptionsPlan() {
        
        guard let url = URL(string: subscriptionUrl) else{
            return self.view.makeToast("Unable to get url from server")
        }
        
        let urlRequest = URLRequest(url: url)
        let _ = self.webKit.load(urlRequest)
        
    }
    
    
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
////      //  let appDelegate = UIApplication.shared.delegate as! AppDelegate
////        if timerDelay == 0{
////            //checkBkashInvoiceStatus()
////        }
//        GPSDKSubscription.checkUserSubscription(timerDelay)
//        secondaryCloseHandler?()
//    }
}

extension BkashPaymentVC: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView,didStart navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.spinner.startAnimating()
        }
    }
    
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
        self.spinner.stopAnimating()
        self.spinner.isHidden = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url?.absoluteString,
           (url.contains("/views/success")){
            decisionHandler(.cancel)
            self.navigationController?.popViewController(animated: true)
            subscriptionSuccsessHandler()
            return
        }
        decisionHandler(.allow)
    }
}
