//
//  FAQAnswerVC.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 5/11/25.
//

import UIKit

struct FAQSelectedData {
    var isSelectedLastID: Int
    var isLiked: Bool
    var isDisLiked: Bool
}

// MARK: - Shared Helper to Store State
class FAQSelectedHelper {
    static let shared = FAQSelectedHelper()
    private init() {}
    
    var faqSelecedLastArray: [FAQSelectedData] = []
    
    func updateSelection(for id: Int, isLiked: Bool, isDisLiked: Bool) {
        if let index = faqSelecedLastArray.firstIndex(where: { $0.isSelectedLastID == id }) {
            if !isLiked && !isDisLiked {
                faqSelecedLastArray.remove(at: index)
            } else {
                faqSelecedLastArray[index].isLiked = isLiked
                faqSelecedLastArray[index].isDisLiked = isDisLiked
            }
        } else {
            if isLiked || isDisLiked {
                faqSelecedLastArray.append(FAQSelectedData(isSelectedLastID: id, isLiked: isLiked, isDisLiked: isDisLiked))
            }
        }
    }
    
    func getSelection(for id: Int) -> FAQSelectedData? {
        return faqSelecedLastArray.first(where: { $0.isSelectedLastID == id })
    }
}


class FAQAnswerVC: UIViewController, NIBVCProtocol {

    // MARK: --- Outlet ---
    @IBOutlet weak var navTitleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var liekedBtn: UIButton!
    @IBOutlet weak var disLikedBtn: UIButton!
    @IBOutlet weak var likedBgView: UIView!
    @IBOutlet weak var likedImg: UIImageView!
    @IBOutlet weak var likedLabel: UILabel!
    @IBOutlet weak var disLikedBgView: UIView!
    @IBOutlet weak var disLikedImg: UIImageView!
    @IBOutlet weak var disLikedLabel: UILabel!
    @IBOutlet weak var helpfulLabel: UILabel!
    @IBOutlet weak var feedBackBgView: UIView!
    
    // MARK: --- Properties ---
    var navTitle: String = ""
    var faqAnswerData : FAQAnswerData?
    var selectedID = Int()
    private var imageHeight: CGFloat?
    private var isLiked = false
    private var isDisLiked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLikedDisLikedUI()
        self.getFAQAnswer(id: selectedID)
        self.setupTableView()
    }
    
    // MARK: --- Actions ---
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func likedBtnAction(_ sender: UIButton) {
        self.isLiked.toggle()
        self.clickLikedBtn()
        FAQSelectedHelper.shared.updateSelection(for: self.faqAnswerData?.faqAnsId ?? 0, isLiked: self.isLiked, isDisLiked: self.isDisLiked)
        self.sendLikedFAQFeedbackApiCall()
    }
    
    @IBAction func disLikedBtnAction(_ sender: UIButton) {
        self.isDisLiked.toggle()
        self.clickDisLikedBtn()
        FAQSelectedHelper.shared.updateSelection(for: self.faqAnswerData?.faqAnsId ?? 0, isLiked: self.isLiked, isDisLiked: self.isDisLiked)
        self.sendDisLikedFAQFeedbackApiCall()
    }
}


// MARK: --- Private Methods ---
extension FAQAnswerVC {
        
    private func setupLikedDisLikedUI() {
        self.likedBgView.layer.cornerRadius = self.likedBgView.bounds.height/2
        self.disLikedBgView.layer.cornerRadius = self.disLikedBgView.bounds.height/2
        self.disLikedBgView.clipsToBounds = true
        self.likedBgView.clipsToBounds = true
        self.feedBackBgView.isHidden = true
        self.likedImg.tintColor = .label
        self.disLikedImg.tintColor = .label
        self.likedBgView.backgroundColor = .mostPopularBg
        self.disLikedBgView.backgroundColor = .mostPopularBg
        self.likedBgView.borderColor = UIColor.label
        self.likedBgView.borderWidth = 0.8
        self.disLikedBgView.borderColor = UIColor.label
        self.disLikedBgView.borderWidth = 0.8
        self.helpfulLabel.startLabelMarquee(text: ShadhinCore.instance.isBangla ? "এটি কি আপনার জন্য সহায়ক?" : "Is this helpful to you?")
        self.likedLabel.text = ShadhinCore.instance.isBangla ? "হ্যাঁ" : "Yes"
        self.disLikedLabel.text = ShadhinCore.instance.isBangla ? "না" : "No"
    }
    
    private func initCheck() {
        guard let id = self.faqAnswerData?.faqAnsId else { return }
        
        if let previousSelection = FAQSelectedHelper.shared.getSelection(for: id) {
            self.isLiked = previousSelection.isLiked
            self.isDisLiked = previousSelection.isDisLiked
            
            if isLiked {
                clickLikedBtn()
            } else if isDisLiked {
                clickDisLikedBtn()
            } else {
                clickNeutral()
            }
        } else {
            clickNeutral()
        }
    }
    
    private func clickNeutral() {
        self.likedImg.tintColor = .label
        self.likedLabel.textColor = .label
        self.likedBgView.backgroundColor = .mostPopularBg
        self.disLikedImg.tintColor = .label
        self.disLikedLabel.textColor = .label
        self.disLikedBgView.backgroundColor = .mostPopularBg
    }

