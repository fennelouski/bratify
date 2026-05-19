//
//  SliderMacRowLayout.swift
//  brat
//

import UIKit

enum SliderMacRowLayout {
    static func isEnabled(for traitCollection: UITraitCollection) -> Bool {
        traitCollection.userInterfaceIdiom == .mac
    }
}

enum SliderMacRowLayoutStyle {
    /// Value label vertically centered beside the slider (design controls).
    case control
    /// Value label aligned to the slider row with label stacked above (settings).
    case settings
}

/// Installs standard and macOS (icon + label beside slider) constraint sets.
final class SliderMacRowLayoutInstaller {

    private let iconImageView: UIImageView
    private weak var label: UILabel?
    private var standardConstraints: [NSLayoutConstraint] = []
    private var macConstraints: [NSLayoutConstraint] = []

    init(iconImageView: UIImageView) {
        self.iconImageView = iconImageView
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .secondaryLabel
        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconImageView.isHidden = true
        iconImageView.isAccessibilityElement = false
    }

    func install(
        in contentView: UIView,
        style: SliderMacRowLayoutStyle,
        margin: CGFloat,
        label: UILabel,
        slider: UISlider,
        valueLabel: UILabel,
        infoButton: UIButton
    ) {
        contentView.addSubview(iconImageView)
        self.label = label
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        slider.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        var standard: [NSLayoutConstraint] = [
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            label.trailingAnchor.constraint(lessThanOrEqualTo: infoButton.leadingAnchor, constant: -4),

            infoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            infoButton.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            infoButton.heightAnchor.constraint(equalToConstant: 28),

            slider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: margin),
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin),
        ]

        switch style {
        case .control:
            standard += [
                slider.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -margin),
                valueLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
                valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
                valueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
            ]
        case .settings:
            standard += [
                valueLabel.topAnchor.constraint(equalTo: slider.topAnchor, constant: margin),
                valueLabel.leadingAnchor.constraint(equalTo: slider.trailingAnchor, constant: margin),
                valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
                valueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
                valueLabel.bottomAnchor.constraint(equalTo: slider.bottomAnchor),
            ]
        }

        standardConstraints = standard

        macConstraints = [
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 6),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            slider.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: margin),
            slider.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            slider.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -margin),

            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -4),
            valueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),

            infoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin),
            infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoButton.heightAnchor.constraint(equalToConstant: 28),

            contentView.topAnchor.constraint(equalTo: slider.topAnchor, constant: -margin),
            contentView.bottomAnchor.constraint(equalTo: slider.bottomAnchor, constant: margin),
        ]

        update(for: contentView.traitCollection)
    }

    func update(for traitCollection: UITraitCollection) {
        let mac = SliderMacRowLayout.isEnabled(for: traitCollection)
        NSLayoutConstraint.deactivate(standardConstraints + macConstraints)
        NSLayoutConstraint.activate(mac ? macConstraints : standardConstraints)
        iconImageView.isHidden = !mac || iconImageView.image == nil
        label?.numberOfLines = mac ? 1 : 0
    }

    func setIconImage(_ image: UIImage?, traitCollection: UITraitCollection) {
        iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
        update(for: traitCollection)
    }
}
