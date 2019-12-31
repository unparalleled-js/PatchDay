//
//  UIControlsExtensions.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


extension UIView {

    func tryGetKeyFromButtonMetadata() -> String? {
        if let key = restorationIdentifier?.dropLast() {
            return String(key)
        }
        return nil
    }
}


extension UIControl {

    func showAsEnabled() {
        isEnabled = true
        isHidden = false
    }

    func hideAsDisabled() {
        isEnabled = false
        isHidden = true
    }

    func replaceTarget(_ baseTarget: Any?, newAction: Selector, for event: UIControl.Event = .touchUpInside) {
        removeTarget(nil, action: nil, for: .allEvents)
        addTarget(baseTarget, action: newAction, for: event)
    }

    func removeTarget(_ source: Any, action: Selector) {
        removeTarget(source, action: action, for: .allEditingEvents)
    }

    func addTarget(_ source: Any, action: Selector) {
        addTarget(source, action: action, for: .touchUpInside)
    }
}

extension UIPickerView {

    func selectRow(_ row: Int) {
        selectRow(row, inComponent: 0, animated: false)
    }
    
    func getSelectedRow() -> Int {
        selectedRow(inComponent: 0)
    }
}

extension UISwitch {
    
    func setOn(_ on: Bool) {
        setOn(on, animated: false)
    }
}

extension UIButton {

    func setTitleForNormalAndDisabled(_ title: String) {
        setTitle(title, for: .normal)
        setTitle(title, for: .disabled)
    }

    func setTitle(_ title: String) {
        setTitle(title, for: .normal)
    }

    func setTitleColor(_ color: UIColor?) {
        setTitleColor(color, for: .normal)
    }

    func restoreSuffix() -> Int? {
        if let restoreId = restorationIdentifier {
            return Int("\(restoreId.suffix(1))")
        }
        return -1
    }
}