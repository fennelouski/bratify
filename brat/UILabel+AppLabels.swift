//
//  UILabel+AppLabels.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/13/24.
//

import UIKit

extension UILabel {
    static var header: UILabel {
        let label = UILabel(frame: .zero)
        label.font = .appHeaderFont
        return label
    }

    static var title: UILabel {
        let label = UILabel(frame: .zero)
        label.font = .appTitleFont
        return label
    }
    
    static var subtitle: UILabel {
        let label = UILabel(frame: .zero)
        label.font = .appSubtitleFont
        return label
    }
    
    static var body: UILabel {
        let label = UILabel(frame: .zero)
        label.font = .appBodyFont
        return label
    }
}
