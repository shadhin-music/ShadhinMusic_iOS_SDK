//
//  ConcertTicketsMainVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/25/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class ConcertTicketsMainVC: UIViewController {
    
    @IBOutlet weak var mainImageBg: UIImageView!
    @IBOutlet weak var mainImage: CircularImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var addressDetails: UILabel!
    @IBOutlet var artistImgs: [CircularImageView]!
    @IBOutlet weak var artistCountLbl: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var subscriptionLbl: UILabel!
    @IBOutlet weak var buySubscriptionBtn: UIButton!
    @IBOutlet weak var buyTicketBtn: UIButton!
    @IBOutlet weak var purchasedHolder: UIView!
    @IBOutlet weak var faqHolder: UIView!
    @IBOutlet weak var faqDetailsLbl: UILabel!
    @IBOutlet weak var termsAndConditionHolder: UIView!
    @IBOutlet weak var tncDetailsLbl: UILabel!
    
    var concertEventObj: ConcertEventObj!
    var purchasedTicketObj: PurchasedTicketObj?{
        didSet{
            if purchasedTicketObj?.data.count ?? 0 > 0{
                purchasedHolder.isHidden = false
                self.view.layoutIfNeeded()
            }else{
                purchasedHolder.isHidden = true
            }
        }
    }
    
    var gatewayPageURL: String?
    var purchaseCode: String?
    var paymentMethod: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "RadioCell", bundle:Bundle.ShadhinMusicSdk), forCellWithReuseIdentifier: "RadioCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        bind()
        getPurchasedTickets()
    }
    
    func getPurchasedTickets(_ willRedirect: Bool = false){
        self.view.lock()
        ShadhinCore.instance.api.getPurchasedTicket { data, err in
            self.purchasedTicketObj = data
            self.view.unlock()
        }
        if willRedirect{
            openPurchasedTickets()
        }
    }
    
    func bind(){
        let imgUrl = concertEventObj.data.banner
        mainImage.kf.indicatorType = .activity
        mainImageBg.kf.setImage(with: URL(string: imgUrl.safeUrl()))
        mainImage.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_playlist",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        mainTitle.text          = concertEventObj.data.name
        eventDate.text          = concertEventObj.data.campaignDate
        eventTime.text          = concertEventObj.data.campaignTime
        address.text            = concertEventObj.data.address
        addressDetails.text     = concertEventObj.data.addressDetails
        eventDescription.text   = concertEventObj.data.dataDescription
        faqDetailsLbl.text      = concertEventObj.data.faq
        tncDetailsLbl.text      = concertEventObj.data.terms
        for i in 0...5{
            if i < concertEventObj.data.artist.count{
                let artist = concertEventObj.data.artist[i]
                artistImgs[i].isHidden = false
                let aImgUrl = artist.image.replacingOccurrences(of: "<$size$>", with: "300")
                artistImgs[i].kf.setImage(with: URL(string: aImgUrl.safeUrl()))
            }else{
                artistImgs[i].isHidden = true
            }
        }
        if concertEventObj.data.artist.count > 6{
            artistCountLbl.isHidden = false
            artistCountLbl.text = "\(concertEventObj.data.artist.count-6)+ Artists"
        }else{
            artistCountLbl.isHidden = true
        }
        if ShadhinCore.instance.isUserPro{
            subscriptionLbl.text = "Subscription Plan"
            buySubscriptionBtn.setTitle("ACTIVE", for: .normal)
            buySubscriptionBtn.backgroundColor = .lightGray
            buySubscriptionBtn.isEnabled = false
        }else{
            buySubscriptionBtn.setClickListener {
                self.goSubscriptionTypeVC()
            }
        }
        buyTicketBtn.setClickListener {
            ConcertTicketsPurchaseVC.show(self)
        }
        faqHolder.setClickListener {
            if self.faqHolder.tag == 0{
                self.faqHolder.tag = 1
                UIView.transition(with: self.faqDetailsLbl, duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.faqDetailsLbl.isHidden = false
                })
            }else{
                self.faqHolder.tag = 0
                UIView.transition(with: self.faqDetailsLbl, duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.faqDetailsLbl.isHidden = true
                })
            }
        }
        termsAndConditionHolder.setClickListener {
            if self.termsAndConditionHolder.tag == 0{
                self.termsAndConditionHolder.tag = 1
                UIView.transition(with: self.tncDetailsLbl, duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.tncDetailsLbl.isHidden = false
                })
            }else{
                self.termsAndConditionHolder.tag = 0
                UIView.transition(with: self.tncDetailsLbl, duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.tncDetailsLbl.isHidden = true
                })
            }
        }
        purchasedHolder.setClickListener {
            self.openPurchasedTickets()
        }
    }
    
    func openPurchasedTickets(){
        let vc = PurchasedTicketVC()
        vc.data = self.purchasedTicketObj
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func proceedToPayment(
        gatewayPageURL: String,
        purchaseCode: String,
        paymentMethod: Int){
            self.gatewayPageURL = gatewayPageURL
            self.purchaseCode = purchaseCode
            self.paymentMethod = paymentMethod
            let storyBoard = UIStoryboard(name: "Payment", bundle:Bundle.ShadhinMusicSdk)
            let vc = storyBoard.instantiateViewController(withIdentifier: "BkashPaymentVC") as! BkashPaymentVC
            vc.subscriptionUrl = gatewayPageURL
            vc.secondaryCloseHandler = {
                self.checkForSuccess()
            }
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkForSuccess(){
        guard let purchaseCode = self.purchaseCode,
              let paymentMethod = self.paymentMethod else {return}
        self.view.lock()
        self.purchaseCode = nil
        ShadhinCore.instance.api.checkTicketPurchase(
            purchaseCode: purchaseCode,
            paymentMethod: paymentMethod) { success in
            self.view.unlock()
            if success{
                self.getPurchasedTickets(true)
            }
        }
    }
    
    
}

extension ConcertTicketsMainVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return concertEventObj.data.artist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RadioCell", for: indexPath) as! RadioCell
        cell.mainView.backgroundColor = .clear
        let imgUrl = concertEventObj.data.artist[indexPath.row].image.replacingOccurrences(of: "<$size$>", with: "300")
        cell.radioImgView.kf.indicatorType = .activity
        cell.radioImgView.kf.setImage(with: URL(string: imgUrl.safeUrl()),placeholder: UIImage(named: "default_radio",in: Bundle.ShadhinMusicSdk,compatibleWith: nil))
        cell.radioTitleLbl.text = concertEventObj.data.artist[indexPath.row].artistName
        cell.radioTitleLbl.textColor = .primaryLableColor()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 112, height: 160)
    }
}
