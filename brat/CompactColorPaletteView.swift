//
//  CompactColorPaletteView.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

class CompactColorPaletteView: UIView, Themeable {
    var colors: ColorModel = ThemeModel.blandTheme3.lightModeColors {
        didSet {
            guard oldValue != colors else {
                return
            }
            setupStackView()
        }
    }
    
    private func setupStackView() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        let colorViews: [UIView] = colors.allColors.map { color in
            let view = UIView()
            view.backgroundColor = color
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: .su).isActive = true
            view.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            view.layer.borderWidth = 1
            return view
        }

        for colorView in colorViews {
            stackView.addArrangedSubview(colorView)
        }

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: .su),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .su),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.su),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.su)
        ])
    }
    
    func apply(_ colorModel: ColorModel) {
        // no op
    }
}

extension ColorModel {
    var allColors: [UIColor] {
        return [
            textColor,
            backgroundColor,
            shadowColor,
            tintColor,
            positiveColor,
            destructiveColor,
            onColor
        ]
    }
}
