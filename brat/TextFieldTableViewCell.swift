//
//  TextFieldTableViewCell.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/13/24.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell, Themeable {
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .clear
        textField.addTarget(
            self,
            action: #selector(textFieldDidTap),
            for: .editingDidBegin
        )
        return textField
    }()
    var textFieldTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        textField.removeFromSuperview()
        textField.updateConstraints()
        contentView.addSubview(textField)
        
        if traitCollection.userInterfaceIdiom == .mac {
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .su),
                textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
                textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
                textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.su),
                textField.heightAnchor.constraint(greaterThanOrEqualToConstant: (textField.font?.pointSize ?? .su2) + .su2)
            ])
        } else {
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .su),
                textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
                textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
                textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.su),
            ])
        }
    }
    
    func configure(
        text: String,
        font: UIFont?,
        theme: ThemeModel?
    ) {
        textField.text = text
        textField.font = font
        apply(theme)
        setupViews()
        textField.sizeToFit()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.01, execute: DispatchWorkItem(block: { [weak self] in
            guard let self else {
                return
            }
            apply(theme)
        }))
    }
    
    @objc private func textFieldDidTap() {
        textFieldTapped?()
    }
    
    func apply(_ colorModel: ColorModel) {
        textField.applyColors(from: colorModel)
        textField.backgroundColor = .clear
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}
