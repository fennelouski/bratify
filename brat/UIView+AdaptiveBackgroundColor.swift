//
//  UIView+AdaptiveBackgroundColor.swift
//  PictureGrid
//
//  Created by Nathan Fennel on 4/13/24.
//

import UIKit

extension UIView {
    func adaptiveBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    #if targetEnvironment(macCatalyst)
                    // Slightly lighter black for macOS
                    return UIColor(white: 0.1, alpha: 1)
                    #else
                    // Standard dark mode color for iOS
                    return UIColor.black
                    #endif
                case .light, .unspecified:
                    // Standard light mode color
                    return UIColor.white
                @unknown default:
                    // Fallback to system background color
                    return UIColor.systemBackground
                }
            }
        } else {
            // Fallback for versions below iOS 13
            return UIColor.white
        }
    }
}
