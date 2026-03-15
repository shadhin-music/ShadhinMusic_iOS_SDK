//
//  ShadhinApi+Profile.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/7/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import CoreData
import UIKit

extension ShadhinApi{
    
    func getUserProfile() {
        AF.request(
            GET_USER_PROFILE,
            method: .get,
            parameters: nil,
            headers: API_HEADER
        )
        .validate()
        .responseDecodable(of: ProfileObj.self) { response in
            
            switch response.result {
                
            case let .success(dto):
                guard let profileDTO = dto.data else {
                    Log.error("Profile data is nil")
                    return
                }
                
                self.saveProfileData(profileDTO)
                DispatchQueue.main.async {
                    for notifier in ShadhinCore.instance.notifiers.objects {
                        notifier.profileInfoUpdated?()
                    }
                }
                
            case let .failure(error):
                Log.error(error.localizedDescription)
            }
        }
    }

    private func saveProfileData(_ profileDTO: UserProfileData) {
        
        let defaults = ShadhinCore.instance.defaults

        if let name = profileDTO.userFullName, !name.isEmpty {
            defaults.userName = name
        }
        
        if let userCode = profileDTO.userCode, !userCode.isEmpty {
            defaults.userCode = userCode
        }
        
        if let phone = profileDTO.phoneNumber {
            let cleanPhone = phone
                .replacingOccurrences(of: "+", with: "")
                .replacingOccurrences(of: " ", with: "")
            defaults.userMsisdn = cleanPhone
        }
        
        if let code = profileDTO.countryCode, !code.isEmpty {
            defaults.userCountryCode = code
        }
        
        if let country = profileDTO.country, !country.isEmpty {
            defaults.userCountry = country
        }
        
        if let city = profileDTO.city, !city.isEmpty {
            defaults.userCity = city
        }
        
        if let pic = profileDTO.userPic, !pic.isEmpty {
            defaults.userProPicUrl = pic
        }
        
        if let birthDate = profileDTO.birthDate,
           let date = Self.profileDateFormatter.date(from: birthDate) {
            defaults.userBirthDate = date
        }
        
        if let genderStr = profileDTO.gender,
           let gender = UserGender(rawValue: genderStr.lowercased()) {
            defaults.userGender = gender
        } else {
            defaults.userGender = .male
        }
        
        defaults.userLinkedAccounts = profileDTO.registerWith ?? []
    }
    
