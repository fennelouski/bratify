import UIKit

protocol AspectRatioTableViewCellDelegate: AnyObject {
    func aspectRatioChanged(to width: CGFloat, height: CGFloat, aspectRatio: CGFloat)
}

class AspectRatioTableViewCell: UITableViewCell {
    
    weak var delegate: AspectRatioTableViewCellDelegate?
    
    private var segmentControl: UISegmentedControl!
    private var label: UILabel!
    private var aspectRatios: [(
        width: CGFloat,
        height: CGFloat,
        aspectRatio: CGFloat
    )] = []
    private var settingsManager: SettingsManager? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        configureAspectRatios()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        segmentControl = UISegmentedControl()
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)
        contentView.addSubview(segmentControl)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            segmentControl.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            segmentControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureAspectRatios() {
        let screenSize = UIScreen.main.bounds.size
        let screenPortraitAspectRatio = screenSize.height / screenSize.width
        let screenLandscapeAspectRatio = screenSize.width / screenSize.height
        
        aspectRatios = [
            (
                width: min(screenSize.width, 512),
                height: min(screenSize.height, 512),
                aspectRatio: screenPortraitAspectRatio
            ),
            (
                width: 9,
                height: 16,
                aspectRatio: CGFloat(9)/CGFloat(16)
            ),
            (
                width: 1,
                height: 1,
                aspectRatio: 1
            ),
            (
                width: 16,
                height: CGFloat(9),
                aspectRatio: CGFloat(16)/CGFloat(9)
            ),
            (
                width: min(screenSize.height, 512),
                height: min(screenSize.width, 512),
                aspectRatio: screenLandscapeAspectRatio
            )
        ]
        
        aspectRatios.sort { $0.aspectRatio < $1.aspectRatio }
        
        let symbols = ["rectangle.portrait", "rectangle.portrait.and.arrow.forward", "square", "rectangle", "rectangle.and.arrow.forward"]
        for (index, aspectRatio) in aspectRatios.enumerated() {
            let title = UIImage(systemName: symbols[index])
            segmentControl.insertSegment(with: title, at: index, animated: false)
        }
        
        segmentControl.selectedSegmentIndex = 0
        segmentControlValueChanged(segmentControl)
    }
    
    @objc private func segmentControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let selectedAspectRatio = aspectRatios[selectedIndex]
        
        let maxArea: CGFloat = 500_000
        let width: CGFloat
        let height: CGFloat
        
        if selectedAspectRatio.width * selectedAspectRatio.height > maxArea {
            let scaleFactor = sqrt(
                maxArea / (
                    selectedAspectRatio.width * selectedAspectRatio.height
                )
            )
            width = selectedAspectRatio.width * scaleFactor
            height = selectedAspectRatio.height * scaleFactor
        } else {
            width = selectedAspectRatio.width
            height = selectedAspectRatio.height
        }
        
        delegate?.aspectRatioChanged(
            to: width,
            height: height,
            aspectRatio: selectedAspectRatio.aspectRatio
        )
        
        settingsManager?.xDimension = width
        settingsManager?.yDimension = height
    }
    
    func configure(
        text: String,
        theme: ThemeModel?,
        settingsManager: SettingsManager
    ) {
        label.text = text.localizedLowercase
        apply(theme)
        self.settingsManager = settingsManager
    }
}

extension AspectRatioTableViewCell: Themeable {
    func apply(_ colorModel: ColorModel) {
        segmentControl.tintColor = colorModel.tintColor
        segmentControl.selectedSegmentTintColor = colorModel.onColor
    }
}
