//
//  StreamNwinCollectionCell.swift
//  Shadhin
//
//  Created by MacBook Pro on 21/12/23.
//  Copyright © 2023 Cloud 7 Limited. All rights reserved.
//

import UIKit

enum OperatorType {
    case robiAirtel, gp, banglalink, ssl, nagad, bkash
}

class StreamNwinCollectionCell: UICollectionViewCell {
    
    //MARK: create nib for access this cell
    static var identifier : String{
        return String(describing: self)
    }
    static var nib : UINib{
         return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
    
    static var HEIGHT : CGFloat{
        let h = (SCREEN_WIDTH - 32) * 500 / 328
        return h
    }
    
    @IBOutlet weak var participateBtn: UIButton!
    @IBOutlet weak var campaignImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var campaignSubTitle: UILabel!
    @IBOutlet weak var campaignTitle: UILabel!
    
    private var campaignWrapper : [CampaignWrapper] = []
    private var campaignData: SimpleCampaign?
    private var campaignDailyDetails : CampaignResponseNew?
    weak var vc: HomeAdapterProtocol?
    
    var operatorType = OperatorType.robiAirtel
    var gotoLeaderboard : (CampaignWrapper)-> Void = {campaign in}
    var viewTostCallBack : ((String)-> Void)?
    var gotoPurchaseVC : (()-> Void)?
    
    private var object : [String: ParticipentObj] = ["Leaderboard" : .init(title: "Listen to Win", subtitle: "View your Leaderboard", buttonTitle: "Scoreboard", icon: .leaderboardIcon, tintColor: .appTintColor),"GP"  : .init(title: "Grameenphone", subtitle: "Payment with GP Number ", buttonTitle: "Participate", icon: .gp, tintColor: .appTintColor),"ROBI"  : .init(title: "Robi & Airtel User", subtitle: "Payment with Robi Number ", buttonTitle: "Participate", icon: .robi, tintColor: .robiTint),"BL" : .init(title: "Banglalink", subtitle: "Payment with Banglalink Number ", buttonTitle: "Participate", icon: .bl, tintColor: .appTintColor),"Bkash" : .init(title: "BKash", subtitle: "Payment with bKash Account", buttonTitle: "Participate", icon: .bkash, tintColor: .appTintColor),"Nagad" : .init(title: "Nagad", subtitle: "Payment with Nagad Account", buttonTitle: "Participate", icon: .nagad, tintColor: .appTintColor),"SSL" : .init(title: "Bank", subtitle: "Payment with credit Card", buttonTitle: "Participate", icon: .gp, tintColor: .appTintColor)]
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.register(WinNStreamTypeCell.nib
                                ,forCellWithReuseIdentifier: WinNStreamTypeCell.identifier)
        self.collectionView.register(WinNStreamSingleTypeCell.nib, forCellWithReuseIdentifier: WinNStreamSingleTypeCell.identifier)
        self.collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
    }

    @IBAction func campaignClickBtnAction(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if ShadhinCore.instance.isUserPro {
                if self.participateBtn.titleLabel?.text == "Scoreboard   " {
                    self.getCampaignDailyScore(campaignId: self.campaignData?.operators?.first?.campaignId ?? 0)
                    
                    if case .campaign(let campaingWrapper) = self.campaignDailyDetails?.data {
                        self.gotoLeaderboard(campaingWrapper)
                        self.ownerStremingDetails(campaingWrapper)
                    }
                    
                } else {
                    self.viewTostCallBack?(self.campaignData?.description ?? "")
                }
            } else {
                self.gotoPurchaseVC?()
            }
        }
    }
    
    private func ownerStremingDetails(_ data: CampaignWrapper) {
        for (index, userData) in data.userStreamings?.enumerated() ?? [] .enumerated() {
            if userData.msisdn == ShadhinCore.instance.defaults.userMsisdn {
                USERSTREAMING = data.userStreamings?[index]
            } else {
                USERSTREAMING = nil
            }
        }
    }
    
    private func getCampaignDailyScore(campaignId : Int) {
        ShadhinCore.instance.api.getStreamAndWinCampaignDailyData(campaignID: "\(campaignId)") {
            result in
            switch result {
            case .success(let data):
                self.campaignDailyDetails = data
                if case .campaign(let campaingWrapp) = self.campaignDailyDetails?.data {
                    self.campaignWrapper.append(campaingWrapp)
                }
                print("data")
            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }
    }
    
    private func checkCampaignUser(_ campaignData: SimpleCampaign) {
        let operatorTitle = campaignData.operators?.first?.title.lowercased()
        if operatorTitle == "robi/airtel" {
            self.operatorType = .robiAirtel
        } else if operatorTitle == "gp" {
            self.operatorType = .gp
        } else if operatorTitle == "banglalink" {
            self.operatorType = .banglalink
        } else if operatorTitle == "nagad" {
            self.operatorType = .nagad
        }
        
        if self.operatorType == .robiAirtel &&
            (ShadhinCore.instance.isRobi() || ShadhinCore.instance.isAirtel()) &&
            ShadhinCore.instance.isUserPro {
            self.participateBtn.setTitle("Scoreboard   ", for: .normal)
            self.logoImageView.image = UIImage(named: "leaderboardIcon",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        }
        
        else if self.operatorType == .gp &&
                    ShadhinCore.instance.isUserPro &&
                    ShadhinCore.instance.isGP() {
            self.participateBtn.setTitle("Scoreboard   ", for: .normal)
            self.logoImageView.image = UIImage(named: "leaderboardIcon",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        }
        
        else if self.operatorType == .banglalink &&
                    ShadhinCore.instance.isUserPro &&
                    ShadhinCore.instance.isBanglalink() {
            self.participateBtn.setTitle("Scoreboard   ", for: .normal)
            self.logoImageView.image = UIImage(named: "leaderboardIcon",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        }
        
        else {
            self.participateBtn.setTitle("Participate   ", for: .normal)
            self.logoImageView.kf.setImage(with: URL(string: campaignData.operators?.first?.iconUrl.image300 ?? ""))
        }
    }
    
    func bind(with campaignData : SimpleCampaign) {
        self.campaignData = campaignData
        self.campaignImg.kf.setImage(with: URL(string: campaignData.imageUrl.image300))
        self.campaignTitle.text = campaignData.title
        self.campaignSubTitle.text = campaignData.description
        self.checkCampaignUser(campaignData)
        self.collectionView.reloadData()
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
        return true
    }
}
