//
//  PurchasedTicketVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PurchasedTicketVC: UIViewController {
    
    
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var data: PurchasedTicketObj?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PurchasedTicketTC.nib, forCellReuseIdentifier: PurchasedTicketTC.identifier)
        tableView.dataSource = self
        //getData()
    }
    func getData(){
        self.view.lock()
        ShadhinCore.instance.api.getPurchasedTicket { data, err in
            self.data = data
            self.view.unlock()
            self.tableView.reloadData()
        }
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PurchasedTicketVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: PurchasedTicketTC.identifier, for: indexPath) as! PurchasedTicketTC
        if let data = data?.data[indexPath.row]{
            cell.bind(data: data)
        }
        return cell
    }
    
}
