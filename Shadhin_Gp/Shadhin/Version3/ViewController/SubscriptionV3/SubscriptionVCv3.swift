//
//  SubscriptionVCv3.swift
//  Shadhin
//
//  Created by Maruf on 13/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionVCv3: UIViewController, NIBVCProtocol {
    
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var proTitleAdapter:SubscriptionAdapter!
    var isSettigns = false

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        addNewSubscriptionObserver()
        view.lock()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkAndUpdateSubscription()
    }
    
    @IBAction func xMarkButton(_ sender: UIButton) {
        if let tab = self.tabBarController {
            if let selectedIndex = tab.viewControllers?.firstIndex(of: tab.viewControllers![1]) {
                print("Current tab index: \(selectedIndex)")
                if selectedIndex == 1 {
                    if let navigationController = self.navigationController {
                        navigationController.popToRootViewController(animated: true)
                    }
                    return
                }
            }
        }
        self.dismiss(animated: isSettigns ? false : true)
    }
    
    @IBAction func onRestorePurchaseBtn(_ sender: Any) {
        AppleSubscriptionManager.shared.restorePurchases()
    }
    
    
    private func addNewSubscriptionObserver() {
        SKPaymentQueue.default().add(AppleSubscriptionManager.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewSubscriptionUpdate(_:)), name: .newSubscriptionUpdate, object: nil)
    }
    
    private func checkAndUpdateSubscription() {
        GPSDKSubscription.getNewUserSubscriptionDetails {[weak self] isSubscribed in
            NotificationCenter.default.post(name: .newSubscriptionUpdate, object: nil)
            if let proTitleAdapter = self?.proTitleAdapter, !isSubscribed, proTitleAdapter.planItemArray.isEmpty {
                proTitleAdapter.getSubscriptionProducts()
            } else {
                self?.view.unlock()
                self?.collectionView.reloadData()
            }
        }
    }
    
    @objc func handleNewSubscriptionUpdate(_ sender: Any) {
        GPSDKSubscription.getNewUserSubscriptionDetails { isSubscribed in
            if let proTitleAdapter = self.proTitleAdapter, !isSubscribed, proTitleAdapter.planItemArray.isEmpty {
                proTitleAdapter.getSubscriptionProducts()
            }
        }
        collectionView.reloadData()
    }
    
    deinit {
        SKPaymentQueue.default().remove(AppleSubscriptionManager.shared)
        NotificationCenter.default.removeObserver(self, name: .newSubscriptionUpdate, object: nil)
    }
    
}

extension SubscriptionVCv3 {
    func  viewSetup() {
        restoreButton.isAccessibilityElement = false
        proTitleAdapter = SubscriptionAdapter(delegate:self, vc: self)
        collectionView.register(ProTitleCell.nib, forCellWithReuseIdentifier: ProTitleCell.identifier)
        collectionView.register(ChoosePlanCell.nib, forCellWithReuseIdentifier: ChoosePlanCell.identifier)
        collectionView.register(CurrentPlanCell.nib, forCellWithReuseIdentifier: CurrentPlanCell.identifier)
        collectionView.register(UINib(nibName: "HeaderViewCVSubscription", bundle: Bundle.ShadhinMusicSdk), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewCVSubscription")
        collectionView.delegate = proTitleAdapter
        collectionView.dataSource = proTitleAdapter
        
    }
}
extension SubscriptionVCv3:SubscriptionAdapterProtocol {
    func getNavController() -> UINavigationController {
        self.navigationController!
    }
    
    
}
