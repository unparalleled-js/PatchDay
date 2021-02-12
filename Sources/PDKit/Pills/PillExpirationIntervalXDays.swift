//
//  PillExpirationIntervalXDays.swift
//  PDKit
//
//  Created by Juliya Smith on 2/9/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillExpirationIntervalXDays {

    private var _one: Int?
    private var _two: Int?
    private var _isOn: Bool?
    private var _position: Int?

    init(_ xDays: String) {
        let daysList = xDays.split(separator: "-").map { String($0) }
        let daysResult = PillExpirationIntervalXDays.parseMultipleDays(daysList)
        self._one = daysResult.0
        self._two = daysResult.1

        if daysList.count > 3 {
            let position = PillExpirationIntervalXDays.parseIntFromXDaysValue(String(daysList[3]))
            self._position = position ?? 1
            let onOrOff = daysList[2]
            self._isOn = onOrOff == "on"
            return
        }

        // Only apply when `two` is used, suc has `.XDaysOnXDaysOff`.
        self._isOn = nil
        self._position = nil
    }

    public var value: String? {
        guard let dayOne = _one else { return nil }
        var builder = "\(dayOne)"
        if let dayTwo = _two {
            builder += "-\(dayTwo)"
        }
        if let isOn = _isOn, let pos = position {
            let prefix = isOn ? "-on-" : "-off-"
            builder += "\(prefix)-\(pos)"
        }
        return builder
    }

    public var isOn: Bool? {
        _isOn
    }

    public var position: Int? {
        _position
    }

    /// The integer version of the first days value in `xDays`; only applies to expiration intervals that use X days.
    public var one: Int? {
        get { _one }
        set {
            if let newValue = newValue {
                guard _daysRange ~= newValue else { return }
                _one = newValue
            } else {
                // setting to nil is allowed
                _one = newValue
            }
        }
    }

    /// The integer version of the second days value in `xDays`; only applies to `.XDaysOnXDaysOff`.
    public var two: Int? {
        get { _two }
        set {
            if let newValue = newValue {
                guard _daysRange ~= newValue else { return }
                _two = newValue
            } else {
                // setting to nil is allowed
                _two = newValue
            }
        }
    }

    /// The string value of the second days property; only applies to `.XDaysOnXDaysOff`.
    public var daysOff: String? {
        guard let days = two else { return nil }
        return String(days)
    }

    /// The string value of the first days property; only applies to expiration intervals that use X days.
    public var daysOn: String? {
        guard let days = two else { return nil }
        return String(days)
    }

    /// The supported range for any days value, 1-25.
    public static var daysRange: ClosedRange<Int> {
        1...SupportedPillExpirationIntervalDaysLimit
    }

    public func incrementDayPosition() {
        /* TODO
         start with `on-1` but dont increment until the user has taken the pill (or alternatively set a start date)

         Once the pill is “done for the day”, increment `on-2` and so on.

         Once you reach the end, on the last day, it will already be set to `6-6-on-6`, after taking the last for that day, it increments to `6-6-off-1`, and the cycle repeates.

         lastTaken is used to determine the calculation along with the current date to get the next on due date

         */
    }

    private var _daysRange: ClosedRange<Int> {
        PillExpirationIntervalXDays.daysRange
    }

    private static func parseMultipleDays(_ daysList: [String]) -> (Int?, Int?) {
        var daysOne: Int?
        var daysTwo: Int?

        if daysList.count > 0, let days = parseIntFromXDaysValue(String(daysList[0])) {
            daysOne = days
        }
        if daysList.count > 1, let days = parseIntFromXDaysValue(String(daysList[1])) {
            daysTwo = days
        }
        return (daysOne, daysTwo)
    }

    private static func parseIntFromXDaysValue(_ value: String) -> Int? {
        if value.contains("-") {
            let daysList = value.split(separator: "-").map { String($0) }
            return parseMultipleDays(daysList).0
        } else if let days = Int(value), daysRange ~= days {
            return days
        }
        return nil
    }
}
