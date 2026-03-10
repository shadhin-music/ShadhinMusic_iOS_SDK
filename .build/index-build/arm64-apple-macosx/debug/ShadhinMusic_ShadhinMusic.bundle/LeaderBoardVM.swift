//
//  LeaderBoardVM.swift
//  Shadhin_BL
//
//  Created by Joy on 11/1/23.
//

import UIKit

protocol LeaderBoardVMProtocol : NSObjectProtocol{
    func userRank(_ rank : UserStreaming)
    func allUserRank(_ ranks : [UserStreaming])
    func prizeNconditions(prizes : Prize)
    func errorResult(_ error : String)
}
