//
//  EKAttributes.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/19/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import Foundation
import UIKit

public struct EKAttributes {
    
    // MARK: Identification
    
    /**
     A settable **optional** name that matches the entry-attributes.
     - Nameless entries cannot be inquired using *SwiftEntryKit.isCurrentlyDisplaying(entryNamed: _) -> Bool*
     */
    public var name: String?
    
    // MARK: Display Attributes
    
    /** Entry presentation window level */
    internal var windowLevel = WindowLevel.statusBar
    
    /** The position of the entry inside the screen */
    internal var position = Position.top

    /** The display manner of the entry. */
    internal var precedence = Precedence.override(priority: .normal, dropEnqueuedEntries: false)
    
    /** Describes how long the entry is displayed before it is dismissed */
    internal var displayDuration: DisplayDuration = 2 // Use .infinity for infinite duration
    
    /** The frame attributes of the entry */
    internal var positionConstraints = PositionConstraints()
    
    // MARK: User Interaction Attributes
    
    /** Describes what happens when the user interacts the screen,
     forwards the touch to the application window by default */
    internal var screenInteraction = UserInteraction.forward
    
    /** Describes what happens when the user interacts the entry,
     dismisses the content by default */
    internal var entryInteraction = UserInteraction.dismiss

    /** Describes the scrolling behaviour of the entry.
     The entry can be swiped out and in with an ability to spring back with a jolt */
    internal var scroll = Scroll.enabled(swipeable: true, pullbackAnimation: .jolt)
    
    /** Generate haptic feedback once the entry is displayed */
    internal var hapticFeedbackType = NotificationHapticFeedback.none
    
    /** Describes the actions that take place when the entry appears or is being dismissed */
    internal var lifecycleEvents = LifecycleEvents()
    
    // MARK: Theme & Style Attributes
    
    /** The display mode of the entry */
    internal var displayMode = DisplayMode.inferred
    
    /** Describes the entry's background appearance while it shows */
    internal var entryBackground = BackgroundStyle.clear
    
    /** Describes the background appearance while the entry shows */
    internal var screenBackground = BackgroundStyle.clear
    
    /** The shadow around the entry */
    internal var shadow = Shadow.none
    
    /** The corner attributes */
    internal var roundCorners = RoundCorners.none
    
    /** The border around the entry */
    internal var border = Border.none
    
    /** Preferred status bar style while the entry shows */
    internal var statusBar = StatusBar.inferred
    
    // MARK: Animation Attributes
    
    /** Describes how the entry animates in */
    internal var entranceAnimation = Animation.translation
    
    /** Describes how the entry animates out */
    internal var exitAnimation = Animation.translation
    
    /** Describes the previous entry behaviour when a new entry with higher display-priority shows */
    internal var popBehavior = PopBehavior.animated(animation: .translation) {
        didSet {
            popBehavior.validate()
        }
    }

    /** Init with default attributes */
    public init() {}
}
