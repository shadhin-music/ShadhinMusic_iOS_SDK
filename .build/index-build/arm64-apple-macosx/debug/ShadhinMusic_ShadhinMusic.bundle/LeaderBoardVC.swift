//
//  LeaderBoardVC.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit
import SafariServices

class LeaderBoardVC: UIViewController, NIBVCProtocol {

    //for coordinator
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var adapter : LeaderBoardAdapter?
    var paymentMethod : PaymentMethod?
    var campaignWrapper : CampaignWrapper?
    var campaignType : String = "Stream & Win"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
        prizeLabel.text = campaignWrapper?.campaign.title
        prizeLabel.textColor = .black
        viewSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.adapter?.campaignWrapper = self.campaignWrapper
        if let prize = self.campaignWrapper?.campaign.prizes?.first {
            self.adapter?.setPrize(prize: prize)
        }

        if let userStriming = self.campaignWrapper?.userStreamings {
            self.adapter?.setAllUserRank(userStriming)
            self.adapter?.top3Rank = userStriming
            if let userStriming2 = userStriming.first {
                self.adapter?.setUserRank(userStriming2)
            }
        }
        //fetchCampaign()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        //coordinator?.pop()
    }
    
}

extension LeaderBoardVC {
    fileprivate func viewSetup(){
        
//        adapter = LeaderBoardAdapter(delegate: self, payment: paymentMethod)
        adapter = LeaderBoardAdapter(delegate: self, campaignWrapper: campaignWrapper)
//        vm = LeaderBoardVM(delegate : self)
        collectionView.register(TopPlayerCell.nib, forCellWithReuseIdentifier: TopPlayerCell.identifier)
        collectionView.register(Top3RankCell.nib, forCellWithReuseIdentifier: Top3RankCell.identifier)
        collectionView.register(MyRankCell.nib, forCellWithReuseIdentifier: MyRankCell.identifier)
        collectionView.register(RankCell.nib, forCellWithReuseIdentifier: RankCell.identifier)
        collectionView.register(CampaignDetailsCell.nib, forCellWithReuseIdentifier: CampaignDetailsCell.identifier)
        collectionView.register(PrizeCell.nib, forCellWithReuseIdentifier: PrizeCell.identifier)
        collectionView.register(Header.nib, forSupplementaryViewOfKind: UICollectionView
            .elementKindSectionHeader, withReuseIdentifier: Header.identifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        collectionView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.delegate = adapter
        collectionView.dataSource = adapter
        
    }

}

extension LeaderBoardVC : LeaderBoardVMProtocol{
    
    func userRank(_ rank: UserStreaming) {
        self.adapter?.setUserRank(rank)
        self.collectionView.reloadData()
    }
    
    func allUserRank(_ ranks: [UserStreaming]) {
        self.adapter?.setAllUserRank(ranks)
        self.collectionView.reloadData()
    }
    func prizeNconditions(prizes: Prize) {
        if let prizes = self.campaignWrapper?.campaign.prizes?.first {
            self.adapter?.setPrize(prize: prizes)
            self.collectionView.reloadData()
        }
    }
    func errorResult(_ error: String) {
        self.adapter?.setAllUserRank([])
        self.collectionView.reloadData()
        self.view.makeToast("Ops! Data not found", position: .bottom) { didTap in
            
        }
    }
}

extension LeaderBoardVC : LeaderboardAdapterProtocol, SFSafariViewControllerDelegate{
    func onCampaignChange(_ campaign: CampaignSegment) {
        
    }
    
    func onMyRankPressed() {
  //      let vc = MyProfileVC.instantiateNib()
     //   self.navigationController?.pushViewController(vc, animated: true)
    }
    func onPrizePressed(url: String) {
        guard let url = URL(string: url) else {return}
        let web = SFSafariViewController(url: url)
        web.configuration.entersReaderIfAvailable = true
        web.delegate = self
        web.toolbarItems = nil
        self.present(web, animated: true)
    }
    func onTermsAndConditionPressed(url: String) {
        guard let url = URL(string: url) else {return}
        let web = SFSafariViewController(url: url)
        web.delegate = self
        self.present(web, animated: true)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
    }
    
}
