//
//  PDTypes.swift
//  PDKit
//
//  Created by Juliya Smith on 5/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public typealias Index = Int
public typealias SiteName = String
public typealias Time = Date
public typealias Stamp = Date
public typealias Stamps = [Stamp?]?
public typealias UIIcon = UIImage

public enum PDBadgeButtonType {
    case forPatchesAndGelHormonesView
    case forInjectionsHormonesView
    case forPillsView
}

public enum DeliveryMethod {
    case Patches
    case Injections
    case Gel
}

public enum Quantity: Int {
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
}

public enum ExpirationInterval {
    case OnceDaily
    case TwiceWeekly
    case OnceWeekly
    case EveryTwoWeeks
}

public class PillExpirationInterval {

    public var value: PillExpirationInterval.Option?
    public var xDaysLoadedFromDeprecatedValue: String?

    public static func expirationIntervalUsesXDays(
        _ interval: PillExpirationInterval.Option
    ) -> Bool {
        // TODO: Add tests
        expirationIntervalThatUseXDays.contains(interval)
    }

    private static var expirationIntervalThatUseXDays: [PillExpirationInterval.Option] {
        return [.FirstXDays, .LastXDays, .XDaysOnXDaysOff]
    }

    public init(_ rawValue: String?) {
        // TODO: Add tests, test that it migrates
        if rawValue == "firstTenDays" {
            self.xDaysLoadedFromDeprecatedValue = "10"
            self.value = Option(rawValue: Option.FirstXDays.rawValue)
        } else if rawValue == "firstTwentyDays" {
            self.xDaysLoadedFromDeprecatedValue = "20"
            self.value = Option(rawValue: Option.FirstXDays.rawValue)
        } else if rawValue == "lastTenDays" {
            self.xDaysLoadedFromDeprecatedValue = "10"
            self.value = Option(rawValue: Option.LastXDays.rawValue)
        } else if rawValue == "lastTwentyDays" {
            self.xDaysLoadedFromDeprecatedValue = "10"
            self.value = Option(rawValue: Option.LastXDays.rawValue)
        } else {
            let defaultInterval = DefaultPillAttributes.expirationInterval
            self.value = Option(rawValue: defaultInterval.rawValue)
        }
    }

    public static func parseDays(
        xDays: String, expirationInterval: Option
    ) -> (daysOn: String?, daysOff: String?) {
        // TODO: Add tests
        if expirationInterval == .XDaysOnXDaysOff {
            let days = xDays.split(separator: "-")
            if days.count == 0 {
                return (daysOn: nil, daysOff: nil)
            } else if days.count == 1 {
                return (daysOn: String(days[0]), daysOff: nil)
            }
            return (daysOn: String(days[0]), daysOff: String(days[1]))
        } else if expirationInterval == .FirstXDays || expirationInterval == .LastXDays {
            return (daysOn: xDays, daysOff: nil)
        }
        return (daysOn: nil, daysOff: nil)
    }

    public enum Option: String {
        case EveryDay = "everyDay"
        case EveryOtherDay = "everyOtherDay"
        case FirstXDays = "firstXDays"
        case LastXDays = "lastXDays"
        case XDaysOnXDaysOff = "xDaysOnXDaysOff"
    }
}

// These strings cannot change - they are for retrieving from Core Data
public enum PDSetting: String {
    case DeliveryMethod = "delivMethod"
    case ExpirationInterval = "patchChangeInterval"
    case Quantity = "numberOfPatches"
    case Notifications = "notification"
    case NotificationsMinutesBefore = "remindMeUpon"
    case MentionedDisclaimer = "mentioned"
    case SiteIndex = "site_i"
}

public enum PDEntity: String, CaseIterable {
    case hormone = "Estrogen"
    case pill = "Pill"
    case site = "Site"
}

public enum ThemedAsset {
    case bg
    case border
    case button
    case evenCell
    case green
    case navBar
    case oddCell
    case purple
    case selected
    case text
    case unselected
}

public enum HormoneMutation {
    case Add
    case Edit
    case Remove
    case None
    case Empty
}

public enum SiteImageReflectionError: Error {
    case AddWithoutGivenPlaceholderImage
}

/// Keys for accessing shared data properties from User Defaults.
public enum SharedDataKey: String {
    case NextHormoneDate = "nextEstroDate"
    case NextPillToTake = "nextPillToTake"
    case NextPillTakeTime = "nextPillTakeTime"
}
