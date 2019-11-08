//
//  PDSwallower.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SwallowPillNotificationActionHandler: SwallowPillNotificationActionHandling {
    
    let notifications: PDNotificationScheduling?
    
    convenience init() {
        self.init(notifications: app?.notifications)
    }
    
    init(notifications: PDNotificationScheduling?) {
        self.notifications = notifications
    }
    
    /// Given to PatchDataSDK for invoking when swallowing a pill,
    func handleSwallow(_ pill: Swallowable) {
        self.notifications?.requestDuePillNotification(pill)
    }
}