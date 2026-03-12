//
//  Crypto.swift
//  Shadhin
//
//  Created by Gakk Alpha on 1/5/22.
//  Copyright © 2022 Cloud 7 Limited. All rights reserved.
//

import UIKit
import Foundation
import CommonCrypto

class CryptoCBC{
    
    static let KEY = "AlongSecrectKeyG"
    static let IV = "qpoUHiRDLgkAliep"
    
    static let shared = CryptoCBC()
    
    private init(){}
    
    func encryptMessage(message: String, encryptionKey: String = KEY, iv: String = IV) -> String? {
        if let aes = try? AES(key: encryptionKey, iv: iv),
           let encrypted = try? aes.encrypt(Array<UInt8>(message.utf8)) {
            return encrypted.toBase64()
        }
        return nil
    }
    
    func decryptMessage(encryptedMessage: String, encryptionKey: String = KEY, iv: String = IV) -> String? {
        
        guard isBase64Encoded(value: encryptedMessage) else{
            return encryptedMessage
        }
        
        if let aes = try? AES(key: encryptionKey, iv: iv), let data = Data(base64Encoded: encryptedMessage),
           let decrypted = try? aes.decrypt(Array<UInt8>(data)) {
            return String(data: Data(decrypted), encoding: .utf8)
        }
        return nil
    }
    
    func isBase64Encoded(value : String) -> Bool{
        let base64Regex = "^(?:[A-Za-z0-9+\\/]{4})*(?:[A-Za-z0-9+\\/]{2}==|[A-Za-z0-9+\\/]{3}=)?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", base64Regex)
        return predicate.evaluate(with: value)
    }
}

struct AesStreamingUrlDecryptor {
    
    static let secretKey = "asdfghjklzxcvbnmqwertyuiop123456"
    
    /// Decrypts an AES encrypted string in the format: encryptedData:iv
    static func decryptString(
        encryptedText: String,
        secretKey: String = AesStreamingUrlDecryptor.secretKey
    ) throws -> String {
        let parts = encryptedText.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else {
            throw DecryptorError.invalidFormat("Invalid format. Expected encryptedData:iv")
        }
        
        let encryptedDataBase64 = parts[0].trimmingCharacters(in: .whitespaces)
        let requestIvBase64 = parts[1].trimmingCharacters(in: .whitespaces)
        
        let iv = try decodeBase64Safe(requestIvBase64)
        let buffer = try decodeBase64Safe(encryptedDataBase64)
        
        let keyBytes = Array(secretKey.utf8)
        guard keyBytes.count == 16 || keyBytes.count == 32 else {
            throw DecryptorError.invalidKeyLength("Invalid AES key length")
        }
        
        let decrypted = try aesCBCDecrypt(data: buffer, key: keyBytes, iv: Array(iv))
        
        guard let result = String(bytes: decrypted, encoding: .utf8) else {
            throw DecryptorError.decodingFailed("Failed to decode decrypted bytes as UTF-8")
        }
        
        return result
    }
    
    static func decodeBase64Safe(_ input: String) throws -> Data {
        var normalized = input
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .trimmingCharacters(in: .whitespaces)
        
        // Add padding if needed
        let remainder = normalized.count % 4
        switch remainder {
        case 2: normalized += "=="
        case 3: normalized += "="
        default: break
        }
        
        guard let data = Data(base64Encoded: normalized) else {
            throw DecryptorError.base64DecodingFailed("Failed to decode Base64 string")
        }
        
        return data
    }
    
    // MARK: - AES CBC Decryption using CommonCrypto
    
    private static func aesCBCDecrypt(
        data: Data,
        key: [UInt8],
        iv: [UInt8]
    ) throws -> [UInt8] {
        let keyLength = key.count
        let dataLength = data.count
        var decryptedBytes = [UInt8](repeating: 0, count: dataLength + kCCBlockSizeAES128)
        var numBytesDecrypted = 0
        
        let cryptStatus = CCCrypt(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            key,
            keyLength,
            iv,
            Array(data),
            dataLength,
            &decryptedBytes,
            decryptedBytes.count,
            &numBytesDecrypted
        )
        
        guard cryptStatus == kCCSuccess else {
            throw DecryptorError.decryptionFailed("AES decryption failed with status: \(cryptStatus)")
        }
        
        return Array(decryptedBytes.prefix(numBytesDecrypted))
    }
    
    // MARK: - BrainFuska (BrainFuck interpreter)
    
    static func createSource(_ string: String) -> [Character] {
        return Array(string)
    }

    enum DecryptorError: Error {
        case invalidFormat(String)
        case invalidKeyLength(String)
        case base64DecodingFailed(String)
        case decodingFailed(String)
        case decryptionFailed(String)
    }
}
