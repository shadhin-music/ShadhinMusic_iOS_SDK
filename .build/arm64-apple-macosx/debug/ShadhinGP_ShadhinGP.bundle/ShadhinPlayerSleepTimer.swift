//
//  ShadhinPlayerSleepTimer.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/20/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

class ShadhinPlayerSleepTimer{
    
    static let instance = ShadhinPlayerSleepTimer()
    private init(){}

    enum State{
        case off
        case tenMinutes
        case twentyMinutes
        case thirtyMinutes
        case sixtyMinutes
        case custom(Int)
    }
    
    var currentState: State = .off{
        didSet{
            delegate?.timerStateChanged(newState: currentState)
        }
    }
    var timer: Timer?
    var timeToStop : Date?
    weak var delegate: ShadhinPlayerSleepTimerDelegate?
    
    
    func initTimer(state: State){
        var minutesToEnd: Double = 0
        switch state{
        case .off:
            minutesToEnd = 0
        case .tenMinutes:
            minutesToEnd = 10
        case .twentyMinutes:
            minutesToEnd = 20
        case .thirtyMinutes:
            minutesToEnd = 30
        case .sixtyMinutes:
            minutesToEnd = 60
        case .custom(let value):
            minutesToEnd = Double(value)
        }
        currentState = state
        timer?.invalidate()
        guard minutesToEnd > 0 else {return}
        timeToStop = Date().addingTimeInterval(minutesToEnd * 60)
        timer = Timer.scheduledTimer(timeInterval: minutesToEnd * 60, target: self, selector: #selector(timeIsUp), userInfo: nil, repeats: false)
    }
    
    @objc func timeIsUp(){
        delegate?.stopPlayer()
        currentState = .off
        timeToStop = nil
    }
    
}

protocol ShadhinPlayerSleepTimerDelegate: AnyObject {
    func timerStateChanged(newState: ShadhinPlayerSleepTimer.State)
    func stopPlayer()
}
