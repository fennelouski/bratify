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
    
    var valueChanged: ((Bool) -> Void)?
    
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
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    func configure(
        text: String,
        isOn: Bool,
        theme: ThemeModel?
    ) {
        titleLabel.text = text.localizedLowercase
        switchControl.isOn = isOn
        apply(theme)
    }
    
    @objc private func switchValueChanged() {
        valueChanged?(switchControl.isOn)
    }
    
    func apply(_ colorModel: ColorModel) {
        switchControl.applyColors(from: colorModel)
        titleLabel.applyColors(from: colorModel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}
