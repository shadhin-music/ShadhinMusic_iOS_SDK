//
//  SettinsData.swift
//  Shadhin_Gp_Examaple
//
//  Created by MD Murad Hossain  on 14/10/25.
//

import UIKit
import Foundation

enum SettingEnumType {
    case darkMode, helpCenter
}

enum AppModeType : String {
    case dark, light, system
}


struct DarkModeData {
    var title: String
    var appModeType: AppModeType = .system
    var subTitle: String? = nil
    var isSystemMode: Bool = false
}

struct HelpCenterData {
    var title: String
    var image: UIImage?
    var arrowImage: UIImage?
}

// MARK: - FAQResponse
struct FAQResponse: Codable {
    let message: String
    let success: Bool
    let responseCode: Int
    let title: String
    let data: [FAQCategory]
    let error: String?
}

// MARK: - FAQCategory
struct FAQCategory: Codable {
    let l0: FAQMainCategory
    let l1: [FAQSubCategory]
}

// MARK: - FAQMainCategory (Level 0)
struct FAQMainCategory: Codable {
    let id: Int
    let titleEn: String
    let titleBn: String
    let iconUrl: String
    let streamingUrl: String?
    let sort: Int
}

// MARK: - FAQSubCategory (Level 1)
struct FAQSubCategory: Codable {
    let id: Int
    let titleEn: String
    let titleBn: String
    let sort: Int
}


// MARK: - Root Model
struct FAQAnswerResponse: Codable {
    let message: String
    let success: Bool
    let responseCode: Int
    let title: String
    let data: FAQAnswerData?
    let error: String?
}

// MARK: - Data
struct FAQAnswerData: Codable {
    let faqAnsId: Int
    let imageUrl: String?
    let en: FAQAnswerLanguage?
    let bn: FAQAnswerLanguage?
}

// MARK: - Language
struct FAQAnswerLanguage: Codable {
    let introText: String?
    let subHeader: String?
    let descriptionsArr: [String]?
}


// MARK: - Request Liked Model
struct FAQFeedbackLikedRequest: Codable {
    let faqAnsId: Int
    let isLiked: Bool
}

// MARK: - Request DisLiked Model

struct FAQFeedbackDisLikedRequest: Codable {
    let faqAnsId: Int
    let isDisLiked: Bool
}

// MARK: - Response Model
struct FAQFeedbackResponse: Codable {
    let message: String?
    let success: Bool
    let responseCode: Int
    let title: String?
    let data: String?
    let error: String?
}

