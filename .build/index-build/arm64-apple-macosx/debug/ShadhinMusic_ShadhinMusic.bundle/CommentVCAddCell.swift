//
//  CommentVCAddCell.swift
//  Shadhin
//
//  Created by Rezwan on 6/14/20.
//  Copyright © 2020 Cloud 7 Limited. All rights reserved.
//

import UIKit

class CommentVCAddCell: UITableViewCell {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var height: CGFloat {
        return 60
    }
    
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var sendBtn: UIImageView!
    var commentVC : CommentVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentTF.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
        sendBtn.setClickListener {
            guard let msg = self.commentTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !msg.isEmpty else {
                return
            }
            self.commentVC?.sendComment(msg: msg)
            self.commentTF.text = ""
            self.sendBtn.image = UIImage(resource: ImageResource(name: "btn_comment_disable", bundle: Bundle.ShadhinMusicSdk))
        }
    }
    
    @objc func textChanged() {
        let trimmed = commentTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.count > 0 {
            sendBtn.image = UIImage(resource: ImageResource(name: "btn_comment_active", bundle: Bundle.ShadhinMusicSdk))
        } else {
            sendBtn.image = UIImage(resource: ImageResource(name: "btn_comment_disable", bundle: Bundle.ShadhinMusicSdk))
        }
    }

}
