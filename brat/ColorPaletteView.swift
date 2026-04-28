//
//  ColorPaletteView.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

class ColorPaletteView: UIView {
    var colorModel: ColorModel? {
        didSet {
            setupView()
        }
    }

    private func setupView() {
        guard let colorModel = colorModel else { return }

        // Remove all existing subviews
        subviews.forEach { $0.removeFromSuperview() }

        let colors = [
            ("Text Color", colorModel.textColor),
            ("Background Color", colorModel.backgroundColor),
            ("Shadow Color", colorModel.shadowColor),
            ("Tint Color", colorModel.tintColor),
            ("Positive Color", colorModel.positiveColor),
            ("Destructive Color", colorModel.destructiveColor)
        ]

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10

        for (labelText, color) in colors {
            let colorView = UIView()
            colorView.backgroundColor = color
            let label: UILabel = .body
            label.text = labelText
            label.textAlignment = .center
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            colorView.addSubview(label)

            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: colorView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: colorView.centerYAnchor)
            ])

            stackView.addArrangedSubview(colorView)
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
