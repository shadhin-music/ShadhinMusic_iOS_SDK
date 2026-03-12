//
//  AudioSettingsVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/9/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit
import AVKit

class AudioSettingsVC: UIViewController,NIBVCProtocol {

    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var volumeDownBtn: UIButton!
    @IBOutlet weak var volumeUpBtn: UIButton!
    
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layer.cornerRadius = 8
        
        playerSlider.setThumbImage(UIImage(named: "slider img",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        playerSlider.setThumbImage(UIImage(named: "slider img",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .highlighted)
        
        playerSlider.value = player?.volume ?? 1
        
        changeBtnImgByValue(value: playerSlider.value)
    }
    
    @IBAction func volumeChnagedAction(_ sender: UISlider) {
        player?.volume = sender.value
        
        changeBtnImgByValue(value: sender.value)
    }
    
    @IBAction func volumeDownAction(_ sender: Any) {
        let volume: Float = 0.0
        playerSlider.value = volume
        player?.volume = volume
        changeBtnImgByValue(value: volume)
    }
    
    @IBAction func volumeUpAction(_ sender: Any) {
        let volume: Float = 1.0
        playerSlider.value = volume
        player?.volume = volume
        changeBtnImgByValue(value: volume)
    }
    
    func changeBtnImgByValue(value: Float) {
        if value == 0 || value == 0.0{
            volumeUpBtn.setImage(UIImage(named: "ic_volume_off",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            volumeDownBtn.setImage(UIImage(named: "ic_volume_mute",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        }else {
            volumeUpBtn.setImage(UIImage(named: "ic_volume_up",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
            volumeDownBtn.setImage(UIImage(named: "ic_volume_down",in: Bundle.ShadhinMusicSdk,compatibleWith: nil), for: .normal)
        }
    }
}
