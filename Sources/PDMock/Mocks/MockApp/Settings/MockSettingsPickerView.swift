//
//  MockSettingsPickerView.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class MockSettingsPickerView: SettingsPickerViewing, Equatable {

    public init() {}

    public var setting: PDSetting? = nil
    public var getStartRow: () -> Index = { 0 }
    public var options: [String]? = nil
    public var count: Int { options?.count ?? 0 }
    public var selected: String? = nil
    public var isHidden: Bool = false
    public var view: UIPickerView = UIPickerView()

    public static func == (lhs: MockSettingsPickerView, rhs: MockSettingsPickerView) -> Bool {
        lhs.view == rhs.view
    }

    public var openCallCount = 0
    public func open() {
        openCallCount += 1
    }

    public var closeCallArgs: [Bool] = []
    public func close(setSelectedRow: Bool) {
        closeCallArgs.append(setSelectedRow)
    }

    public var selectRowCallArgs: [Int] = []
    public var selectRowReturnValue = 0
    public func selectedRow(inComponent component: Int) -> Int {
        selectRowCallArgs.append(component)
        return selectRowReturnValue
    }

    public var selectCallArgs: [Index] = []
    public func select(_ row: Index) {
        selectCallArgs.append(row)
    }
}