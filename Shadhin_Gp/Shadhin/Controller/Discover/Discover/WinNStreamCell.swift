//
//  WinNStreamCell.swift
//  Shadhin
//
//  Created by Joy on 15/2/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

struct ParticipentObj{
    var title : String
    var subtitle : String
    var buttonTitle : String
    var icon : AppImage
    var tintColor : UIColor
}

class WinNStreamCell: UITableViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var HEIGHT : CGFloat{
        let h = (SCREEN_WIDTH - 32) * 500 / 328
        return h
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    
    private var paymentMethods : [PaymentMethod] = []
    
    var gotoLeaderboard : (PaymentMethod)-> Void = {campaign in}
    var onParticipant : (PaymentMethod)-> Void = {paymentMethod in}
    
    private var object : [String: ParticipentObj] = ["Leaderboard" : .init(title: "Listen to Win", subtitle: "View your Leaderboard", buttonTitle: "Scoreboard", icon: .leaderboardIcon, tintColor: .appTintColor),"GP"  : .init(title: "Grameenphone", subtitle: "Payment with GP Number ", buttonTitle: "Participate", icon: .gp, tintColor: .appTintColor),"ROBI"  : .init(title: "Robi & Airtel User", subtitle: "Payment with Robi Number ", buttonTitle: "Participate", icon: .robi, tintColor: .robiTint),"BL" : .init(title: "Banglalink", subtitle: "Payment with Banglalink Number ", buttonTitle: "Participate", icon: .bl, tintColor: .appTintColor),"Bkash" : .init(title: "BKash", subtitle: "Payment with bKash Account", buttonTitle: "Participate", icon: .bkash, tintColor: .appTintColor),"Nagad" : .init(title: "Nagad", subtitle: "Payment with Nagad Account", buttonTitle: "Participate", icon: .nagad, tintColor: .appTintColor),"SSL" : .init(title: "Bank", subtitle: "Payment with credit Card", buttonTitle: "Participate", icon: .gp, tintColor: .appTintColor)]
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(WinNStreamTypeCell.nib
                                , forCellWithReuseIdentifier: WinNStreamTypeCell.identifier)
        collectionView.register(WinNStreamSingleTypeCell.nib, forCellWithReuseIdentifier: WinNStreamSingleTypeCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 32
    }

    
    func bind(with paymentMethods : [PaymentMethod]){
        guard paymentMethods.count > 0 else {return}
        
        if paymentMethods.contains(where: {isLeaderboard(payment: $0)}),let payment = paymentMethods.first(where: {isLeaderboard(payment: $0)}){
            self.paymentMethods = [payment]
        }else{
            self.paymentMethods = paymentMethods
        }
        
        if self.paymentMethods.count == 1{
            self.heightConstraint.constant = 80
        }else{
            self.heightConstraint.constant = 144
        }
        
        collectionView.reloadData()
    }
    
    func isLeaderboard(payment : PaymentMethod)->Bool{
        guard ShadhinCore.instance.isUserPro else{
            return false
        }
        if let type = PaymentGetwayType(rawValue: payment.name.uppercased()){
            switch type {
            case .GP:
                if ShadhinCore.instance.isGP() && ShadhinDefaults().isTelcoSubscribedUser{
                    return true
                }
            case .BL:
                if ShadhinCore.instance.isBanglalink() &&  ShadhinDefaults().isTelcoSubscribedUser{
                    return true
                }
            case .ROBI:
                if ShadhinCore
                    .instance
                    .isAirtelOrRobi() && ShadhinDefaults().isTelcoSubscribedUser{
                    return true
                }
            case .SSL:
                if ShadhinDefaults().isSSLSubscribedUser{
                    return true
                }
                
            case .Bkash:
                if ShadhinDefaults().isBkashSubscribedUser{
                    return true
                }
            case .Nagad:
                if ShadhinDefaults().isNagadSubscribedUser{
                    return true
                }
                
            }
        }
        return false
    }
    
}


extension WinNStreamCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paymentMethods.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let payment = paymentMethods[indexPath.row]
        if paymentMethods.count == 1  {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WinNStreamSingleTypeCell.identifier, for: indexPath) as? WinNStreamSingleTypeCell else {
                fatalError()
            }
            let isLeaderboard = isLeaderboard(payment: payment)
            cell.bind(with: payment, obj: isLeaderboard ? object["Leaderboard"] : object[payment.name], isLeaderboard: isLeaderboard)
            
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WinNStreamTypeCell.identifier, for: indexPath) as? WinNStreamTypeCell else{
            fatalError()
        }
        
        cell.bind(with: object[payment.name])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if paymentMethods.count == 1{
            let w = collectionView.bounds.width - 32
            return .init(width: w, height: 80)
        }
        let w = (collectionView.bounds.width - 48) / 2
        
        return .init(width: w, height: 144)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let payment = paymentMethods[indexPath.row]
        if isLeaderboard(payment: payment){
            gotoLeaderboard(payment)
        }else{
            onParticipant(payment)
        }
    }
}
