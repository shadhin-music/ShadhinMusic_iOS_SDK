//
//  NibLoadable.swift
//  Shadhin
//
//  Created by Joy on 16/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
protocol NibLoadable{
    static var identifier : String {get}
    static var nib : UINib {get}
}
extension NibLoadable where Self : UIView{
    static var identifier : String{
        return String(describing: Self.self)
    }
    static var nib : UINib{
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: identifier, bundle: Bundle.ShadhinMusicSdk)
    }
}
