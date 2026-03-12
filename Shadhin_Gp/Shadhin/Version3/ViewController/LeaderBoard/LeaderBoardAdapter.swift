//
//  LeaderBoardAdapter.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit

protocol LeaderboardAdapterProtocol  : NSObjectProtocol{
    func onMyRankPressed()
    func onPrizePressed(url : String)
    func onTermsAndConditionPressed(url : String)
}

class LeaderBoardAdapter: NSObject {
    
    
    private weak var delegate : LeaderboardAdapterProtocol?
    var campaignWrapper : CampaignWrapper?
    
    var userRank : UserStreaming?
    var top3Rank : [UserStreaming]?
    var allUserRank : [UserStreaming]?
    private var prize : Prize?
    private var campaignID : Int = 1
    
    init(delegate: LeaderboardAdapterProtocol? = nil, campaignWrapper: CampaignWrapper?) {
        self.delegate = delegate
        self.campaignWrapper = campaignWrapper
    }
    
    func setPaymentMethod( method : CampaignWrapper?){
        self.campaignWrapper = method
    }
    func setUserRank(_ rank : UserStreaming){
        self.userRank = rank
    }
    func setAllUserRank(_ ranks : [UserStreaming]){
        guard ranks.count > 3 else{
            top3Rank = nil
            return
        }
        top3Rank = Array(ranks.prefix(3))
        allUserRank = Array(ranks.suffix(from: 3))
    }
    
    func setPrize(prize : Prize) {
        self.prize = prize
    }
}

extension LeaderBoardAdapter : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0:
            return campaignWrapper == nil ? 0 : 1
        case 1:
            return top3Rank == nil ? 0 : 1
        case 2:
            return USERSTREAMING == nil ? 0 : 1
        case 3:
            return (allUserRank?.count ?? 0) > 0 ? (allUserRank?.count ?? 0) : 0
        case 4:
            return 1
        case 5, 6:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopPlayerCell.identifier, for: indexPath) as? TopPlayerCell else {
                fatalError()
            }
            if let campgign = campaignWrapper?.campaign {
                cell.bind(with: campgign)
            }
            cell.onCampaign = { campaign in
                self.campaignID = campaign.id ?? 0
            }
            return cell
        }
        
        else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Top3RankCell.identifier, for: indexPath) as? Top3RankCell else {
                fatalError()
            }
            if let rank = self.campaignWrapper?.userStreamings {
                cell.bind(with: rank)
                return cell
            }
        }
        
        else if indexPath.section == 2 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyRankCell.identifier, for: indexPath) as? MyRankCell else {
                fatalError()
            }
            if let userData = USERSTREAMING {
                cell.bind(with: userData)
                return cell
            }
        }
        
        else if indexPath.section == 3 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RankCell.identifier, for: indexPath) as?  RankCell else {
                fatalError()
            }
            if let allUserRank = self.allUserRank {
                let obj = allUserRank[indexPath.row]
                cell.bind(with: obj)
                return cell
            }
        }
        
        else if indexPath.section == 4 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrizeCell.identifier, for: indexPath) as? PrizeCell else{
                fatalError()
            }
            cell.bind(with : self.prize)
            return cell
        }
        
        else if indexPath.section == 5  {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CampaignDetailsCell.identifier, for: indexPath) as? CampaignDetailsCell else{
                fatalError()
            }
            cell.titleLabel.text = "Terms & Conditions"
            return cell
        }
        
        else if indexPath.section == 6 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CampaignDetailsCell.identifier, for: indexPath) as? CampaignDetailsCell else{
                fatalError()
            }
            cell.titleLabel.text = "Frequently Asked Questions"
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .zero
        } else if section == 3, self.allUserRank == nil {
            return .init(top: 0, left: 0, bottom: 0, right: 0)
        } else if section == 4 {
            return .init(top: 16, left: 0, bottom: 0, right: 0)
        } else if section == 5 || section == 6 {
            return .init(top: 10, left: 0, bottom: 5, right: 0)
        } else {
            return .init(top: 14, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width
        if indexPath.section == 0 {
            return .init(width: w - 32, height: TopPlayerCell.height)
        }
        else if indexPath.section ==  1 {
            return .init(width: w - 16, height: Top3RankCell.height)
        }
        
        else if indexPath.section == 2 {
            return .init(width: w - 32, height: MyRankCell.height)
        }
        else if indexPath.section ==  3 {
            var offset : CGFloat = 0
            if let _ = userRank?.bonsuStreaming, let _ = userRank?.totalStreaming{
                offset = 0
            } else {
                offset = 20
            }
            if campaignID == 3 {
                offset = 30
            }
            return .init(width: w - 32, height: MyRankCell.height - offset)
        }
        else if indexPath.section == 4 {
            return .init(width: w - 32, height: 120)
        }else if indexPath.section == 5 {
            return .init(width: w - 32, height: RankCell.HEIGHT)
        }else if indexPath.section == 6 {
            return .init(width: w - 32, height: RankCell.HEIGHT)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return  8
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Header.identifier, for: indexPath) as? Header else {
                fatalError()
            }
            
            if indexPath.section == 2, USERSTREAMING != nil {
                header.ttitleLabel.text = "My Rank"
                header.ttitleLabel.textColor = .darkGray
            } else if indexPath.section == 3,  self.allUserRank != nil {
                header.ttitleLabel.text = "Today's Winner"
                header.ttitleLabel.textColor = .darkGray
            } else if indexPath.section == 4, prize != nil {
                header.ttitleLabel.text = "Prizes for Winners"
                header.ttitleLabel.textColor = .darkGray
            } else if indexPath.section == 5 {
                header.ttitleLabel.text = "Terms & Conditions"
                header.ttitleLabel.textColor = .darkGray
            } else {
                header.ttitleLabel.text = ""
            }

            return header
        }
        
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 2, USERSTREAMING != nil {
            return .init(width: collectionView.bounds.width - 32, height: 50)
        } else if section == 3, self.allUserRank != nil  {
            return .init(width: collectionView.bounds.width - 32, height: 50)
        } else if section == 5 {
            return .init(width: collectionView.bounds.width - 32, height: 50)
        } else if section == 4, prize != nil {
            return .init(width: collectionView.bounds.width - 32, height: 50)
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 5 {
            self.delegate?.onTermsAndConditionPressed(url: campaignWrapper?.campaign.tnCUrl ?? "")
        } else if indexPath.section == 6 {
            self.delegate?.onTermsAndConditionPressed(url: campaignWrapper?.campaign.faqUrl ?? "")
        }
    }
}

