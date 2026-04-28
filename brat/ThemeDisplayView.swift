//
//  ThemeDisplayView.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

class ThemeDisplayView: UIView, Themeable {
    var themeModel: ThemeModel? {
        didSet {
            setupView()
        }
    }

    private let nameLabel: UILabel = .title
    private let descriptionLabel: UILabel = .subtitle
    private let lightPaletteView = CompactColorPaletteView()
    private let darkPaletteView = CompactColorPaletteView()

    private func setupView() {
        guard let themeModel = themeModel else { return }

        // Remove all existing subviews
        subviews.forEach { $0.removeFromSuperview() }

        nameLabel.text = themeModel.name.localizedLowercase
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        descriptionLabel.text = themeModel.description?.localizedLowercase
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = .su
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Configure Light Mode Views
        let lightModeLabel: UILabel = .body
        lightModeLabel.text = NSLocalizedString(
            "Light Mode",
            comment: "Label indicating light mode"
        ).localizedLowercase
        lightModeLabel.textAlignment = .center
        lightModeLabel.alpha = 0.7
        
        lightPaletteView.colors = themeModel.lightModeColors
        
        // Configure Dark Mode Views
        let darkModeLabel: UILabel = .body
        darkModeLabel.text = NSLocalizedString(
            "Dark Mode",
            comment: "Label indicating dark mode"
        ).localizedLowercase
        darkModeLabel.textAlignment = .center
        darkModeLabel.alpha = 0.8

        darkPaletteView.colors = themeModel.darkModeColors

        // Add subviews to stackView
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(descriptionLabel)
        if traitCollection.userInterfaceStyle == .light {
            stackView.addArrangedSubview(lightModeLabel)
            stackView.addArrangedSubview(lightPaletteView)
            stackView.addArrangedSubview(darkModeLabel)
            stackView.addArrangedSubview(darkPaletteView)
        } else {
            stackView.addArrangedSubview(darkModeLabel)
            stackView.addArrangedSubview(darkPaletteView)
            stackView.addArrangedSubview(lightModeLabel)
            stackView.addArrangedSubview(lightPaletteView)
        }

        addSubview(stackView)

        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(
                    equalTo: topAnchor,
                    constant: .su
                ),
                stackView.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: .su
                ),
                stackView.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -.su
                ),
                stackView.bottomAnchor.constraint(
                    equalTo: bottomAnchor
                ),
                darkPaletteView.heightAnchor.constraint(
                    equalTo: lightPaletteView.heightAnchor
                ),
            ]
        )
    }
    
    func apply(_ colorModel: ColorModel) {
        nameLabel.textColor = colorModel.textColor
        descriptionLabel.textColor = colorModel.textColor
    }
}
