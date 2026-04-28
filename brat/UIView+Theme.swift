//
//  UIView+Theme.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

extension UIView {
    func apply(_ theme: ThemeModel?) {
        guard let theme else {
            return
        }
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let colorModel = isDarkMode ? theme.darkModeColors : theme.lightModeColors
        applyColors(from: colorModel)
    }

    func applyColors(from colorModel: ColorModel) {
        if let themeable = self as? Themeable {
            themeable.apply(colorModel)
            return
        }
        
        if let cell = self as? UITableViewCell {
            cell.contentView.backgroundColor = .clear
            cell.backgroundColor = .clear
            return
        } else if self.backgroundColor != nil, self.backgroundColor != UIColor.clear {
            self.backgroundColor = colorModel.backgroundColor
        }
        
        if self.tintColor != nil, self.tintColor != UIColor.clear {
            self.tintColor = colorModel.tintColor
        }

        if let label = self as? UILabel, label.textColor != nil, label.textColor != UIColor.clear {
            label.textColor = colorModel.textColor
        } else if let textField = self as? UITextField, textField.textColor != nil, textField.textColor != UIColor.clear {
            textField.textColor = colorModel.textColor
            textField.backgroundColor = colorModel.backgroundColor
        } else if let textView = self as? UITextView, textView.textColor != nil, textView.textColor != UIColor.clear {
            textView.textColor = colorModel.textColor
        } else if let histogramSliderView = self as? HistogramSliderView {
            histogramSliderView.positiveColor = colorModel.positiveColor
            histogramSliderView.negativeColor = colorModel.destructiveColor
        } else if let switchView = self as? UISwitch {
            switchView.tintColor = colorModel.tintColor
            switchView.onTintColor = colorModel.onColor
            switchView.thumbTintColor = colorModel.textColor
            switchView.layer.borderColor = colorModel.shadowColor.cgColor
            if traitCollection.userInterfaceIdiom != .mac {
                switchView.layer.borderWidth = 2
                switchView.layer.cornerRadius = 16
                switchView.clipsToBounds = true
            }
            return
        } else if let slider = self as? UISlider {
            slider.tintColor = colorModel.tintColor
        } else if let stepper = self as? UIStepper {
            stepper.tintColor = colorModel.tintColor
            stepper.backgroundColor = colorModel.backgroundColor
        }
        
        if let button = self as? UIButton, 
            button.titleColor(for: .normal) != nil,
            button.titleColor(for: .normal) != UIColor.clear {
            button.setTitleColor(colorModel.textColor, for: .normal)
        }
        
        // Recursively apply colors to subviews
        for subview in subviews {
            subview.applyColors(from: colorModel)
        }
    }
}
