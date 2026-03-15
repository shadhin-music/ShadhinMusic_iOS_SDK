//
//  MusicPlayerV3TimerExt.swift
//  Shadhin
//
//  Created by Joy on 23/11/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import Foundation

extension MusicPlayerV3: ShadhinPlayerSleepTimerDelegate{
    func timerStateChanged(newState: ShadhinPlayerSleepTimer.State) {
        if case .off = newState {
            sleepTimerBtn.setImage(UIImage(resource: ImageResource(name: "ic_sleep_timer", bundle: Bundle.ShadhinMusicSdk)))
        }else{
            sleepTimerBtn.setImage(UIImage(resource: ImageResource(name: "ic_sleep_timer_active", bundle: Bundle.ShadhinMusicSdk)))
        }
    }
    
    func stopPlayer() {
        audioPause()
    }
}
