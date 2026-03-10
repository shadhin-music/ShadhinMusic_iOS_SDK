//
//  VGCustomPlayerView.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 4/23/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//
import UIKit

class VGCustomPlayerView: VGPlayerView {
    // var playRate: Float = 1.0
    //var rateButton = UIButton(type: .custom)
    var rev = UIButton(type: .custom)
    var frw = UIButton(type: .custom)
    override func configurationUI() {
        super.configurationUI()
        
        rev.setImage(UIImage(named: "ic_reward_10",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        frw.setImage(UIImage(named: "ic_forward_10",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        
        self.addSubview(rev)
        self.addSubview(frw)
        
        rev.snp.makeConstraints { [] (make) in
            make.centerX.equalToSuperview().offset(-40 - 22)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
            make.width.equalTo(36)
        }
        
        frw.snp.makeConstraints { [] (make) in
            make.centerX.equalToSuperview().offset(+40 + 22)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
            make.width.equalTo(36)
        }
        rev.isHidden = true
        frw.isHidden = true
        
        let playImage = UIImage(named: "ic_play_1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        let pauseImage = UIImage(named: "ic_pause_1",in: Bundle.ShadhinMusicSdk,compatibleWith: nil)
        playButtion.setImage(playImage, for: .normal)
        playButtion.setImage(pauseImage, for: .selected)
        rev.addTarget(self, action: #selector(rewind), for: .touchUpInside)
        frw.addTarget(self, action: #selector(forward), for: .touchUpInside)
    }
    
    
    override func displayControlView(_ isDisplay: Bool) {
        super.displayControlView(isDisplay)
        if isDisplay{
            rev.isHidden = false
            frw.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.rev.alpha = 1
                self.frw.alpha = 1
            })
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.rev.alpha = 0
                self.frw.alpha = 0
            }) { (completion) in
                self.rev.isHidden = true
                self.frw.isHidden = true
            }
        }
    }
    
    override func bufferStateDidChange(_ state: VGPlayerBufferstate) {
        super.bufferStateDidChange(state)
        if state == .buffering {
            self.rev.isHidden = true
            self.frw.isHidden = true
        } else {
            self.rev.isHidden = false
            self.frw.isHidden = false
        }
    }
    
    @objc func rewind(){
        displayControlView(true)
        if let currentDuration = vgPlayer?.currentDuration {
            var seekTime = currentDuration - TimeInterval(10)
            if seekTime < TimeInterval.zero{
                seekTime = TimeInterval.zero
            }
            self.vgPlayer?.seekTime(seekTime, completion: nil)
        }
    }
    
    @objc func forward(){
        displayControlView(true)
        if let currentDuration = vgPlayer?.currentDuration ,let totalDuration = vgPlayer?.totalDuration {
            var seekTime = currentDuration + TimeInterval(10)
            if seekTime > totalDuration{
                seekTime = totalDuration
            }
            self.vgPlayer?.seekTime(seekTime, completion: nil)
        }
    }
    
    
}
