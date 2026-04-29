//
//  ColorContextView.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

class ColorContextView: UIView {
    var colorModel: ColorModel? {
        didSet {
            setupView()
        }
    }

    var sampleText: String = "Sample Text" {
        didSet {
            setupView()
        }
    }

    private func setupView() {
        guard let colorModel = colorModel else { return }

        // Remove all existing subviews
        subviews.forEach { $0.removeFromSuperview() }

        let labels = [
            ("Text Color", colorModel.textColor),
            ("Background Color", colorModel.backgroundColor),
            ("Shadow Color", colorModel.shadowColor),
            ("Tint Color", colorModel.tintColor),
            ("Positive Color", colorModel.positiveColor),
            ("Destructive Color", colorModel.destructiveColor)
        ]

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10

        for (labelText, color) in labels {
            let label: UILabel = .subtitle
            label.text = "\(labelText): \(sampleText)".localizedLowercase
            label.backgroundColor = color
            label.textAlignment = .center
            label.textColor = colorModel.textColor.readable(on: color)
            stackView.addArrangedSubview(label)
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
