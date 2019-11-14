//
//  PDTabReflector.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit

class PDTabReflector: PDTabReflective {
    
    private let tabController: UITabBarController
    private let viewControllers: [UIViewController]
    private let sdk: PatchDataDelegate?
    
    convenience init(
        tabController: UITabBarController,
        viewControllers: [UIViewController]
    ) {
        self.init(
            tabController: tabController,
            viewControllers: viewControllers,
            sdk: app?.sdk
        )
    }

    init(
        tabController: UITabBarController,
        viewControllers: [UIViewController],
        sdk: PatchDataDelegate?
    ) {
        self.tabController = tabController
        self.viewControllers = viewControllers
        self.sdk = sdk
    }
    
    var hormonesVC: UIViewController? { return viewControllers.tryGet(at: 0) }
    var pillsVC: UIViewController? { return viewControllers.tryGet(at: 1) }
    var sitesVC: UIViewController? { return viewControllers.tryGet(at: 2) }
    
    func reflectTheme(theme: AppTheme) {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = theme[.button]
        tabBarAppearance.barTintColor = theme[.navbar]
    }
    
    func reflectHormone() {
        if let sdk = sdk, let hormonesVC = hormonesVC {
            let total = sdk.totalAlerts
            let method = sdk.deliveryMethod
            let title = PDVCTitleStrings.getTitle(for: method)
            hormonesVC.tabBarItem.title = title
            hormonesVC.tabBarItem.badgeValue = total > 0 ? String(total) : nil
            let icon = PDImages.getDeliveryIcon(method)
            hormonesVC.tabBarItem.image = icon
            hormonesVC.tabBarItem.selectedImage = icon
            hormonesVC.awakeFromNib()
        }
    }
    
    func reflectExpiredHormoneBadgeValue() {
        if let hormoneTab = hormonesVC?.tabBarItem {
            let exp = sdk?.totalHormonesExpired ?? 0
            hormoneTab.badgeValue = exp > 0 ? "\(exp)" : nil
        }
    }
    
    func reflectDuePillBadgeValue() {
        if let totalDue = sdk?.pills.totalDue, let pillTab = pillsVC?.tabBarItem {
            pillTab.badgeValue = String(totalDue)
        }
    }
}
