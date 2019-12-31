//
//  NavigationDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

protocol NavigationDelegate {
    func reflectTheme(theme: AppTheme)
    func goToHormoneDetails(_ mone: Hormonal, source: UIViewController)
    func goToPillDetails(_ pill: PillStruct, source: UIViewController)
    func goToSiteDetails(_ site: Bodily, source: UIViewController, params: SiteImageDeterminationParameters)
    func goToSettings(source: UIViewController)
    func pop(source: UIViewController)
}