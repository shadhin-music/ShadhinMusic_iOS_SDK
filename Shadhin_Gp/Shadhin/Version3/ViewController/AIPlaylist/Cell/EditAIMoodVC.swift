//
//  EditAIMoodVC.swift
//  Shadhin
//
//  Created by MD Murad Hossain  on 21/5/24.
//  Copyright © 2024 Cloud 7 Limited. All rights reserved.
//

import UIKit

class EditAIMoodVC: UIViewController,NIBVCProtocol {

    @IBOutlet weak var aiLbl: UILabel!
    @IBOutlet weak var feelingLbl: UILabel!
    @IBOutlet weak var editMoodBgView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var showGenerateButton = false
    var aiMoods = [MoodCategory]()
    var vc: HomeAdapterProtocol?
    var isDark = false
    override func viewDidLoad() {
        super.viewDidLoad()
        isDark = traitCollection.userInterfaceStyle == .dark
        editMoodBgView.layer.backgroundColor = UIColor(named: "procressViewBgColor",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)?.cgColor
      //  editMoodBgView.backgroundColor = UIColor.black
        if traitCollection.userInterfaceStyle == .dark {
            feelingLbl.textColor = UIColor.white
            aiLbl.textColor = UIColor.gray
        } else {
            feelingLbl.textColor = UIColor.black
            aiLbl.textColor = UIColor.gray
        }
       
        getMoods()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EditAIMoodCell.nib, forCellWithReuseIdentifier: EditAIMoodCell.identifier)
    }
    private func getMoods(){
        ShadhinApi.getAIMoods {[weak self] moodResponse in
            guard let self = self else {return}
            switch moodResponse {
            case .success(let success):
                self.aiMoods = success.data
                self.collectionView.reloadData()
            case .failure(_): break
               // Toast.show(message: "Sometheing is wrong!", inView:self.view)
            }
        }
    }

}

extension EditAIMoodVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        aiMoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditAIMoodCell.identifier, for: indexPath) as! EditAIMoodCell
        cell.selectedMoodId = String(aiMoods[indexPath.item].id)
        cell.vc = vc
        cell.bind(data: aiMoods[indexPath.item], indexPath: indexPath)
        if isDark {
            cell.moodLbl.textColor = .white
           // cell.layer.backgroundColor = UIColor.gray.cgColor
        } else {
            cell.moodLbl.textColor = .black
           // cell.layer.backgroundColor = UIColor.black.cgColor
        }
        cell.isDark = isDark
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        EditAIMoodCell.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
