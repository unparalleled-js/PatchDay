//
// Created by Juliya Smith on 11/30/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PillDetailViewModel: CodeBehindDependencies<PillDetailViewModel>, PillDetailViewModelProtocol {

    let index: Index
    var pill: Swallowable {
        sdk!.pills[index]!
    }
    static let DefaultViewControllerTitle = PDTitleStrings.PillTitle
    var selections = PillAttributes()
    private let now: NowProtocol?

    private var pillExpirationIntervals: [PillExpirationInterval] = [
        .EveryDay,
        .EveryOtherDay,
        .FirstTenDays,
        .FirstTwentyDays,
        .LastTenDays,
        .LastTwentyDays
    ]

    private var textToExpirationInterval: [String: PillExpirationInterval] = [
        PillStrings.Intervals.EveryDay: .EveryDay,
        PillStrings.Intervals.EveryOtherDay: .EveryOtherDay,
        PillStrings.Intervals.FirstTenDays: .FirstTenDays,
        PillStrings.Intervals.LastTenDays: .LastTenDays,
        PillStrings.Intervals.FirstTwentyDays: .FirstTwentyDays,
        PillStrings.Intervals.LastTwentyDays: .LastTwentyDays
    ]

    private var expirationIntervalToText: [PillExpirationInterval: String] = [
        .EveryDay: PillStrings.Intervals.EveryDay,
        .EveryOtherDay: PillStrings.Intervals.EveryOtherDay,
        .FirstTenDays: PillStrings.Intervals.FirstTenDays,
        .FirstTwentyDays: PillStrings.Intervals.FirstTwentyDays,
        .LastTenDays: PillStrings.Intervals.LastTenDays,
        .LastTwentyDays: PillStrings.Intervals.LastTwentyDays
    ]

    init(_ pillIndex: Index) {
        self.index = pillIndex
        self.now = nil
        super.init()
    }

    init(_ pillIndex: Index, dependencies: DependenciesProtocol, now: NowProtocol?=nil) {
        self.index = pillIndex
        self.now = now
        super.init(
            sdk: dependencies.sdk,
            tabs: dependencies.tabs,
            notifications: dependencies.notifications,
            alerts: dependencies.alerts,
            nav: dependencies.nav,
            badge: dependencies.badge
        )
    }

    var title: String {
        pill.isNew ? PDTitleStrings.NewPillTitle : PDTitleStrings.EditPillTitle
    }

    var namePickerStartIndex: Index {
        let name = selections.name ?? pill.name
        return providedPillNameSelection.firstIndex(of: name) ?? 0
    }

    var timesaday: Int {
        times.count
    }

    var expirationIntervalText: String {
        expirationIntervalToText[expirationInterval] ?? PillStrings.Intervals.all[0]
    }

    var expirationInterval: PillExpirationInterval {
        selections.expirationInterval ?? pill.expirationInterval
    }

    var expirationIntervalStartIndex: Index {
        pillExpirationIntervals.firstIndex(of: expirationInterval) ?? 0
    }

    var notifyStartValue: Bool {
        selections.notify ?? pill.notify
    }

    var providedPillNameSelection: [String] {
        PillStrings.DefaultPills + PillStrings.ExtraPills
    }

    var pillSelectionCount: Int {
        PillStrings.DefaultPills.count + PillStrings.ExtraPills.count
    }

    var times: [Time] {
        if let selectedTimes = selections.times {
            return DateFactory.createTimesFromCommaSeparatedString(selectedTimes, now: now)
        }
        // Sort, in case Swallowable impl doesn't
        let timeString = PDDateFormatter.convertDatesToCommaSeparatedString(pill.times)
        return DateFactory.createTimesFromCommaSeparatedString(timeString, now: now)
    }

    func selectTime(_ time: Time, _ index: Index) {
        var times = self.times
        guard index < times.count && index >= 0 else { return }
        for i in index..<times.count {
            if times[i] < time || i == index {
                times[i] = time
            }
        }
        let timeStrings = PDDateFormatter.convertDatesToCommaSeparatedString(times)
        selections.times = timeStrings
    }

    func setTimesaday(_ timesaday: Int) {
        guard timesaday < MaxPillTimesaday else { return }
        guard timesaday > 0 else { return }
        guard timesaday != self.timesaday else { return }
        var timesCopy = times
        if timesaday > self.timesaday {
            // Set new times to have latest time
            for i in self.timesaday..<timesaday {
                timesCopy.append(times[i-1])
            }
        } else {
            for _ in timesaday..<self.timesaday {
                timesCopy.removeLast()
            }
        }
        let newTimeString = PDDateFormatter.convertDatesToCommaSeparatedString(timesCopy)
        selections.times = newTimeString
    }

    func getPickerTimes(timeIndex: Index) -> (start: Time, min: Time?) {
        var startTime = times.tryGet(at: timeIndex) ?? Date()
        var minTime: Time?
        if timeIndex > 0 {
            minTime = self.times.tryGet(at: timeIndex - 1) ?? Date()
        }
        if let minTime = minTime, minTime > startTime {
            startTime = minTime
        }
        return (startTime, minTime)
    }

    func save() {
        notifications?.cancelDuePillNotification(pill)
        sdk?.pills.set(by: pill.id, with: selections)
        notifications?.requestDuePillNotification(pill)
        tabs?.reflectPills()
        selections = PillAttributes()
    }

    func handleIfUnsaved(_ viewController: UIViewController) {
        let save: () -> Void = {
            self.save()
            self.nav?.pop(source: viewController)
        }
        let discard: () -> Void = {
            self.selections = PillAttributes()
            if self.pill.name == PillStrings.NewPill {
                self.sdk?.pills.delete(at: self.index)
            }
            self.nav?.pop(source: viewController)
        }
        if selections.anyAttributeExists || pill.name == PillStrings.NewPill {
            self.alerts?.createUnsavedAlert(
                viewController,
                saveAndContinueHandler: save,
                discardHandler: discard
            ).present()
        } else {
            self.nav?.pop(source: viewController)
        }
    }

    /// Sets the selected name with the name at the given index and optionally returns the name.
    @discardableResult
    func selectNameFromRow(_ row: Index) -> String {
        let name = providedPillNameSelection.tryGet(at: row)
        selections.name = name
        return name ?? ""
    }

    @discardableResult
    func selectExpirationIntervalFromRow(_ row: Index) -> String {
        let rowString = PillStrings.Intervals.all.tryGet(at: row) ?? PillStrings.Intervals.all[0]
        let defaultInterval = DefaultPillAttributes.expirationInterval
        let interval = textToExpirationInterval[rowString] ?? defaultInterval
        selections.expirationInterval = interval
        return rowString
    }

    func enableOrDisablePickers(_ pickers: [UIDatePicker]) {
        let timesaday = pill.timesaday
        guard 1...pickers.count ~= timesaday else { return }
        for i in 0...timesaday - 1 {
            pickers[i].isEnabled = true
        }
        for i in timesaday..<pickers.count {
            pickers[i].isEnabled = false
        }
        assignTimePickerMinsAndMaxes(pickers)
    }

    func assignTimePickerMinsAndMaxes(_ pickers: [UIDatePicker]) {
        guard pickers.count == 4 else { return }
        if pill.timesaday > 1 {
            pickers[0].maximumDate = pickers[1].date
            pickers[1].minimumDate = pickers[0].date
        }
        if pill.timesaday > 2 {
            pickers[1].maximumDate = pickers[2].date
            pickers[2].minimumDate = pickers[1].date
        }
        if pill.timesaday > 3 {
            pickers[2].maximumDate = pickers[3].date
            pickers[3].minimumDate = pickers[2].date
        }
    }
}
