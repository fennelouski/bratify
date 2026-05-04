//
//  UIViewController+Theme.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

var themingEnabled: Bool {
    UserDefaults.standard.bool(forKey: "themingEnabled")
}

extension UIViewController {
    func apply(_ theme: ThemeModel?) {
        guard themingEnabled else { return }
        guard let theme = theme else {
            return
        }
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let colorModel = isDarkMode ? theme.darkModeColors : theme.lightModeColors
        
        // Apply theme to navigation bar
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = colorModel.tintColor
            navigationBar.barTintColor = colorModel.backgroundColor
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colorModel.readableTextColor]
            navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorModel.readableTextColor]
        }
        
        let blurTag = 99_001
        if view.viewWithTag(blurTag) == nil {
            let fullBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            fullBlur.tag = blurTag
            fullBlur.translatesAutoresizingMaskIntoConstraints = false
            fullBlur.isUserInteractionEnabled = false
            view.insertSubview(fullBlur, at: 0)
            NSLayoutConstraint.activate([
                fullBlur.topAnchor.constraint(equalTo: view.topAnchor),
                fullBlur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                fullBlur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                fullBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        view.backgroundColor = .systemBackground

        // Apply theme to view
        view.apply(theme)
        
        // Apply theme to tab bar if present
        if let tabBar = tabBarController?.tabBar {
            tabBar.isTranslucent = false
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = UIImage()
            tabBar.tintColor = colorModel.tintColor
            tabBar.barTintColor = colorModel.backgroundColor
            tabBar.unselectedItemTintColor = colorModel.shadowColor
        }
        
        // Apply theme to toolbar if present
        if let toolbar = navigationController?.toolbar {
            toolbar.tintColor = colorModel.tintColor
            toolbar.barTintColor = colorModel.backgroundColor
        }
        
        // Apply theme to navigation controller's view
        navigationController?.view.apply(theme)
    }
}
