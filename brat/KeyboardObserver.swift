//
//  KeyboardObserver.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/14/24.
//

import UIKit

class KeyboardObserver {
    static let shared = KeyboardObserver()

    private init() {}

    private(set) var isExternalKeyboardAttached: Bool = false

    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // Check if the keyboard height is less than 100 points, indicating an external keyboard
            isExternalKeyboardAttached = keyboardFrame.height < 100
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        isExternalKeyboardAttached = false
    }
}
