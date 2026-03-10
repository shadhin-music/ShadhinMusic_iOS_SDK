//
//  PopUpUtil.swift
//  Shadhin_Gp
//
//  Created by Maruf on 9/6/24.
//

import Foundation

class PopUpUtil{
    
    var contents = [PopUpObj.Content]()
    weak var vc: UIViewController?
    weak var discoverVC : HomeVCv3?
    
    func handelePopUpTasks(_ vc: UIViewController, _ discoverVC: HomeVCv3){
        self.vc = vc
        self.discoverVC = discoverVC
        ShadhinCore.instance.api.getPopUpData {
            data, error in
            guard let popUpDto = data else {return}
            self.setFilterArray(items: popUpDto.content)
        }
        
    }
    
    func setFilterArray(items : [PopUpObj.Content]){
        let filterParam = getFilterParameter()
        contents = items.filter{$0.createDate == filterParam}
        guard !contents.isEmpty else {return}
        showPopUp()
    }
    
    func showPopUp(){
        let item = getFilteredItem()
        OpenAppPopupVC.show(self.vc, self.discoverVC, item)
    }
    
    func getFilteredItem()->PopUpObj.Content{
        var array = contents
        var ids = ShadhinCore.instance.defaults.popUpShownIds
        for id in ids{
            array = array.filter{$0.contentID != id}
        }
        if array.count == 0{
            array = contents
            ids.removeAll()
        }
        let item = array[0]
        if let id =  item.contentID{
            ids.append(id)
        }
        ShadhinCore.instance.defaults.popUpShownIds = ids
        return item
    }
    
    func getFilterParameter()-> String{
        switch ShadhinCore.instance.defaults.shadhinUserType{
        case .FreeNotSignedIn:
            return "NeverPro"
        case .FreeNeverPro:
            return "NeverPro"
        case .FreeOncePro:
            return "OncePro"
        case .Pro:
            return "Pro"
        }
    }
    
}
