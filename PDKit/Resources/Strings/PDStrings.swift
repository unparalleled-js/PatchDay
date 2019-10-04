//
//  PDStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 6/4/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public class PDStrings: NSObject {
    
    override public var description: String {
        return "Read-only class for PatchDay Strings."
    }
    
    /**********************************
        LOCALIZABLE
    **********************************/
    
    // MARK: - Days (Localizable)
    
    public struct DayStrings {
        private static let comment = "The word 'today' displayed on a button."
        public static let today = {
            return NSLocalizedString("Today", comment: comment)
        }()
        public static let yesterday = {
            return NSLocalizedString("Yesterday", comment: comment)
        }()
        public static let tomorrow = {
            return NSLocalizedString("Tomorrow", comment: comment)
        }()
    }
    
    // MARK: - PlaceHolders
    
    public class PlaceholderStrings {
        
        private static let c1 = "On buttons with plenty of room"
        private static let c2 = "Instruction for empty patch"
        private static let c3 = "Probably won't be seen by users, so don't worry too much."
        private static let c4 = "Displayed under a button with medium room."
        
        public static let nothing_yet = {
            return NSLocalizedString("Nothing yet", comment: c1)
        }()
        public static let dotdotdot = {
            return NSLocalizedString("...", comment: c2)
        }()
        public static let new_site = {
            return NSLocalizedString("New Site", comment: c3)
        }()
        public static let new_pill = {
            return NSLocalizedString("New Pill", comment: c4)
        }()
    }
    
    // MARK: - Coloned strings (Localizable)
    
    public struct ColonedStrings {
        private static let comment1 = "Displayed on a label, plenty of room."
        private static let comment2 = "Label next to date. Easy on room."
        public static let count = {
            return NSLocalizedString("Count:", comment: comment1)
        }()
        public static let time = {
            return NSLocalizedString("Time:", comment: comment1)
        }()
        public static let firstTime = {
            return NSLocalizedString("First time:", comment: comment1)
        }()
        public static let expires = {
            return NSLocalizedString("Expires: ", comment: comment2)
        }()
        public static let expired = {
            return NSLocalizedString("Expired: ", comment: comment2)
        }()
        public static let lastInjected = {
            return NSLocalizedString("Injected: ", comment: comment2)
        }()
        public static let nextDue = {
            return NSLocalizedString("Next due: ", comment: comment2)
        }()
        public static let dateAndTimeApplied = {
            return NSLocalizedString("Date and time applied: ", comment: comment2)
        }()
        public static let dateAndTimeInjected = {
            return NSLocalizedString("Date and time injected: ", comment: comment2)
        }()
        public static let site = {
            return NSLocalizedString("Site: ", comment: comment2)
        }()
        public static let lastSiteInjected = {
            return NSLocalizedString("Site injected: ", comment: comment2)
        }()
    }
    
    // Non-Localizable
    
    // MARK: - Core data keys
    
    public struct CoreDataKeys {
        public static let persistantContainerKey = { return "patchData" }()
        public static let testContainerKey = { return "patchDataTest" }()
        public static let estrogenEntityName = { return "Estrogen" }()
        public static let estrogenProps = { return ["date", "id", "siteNameBackUp"] }()
        public static let siteEntityName = { return "Site" }()
        public static let siteProps = { return ["order", "name"] }()
        public static let pillEntityName = { return "Pill" }()
        public static let pillProps = {
            return ["name", "timesaday", "time1", "time2", "notify", "timesTakenToday", "lastTaken"]
        }()
    }
    
    // MARK: - User default keys
    
    public enum TodayKey: String {
        case nextEstroSiteName = "nextEstroSiteName"
        case nextEstroDate = "nextEstroDate"
        case nextPillToTake = "nextPillToTake"
        case nextPillTakeTime = "nextPillTakeTime"
    }
    
    public struct PillTypes {
        public static let defaultPills = { return ["T-Blocker", "Progesterone"] }()
        public static let extraPills = { return ["Estrogen", "Prolactin"] }()
    }
    
    // MARK: - Color keys

    public enum ColorKey: String {
        case OffWhite = "whitish"
        case LightBlue = "blue"
        case Gray = "cute_gray"
        case LightGray = "light_cute_gray"
        case Green = "green"
        case Pink = "pink"
        case Purple = "purple"
        case Black = "black"
    }
}