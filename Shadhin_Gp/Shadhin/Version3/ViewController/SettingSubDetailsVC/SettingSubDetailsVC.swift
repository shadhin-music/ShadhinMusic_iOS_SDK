//
//  SettingSubDetailsVC.swift
//  Shadhin_Gp
//
//  Created by MD Murad Hossain  on 5/11/25.
//

import UIKit

class SettingSubDetailsVC: UIViewController, NIBVCProtocol {
    
    @IBOutlet weak var navTitleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var helpCenterSubData = [FAQSubCategory]()
    var titleText: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()

    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingSubDetailsVC {
    
    private func setupTableView() {
        self.navTitleLbl.startLabelMarquee(text: self.titleText)
        self.helpCenterSubData.sort { $0.sort < $1.sort }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(SettingSubDetailsTVCell.nib, forCellReuseIdentifier: SettingSubDetailsTVCell.identifier)
        self.tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 15, right: 0)
        self.tableView.reloadData()
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
    }
}

extension SettingSubDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpCenterSubData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingSubDetailsTVCell.identifier, for: indexPath) as! SettingSubDetailsTVCell
        let data = helpCenterSubData[indexPath.row]
        cell.dataBindCell(data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = FAQAnswerVC.instantiateNib()
        let data = helpCenterSubData[indexPath.row]
        vc.selectedID = data.id
        vc.navTitle = ShadhinCore.instance.isBangla ? data.titleBn : data.titleEn
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
