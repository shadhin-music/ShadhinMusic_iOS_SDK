//
//  EKSimpleMessage.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 6/1/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import Foundation

struct EKSimpleMessage {
    
    /** The image view descriptor */
    let image: EKProperty.ImageContent?
    
    /** The title label descriptor */
    let title: EKProperty.LabelContent
    
    /** The description label descriptor */
    let description: EKProperty.LabelContent
        
    init(image: EKProperty.ImageContent? = nil,
                title: EKProperty.LabelContent,
                description: EKProperty.LabelContent) {
        self.image = image
        self.title = title
        self.description = description
    }
}
