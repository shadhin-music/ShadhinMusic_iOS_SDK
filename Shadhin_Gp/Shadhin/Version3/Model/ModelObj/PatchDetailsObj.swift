//
//  CategoriesByDataModel.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/10/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation



struct PatchDetailsObj: Codable {
    var _sort: Float?
    var name: String?
    var code: String?
    var design: String?
    var data0 : [CommonContent_V0]?
    var data1 : [CommonContent_V0]?
    
    var sort : String{
        get{
            return "\((_sort) ?? 0)"
        }
        set{
            _sort = Float(newValue)!
        }
    }
    
    var data : [CommonContent_V0]{
        get{
            if self.data0 != nil{
                return self.data0!
            }else if self.data0 == nil && self.data1 != nil{
                return self.data1!
            }else{
                return []
            }
        }
        set{
            self.data0 = newValue
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case _sort = "Sort"
        case name = "Name"
        case code = "Code"
        case design = "Design"
        case data0 = "Data"
        case data1 = "data"
    }
}

