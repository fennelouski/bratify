//
//  UIViewController+Theme.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

extension UIViewController {
    func apply(_ theme: ThemeModel?) {
        guard let theme = theme else {
            return
        }
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let colorModel = isDarkMode ? theme.darkModeColors : theme.lightModeColors
        
        // Apply theme to navigation bar
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = colorModel.tintColor
            navigationBar.barTintColor = colorModel.backgroundColor
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: colorModel.textColor]
            navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: colorModel.textColor]
        }
        
        view.backgroundColor = colorModel.backgroundColor

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
