//
//  CustomStepper.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/18/24.
//

import UIKit

class CustomStepper: UIControl, CustomStepperProtocol {
    var value: Double = 1
    
    var minimumValue: Double = 0
    
    var maximumValue: Double = 2
    
    var stepValue: Double = 1
    
    var isContinuous: Bool = true
    
    var wraps: Bool = false
    
    var autorepeat: Bool = false
    
    var onValueChange: (Double)->Void
    
    func increment() {
        setValue(value + stepValue)
    }
    
    func decrement() {
        setValue(value - stepValue)
    }
    
    func setValue(_ newValue: Double) {
        if newValue < minimumValue {
            value = wraps ? maximumValue : minimumValue
        } else if newValue > maximumValue {
            value = wraps ? minimumValue : maximumValue
        } else {
            value = newValue
        }
        
        onValueChange(value)
    }
    
    init(
        frame: CGRect = CGRect(x: 0, y: 0, width: 120, height: 44),
        value: Double = 1,
        minimumValue: Double = 0,
        maximumValue: Double = 2,
        stepValue: Double = 1,
        isContinuous: Bool = true,
        wraps: Bool = false,
        autorepeat: Bool = false,
        onValueChange: @escaping (Double)->Void
    ) {
        self.value = value
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.stepValue = stepValue
        self.isContinuous = isContinuous
        self.wraps = wraps
        self.autorepeat = autorepeat
        self.onValueChange = onValueChange
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(splitView)
        setupGestureRecognizers()

        // Set up constraints for splitView to fill the entire custom view
        splitView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splitView.leadingAnchor.constraint(equalTo: leadingAnchor),
            splitView.trailingAnchor.constraint(equalTo: trailingAnchor),
            splitView.topAnchor.constraint(equalTo: topAnchor),
            splitView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    fileprivate let leftLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        label.text = "-"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: .su5)
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .darkText
        return label
    }()
    fileprivate lazy var rightLabel: UILabel = {
        let label: UILabel = UILabel(
            frame: CGRect(
                x: leftLabel.bounds.maxX,
                y: leftLabel.frame.origin.y,
                width: leftLabel.bounds.width,
                height: leftLabel.bounds.height
            )
        )
        label.text = "+"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: .su5)
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .darkText
        return label
    }()
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.alpha = 0.9
        return view
    }()

    private lazy var splitView: UIView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        
        view.contentView.addSubview(leftLabel)
        view.contentView.addSubview(rightLabel)
        view.contentView.addSubview(separatorView)
        
        // Constraints for leftLabel
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -.suHalf),
            leftLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: .su4),
            leftLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: .su4)
        ])
        
        // Constraints for rightLabel
        NSLayoutConstraint.activate([
            rightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightLabel.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor),
            rightLabel.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor),
            rightLabel.widthAnchor.constraint(equalTo: leftLabel.widthAnchor)
        ])
        
        // Constraints for separatorView
        NSLayoutConstraint.activate([
            separatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            separatorView.widthAnchor.constraint(equalToConstant: 2),
            separatorView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8)
        ])

        return view
    }()
    
    private func setupGestureRecognizers() {
        let leftTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(leftLabelTapped)
        )
        leftLabel.addGestureRecognizer(leftTapGesture)
        leftLabel.isUserInteractionEnabled = true
        
        let rightTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(rightLabelTapped)
        )
        rightLabel.addGestureRecognizer(rightTapGesture)
        rightLabel.isUserInteractionEnabled = true
    }

    @objc private func leftLabelTapped() {
        decrement()
    }
    
    @objc private func rightLabelTapped() {
        increment()
    }

}
extension CustomStepper: Themeable {
    func apply(_ colorModel: ColorModel) {
        self.tintColor = colorModel.tintColor
        self.splitView.layer.borderColor = colorModel.shadowColor.cgColor
        self.separatorView.backgroundColor = colorModel.backgroundColor
        self.leftLabel.textColor = colorModel.positiveColor
        self.rightLabel.textColor = colorModel.destructiveColor
    }
}
