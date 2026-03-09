//
//  ShadhinApiContants.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/26/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import Foundation


public class ShadhinApiContants {
    var API_HEADER: HTTPHeaders {
        get{
            var header = [
                "Token" : !(ShadhinCore.instance.defaults.userSessionToken.isEmpty) ? ShadhinCore.instance.defaults.userSessionToken : "aU9T",
                "Content-Type" : "application/json"
            ]
            if !ShadhinCore.instance.defaults.userSessionToken.isEmpty{
                header["Authorization"] = "Bearer \(ShadhinCore.instance.defaults.userSessionToken)"
            }
            header["countryCode"] = ShadhinCore.instance.defaults.userCountryCode.lowercased()
            header["DeviceType"] =  "iOS"
            header["client"] = "16"
            return  HTTPHeaders.init(header)
        }
    }
    
    var API_HEADER_FOR_FORM_DATA: HTTPHeaders {
        get{
            var header : [String: String] = [:]
            if !ShadhinCore.instance.defaults.userSessionToken.isEmpty{
                header["Authorization"] = "Bearer \(ShadhinCore.instance.defaults.userSessionToken)"
            }
            header["countryCode"] = ShadhinCore.instance.defaults.geoLocation.lowercased()
            header["DeviceType"] =  "iOS"
            return  HTTPHeaders.init(header)
        }
    }
    
    func getAPIHeaderForUserInfo(token: String) -> HTTPHeaders {
        var header = [
            "Token" : token,
            "Content-Type" : "application/json"
        ]
        
        header["Authorization"] = "Bearer \(token)"
        
        header["countryCode"] = ShadhinCore.instance.defaults.geoLocation.lowercased()
        header["DeviceType"] =  "iOS"
        return  HTTPHeaders.init(header)
    }
    
    var API_HEADER_FOR_NEWSUBSCRIPTION: HTTPHeaders {
        get{
            var header = [
                "Token" : !(ShadhinCore.instance.defaults.userSessionToken.isEmpty) ? ShadhinCore.instance.defaults.userSessionToken : "aU9T",
                "Content-Type" : "application/json"
            ]
            if !ShadhinCore.instance.defaults.userSessionToken.isEmpty{
                header["Authorization"] = "Bearer PmQkWs/8RuxBSex+kNna5OWnE4kPLNcZwdLjSQyKFPGjShBaMlEQFqdfa9NF/2bYC+0Rl4PEUwgpgv6lOz53m4yw9Odn5AoMgtNDa9r9BE5C264I6iRumTWrlMC1RfAOqH+bUWy/a0VsuvMqRTU96ihGYyIxXtHNvFdGEJS5junVcesoRD4oXze5+8uvz0KGXvIu6EfwJFllSrUVZ/2dxrEN9yliP16SdXvtJxsmL4YoBeRwy67vJCKRxzqkUEsIsf48w9apXUDDP1Q1D+yvGNaCpMynjIiWDZET+gDb1i5wC1pYfCVvYK7v/YkNpbAAPZlBkkH0DH91WF992Kq8iBBKUql1g0aDzb/Dt4+LBvSgSQYF92Qn7vCSe4S2BcjETACa5NZYccbscLpQz7zkzB9x1/Oh68iR47z9paQEvdIHmNfRt2i891vB8GOdfKYHWbbGWlR0tF1NclKr2SQY453uLoSKnN+ducLHUedETyveHYat6jesL60QjsG//UeQTFV1zlaeGeFAG09jXpqL3L9CyfWskS8jmgZ/WMicDmMUaAhZ/wuJZfmFS2DBS52ItT3pdpeWF+7ZyMrdQyquNyfW+q1Ly+PCnnxL4zk090MUUvrkx9UXzBDva9zIr4zQz9eS/8k5bYGetcmEgHJN5LTG6fwiT6biFua3wveIl563VtPUtKf4RMXy5TEhmqq2EIGUCk5LGzHFPG48ewr6WPYLp57GB/4RFChJr/KrQ0q5z+L5AuOL26ipBrGrDo29v0oTm4F2sFbAx1bd8Y45EdFHkZNDgHJVMwVcFLl6DUzJCEY/YWPU4lNzLWaPDQTwx1UaHwm74cKnJ+3G7ET6VgCOvT5qQbtgrYSPf0UifE+/W7n/oUMVJHcVgr8OE6aRAtfo6EUEIC6ZnLaRHw3RIzBkX0Ou316vOnWosWSWIwiuua0R+ZszHG8dIhLi1F6Xgz0nwCiVdfYMwIWjCTQFyg==:kYHIsrApy2i6t4WXLBLbUw=="
            }
            header["countryCode"] = ShadhinCore.instance.defaults.geoLocation.lowercased()
            header["DeviceType"] =  "iOS"
            return  HTTPHeaders.init(header)
        }
    }
    
