//
//  FilterPresetPickerView.swift
//  brat
//

import UIKit

/// Horizontal scroll of filter preset chips, including "None".
final class FilterPresetPickerView: UIView {

    var onSelectPreset: ((FilterPreset) -> Void)?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var theme: ThemeModel?
    private var selectedPresetID: String?
    private var presetButtons: [String: UIButton] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)

        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 36),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
    }

    func configure(theme: ThemeModel?, selectedPresetID: String?) {
        self.theme = theme
        self.selectedPresetID = selectedPresetID
        rebuildChips()
    }

    func updateSelection(selectedPresetID: String?) {
        self.selectedPresetID = selectedPresetID
        for (id, button) in presetButtons {
            applyChipAppearance(to: button, presetID: id, isSelected: id == selectedPresetID)
        }
    }

    private func rebuildChips() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        presetButtons.removeAll()

        for preset in FilterPreset.builtIn {
            let button = makeChipButton(for: preset)
            presetButtons[preset.id] = button
            stackView.addArrangedSubview(button)
        }
    }

    private func makeChipButton(for preset: FilterPreset) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(preset.name.localizedLowercase, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1

        button.accessibilityLabel = preset.name
        if preset.id == "none" {
            button.accessibilityHint = NSLocalizedString(
                "Clears filter looks and resets background zoom, flip, blur, and transparency",
                comment: "Accessibility hint for None filter preset"
            )
        }

        applyChipAppearance(to: button, presetID: preset.id, isSelected: preset.id == selectedPresetID)

        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.selectedPresetID = preset.id
            self.updateSelection(selectedPresetID: preset.id)
            self.onSelectPreset?(preset)
        }, for: .touchUpInside)

        return button
    }

    private func applyChipAppearance(to button: UIButton, presetID: String, isSelected: Bool) {
        let colors = theme?.lightModeColors
        let accent = colors?.textColor ?? UIColor.label

        if isSelected {
            button.setTitleColor(accent, for: .normal)
            button.layer.borderColor = accent.cgColor
            button.layer.borderWidth = 2
            button.backgroundColor = accent.withAlphaComponent(0.2)
            button.accessibilityTraits = [.button, .selected]
        } else {
            button.layer.borderWidth = 1
            if let colors {
                button.setTitleColor(colors.textColor, for: .normal)
                button.layer.borderColor = colors.textColor.withAlphaComponent(0.35).cgColor
                button.backgroundColor = colors.backgroundColor.withAlphaComponent(0.15)
            } else {
                button.setTitleColor(.label, for: .normal)
                button.layer.borderColor = UIColor.separator.cgColor
                button.backgroundColor = .secondarySystemBackground
            }
            button.accessibilityTraits = .button
        }
    }
}
