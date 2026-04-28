//
//  Themeable.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

protocol ThemeableViewController: UIViewController {
    var theme: ThemeModel { get }
}

extension ThemeableViewController {
    func applyTheme(_ previousTraitCollection: UITraitCollection? = nil) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            view.apply(theme)
        }
    }
}

protocol Themeable {
    func apply(_ colorModel: ColorModel)
}