    let CONTENT_HEADER: HTTPHeaders = HTTPHeaders.init(["Content-Type" : "application/json"])
    var runningCampaignInRamCache : [String]? = nil
    let cbc_secret_key = "andgraphicdesign"
    let cbc_iv = "shing1248andgrap"
    var isRestrictionPaidAlertNotShowing = true
    let locationUpdateDelayInSecs: Double =  5 //15 * (24 * 60 * 60)
    //let RBTSubscriptionIDs = [["30AYCEOT", "30AYCELT"], ["7AYCEOT","7AYCELT"], ["1AYCEOT", "1AYCELT"]]
    let X_Compatibility = "2"
    let customArtistBio = [
        "habib%20wahid" : "Habib wahid is a Bangladeshi music composer, performer, producer &amp; singer. He has been successful working in the Bangladeshi music industry since 2003 when his first album “kirshno” got released, which was mainly made with a vision of re introducing old Bengali folk songs re made with a new sound completely to popularise them to the audience. Ever since then, he has worked on many original albums, flim songs, jingles for tv commercials etc. He has won several awards including a national award for uja contribution in the music industry. Habib wahid also has a major contribution in modernising the concept of Bangladeshi music videos through his video “Hariye fela bhalobasha” released in 2015. Since then he has been working regularly on producing and performing in his music videos. Apart from singing his own original songs, habib has features various artists over the years of which some gained tremendous success like Nancy, who has been known as a regular duet singing partner of habib. Habib wahid has performed in live concerts throughout many counties of the world like USA, Canada, uk, Australia, Dubai, Qatar, malaysia, and many more. Habib wahid is always appreciated by his fans for his unique, authentic and original approach towards composing music.",
        "shafin%20ahmed" : "Shafin Ahmed as a composer, lyricist, singer and Bassist, is an icon today in the music industry. Exceptional musical talent inherited from his legendary parents, Kamal Dasgupta and Feroza Begum, combined with his own dedication applied over 40 years have established him permanently in the hearts and minds of millions of Bangla music listeners around the world.",
        "miles" : "Miles was formed in 1979 in Dhaka, Bangladesh with eyes looking ahead on miles of travel through time in Music. After 40 years with many changes in the line up, Tours and achievements behind, the band is still pursuing the excellence in music. Considered one of the leading Rock Fusion bands of the Sub-Continent and perhaps the only band in Asia to exist at the top for so long with it’s core members, it has a very unique blend of Eastern &amp; Western music in their generic  Bangla Songs to create a very diversified trend in the Bengali music scene in Bangladesh, India, USA, Canada and rest of the world. Rich in melody, blended with power with very matured arrangements and application of instruments, Miles have their own distinct sound that has captured the heart and soul of the Bengali music fans all over the world for four decades now. In Bangladesh, Miles have so far released 2 English,  7 Bengali albums, and an EP, that are -  Miles, A Step Further, Protisruty, Prattasha, Prattay, Prabaha, Pratiddhani, Protichobi, Proticchobi Delux, and Prayash and in India 3 albums: Best of volume 1 &amp; Volume 2. and Proborton. Each of these albums are considered milestones for “Bangla Rock” music in Bangladesh as well as in India in terms of both sales &amp; unique blend of Miles’ music.   USA, Canada, U.K., Italy, Germany, Austria, Switzerland, Australia. UAE,  and India are some of the countries that MILES have rocked along with numerous concerts in Bangladesh till date. It is the only Band in Bangladesh to have been covered by MTV, Channel “V”, CNN, BBC, Al-Jazeera, Star Plus, ETV India, B4U, Zee-TV and Tara Bangla. MILES has also made number of international appearances for charitable causes as well.   Miles’ current line up is- Hamin Ahmed-  Vocal &amp; Guitar, Shafin Ahmed- Vocal &amp; Bass, Manam Ahmed- Keyboards &amp; Vocal,  Ziaur Rahman Turja- Drums &amp; Percussions and Iqbal Asif Jewel- Guitar and Vocal.   Miles is determined to rock on with “Bangla Rock Fusion” for the international recognition and that determination is still driving the Band to miles of music ahead,!!",
        "popeye" : "Popeye is a Bangladeshi music project that has been active for a decade. They do not perform in concerts, nor appear on television, and cannot be heard on the radio. Yet they have quietly garnered a cult following among rock-fusion lovers in Bangladesh over the last few years.",
        "the%20roads" : "THE ROADS is a Rock band formed in Dhaka, Bangladesh. They started their musical journey from 2011. THE ROADS performed numerous shows LIVE shows, TV shows, Radio shows, Online shows etc. Their released songs are MonePore, Bristy, ChenaGaan, Sritir-Michil, Dakghor, Jadu Khela, MonDuary, Dheu and more. THE ROADS is grateful for the Love and Support from their fans to keep them encouraged and going forward. THE ROADS is - Aapel Mahmud (Voice & Lead Guitars), Zaki Mahmud (Rhythm Guitar & Manager), Blaze Rodrigues (Bass), Shirajul Islam Munna (Drums), Aapel Mahmud Labu (Keyboards). You can reach them at their fan-page: www.facebook.com/theroadsbandbd",
        "micky" : "Mehedi Hasan (born 1 April 2002), better known by his stage name Mïcky is a Singer, Songwriter, Music Producer, Composer and Dancer from Dhaka, Bangladesh. He is renowned for his unique ideas, not sticking to any specific genre and representing different vibes to everyone through his music. Also, he likes to combine and play with different genres. His first music was officially released on February 14, 2021, titled as 'Fragrance’. He started producing music when he was 16, but he is still underrated in his country. Mïcky wants to spread the message through his music that music is so beautiful that it can spread positivity and inspire people in their daily life and can help to reach their major goals. That's why he wants his listeners to be a part of his journey!",
        "ayan" : "AYAN, a growing musician based in Dhaka, Bangladesh who has been making music from different genres, a versatile musician who has his unique touch in different songs he has worked in.",
        "eyecon" : "EYECON, formerly known as A$H is an Artist originating from Sunamganj, Sylhet, Bangladesh. He started making music from the year 2016 and never looked back. He redefined his music style through the years and now he became more versatile excelling in a lot of genres. He belongs to the collective CLVR where they collectively work to bring new sounds and expression of art to display to the world. Genres: Pop Punk, Alternative Rock, Emo Rock, Hip-hop, R&B.",
        "feedback" : "Feedback is a Bangladeshi rock band, formed in 4 October 1976 in Dhaka by keyboardist Foad Nasser Babu. Multiple lineup changes have taken place since 1976. They have released seven studio albums and have also appeared in some compilations. Their first appearance was in The Hotel Inter-continental (now the Sheraton), Dhaka, on 11 October 1976. Their first recorded song was 'Aye Din Chiro Din Robey' in 1980. After Labu Rahman joined the band in 1986, they started concerts out of the hotels. They released their first album Feedback and then Sragam Acoustics. Feedback performed at Shilpakala Academy on 25 September 1989, at Dhaka University on 16 December 1990, at Nicco Park, Kolkata on 26 January 1992, at Jadavpur University on 12 July 1994."
        
    ]
    
    static func getCallerTuneServices()->[CallerTuneObj]{
        let gpCallerTuneServiceJson = "[{\"amount\":\"৳32.83\",\"duration\":\"30 days\",\"serviceID\":[\"30AYCEOT\",\"30AYCELT\"]},{\"amount\":\"৳7.66\",\"duration\":\"7 days\",\"serviceID\":[\"7AYCEOT\",\"7AYCELT\"]},{\"amount\":\"৳1.09\",\"duration\":\"1 day\",\"serviceID\":[\"1AYCEOT\",\"1AYCELT\"]}]"
        let blCallerTuneServiceJson = "[{\"amount\":\"৳30.00\",\"duration\":\"30 days\",\"serviceID\":[\"OT30\",\"NAYCE\"]}]"
        
        switch ShadhinCore.instance.getUserTelcoBrand(){
        case .GrameenPhone:
            return try! JSONDecoder().decode(
                [CallerTuneObj].self,
                from: Data(gpCallerTuneServiceJson.utf8))
        case .BanglaLink:
            return try! JSONDecoder().decode(
                [CallerTuneObj].self,
                from: Data(blCallerTuneServiceJson.utf8))
        default:
            return []
        }
    }
}


