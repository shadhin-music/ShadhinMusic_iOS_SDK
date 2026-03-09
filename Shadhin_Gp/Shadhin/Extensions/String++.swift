//
//  String++.swift
//  Shadhin
//
//  Created by Joy on 10/10/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import Foundation

extension String{
    var imageURL : String{
        return self.replacingOccurrences(of: "<$size$>", with: "\(300)")
    }
    var image300 : String{
        return self.replacingOccurrences(of: "<$size$>", with: "\(300)").safeUrl()
    }
    var image450 : String{
        return self.replacingOccurrences(of: "<$size$>", with: "\(450)").safeUrl()
    }
    var image596 : String{
        return self.replacingOccurrences(of: "<$size$>", with: "\(596)").safeUrl()
    }
    //"596"
    var image1280 : String{
        
        let url = self.replacingOccurrences(of: "<$size$>", with: "\(1280)").safeUrl()
        print("url",url, self)
        return url
    }
    var image980 : String{
        return self.replacingOccurrences(of: "<$size$>", with: "\(980)").safeUrl()
    }
    var htmlToAttributedString: NSMutableAttributedString? {
        do {
            guard let data = data(using: .utf8) else { return NSMutableAttributedString(string: "") }
            let returnStr = try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            return returnStr
        } catch {
            return NSMutableAttributedString(string: "")
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
  
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
    
    func attributedStringFromHTML(_ color: UIColor = .primaryLableColor(), completionBlock: @escaping (NSAttributedString?) ->()) {
        
        guard let data = data(using: .utf8) else {
            return completionBlock(nil)
        }
        
        DispatchQueue.main.async{
            if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil){
                attributedString.addAttributes([NSAttributedString.Key.foregroundColor : color], range: NSRange(location: 0, length: attributedString.length))
                completionBlock(attributedString)
            } else {
                completionBlock(nil)
            }
        }
    }
    
    func stringFromHTML(_ color: UIColor = .primaryLableColor(), completionBlock: @escaping (String?) ->()) {
        guard let data = data(using: .utf8) else {
            return completionBlock(nil)
        }
        DispatchQueue.main.async{
            if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil){
                attributedString.addAttributes([NSAttributedString.Key.foregroundColor : color], range: NSRange(location: 0, length: attributedString.length))
                completionBlock(attributedString.string)
            } else {
                completionBlock(nil)
            }
        }
    }
    
    func safeUrl(_ size: ImageSize? = nil) -> String{
        var rStr = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if let size = size{
            rStr = rStr.replacingOccurrences(of: "<$size$>", with: size.rawValue)
        }
        rStr = rStr.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ?? ""
        return rStr
    }
    
    func decryptUrl() -> String?{
        CryptoCBC.shared.decryptMessage(encryptedMessage: self)
    }
    
    func decryptPlayerUrl() -> String? {
        do {
            return try AesStreamingUrlDecryptor.decryptString(encryptedText: self)
        } catch {
            print("Decryption failed: \(error)")
            return nil
        }
    }
    
    func widthOfAttributedString(withFont font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        return attributedString.size().width
    }
    
    func heightOfAttributedString(withFont font: UIFont, width: CGFloat) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        
        let constraintBox = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = attributedString.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    
}
extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    var validURL: Bool {
            get {
                let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
                let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
                return predicate.evaluate(with: self)
            }
        }
}
