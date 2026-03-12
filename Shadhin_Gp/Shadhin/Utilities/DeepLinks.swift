//
//  DeepLinks.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 12/19/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import UIKit

class DeepLinks {
    
    static func createDeepLink(model: CommonContentProtocol,controller: UIViewController, vcType: String) {
        
//        var txtShare = ""
//        
//        let deepURL = "https://shadhinco.app.link/oQWAwFoOx2"
//        let deepAndroid = "https://play.google.com/store/apps/details?id=com.gm.shadhin"
//        let deepiOS = "https://apps.apple.com/us/app/shadhin-music/id1481808365"
//        
//        let buo = BranchUniversalObject.init(canonicalIdentifier: "content/\(String(describing: model.contentID))")
//        buo.title = model.title ?? ""
//        buo.contentDescription = model.artist ?? ""
//        buo.imageUrl = model.image?.replacingOccurrences(of: "<$size$>", with: "300") ?? ""
//        buo.publiclyIndex = true
//        buo.locallyIndex = true
//        guard var id = model.contentID,
//              let type = model.contentType else{
//            return
//        }
//        if SMContentType(rawValue: type) == .podcast,
//           let albumId = model.albumId{
//            id = albumId
//        }
//        buo.contentMetadata.customMetadata["id"] = id
//        buo.contentMetadata.customMetadata["custom"] = type
//        
//        
//        //        buo.title = "Shadhin Music"
//        //        buo.contentDescription = "Get shadhin music pro"
//        //        buo.imageUrl = "https://cdn.branch.io/branch-assets/1574580988143-og_image.png"
//        //        buo.publiclyIndex = true
//        //        buo.locallyIndex = true
//        //        guard let id = model.contentID,
//        //            let type = model.contentType else{
//        //                return
//        //        }
//        //        buo.contentMetadata.customMetadata["id"] = "id"
//        //        buo.contentMetadata.customMetadata["custom"] = "sub"
//        
//        
//        
//        //        buo.contentMetadata.customMetadata["key"] = model.contentID ?? ""
//        //        buo.contentMetadata.customMetadata["artistName"] = model.artist ?? ""
//        //        buo.contentMetadata.customMetadata["title"] = model.title ?? ""
//        //        buo.contentMetadata.customMetadata["image"] = model.image ?? ""
//        
//        let lp: BranchLinkProperties = BranchLinkProperties()
//        //        lp.channel = "facebook"
//        //        lp.feature = "sharing"
//        //        lp.campaign = "content 123 launch"
//        //        lp.stage = "new user"
//        //        lp.tags = ["one", "two", "three"]
//        
//        lp.addControlParam("$desktop_url", withValue: deepURL)
//        lp.addControlParam("$ios_url", withValue: deepiOS)
//        lp.addControlParam("$android_url", withValue: deepAndroid)
//        
//        //lp.addControlParam("$match_duration", withValue: "2000")
//        
//        //        lp.addControlParam("custom_data", withValue: "yes")
//        //        lp.addControlParam("look_at", withValue: "this")
//        
//        if vcType == "artist" {
//            //lp.addControlParam("nav_to", withValue: "artist")
//            txtShare = "Listen latest songs of \(model.title ?? "") From Shadhin,\nDownload it from :"
//        }else if vcType == "playlist" {
//            //lp.addControlParam("nav_to", withValue: "playlist")
//            txtShare = "Listen songs from \(model.title ?? "") Playlist From Shadhin,\nDownload it from :"
//        }else if vcType == "podcast"{
//            //lp.addControlParam("nav_to", withValue: "podcast")
//            txtShare = "Listen latest podcast of \(model.title ?? "") From Shadhin,\nDownload it from :"
//        }else{
//            //lp.addControlParam("nav_to", withValue: "podcast")
//            txtShare = "Listen to \(model.title ?? "") From Shadhin,\nDownload it from :"
//        }
//        
//        //lp.addControlParam("random", withValue: UUID.init().uuidString)
//        
//        buo.getShortUrl(with: lp) { (url, error) in
//            //print(url ?? "")
//            
//        }
//        
//        buo.showShareSheet(with: lp, andShareText: txtShare, from: controller) { (activityType, completed) in
//            //print(activityType ?? "")
//        }
//    }
//    
//    
//    static func createDeepLinkMyPlaylist(name: String, contentID: String, imgUrl: String, controller: UIViewController) {
//        
//        var txtShare = ""
//        
//        let deepURL = "https://shadhinco.app.link/oQWAwFoOx2"
//        let deepiOS = "https://apps.apple.com/us/app/shadhin-music/id1481808365"
//        
//        let buo = BranchUniversalObject.init(canonicalIdentifier: "content/\(contentID)")
//        buo.title = name
//        buo.contentDescription = "Shadhin Playlist"
//        buo.imageUrl = imgUrl.replacingOccurrences(of: "<$size$>", with: "300")
//        buo.publiclyIndex = true
//        buo.locallyIndex = true
//        
//        buo.contentMetadata.customMetadata["id"] = contentID
//        buo.contentMetadata.customMetadata["custom"] = "mp"
//        
//        let lp: BranchLinkProperties = BranchLinkProperties()
//        lp.addControlParam("$desktop_url", withValue: deepURL)
//        lp.addControlParam("$ios_url", withValue: deepiOS)
//        
//        
//        if ShadhinCore.instance.defaults.userName.isEmpty{
//            txtShare = "Here is a playlist for you... \(name) From Shadhin,\nDownload it from :"
//        }else{
//            txtShare = "Here is a playlist for you... \(name) From Shadhin by \(ShadhinCore.instance.defaults.userName),\nDownload it from :"
//        }
//        
//        buo.getShortUrl(with: lp) { (url, error) in
//            //print(url ?? "")
//            
//        }
//        
//        buo.showShareSheet(with: lp, andShareText: txtShare, from: controller) { (activityType, completed) in
//            //print(activityType ?? "")
//        }
    }
    
    
    
    static func createLinkTest(controller: UIViewController) {
        let textToShare = "Check out this awesome content!"
               let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
               
               // Optionally exclude some activity types
               activityViewController.excludedActivityTypes = [
                   .postToFacebook,
                   .postToTwitter,
                   .message,
                   .mail
               ]
        controller.present(activityViewController, animated: true, completion: nil)

    }
}
