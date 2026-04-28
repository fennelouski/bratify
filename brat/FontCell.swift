//
//  FontCell.swift
//  PictureGrid
//
//  Created by Nathan Fennel on 4/12/24.
//

import UIKit

class FontCell: UITableViewCell, Themeable {
    static let reuseIdentifier = "FontCell"
    
    private var fontNameLabel = UILabel()
    private var sampleLabel = UILabel()
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        updateForCurrentTraits()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        fontNameLabel.translatesAutoresizingMaskIntoConstraints = false
        sampleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(fontNameLabel)
        contentView.addSubview(sampleLabel)
        
        fontNameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        sampleLabel.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        sampleLabel.textAlignment = .right
        sampleLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func setupConstraints() {
        // Compact constraints (Vertical stacking)
        compactConstraints = [
            fontNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            fontNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .su),
            fontNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            
            sampleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            sampleLabel.topAnchor.constraint(equalTo: fontNameLabel.bottomAnchor, constant: .su),
            sampleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            sampleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.su)
        ]
        
        // Regular constraints (Horizontal alignment)
        regularConstraints = [
            fontNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            fontNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .su),
            fontNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.su),
            
            sampleLabel.leadingAnchor.constraint(equalTo: fontNameLabel.trailingAnchor, constant: .su2),
            sampleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            sampleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .su),
            sampleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.su),
            fontNameLabel.widthAnchor.constraint(equalTo: sampleLabel.widthAnchor)
        ]
        
        NSLayoutConstraint.activate(compactConstraints)
    }
    
    func configure(
        fontName: String,
        theme: ThemeModel?
    ) {
        fontNameLabel.text = fontName.localizedLowercase
        if traitCollection.horizontalSizeClass == .compact {
            sampleLabel.text = fontName.localizedLowercase
        } else {
            let localizedFontNameLabel = String(
                format: NSLocalizedString(
                    "FontNameLabel",
                    comment: "Label showing the font name"
                ),
                fontName
            )

            sampleLabel.text = localizedFontNameLabel.localizedLowercase
        }
        sampleLabel.font = UIFont(name: fontName, size: .su3)
        apply(theme)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateForCurrentTraits()
    }
    
    private func updateForCurrentTraits() {
        if traitCollection.horizontalSizeClass == .regular {
            NSLayoutConstraint.deactivate(compactConstraints)
            NSLayoutConstraint.activate(regularConstraints)
        } else {
            NSLayoutConstraint.deactivate(regularConstraints)
            NSLayoutConstraint.activate(compactConstraints)
        }
    }
    
    func apply(_ colorModel: ColorModel) {
        fontNameLabel.textColor = colorModel.textColor
        sampleLabel.textColor = colorModel.textColor
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}
