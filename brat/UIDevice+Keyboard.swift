//
//  UIDevice+Keyboard.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/14/24.
//

import UIKit

extension UIDevice {
    var isPhoneOrPadWithoutKeyboard: Bool {
        if userInterfaceIdiom == .phone {
            return true
        } else if userInterfaceIdiom == .pad {
            return !isKeyboardAttached
        }
        return false
    }

    private var isKeyboardAttached: Bool {
        return KeyboardObserver.shared.isExternalKeyboardAttached
    }
}

extension UIDevice {
    var modelIdentifier: String? {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(
            bytes: Data(
                bytes: &sysinfo.machine,
                count: Int(_SYS_NAMELEN)
            ),
            encoding: .ascii
        )?.trimmingCharacters(in: .controlCharacters)
    }
}
