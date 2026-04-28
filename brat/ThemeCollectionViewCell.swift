//
//  ThemeCollectionViewCell.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

// UICollectionView Cell
class ThemeCollectionViewCell: UICollectionViewCell {
    var themeModel: ThemeModel? = .blandTheme3 {
        didSet {
            setupView()
        }
    }
    
    private let themeDisplayView = ThemeDisplayView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(themeDisplayView)
        themeDisplayView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            themeDisplayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            themeDisplayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            themeDisplayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            themeDisplayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 2
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = .su
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        themeDisplayView.themeModel = themeModel
    }
}
