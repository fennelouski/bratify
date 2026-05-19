//
//  FilterPresetPickerCell.swift
//  brat
//

import UIKit

final class FilterPresetPickerCell: UITableViewCell {
    static let reuseIdentifier = "FilterPresetPickerCell"

    var onSelectPreset: ((FilterPreset) -> Void)? {
        get { pickerView.onSelectPreset }
        set { pickerView.onSelectPreset = newValue }
    }

    private let pickerView = FilterPresetPickerView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pickerView)
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            pickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            pickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            pickerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(theme: ThemeModel?, selectedPresetID: String? = nil) {
        pickerView.configure(theme: theme, selectedPresetID: selectedPresetID)
    }
}

final class FilterActionsFooterView: UIView {
    var onPrimary: (() -> Void)?
    var onSecondary: (() -> Void)?

    private let primaryButton = UIButton(type: .system)
    private let secondaryButton = UIButton(type: .system)

    init(primaryTitle: String, secondaryTitle: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        primaryButton.setTitle(primaryTitle.localizedLowercase, for: .normal)
        let secondaryVisible = !secondaryTitle.isEmpty
        secondaryButton.isHidden = !secondaryVisible
        secondaryButton.setTitle(secondaryTitle.localizedLowercase, for: .normal)
        primaryButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        secondaryButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [secondaryButton, primaryButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func primaryTapped() { onPrimary?() }
    @objc private func secondaryTapped() { onSecondary?() }
}
