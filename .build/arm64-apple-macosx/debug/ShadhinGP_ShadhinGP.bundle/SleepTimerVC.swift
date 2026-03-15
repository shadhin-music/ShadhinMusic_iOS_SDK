//
//  SleepTimerVC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/20/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit


class SleepTimerVC: UIViewController,NIBVCProtocol {
    
    static func show(){
        let vc = SleepTimerVC.instantiateNib()
        var attribute = SwiftEntryKitAttributes.bottomAlertWrapAttributesRound(offsetValue: 0)
        attribute.entryBackground = .color(color: .clear)
        attribute.border = .none
        attribute.positionConstraints.size.width = .fill
        SwiftEntryKit.display(entry: vc, using: attribute)
    }
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet var selectionHolders: [UIView]!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var isTimerActive = false{
        didSet{
            self.timerActive(value: isTimerActive)
        }
    }
    var selectedState: ShadhinPlayerSleepTimer.State = .off
    var timer: Timer?
    var secondsLeft: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectionHolders[0].setClickListener {
            self.selectedState = .tenMinutes
            self.selectedOption(index: 0, stopAfterMinutes: 10)
        }
        selectionHolders[1].setClickListener {
            self.selectedState = .twentyMinutes
            self.selectedOption(index: 1, stopAfterMinutes: 20)
        }
        selectionHolders[2].setClickListener {
            self.selectedState = .thirtyMinutes
            self.selectedOption(index: 2, stopAfterMinutes: 30)
        }
        selectionHolders[3].setClickListener {
            self.selectedState = .sixtyMinutes
            self.selectedOption(index: 3, stopAfterMinutes: 60)
        }
        selectionHolders[4].setClickListener {
            //print("open custom")
            //self.selectedState = .custom(1)
            self.openCustom()
        }
        if case .off = ShadhinPlayerSleepTimer.instance.currentState{
            //ignore
        }else{
            isTimerActive = true
        }
    }
    
    func openCustom(){
        SwiftEntryKit.dismiss(){
            SleepTimerCustomVC.show()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    @IBAction func confirmBtnTapped(_ sender: Any) {
        if isTimerActive{
            timer?.invalidate()
            selectedState = .off
            isTimerActive = false
            ShadhinPlayerSleepTimer.instance.initTimer(state: .off)
            SwiftEntryKit.dismiss()
        }else{
            if case .off = selectedState{
                //ignore
            }else{
                isTimerActive = true
                ShadhinPlayerSleepTimer.instance.initTimer(state: selectedState)
                SwiftEntryKit.dismiss()
            }
            
        }
       
    }

    func selectedOption(index: Int, willOverRide: Bool = true, stopAfterMinutes: Int = 0){
        for i in 0...4{
            if i == index{
                selectionHolders[i].borderWidth = 1
                (selectionHolders[i].viewWithTag(1) as! UILabel).textColor = .primaryLableColor()
                selectionHolders[i].viewWithTag(2)?.isHidden = false
            }else{
                selectionHolders[i].borderWidth = 0
                (selectionHolders[i].viewWithTag(1) as! UILabel).textColor = .secondaryLabelColor()
                selectionHolders[i].viewWithTag(2)?.isHidden = true
            }
        }
        if willOverRide{
            isTimerActive = false
            timer?.invalidate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            timeLbl.text = "The timer will end at \(dateFormatter.string(from: Date().addingTimeInterval(TimeInterval(stopAfterMinutes * 60))))"
        }
    }
    
    func timerActive(value: Bool){
        if value{
            setActiveTimerCountDown()
        }else{
            setToBeActivcTimer()
        }
    }
    
    func setActiveTimerCountDown(){
        confirmBtn.setTitle("Stop timer", for: .normal)
        confirmBtn.setTitleColor(.primaryLableColor(), for: .normal)
        confirmBtn.borderColor = .primaryLableColor()
        switch ShadhinPlayerSleepTimer.instance.currentState{
        case .off:
            break
        case .tenMinutes:
            selectedOption(index: 0, willOverRide: false)
        case .twentyMinutes:
            selectedOption(index: 1, willOverRide: false)
        case .thirtyMinutes:
            selectedOption(index: 2, willOverRide: false)
        case .sixtyMinutes:
            selectedOption(index: 3, willOverRide: false)
        case .custom(_):
            selectedOption(index: 4, willOverRide: false)
        }
        guard let endTime = ShadhinPlayerSleepTimer.instance.timeToStop else {return}
        secondsLeft = Int(endTime.timeIntervalSince1970 - Date().timeIntervalSince1970)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeRemaining), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimeRemaining(){
        guard secondsLeft > 0 else{
            timer?.invalidate()
            selectedOption(index: -1)
            return
        }
        timeLbl.text = "Time left to stop \(timeFormatted(secondsLeft))"
        secondsLeft -= 1
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = (totalSeconds % 3600) % 60
        let minutes: Int = (totalSeconds % 3600) / 60
        let hours  : Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func setToBeActivcTimer(){
        switch selectedState{
        case .off:
            confirmBtn.setTitle("Start timer", for: .normal)
            confirmBtn.setTitleColor(.secondaryLabelColor(), for: .normal)
            confirmBtn.borderColor = .secondaryLabelColor()
            break
        default:
            confirmBtn.setTitle("Start timer", for: .normal)
            confirmBtn.setTitleColor(.init(rgb: 0x00B0FF), for: .normal)
            confirmBtn.borderColor = .init(rgb: 0x00B0FF)
            break
        }
    }
    
}
