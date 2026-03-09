//
//  HelpCenterCVCell2.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 19/10/25.
//

import UIKit

protocol HelpCenterCVCell2Delegate: AnyObject {
    func helpCenterCell2DidUpdateHeight(_ cell: HelpCenterCVCell2, itemCount: Int)
    func didSelectHelpCenterData(_ data: [FAQSubCategory], navTitle: String)
}

class HelpCenterCVCell2: UICollectionViewCell {
    
    @IBOutlet weak var btnBgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var englishBtn: UIButton!
    @IBOutlet weak var banglaBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }

    // MARK: - Properties
    var helpCenterData: [FAQMainCategory] = []
    var helpCenterSubData: [[FAQSubCategory]] = [[]]
    weak var delegate: HelpCenterCVCell2Delegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup UI
        self.btnBgView.layer.cornerRadius = 12
        self.englishBtn.layer.cornerRadius = self.englishBtn.bounds.height / 2
        self.banglaBtn.layer.cornerRadius = self.banglaBtn.bounds.height / 2
        
        // Setup collectionView
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(HelpCenterMoreItemCV.nib, forCellWithReuseIdentifier: HelpCenterMoreItemCV.identifier)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            getFAQData()
        }
    }

    // MARK: - API Call
    private func getFAQData() {
        ShadhinCore.instance.api.getHelpCenterFAQData { result in
            if let data = result.success {
                self.helpCenterData = data.data.map { $0.l0 }
                self.helpCenterData.sort { $0.sort < $1.sort }
                self.helpCenterSubData = data.data.map { $0.l1 }

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.updateLanguageBtnUI()
                    self.delegate?.helpCenterCell2DidUpdateHeight(self, itemCount: self.helpCenterData.count)
                }
            } else {
                self.makeToast("\(result.failure, default: "")")
            }
        }
    }

    // MARK: - Actions
    @IBAction func egnlishBtnAction(_ sender: UIButton) {
        ShadhinCore.instance.isBangla = false
        updateLanguageBtnUI()
        collectionView.reloadData()
    }
    
    @IBAction func banglaBtnAction(_ sender: UIButton) {
        ShadhinCore.instance.isBangla = true
        updateLanguageBtnUI()
        collectionView.reloadData()
    }

    // MARK: - UI Updates
    private func updateLanguageBtnUI() {
        if ShadhinCore.instance.isBangla {
            englishBtn.backgroundColor = .white
            englishBtn.borderColor = UIColor.black.withAlphaComponent(0.12)
            englishBtn.borderWidth = 1
            englishBtn.setTitleColor(.black, for: .normal)

            banglaBtn.backgroundColor = .tintColor
            banglaBtn.setTitleColor(.white, for: .normal)
        }
        
        else {
            banglaBtn.backgroundColor = .white
            banglaBtn.borderColor = UIColor.black.withAlphaComponent(0.12)
            banglaBtn.borderWidth = 1
            banglaBtn.setTitleColor(.black, for: .normal)

            englishBtn.backgroundColor = .tintColor
            englishBtn.setTitleColor(.white, for: .normal)
        }
    }
}


// MARK: - UICollectionView Delegate + DataSource
extension HelpCenterCVCell2: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return helpCenterData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HelpCenterMoreItemCV.identifier, for: indexPath) as! HelpCenterMoreItemCV
        cell.dataBindCell(data: helpCenterData[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.helpCenterData[indexPath.row]
        let index = item.sort
        let navTitle = ShadhinCore.instance.isBangla ? item.titleBn : item.titleEn
        self.delegate?.didSelectHelpCenterData(self.helpCenterSubData[index], navTitle: navTitle)
    }
}


// MARK: - UICollectionView DelegateFlowLayout
extension HelpCenterCVCell2: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
