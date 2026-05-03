//
//  SwitchTableViewCell.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

class SwitchTableViewCell: UITableViewCell, Themeable {

    private let titleLabel = UILabel()
    private let switchControl = UISwitch()
    private let infoButton = UIButton(type: .system)
    private var infoButtonWidthConstraint: NSLayoutConstraint!

    var valueChanged: ((Bool) -> Void)?
    var infoButtonTapped: (() -> Void)?

    var showInfoButton: Bool = false {
        didSet {
            infoButtonWidthConstraint.constant = showInfoButton ? 28 : 0
            infoButton.isHidden = !showInfoButton
            infoButton.isUserInteractionEnabled = showInfoButton
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        infoButton.setImage(UIImage(systemName: "info.circle", withConfiguration: config), for: .normal)
        infoButton.tintColor = .secondaryLabel
        infoButton.isHidden = true
        infoButton.isUserInteractionEnabled = false
        infoButton.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)

        contentView.addSubview(titleLabel)
        contentView.addSubview(infoButton)
        contentView.addSubview(switchControl)

        infoButtonWidthConstraint = infoButton.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: infoButton.leadingAnchor, constant: -4),

            infoButton.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -8),
            infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoButton.heightAnchor.constraint(equalToConstant: 28),
            infoButtonWidthConstraint,

            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    func configure(
        text: String,
        isOn: Bool,
        theme: ThemeModel?,
        showInfoButton: Bool = false
    ) {
        infoButtonTapped = nil
        titleLabel.text = text.localizedLowercase
        switchControl.isOn = isOn
        self.showInfoButton = showInfoButton
        apply(theme)
    }

    @objc private func switchValueChanged() {
        valueChanged?(switchControl.isOn)
    }

    @objc private func infoButtonAction() {
        infoButtonTapped?()
    }

    func apply(_ colorModel: ColorModel) {
        switchControl.applyColors(from: colorModel)
        titleLabel.applyColors(from: colorModel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}
