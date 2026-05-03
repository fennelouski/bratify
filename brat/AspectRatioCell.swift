import UIKit

class AspectRatioCell: UICollectionViewCell {

    static let reuseIdentifier = "AspectRatioCell"

    private var dynamicConstraints: [NSLayoutConstraint] = []

    private let aspectRatioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

    private func setupView() {
        contentView.clipsToBounds = true
        contentView.addSubview(aspectRatioLabel)
        contentView.addSubview(aspectRatioView)

        NSLayoutConstraint.activate([
            aspectRatioLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            aspectRatioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            aspectRatioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            aspectRatioView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            aspectRatioView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    func configure(with width: Int, height: Int) {
        aspectRatioLabel.text = "\(width):\(height)"
        let ratio = CGFloat(width) / CGFloat(height)

        NSLayoutConstraint.deactivate(dynamicConstraints)
        dynamicConstraints.removeAll()

        if ratio >= 1.0 {
            dynamicConstraints = [
                aspectRatioView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
                aspectRatioView.heightAnchor.constraint(equalTo: aspectRatioView.widthAnchor, multiplier: 1.0 / ratio),
            ]
        } else {
            dynamicConstraints = [
                aspectRatioView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.75),
                aspectRatioView.widthAnchor.constraint(equalTo: aspectRatioView.heightAnchor, multiplier: ratio),
            ]
        }

        NSLayoutConstraint.activate(dynamicConstraints)
    }
}
