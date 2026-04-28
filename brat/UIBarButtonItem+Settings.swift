//
//  UIBarButtonItem+Settings.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

import UIKit

protocol SettingsReferenceable: UIViewController {
    var settingsManager: SettingsManager { get }
}

extension UIBarButtonItem {
    static func settings(_ settingsReferenceable: SettingsReferenceable) -> UIBarButtonItem {
        guard let image: UIImage = .gear else {
            return UIBarButtonItem(
                title: NSLocalizedString("Settings", comment: "The name of the button that goes to the settings menu."),
                style: .plain,
                target: settingsReferenceable,
                action: #selector(settingsReferenceable.openSettings)
            )
        }
        let gearButton = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: settingsReferenceable,
                                         action: #selector(settingsReferenceable.openSettings))
        gearButton.accessibilityLabel = NSLocalizedString("Settings", comment: "The name of the button that goes to the settings menu.")
        return gearButton
    }
}

extension UIViewController {
    @objc func openSettings() {
        guard let settingsManager = (self as? SettingsReferenceable)?.settingsManager else {
            return
        }
        let settingsVC = SettingsViewController(settingsManager: settingsManager)
        if let navigationController {
            navigationController.pushViewController(settingsVC, animated: true)
        } else {
            present(settingsVC)
        }
    }
}
