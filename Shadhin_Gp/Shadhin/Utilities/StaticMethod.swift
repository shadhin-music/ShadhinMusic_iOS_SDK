//
//  StaticMethod.swift
//  Shadhin
//
//  Created by Gakk Media Ltd on 6/13/19.
//  Copyright © 2019 Gakk Media Ltd. All rights reserved.
//

import Foundation
import UIKit


func documentoryPathURL(urlString: String)-> String {
    let audioUrl = URL(string: urlString)
    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl!.lastPathComponent)
    return destinationUrl.absoluteString
    
}

