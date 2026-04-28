//
//  SliderTableViewCell.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/13/24.
//

import UIKit

class SliderTableViewCell: UITableViewCell, Themeable {
    enum Mode {
        case alpha
        case integer
        case unknown
    }
    
    var label: UILabel!
    var slider: UISlider!
    var valueLabel: UILabel!
    var mode: Mode = .unknown
    var valueChanged: ((Float) -> Void)?
    
    private var thumbImage: UIImage? {
        didSet {
            guard oldValue != thumbImage else {
                return
            }
            if traitCollection.userInterfaceIdiom != .mac {
                slider.setThumbImage(thumbImage, for: .normal)
            }
        }
    }

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
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
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(
            self,
            action: #selector(sliderValueChanged(_:)),
            for: .valueChanged
        )
        contentView.addSubview(slider)
        
        valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate(
            [
                label.topAnchor.constraint(
                    equalTo: contentView.topAnchor,
                    constant: .su
                ),
                label.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: .su
                ),
                label.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -.su
                ),
                
                slider.topAnchor.constraint(
                    equalTo: label.bottomAnchor,
                    constant: .su
                ),
                slider.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: .su2
                ),
                slider.bottomAnchor.constraint(
                    equalTo: contentView.bottomAnchor,
                    constant: -.su
                ),
                
                valueLabel.topAnchor.constraint(
                    equalTo: slider.topAnchor,
                    constant: .su
                ),
                valueLabel.leadingAnchor.constraint(
                    equalTo: slider.trailingAnchor,
                    constant: .su
                ),
                valueLabel.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -.su
                ),
                valueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: .su5),
                valueLabel.bottomAnchor.constraint(equalTo: slider.bottomAnchor)
            ]
        )
    }
    
    func configure(
        text: String,
        with value: Float,
        min: Float,
        max: Float,
        mode: Mode,
        thumbImage: UIImage?,
        theme: ThemeModel?
    ) {
        valueChanged = nil
        label.text = text
        slider.minimumValue = min
        slider.maximumValue = max
        self.mode = mode
        slider.value = value
        self.thumbImage = thumbImage
        sliderValueChanged(slider)
        apply(theme)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        switch mode {
        case .alpha:
            let percentage = Int(sender.value * 100)
            valueLabel.text = "\(percentage)%"
            valueChanged?(sender.value)
        case .integer:
            let roundedValue = Int(sender.value.rounded())
            valueLabel.text = "\(roundedValue)"
            valueChanged?(Float(roundedValue))
        case .unknown:
            break
        }
    }
    
    func apply(_ colorModel: ColorModel) {
        slider.applyColors(from: colorModel)
        valueLabel.applyColors(from: colorModel)
        label.applyColors(from: colorModel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

