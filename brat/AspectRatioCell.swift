import UIKit

class AspectRatioCell: UICollectionViewCell {
    
    static let reuseIdentifier = "AspectRatioCell"
    
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
        contentView.addSubview(aspectRatioLabel)
        contentView.addSubview(aspectRatioView)
        
        NSLayoutConstraint.activate([
            aspectRatioLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            aspectRatioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            aspectRatioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            aspectRatioView.topAnchor.constraint(equalTo: aspectRatioLabel.bottomAnchor, constant: 8),
            aspectRatioView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            aspectRatioView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    func configure(with width: Int, height: Int) {
        aspectRatioLabel.text = "\(width):\(height)"
        let aspectRatio = CGFloat(width) / CGFloat(height)
        
        NSLayoutConstraint.deactivate(aspectRatioView.constraints)
        NSLayoutConstraint.activate([
            aspectRatioView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            aspectRatioView.heightAnchor.constraint(equalTo: aspectRatioView.widthAnchor, multiplier: 1.0 / aspectRatio)
        ])
    }
}
