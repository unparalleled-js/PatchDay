//
//  CodeBehindDependencies.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.

import Foundation
import PDKit

class CodeBehindDependencies<T>: DependenciesProtocol {

    let sdk: PatchDataSDK?
    var tabs: TabReflective?
    let notifications: NotificationScheduling?
    var alerts: AlertProducing?
    let nav: NavigationHandling?
    let badge: PDBadgeReflective?
    let widget: PDWidgetProtocol?

    lazy var log = PDLog<CodeBehindDependencies>()
    lazy var contextClass = String(describing: T.self)

    init(
        sdk: PatchDataSDK?,
        tabs: TabReflective?,
        notifications: NotificationScheduling?,
        alerts: AlertProducing?,
        nav: NavigationHandling?,
        badge: PDBadgeReflective?,
        widget: PDWidgetProtocol?
    ) {
        self.sdk = sdk
        self.tabs = tabs
        self.notifications = notifications
        self.alerts = alerts
        self.nav = nav
        self.badge = badge
        self.widget = widget
    }

    init() {
        if let app = AppDelegate.current {
            self.sdk = app.sdk
            self.tabs = app.tabs
            self.notifications = app.notifications
            self.alerts = app.alerts
            self.nav = app.nav
            self.badge = app.badge
            self.widget = app.widget
        } else {
            self.sdk = nil
            self.tabs = nil
            self.notifications = nil
            self.alerts = nil
            self.nav = nil
            self.badge = nil
            self.widget = nil
            log.error("App is not yet initialized before \(contextClass)")
        }
    }
}
