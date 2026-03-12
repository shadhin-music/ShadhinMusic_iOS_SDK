//
//  PurchasedTicketTC.swift
//  Shadhin
//
//  Created by Gakk Alpha on 9/6/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit

class PurchasedTicketTC: UITableViewCell,UINavigationControllerDelegate {
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle:Bundle.ShadhinMusicSdk)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var size: CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBOutlet weak var ticketHolder: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhone: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var barcodeImg: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var ticketTypeLbl: UILabel!
    @IBOutlet weak var placeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(data: PurchasedTicketObj.Data){
        userName.text = data.userName
        userPhone.text = data.phonenumber
        userEmail.text = data.userEmail
        timeLbl.text = data.campaignTime
        dateLbl.text = data.campaignDate
        ticketTypeLbl.text = data.ticketType
        placeLbl.text = "\(data.venueName ?? "") \(data.venueHall ?? "")"
        
        if let b64Str = data.barcode,
           let dataDecoded:NSData = NSData(base64Encoded: b64Str, options: NSData.Base64DecodingOptions(rawValue: 0)),
           let decodedimage:UIImage = UIImage(data: dataDecoded as Data){
            barcodeImg.image = decodedimage
        }
    }

    @IBAction func printTicket(_ sender: Any) {
        guard let image = getImage() else {return}
        let info = UIPrintInfo(dictionary:nil)
        info.outputType = UIPrintInfo.OutputType.general
        info.jobName = "Ticket Printing"
        let vc = UIPrintInteractionController.shared
        vc.printInfo = info
        vc.printingItem = image
        vc.present(from: self.ticketHolder.frame, in: self.ticketHolder, animated: true, completionHandler: nil)
    }
    
    @IBAction func downloadTicket(_ sender: Any) {
        guard let image = getImage() else {return}
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func getImage() -> UIImage?{
        //UIGraphicsBeginImageContext(ticketHolder.frame.size)
        UIGraphicsBeginImageContextWithOptions(ticketHolder.frame.size, false, 0.0)
        ticketHolder.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            ticketHolder.makeToast(error.localizedDescription, position: .bottom, title: "Save error")
        } else {
            ticketHolder.makeToast("Your ticket has been saved to your photos.", position: .bottom, title: "Saved!")
        }
    }
    
}
