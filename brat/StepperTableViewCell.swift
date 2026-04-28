//
//  StepperTableViewCell.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/13/24.
//

import UIKit

class StepperTableViewCell: UITableViewCell, Themeable {
    var label: UILabel!
    var stepper: CustomStepperProtocol!
    var valueLabel: UILabel!
    var valueChanged: ((Double) -> Void)?

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

        if traitCollection.userInterfaceIdiom == .mac {
            stepper = CustomStepper { [weak self] value in
                guard let self else {
                    return
                }
                valueLabel.text = "\(Int(value))".localizedLowercase
                valueChanged?(Double(value))
            }
        } else {
            stepper = UIStepper()
            stepper.addTarget(
                self,
                action: #selector(stepperValueChanged),
                for: .valueChanged
            )
        }
        stepper.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stepper)
        
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
                label.bottomAnchor.constraint(
                    equalTo: contentView.bottomAnchor,
                    constant: -.su
                ),
                
                stepper.topAnchor.constraint(
                    equalTo: label.topAnchor
                ),
                stepper.leadingAnchor.constraint(
                    equalTo: label.trailingAnchor,
                    constant: .su
                ),
                stepper.bottomAnchor.constraint(
                    equalTo: label.bottomAnchor
                ),
                stepper.heightAnchor.constraint(greaterThanOrEqualToConstant: .su5),
                stepper.widthAnchor.constraint(equalToConstant: .su15),
                
                valueLabel.topAnchor.constraint(
                    equalTo: label.topAnchor,
                    constant: .su
                ),
                valueLabel.leadingAnchor.constraint(
                    equalTo: stepper.trailingAnchor,
                    constant: .su
                ),
                valueLabel.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -.su
                ),
                valueLabel.bottomAnchor.constraint(
                    equalTo: label.bottomAnchor
                )
            ]
        )
    }
    
    func configure(
        text: String,
        with value: Double,
        min: Double,
        max: Double,
        step: Double,
        theme: ThemeModel?
    ) {
        label.text = text.localizedLowercase
        stepper.minimumValue = min
        stepper.maximumValue = max
        stepper.stepValue = value > 40 ? value * step : 1
        stepper.value = value
        valueLabel.text = "\(Int(value))".localizedLowercase
        apply(theme)
    }
    
    @objc private func stepperValueChanged() {
        let value = stepper.value
        valueLabel.text = "\(Int(value))".localizedLowercase
        valueChanged?(value)
    }
    
    func apply(_ colorModel: ColorModel) {
        stepper.applyColors(from: colorModel)
        label.applyColors(from: colorModel)
        valueLabel.applyColors(from: colorModel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

