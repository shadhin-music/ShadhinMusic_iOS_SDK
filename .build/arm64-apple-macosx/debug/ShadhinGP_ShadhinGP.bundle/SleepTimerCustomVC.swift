//
//  SleepTimerCustomVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/21/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit


class SleepTimerCustomVC: UIViewController,NIBVCProtocol {
    
    static func show(){
        let vc = SleepTimerCustomVC.instantiateNib()
        var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 0)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        attribute.positionConstraints.size = .init(width: .fill, height: .constant(value: 352))
        SwiftEntryKit.display(entry: vc, using: attribute)
    }
    
    
    @IBOutlet weak var endTimeLbl: UILabel!
    var minutesToSleep = 1
    let dateFormatter = DateFormatter()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "h:mm a"
        endTimeLbl.text = "The timer will end at \(dateFormatter.string(from: Date().addingTimeInterval(60)))"
    }

    @IBAction func timeUpdated(_ sender: UIDatePicker) {
        let seconds = sender.countDownDuration
        minutesToSleep = Int(seconds/60)
        endTimeLbl.text = "The timer will end at \(dateFormatter.string(from: Date().addingTimeInterval(seconds)))"
    }
    
    @IBAction func startTime(_ sender: Any) {
        ShadhinPlayerSleepTimer.instance.initTimer(state: .custom(minutesToSleep))
        SwiftEntryKit.dismiss()
    }
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = (totalSeconds % 3600) % 60
        let minutes: Int = (totalSeconds % 3600) / 60
        let hours  : Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
