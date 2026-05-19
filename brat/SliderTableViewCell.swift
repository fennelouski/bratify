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
    var infoButtonTapped: (() -> Void)?

    private let infoButton = UIButton(type: .system)
    private var infoButtonWidthConstraint: NSLayoutConstraint!
    private let macIconImageView = UIImageView()
    private lazy var macLayoutInstaller = SliderMacRowLayoutInstaller(iconImageView: macIconImageView)

    var showInfoButton: Bool = false {
        didSet {
            infoButtonWidthConstraint.constant = showInfoButton ? 28 : 0
            infoButton.isHidden = !showInfoButton
            infoButton.isUserInteractionEnabled = showInfoButton
        }
    }
    
    private var thumbImage: UIImage? {
        didSet {
            guard oldValue != thumbImage else {
                return
            }
            if SliderMacRowLayout.isEnabled(for: traitCollection) {
                macLayoutInstaller.setIconImage(thumbImage, traitCollection: traitCollection)
            } else {
                slider.setThumbImage(thumbImage, for: .normal)
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceIdiom != traitCollection.userInterfaceIdiom {
            macLayoutInstaller.update(for: traitCollection)
            if SliderMacRowLayout.isEnabled(for: traitCollection) {
                slider.setThumbImage(nil, for: .normal)
                macLayoutInstaller.setIconImage(thumbImage, traitCollection: traitCollection)
            } else {
                macIconImageView.isHidden = true
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
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        contentView.addSubview(label)

        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        infoButton.setImage(UIImage(systemName: "info.circle", withConfiguration: config), for: .normal)
        infoButton.tintColor = .secondaryLabel
        infoButton.isHidden = true
        infoButton.isUserInteractionEnabled = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
        contentView.addSubview(infoButton)

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

        infoButtonWidthConstraint = infoButton.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([infoButtonWidthConstraint])

        macLayoutInstaller.install(
            in: contentView,
            style: .settings,
            margin: .su,
            label: label,
            slider: slider,
            valueLabel: valueLabel,
            infoButton: infoButton
        )
    }

    @objc private func infoButtonAction() {
        infoButtonTapped?()
    }
    
    func configure(
        text: String,
        with value: Float,
        min: Float,
        max: Float,
        mode: Mode,
        thumbImage: UIImage?,
        theme: ThemeModel?,
        showInfoButton: Bool = false
    ) {
        valueChanged = nil
        infoButtonTapped = nil
        label.text = text.localizedLowercase
        self.showInfoButton = showInfoButton
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
            valueLabel.text = "\(percentage)%".localizedLowercase
            valueChanged?(sender.value)
        case .integer:
            let roundedValue = Int(sender.value.rounded())
            valueLabel.text = "\(roundedValue)".localizedLowercase
            valueChanged?(Float(roundedValue))
        case .unknown:
            break
        }
    }
    
    func apply(_ colorModel: ColorModel) {
        slider.applyColors(from: colorModel)
        valueLabel.applyColors(from: colorModel)
        label.applyColors(from: colorModel)
        macIconImageView.tintColor = colorModel.textColor
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

