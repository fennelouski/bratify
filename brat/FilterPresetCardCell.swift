//
//  FilterPresetCardCell.swift
//  brat
//

import UIKit

final class FilterPresetCardCell: UICollectionViewCell {

    static let reuseIdentifier = "FilterPresetCardCell"

    private var previewRequestPresetID: String?

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .tertiarySystemFill
        return imageView
    }()

    private let symbolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let footerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var footerHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewRequestPresetID = nil
        previewImageView.image = nil
        contentView.layer.borderWidth = 0
        contentView.backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let footerHeight = bounds.width * MasonryLayout.labelHeightFraction
        if footerHeightConstraint?.constant != footerHeight {
            footerHeightConstraint?.constant = footerHeight
        }
        contentView.layer.cornerRadius = 8
        previewImageView.layer.cornerRadius = 6
        previewImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func setup() {
        contentView.clipsToBounds = true
        footerStack.addArrangedSubview(symbolImageView)
        footerStack.addArrangedSubview(nameLabel)
        contentView.addSubview(previewImageView)
        contentView.addSubview(footerStack)

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        symbolImageView.preferredSymbolConfiguration = symbolConfig

        footerHeightConstraint = footerStack.heightAnchor.constraint(
            equalTo: contentView.widthAnchor,
            multiplier: MasonryLayout.labelHeightFraction
        )

        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            previewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            footerStack.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 2),
            footerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            footerStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -6),
            footerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            footerHeightConstraint!,

            symbolImageView.widthAnchor.constraint(equalToConstant: 14),
            symbolImageView.heightAnchor.constraint(equalToConstant: 14),
        ])
    }

    func configure(preset: FilterPreset, theme: ThemeModel?, isSelected: Bool) {
        previewRequestPresetID = preset.id
        nameLabel.text = preset.name.localizedLowercase

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        symbolImageView.image = UIImage(systemName: preset.symbolName, withConfiguration: symbolConfig)

        applySelectionAppearance(theme: theme, isSelected: isSelected)

        accessibilityLabel = preset.name
        if preset.id == "none" {
            accessibilityHint = NSLocalizedString(
                "Clears filter looks and resets background zoom, flip, blur, and transparency",
                comment: "Accessibility hint for None filter preset"
            )
        } else {
            accessibilityHint = nil
        }
        accessibilityTraits = isSelected ? [.button, .selected] : .button

        if let cached = FilterPresetPreviewProvider.cachedPreview(for: preset.id) {
            previewImageView.image = cached
            return
        }

        previewImageView.image = nil
        FilterPresetPreviewProvider.preview(for: preset) { [weak self] image in
            guard let self, self.previewRequestPresetID == preset.id else { return }
            self.previewImageView.image = image
        }
    }

    private func applySelectionAppearance(theme: ThemeModel?, isSelected: Bool) {
        let colors = theme?.lightModeColors
        let accent = colors?.textColor ?? UIColor.label

        if isSelected {
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = accent.cgColor
            contentView.backgroundColor = accent.withAlphaComponent(0.2)
            nameLabel.textColor = accent
            symbolImageView.tintColor = accent
        } else {
            contentView.layer.borderWidth = 1
            if let colors {
                contentView.layer.borderColor = colors.textColor.withAlphaComponent(0.35).cgColor
                contentView.backgroundColor = colors.backgroundColor.withAlphaComponent(0.15)
                nameLabel.textColor = colors.textColor
                symbolImageView.tintColor = colors.textColor
            } else {
                contentView.layer.borderColor = UIColor.separator.cgColor
                contentView.backgroundColor = .secondarySystemBackground
                nameLabel.textColor = .label
                symbolImageView.tintColor = .secondaryLabel
            }
        }
    }
}
