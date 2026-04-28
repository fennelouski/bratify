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
            label.textColor = contrastColor(for: color)
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

    private func contrastColor(for backgroundColor: UIColor) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Calculate brightness
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000

        // Return black or white depending on brightness
        return brightness > 0.5 ? .black : .white
    }
}
