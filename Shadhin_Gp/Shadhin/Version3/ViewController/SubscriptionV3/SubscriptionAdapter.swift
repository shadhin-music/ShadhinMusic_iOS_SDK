//
//  SubscriptionAdapter.swift
//  Shadhin
//
//  Created by Maruf on 13/2/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import Foundation

protocol SubscriptionAdapterProtocol:NSObjectProtocol {
    func getNavController() -> UINavigationController
}

class  SubscriptionAdapter: NSObject  {
    private weak var delegate : SubscriptionAdapterProtocol?
    private weak var vc: SubscriptionVCv3?
    
    init(delegate: SubscriptionAdapterProtocol, vc: SubscriptionVCv3) {
        self.delegate = delegate
        self.vc = vc
        super.init()
    }
    var planItemArray = [Plan]()
    
    func getSubscriptionProducts() {
        DispatchQueue.main.async { [weak self] in
            self?.vc?.view.lock()
        }
        
        ShadhinCore.instance.api.getNewUsersubscriptionPaymentProducts() {[weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.vc?.view.unlock()
                switch result {
                case .success(let success):
                    self.planItemArray = success.data
                    self.planItemArray = self.planItemArray.filter({$0.currencySymbol != "$"})
                    self.planItemArray = self.planItemArray.sorted(by: {$0.durationInDays < $1.durationInDays})
                    self.vc?.collectionView.reloadData()
                case .failure( _):
                    self.vc?.view.makeToast("We are experiencing technical problems now which will be fixed soon. Thanks for your patience.")
                }
            }
        }
    }
}
extension SubscriptionAdapter: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section == 0) ? 1 : ShadhinCore.instance.isUserPro ? 1 : planItemArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProTitleCell.identifier, for: indexPath) as? ProTitleCell else{
                fatalError()
            }
            return cell
        } else {
            
            if ShadhinCore.instance.isUserPro {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrentPlanCell.identifier, for: indexPath) as? CurrentPlanCell else{
                    fatalError()
                }
                cell.bind()
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChoosePlanCell.identifier, for: indexPath) as? ChoosePlanCell else{
                    fatalError()
                }
                let plan = planItemArray[indexPath.item]
                cell.bindData(data: plan)
                return cell
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return ProTitleCell.SIZE
        }  else {
            if ShadhinCore.instance.isUserPro {
                return CurrentPlanCell.SIZE
            } else {
                let width = (SCREEN_WIDTH - 32)
                return CGSize(width: width,height:60)
            }
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
            // here plan  title customize able
            if ShadhinCore.instance.isUserPro {
                headerView.planTitleLbl.text =  "Current plan"
            }  else {
                headerView.planTitleLbl.text =  "Choose a plan"
            }
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
           if indexPath.section == 1 && !ShadhinCore.instance.isUserPro {
               let plan = planItemArray[indexPath.item]
               let vc = PaymentOptionsVCv3.instantiateNib()
               vc.selectedPay = plan
               delegate?.getNavController().pushViewController(vc, animated: true)
           }
       }
}