    func updateProfile(
        userFullName   : String,
        birthDate      : Date?,
        gender         : UserGender,
        country        : String = "",
        countryCode    : String = "",
        city           : String = "",
        imageFile      : UIImage?,
        completion     : @escaping (_ isSuccess: Bool,_ message: String?)->Void
    ){
        
        var parameters = [
            "UserFullName"   : userFullName,
            "Gender"         : gender.rawValue,
            "Country"        : country,
            "CountryCode"    : countryCode,
            "City"           : city,
        ]
        
        if let dateOfBirth = birthDate{
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy-MM-dd"
            let dateStr = dateFormatterPrint.string(from: dateOfBirth)
            parameters["BirthDate"] = dateStr
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            if let image = imageFile {
                if image.size.width > 0 {
                    let constantHeight = 100.0
                    let resizedImage = image.resizeImageWith(newSize: CGSize(width: (Double((image.size.width/image.size.height)) * constantHeight), height: constantHeight))
                    multipartFormData.append(resizedImage.jpegData(compressionQuality: 0.3)!, withName: "ImageFile", fileName: "user_image.jpeg", mimeType: "image/jpeg")
                }
            }
        }, to: UPDATE_USER_PROFILE, method: .post, headers: API_HEADER)
        .responseDecodable(of: ProfileObj.self){ response in
            switch response.result{
            case let .success(data):
                if let profileDTO = data.data {
                    self.saveProfileData(profileDTO)
                    completion(true, "")
                    for notifyer in ShadhinCore.instance.notifiers.objects{
                        notifyer.profileInfoUpdated?()
                    }
                }else{
                    completion(false, data.message)
                }
            case .failure(_):
                completion(false, "We are experiencing technical problems now which will be fixed soon.Thanks for your patience.")
            }
        }
    }
    
    
    func updateFcmTokenToServer(newToken: String, key: String, defaults: UserDefaults){
        guard !newToken.isEmpty, ShadhinCore.instance.isUserLoggedIn else {return}
        if let sentFcmToken = ShadhinCore.instance.defaults.fcmToken,
           sentFcmToken == newToken{
            return
        }
        AF.request(
            UPDATE_FCM_TOKEN(newToken),
            method: .post,
            encoding: JSONEncoding.default,
            headers: API_HEADER
        ).responseData {
            response in
            if response.response?.statusCode == 200{
                defaults.set(newToken, forKey: key)
                defaults.synchronize()
            }
        }
    }
    
    
    func recentlyPlayedLoad(){
        recentlyPlayedGetAll(with: 1) { result in
            switch result{
            case .success(let response):
                let array = response.data.reversed()
                array.forEach { rpl in
                    let cdm = rpl.getDatabaseContentModel()
                    RecentlyPlayedDatabase.instance.insertData(musicData: cdm)
                }
                break
            case .failure(let error):
                Log.error(error.localizedDescription)
            }
        }
    }
    
    
    public func clearDatabase() {
        resetAllRecords(in: "AlbumMyMusic")
        //resetAllRecords(in: "FavoritesMyMusic")
        resetAllRecords(in: "FavoriteCache")
        resetAllRecords(in: "RecentlyPlayed")
        resetAllRecords(in: "VideoHistoryAndWatchLater")
    }
    
    func resetAllRecords(in entity : String){
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
    
    func tryToGetApproxLocationData(){
        let lastLocationGetTimeStamp = ShadhinCore.instance.defaults.locationGetTimeStamp
        if lastLocationGetTimeStamp > 0{
            guard (Date().timeIntervalSince1970 - lastLocationGetTimeStamp) > locationUpdateDelayInSecs else {
                return
            }
        }
        AF.request(
            "http://ip-api.com/json/",
            method: .get,
            encoding: JSONEncoding.default,
            headers: CONTENT_HEADER)
        .responseData {
            response in
            guard let data = response.data,
                  let obj = try? JSONDecoder().decode(LocationObj.self, from: data) else {return}
            ShadhinCore.instance.defaults.locationGetTimeStamp = Date().timeIntervalSince1970
            if let country = obj.country{
                ShadhinCore.instance.defaults.userCountry = country
            }
            if let countryCode = obj.countryCode{
                ShadhinCore.instance.defaults.userCountryCode = countryCode
            }
            if let city = obj.city{
                ShadhinCore.instance.defaults.userCity = city
            }
            if let isp = obj.isp{
                ShadhinCore.instance.defaults.userISP = isp
            }
        }
        
    }
    
    func trackUserHistory(
        contentID: String,
        type: String,
        playCount: String,
        totalPlayInSeconds: Int,
        playInDate: String,
        playOutDate: String,
        playlistId: String,
        completion: @escaping (_ isSuccess: Bool)->Void) {
        
        var url = POST_USER_HISTORY
        var body : [String : Any] = [:]
        
        if type.prefix(2).lowercased() == "pd" ||
           type.prefix(2).lowercased() == "vd" {
            url = POST_USER_PODCAST_HISTORY
            body = [
                "Type" : type.prefix(2).uppercased(),
                "ContentId" : contentID,
                "ContentType"  : type.suffix(type.count - 2).uppercased(),
                "PlayCount" : playCount,
                "TimeCountSecond" : totalPlayInSeconds,
                "PlayIn" : playInDate,
                "PlayOut" : playOutDate
            ]
        }else{
            body = [
                "ContentId" : contentID,
                "Type" : type,
                "PlayCount" : playCount,
                "TimeCountSecond" : totalPlayInSeconds,
                "PlayIn" : playInDate,
                "PlayOut" : playOutDate,
                "UserPlayListId": playlistId
            ]
        }
            //Log.info("Streaming count : \(totalPlayInSeconds)")
            //print("Streaming count : \(totalPlayInSeconds)",playInDate,playOutDate)
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseData{ response in
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                    value["Status"] is String{
                    completion(true)
                }else{
                    completion(false)
                }
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
    func trackUserHistoryV6(
        contentID: String,
        type: String,
        playCount: String,
        totalPlayInSeconds: Int,
        playInDate: String,
        playOutDate: String,
        playlistId: String,
        completion: @escaping (_ isSuccess: Bool)->Void) {
        
        var url = POST_USER_HISTORY_V6
        var body : [String : Any] = [:]
        
        if type.prefix(2).lowercased() == "pd",
           type.prefix(2).lowercased() == "vd"{
            url = POST_USER_PODCAST_HISTORY_V6
            body = [
                "Type" : type.prefix(2).uppercased(),
                "ContentId" : contentID,
                "ContentType"  : type.suffix(type.count - 2).uppercased(),
                "PlayCount" : playCount,
                "TimeCountSecond" : totalPlayInSeconds,
                "PlayIn" : playInDate,
                "PlayOut" : playOutDate
            ]
        }else{
            body = [
                "ContentId" : contentID,
                "Type" : type,
                "PlayCount" : playCount,
                "TimeCountSecond" : totalPlayInSeconds,
                "PlayIn" : playInDate,
                "PlayOut" : playOutDate,
                "UserPlayListId": playlistId
            ]
        }
            //Log.info("Streaming count : \(totalPlayInSeconds)")
            print("Streaming count : \(totalPlayInSeconds)",playInDate,playOutDate)
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: API_HEADER)
        .responseData{ response in
            switch response.result{
            case let .success(data):
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let value = json as? [String : Any],
                    value["Status"] is String{
                    completion(true)
                }else{
                    completion(false)
                }
            case let .failure(error):
                completion(false)
                Log.error(error.localizedDescription)
            }
        }
    }
}

private extension ShadhinApi {
    static let profileDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
}
