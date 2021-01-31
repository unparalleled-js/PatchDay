//
//  Pill.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class Pill: Swallowable {

    private var pillData: PillStruct  // Stored data
    private lazy var log = PDLog<Pill>()
    private let _now: NowProtocol

    private var now: Date { self._now.now }

    public init(pillData: PillStruct, now: NowProtocol?=nil) {
        self.pillData = pillData
        self._now = now ?? PDNow()
        if pillData.attributes.name == nil {
            self.pillData.attributes.name = PillStrings.NewPill
        }
    }

    public var id: UUID {
        get { pillData.id }
        set { pillData.id = newValue }
    }

    public var attributes: PillAttributes {
        let defaultInterval = DefaultPillAttributes.expirationInterval
        return PillAttributes(
            name: name,
            expirationInterval: pillData.attributes.expirationInterval ?? defaultInterval,
            times: PDDateFormatter.convertDatesToCommaSeparatedString(times),
            notify: notify,
            timesTakenToday: timesTakenToday,
            lastTaken: lastTaken,
            xDays: xDays
        )
    }

    public var name: String {
        get { pillData.attributes.name ?? PillStrings.NewPill }
        set { pillData.attributes.name = newValue }
    }

    public var expirationInterval: PillExpirationInterval.Option {
        get {
            let defaultInterval = DefaultPillAttributes.expirationInterval
            let storedInterval = pillData.attributes.expirationInterval
            return storedInterval ?? defaultInterval
        }
        set {
            pillData.attributes.expirationInterval = newValue
        }
    }

    public var times: [Time] {
        guard let timeString = pillData.attributes.times else { return [] }
        return DateFactory.createTimesFromCommaSeparatedString(timeString)
    }

    public func appendTime(_ time: Time) {
        var newTimes = times
        newTimes.append(time)
        newTimes = newTimes.filter { $0 != DateFactory.createDefaultDate() }
        let timeString = PDDateFormatter.convertDatesToCommaSeparatedString(newTimes)
        pillData.attributes.times = timeString
    }

    public var notify: Bool {
        get { pillData.attributes.notify ?? DefaultPillAttributes.notify }
        set { pillData.attributes.notify = newValue }
    }

    public var timesaday: Int { times.count }

    public var timesTakenToday: Int {
        pillData.attributes.timesTakenToday ?? DefaultPillAttributes.timesTakenToday
    }

    public var lastTaken: Date? {
        get { pillData.attributes.lastTaken }
        set { pillData.attributes.lastTaken = newValue }
    }

    public var xDays: String? {
        get {
            guard expirationIntervalUsesXDays else { return nil }
            return pillData.attributes.xDays
        }
        set {
            if let newValue = newValue {
                guard newValue.count <= 5 else { return }  // Don't set invalid values
                pillData.attributes.xDays = newValue
            }
        }
    }

    public var due: Date? {
        // Schedule doesn't start until taken at least once.
        guard let lastTaken = lastTaken, !lastTaken.isDefault() else { return nil }
        switch expirationInterval {
            case .EveryDay: return nextDueTimeForEveryDaySchedule
            case .EveryOtherDay: return dueDateForEveryOtherDay
            case .XDaysOnXDaysOff: return dueDateForXDaysOnXDaysOff
            case .FirstXDays: return dueDateForFirstXDays
            case .LastXDays: return dueDateForLastXDays
        }
    }

    public var isDue: Bool {
        guard timesTakenToday < timesaday else { return false }
        guard let dueDate = due else { return false }
        return now > dueDate
    }

    public var isNew: Bool {
        pillData.attributes.lastTaken == nil && !hasName
    }

    public var hasName: Bool {
        pillData.attributes.name != PillStrings.NewPill && pillData.attributes.name != ""
    }

    public var isDone: Bool {
        timesTakenToday >= timesaday && lastTaken != nil
    }

    public func set(attributes: PillAttributes) {
        name = attributes.name ?? name
        notify = attributes.notify ?? notify
        lastTaken = attributes.lastTaken ?? lastTaken
        expirationInterval = attributes.expirationInterval ?? expirationInterval
        pillData.attributes.times = attributes.times ?? pillData.attributes.times
        pillData.attributes.timesTakenToday = attributes.timesTakenToday
            ?? pillData.attributes.timesTakenToday
    }

    public func swallow() {
        guard timesTakenToday < timesaday || lastTaken == nil else { return }
        let currentTimesTaken = pillData.attributes.timesTakenToday ?? 0
        pillData.attributes.timesTakenToday = currentTimesTaken + 1
        lastTaken = now
    }

    public func awaken() {
        if timesTakenToday > 0,
            let lastDate = lastTaken as Date?,
            !lastDate.isInToday() {

            pillData.attributes.timesTakenToday = 0
        }
    }

    private var pillDueDateFinderParams: PillDueDateFinderParams {
        PillDueDateFinderParams(timesTakenToday, timesaday, times)
    }

    private var dueDateForEveryOtherDay: Date? {
        guard let lastTaken = lastTaken else { return nextDueTimeForEveryDaySchedule }
        if _now.isInYesterday(lastTaken) {
            return tomorrowAtTimeOne
        } else if isDone {
            return getTimeOne(daysFromNow: 2)
        }
        return nextDueTimeForEveryDaySchedule
    }

    private var tomorrowAtTimeOne: Date? {
        getTimeOne(daysFromNow: 1)
    }

    private func getTimeOne(daysFromNow: Int) -> Date? {
        guard times.count >= 1 else { return nil }
        return DateFactory.createDate(at: times[0], daysFromToday: daysFromNow, now: _now)
    }

    private func beginningOfDueMonthAtTimeOne(lastTaken: Date) -> Date? {
        if let nextTime = nextDueTimeForEveryDaySchedule,
            let nextMonth = Calendar.current.date(bySetting: .day, value: 1, of: lastTaken) {
            return DateFactory.createDate(on: nextMonth, at: nextTime)
        }
        return nil
    }

    private func endOfDueMonthAtTimeOne(lastTaken: Date, days: Int) -> Date? {
        var startDay: Int
        guard let daysThisMonth = now.daysInMonth() else { return nil }
        if now.dayValue() == daysThisMonth {
            if let daysNextMonth = DateFactory.createDate(
                byAddingHours: 48, to: now
            )?.daysInMonth() {
                startDay = daysNextMonth - days
            } else {
                return nil
            }
        } else {
            startDay = daysThisMonth - days
        }

        if let nextTime = nextDueTimeForEveryDaySchedule,
            let month = Calendar.current.date(bySetting: .day, value: startDay, of: lastTaken) {
            return DateFactory.createDate(on: month, at: nextTime)
        }
        return nil
    }

    private var dueDateForFirstXDays: Date? {
        guard let xDays = xDays, let days = Int(xDays) else { return nil }
        return dueDateBegin(days)
    }

    private var dueDateForLastXDays: Date? {
        guard let xDays = xDays, let days = Int(xDays) else { return nil }
        return dueDateEnd(days - 1)
    }

    private func dueDateBegin(_ begin: Int) -> Date? {
        guard let lastTaken = lastTaken else { return nextDueTimeForEveryDaySchedule }
        let currentDay = now.dayValue()
        if currentDay < begin || (currentDay == begin && !isDone) {
            return nextDueTimeForEveryDaySchedule
        }
        return beginningOfDueMonthAtTimeOne(lastTaken: lastTaken)
    }

    private func dueDateEnd(_ end: Int) -> Date? {
        guard let lastTaken = lastTaken else { return nextDueTimeForEveryDaySchedule }
        guard let daysInMonth = lastTaken.daysInMonth() else {
            return nextDueTimeForEveryDaySchedule
        }
        let dayNumber = lastTaken.dayNumberInMonth()
        // Last "5" of 30 days = 26, 27, 28, 29, 30, len=5, 30-4=26.
        if dayNumber == daysInMonth && isDone || dayNumber <= end || lastTaken < Date() {
            return endOfDueMonthAtTimeOne(lastTaken: lastTaken, days: end)
        }
        return nextDueTimeForEveryDaySchedule
    }

    private var nextDueTimeForEveryDaySchedule: Date? {
        guard timesaday <= times.count else { return nil }
        if timesTakenToday < timesaday {
            let time = times[timesTakenToday]
            return DateFactory.createTodayDate(at: time, now: _now)
        }
        return tomorrowAtTimeOne
    }

    private var dueDateForXDaysOnXDaysOff: Date? {
//        guard let lastTaken = lastTaken else { return nil }
//        let days = daysOnDaysOff
        return Date() // TODO: Calc the date
    }

    private var expirationIntervalUsesXDays: Bool {
        expirationIntervalThatUseXDays.contains(expirationInterval)
    }

    private var expirationIntervalThatUseXDays: [PillExpirationInterval.Option] {
        return [.FirstXDays, .LastXDays, .XDaysOnXDaysOff]
    }
}