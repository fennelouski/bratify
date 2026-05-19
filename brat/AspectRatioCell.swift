import UIKit

class AspectRatioCell: UICollectionViewCell {

    static let reuseIdentifier = "AspectRatioCell"

    private var dynamicConstraints: [NSLayoutConstraint] = []
    private var platformIconWidthConstraints: [NSLayoutConstraint] = []

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ratioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let imageBadgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        imageView.image = UIImage(systemName: "photo", withConfiguration: config)
        return imageView
    }()

    private let platformIconsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()

    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let aspectRatioView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.label.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
        imageBadgeImageView.isHidden = true
        setPlatformIcons([])
    }

    private func setupView() {
        contentView.clipsToBounds = true
        titleStackView.addArrangedSubview(imageBadgeImageView)
        titleStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(platformIconsStackView)
        labelsStackView.addArrangedSubview(titleStackView)
        labelsStackView.addArrangedSubview(ratioLabel)
        contentView.addSubview(aspectRatioView)
        contentView.addSubview(labelsStackView)

        NSLayoutConstraint.activate([
            imageBadgeImageView.widthAnchor.constraint(equalToConstant: 12),
            imageBadgeImageView.heightAnchor.constraint(equalToConstant: 12),
            platformIconsStackView.heightAnchor.constraint(equalToConstant: 14),

            aspectRatioView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            aspectRatioView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            labelsStackView.topAnchor.constraint(greaterThanOrEqualTo: aspectRatioView.bottomAnchor, constant: 2),
        ])
    }

    private func setPlatformIcons(_ icons: [PlatformBrandIcon]) {
        platformIconsStackView.arrangedSubviews.forEach { view in
            platformIconsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        NSLayoutConstraint.deactivate(platformIconWidthConstraints)
        platformIconWidthConstraints.removeAll()

        platformIconsStackView.isHidden = icons.isEmpty
        for icon in icons {
            let imageView = UIImageView(image: icon.image(pointSize: 12))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.accessibilityLabel = icon.accessibilityLabel
            platformIconsStackView.addArrangedSubview(imageView)
            platformIconWidthConstraints.append(
                imageView.widthAnchor.constraint(equalToConstant: 12)
            )
            platformIconWidthConstraints.append(
                imageView.heightAnchor.constraint(equalToConstant: 12)
            )
        }
        NSLayoutConstraint.activate(platformIconWidthConstraints)
    }

    func configure(
        title: String,
        ratioWidth: Int,
        ratioHeight: Int,
        platformIcons: [PlatformBrandIcon] = [],
        showsImageBadge: Bool = false,
        isSelected: Bool = false,
        selectionTint: UIColor = .tintColor
    ) {
        titleLabel.text = title.localizedLowercase
        titleStackView.isHidden = !showsImageBadge && (title.isEmpty || !platformIcons.isEmpty)
        let simplified = CanvasDimensions.simplifiedRatio(width: ratioWidth, height: ratioHeight)
        ratioLabel.text = "\(simplified.0):\(simplified.1)"
        imageBadgeImageView.isHidden = !showsImageBadge
        setPlatformIcons(platformIcons)

        let ratio = CGFloat(ratioWidth) / CGFloat(ratioHeight)
        NSLayoutConstraint.deactivate(dynamicConstraints)
        dynamicConstraints.removeAll()

        if ratio >= 1.0 {
            dynamicConstraints = [
                aspectRatioView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
                aspectRatioView.heightAnchor.constraint(equalTo: aspectRatioView.widthAnchor, multiplier: 1.0 / ratio),
            ]
        } else {
            dynamicConstraints = [
                aspectRatioView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.44),
                aspectRatioView.widthAnchor.constraint(equalTo: aspectRatioView.heightAnchor, multiplier: ratio),
            ]
        }
        NSLayoutConstraint.activate(dynamicConstraints)

        if isSelected {
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = selectionTint.cgColor
            contentView.layer.cornerRadius = 8
            aspectRatioView.layer.borderColor = selectionTint.cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.cornerRadius = 0
            aspectRatioView.layer.borderColor = UIColor.label.cgColor
        }
    }

    func configure(
        preset: AspectRatioPreset,
        showsImageBadge: Bool = false,
        isSelected: Bool = false,
        selectionTint: UIColor = .tintColor
    ) {
        let icons = preset.platformIcons
        let title = icons.isEmpty ? preset.localizedTitle : ""
        configure(
            title: title,
            ratioWidth: preset.width,
            ratioHeight: preset.height,
            platformIcons: icons,
            showsImageBadge: showsImageBadge,
            isSelected: isSelected,
            selectionTint: selectionTint
        )
        if !icons.isEmpty {
            accessibilityLabel = "\(preset.localizedTitle), \(preset.ratioLabel)"
        }
    }
}

private extension PlatformBrandIcon {
    var accessibilityLabel: String {
        switch self {
        case .instagram: return "Instagram"
        case .tiktok: return "TikTok"
        case .snapchat: return "Snapchat"
        case .youtube: return "YouTube"
        case .facebook: return "Facebook"
        case .pinterest: return "Pinterest"
        case .linkedIn: return "LinkedIn"
        case .x: return "X"
        }
    }
}