    private func sendDisLikedFAQFeedbackApiCall() {
        ShadhinCore.instance.api.sendDisLikedFAQFeedback(faqAnsId: faqAnswerData?.faqAnsId ?? 0, isDisLiked: self.isDisLiked) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Response: \(response)")
                case .failure(let error):
                    print("❌ Error sending feedback:", error.localizedDescription)
                    self.view.makeToast(error.localizedDescription)
                }
            }
        }
    }
    
    private func sendLikedFAQFeedbackApiCall() {
        ShadhinCore.instance.api.sendLikedFAQFeedback(faqAnsId: faqAnswerData?.faqAnsId ?? 0, isLiked: self.isLiked) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Response: \(response)")
                case .failure(let error):
                    print("❌ Error sending feedback:", error.localizedDescription)
                    self.view.makeToast(error.localizedDescription)
                }
            }
        }
    }
    
    private func clickLikedBtn() {
        self.likedImg.tintColor = self.isLiked ? .white : .label
        self.likedLabel.textColor = self.isLiked ? .white : .label
        self.likedBgView.backgroundColor = self.isLiked ? #colorLiteral(red: 0.2901960784, green: 0.7294117647, blue: 0.568627451, alpha: 1) : .mostPopularBg

        self.disLikedLabel.textColor = .label
        self.disLikedImg.tintColor = .label
        self.disLikedBgView.backgroundColor = .mostPopularBg
        self.isDisLiked = false
    }
    
    private func clickDisLikedBtn() {
        self.disLikedImg.tintColor = self.isDisLiked ? .white : .label
        self.disLikedLabel.textColor = self.isDisLiked ? .white : .label
        self.disLikedBgView.backgroundColor = self.isDisLiked ? #colorLiteral(red: 0.9997431636, green: 0.1923860908, blue: 0.1920928061, alpha: 1) : .mostPopularBg
        
        self.likedImg.tintColor = .label
        self.likedLabel.textColor = .label
        self.likedBgView.backgroundColor = .mostPopularBg
        self.isLiked = false
    }
    
    private func setupTableView() {
        self.navTitleLbl.startLabelMarquee(text: navTitle)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(FAQAnswerTVCell.nib, forCellReuseIdentifier: FAQAnswerTVCell.identifier)
        self.tableView.register(FAQAnswerScrollTVCell.nib, forCellReuseIdentifier: FAQAnswerScrollTVCell.identifier)
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 90, right: 0)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
    }

    private func getFAQAnswer(id: Int) {
        ShadhinCore.instance.api.getAnswerFAQDataByID(id: id) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if let data = result.success?.data {
                    self.faqAnswerData = data
                    self.initCheck()

                    if let imageUrl = data.imageUrl, let url = URL(string: imageUrl) {
                        self.calculateImageHeight(from: url) { height in
                            DispatchQueue.main.async {
                                self.imageHeight = height
                                self.tableView.reloadData()
                                self.feedBackBgView.isHidden = false
                                self.loader.stopAnimating()
                            }
                        }
                    } else {
                        self.tableView.reloadData()
                        self.feedBackBgView.isHidden = false
                        self.loader.stopAnimating()
                    }
                } else {
                    self.loader.stopAnimating()
                    //self.view.makeToast("\(result.failure, default: "")")
                }
            }
        }
    }

    private func calculateImageHeight(from url: URL, completion: @escaping (CGFloat) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {

                let ratio = image.size.height / image.size.width
                let screenWidth = UIScreen.main.bounds.width
                let height = screenWidth * ratio

                completion(height)
            } else {
                completion(400)
            }
        }
    }
}


// MARK: --- TableView Delete Methods ---
extension FAQAnswerVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.faqAnswerData {
            return self.dataCount(data: data)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = self.faqAnswerData {
            if let urlString = data.imageUrl, let url = URL(string: urlString) {
                if isVideoURL(url) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: FAQAnswerTVCell.identifier, for: indexPath) as! FAQAnswerTVCell
                    cell.dataBindCell(data)
                    return cell

                } else {
                    if indexPath.row == 0 {
                        let cell = tableView.dequeueReusableCell(withIdentifier: FAQAnswerScrollTVCell.identifier, for: indexPath) as! FAQAnswerScrollTVCell
                        cell.dataBindCell(data)
                        return cell

                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: FAQAnswerTVCell.identifier, for: indexPath) as! FAQAnswerTVCell
                        cell.dataBindCell(data)
                        return cell
                    }
                }
            }
            
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: FAQAnswerTVCell.identifier, for: indexPath) as! FAQAnswerTVCell
                cell.dataBindCell(data)
                return cell
            }
        }
        
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if let urlString = faqAnswerData?.imageUrl, let url = URL(string: urlString) {
            if !isVideoURL(url) {
                if indexPath.row == 0 {
                    return imageHeight ?? 400
                }
                return UITableView.automaticDimension
            }
            return UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }

    private func dataCount(data: FAQAnswerData) -> Int {
        if let urlString = data.imageUrl, let url = URL(string: urlString) {
            if !isVideoURL(url) {
                return 2
            }
            return 1
        } else {
            return 1
        }
    }
}


