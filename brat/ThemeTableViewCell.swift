//
//  ThemeTableViewCell.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

class ThemeTableViewCell: UITableViewCell, Themeable {

    private let nameLabel: UILabel = {
        let label: UILabel = .title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label: UILabel = .subtitle
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let darkModeColorsLabel: UILabel = {
        let label: UILabel = .dynamicTypeLabel
        label.text = NSLocalizedString("Dark Mode Colors", comment: "Label indicating colors for dark mode").localizedLowercase
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let lightModeColorsLabel: UILabel = {
        let label: UILabel = .dynamicTypeLabel
        label.text = NSLocalizedString("Light Mode Colors", comment: "Label indicating colors for light mode").localizedLowercase
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    private let darkModeColorPaletteView: CompactColorPaletteView = {
        let view = CompactColorPaletteView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let lightModeColorPaletteView: CompactColorPaletteView = {
        let view = CompactColorPaletteView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(darkModeColorsLabel)
        contentView.addSubview(darkModeColorPaletteView)
        contentView.addSubview(lightModeColorsLabel)
        contentView.addSubview(lightModeColorPaletteView)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .su),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: .suHalf),
            
            darkModeColorsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            darkModeColorsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            darkModeColorsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: .su),
            
            darkModeColorPaletteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            darkModeColorPaletteView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            darkModeColorPaletteView.topAnchor.constraint(equalTo: darkModeColorsLabel.bottomAnchor, constant: .suHalf),
            darkModeColorPaletteView.heightAnchor.constraint(equalToConstant: .su5),
            
            lightModeColorsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            lightModeColorsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            lightModeColorsLabel.topAnchor.constraint(equalTo: darkModeColorPaletteView.bottomAnchor, constant: .su),
            
            lightModeColorPaletteView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .su2),
            lightModeColorPaletteView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.su2),
            lightModeColorPaletteView.topAnchor.constraint(equalTo: lightModeColorsLabel.bottomAnchor, constant: .suHalf),
            lightModeColorPaletteView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.su),
            lightModeColorPaletteView.heightAnchor.constraint(equalTo: darkModeColorPaletteView.heightAnchor)
        ])
    }
    
    func configure(with theme: ThemeModel) {
        nameLabel.text = theme.name.localizedLowercase
        descriptionLabel.text = theme.description?.localizedLowercase
        darkModeColorPaletteView.colors = theme.darkModeColors
        lightModeColorPaletteView.colors = theme.lightModeColors
    }
    
    func apply(_ colorModel: ColorModel) {
        contentView.backgroundColor = colorModel.backgroundColor
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
}
