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
            (
                NSLocalizedString(
                    "Text Color",
                    comment: "Color used for text"
                ),
                colorModel.textColor
            ),
            (
                NSLocalizedString(
                    "Background Color",
                    comment: "Color used for the background"
                ),
                colorModel.backgroundColor
            ),
            (
                NSLocalizedString(
                    "Shadow Color",
                    comment: "Color used for shadows"
                ),
                colorModel.shadowColor
            ),
            (
                NSLocalizedString(
                    "Tint Color",
                    comment: "Color used for tinting elements"
                ),
                colorModel.tintColor
            ),
            (
                NSLocalizedString(
                    "Positive Color",
                    comment: "Color representing positivity"
                ),
                colorModel.positiveColor
            ),
            (
                NSLocalizedString(
                    "Destructive Color",
                    comment: "Color representing destructive actions"
                ),
                colorModel.destructiveColor
            )
        ]

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10

        for (labelText, color) in colors {
            let colorView = UIView()
            colorView.backgroundColor = color
            let label: UILabel = .body
            label.text = labelText.localizedLowercase
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
