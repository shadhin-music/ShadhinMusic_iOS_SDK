//
//  PlaylistInputVC.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 7/7/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit


typealias PlaylistCreateCompleted = ()->()

class PlaylistInputVC: UIViewController,NIBVCProtocol {

    @IBOutlet weak var playlistTxtFld: UITextField!
    var playlistCreateCompleted: PlaylistCreateCompleted?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func cancelAction(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    func didPlaylistCreateCompleted(completion: @escaping PlaylistCreateCompleted) {
        playlistCreateCompleted = completion
    }
    
    // PlaylistInputVC.swift
    var createdName: String = ""

    typealias PlaylistCreateCompleted = (_ name: String) -> ()

    @IBAction func saveAction(_ sender: Any) {
        guard let name = playlistTxtFld.text, !name.isEmpty else {
            view.makeToast("Playlist name cannot be empty")
            return
        }
        ShadhinCore.instance.api.createUserPlaylist(name: name) { (err) in
            if err == nil {
                self.createdName = name
                self.playlistCreatedSuccess()
            }
        }
    }

    func playlistCreatedSuccess() {
        self.view!.makeToast("Playlist created", duration: 1, position: .bottom, title: nil, image: nil, style: .init()) { (success) in
            SwiftEntryKit.dismiss {
                self.playlistCreateCompleted?(self.createdName)
            }
        }
    }
}
