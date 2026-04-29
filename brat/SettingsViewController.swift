import UIKit

class SettingsViewController: UITableViewController {
    
    private let settingsManager: SettingsManager
    
    enum SettingsSection: Int, CaseIterable {
        case preferredFontSize
        case preferredFontName
        case themeSelection
        case pixelationScale
        case autocorrectionEnabled
        case forceLowercase
        case showLabels
        case saveWithoutTitle
        case aspectRatio
        case gallerySortOrder
        case defaultTextColor
        case defaultBackgroundColor

        static var allCases: [SettingsSection] {
            let baseSet: [SettingsSection] = [
                .preferredFontSize,
                .preferredFontName,
                .themeSelection,
                .pixelationScale,
                .aspectRatio,
                .autocorrectionEnabled,
                .forceLowercase,
                .showLabels,
                .saveWithoutTitle,
                .gallerySortOrder,
                .defaultTextColor,
                .defaultBackgroundColor
            ]
            return baseSet
        }
    }

    private enum ActiveColorPicker {
        case textColor, backgroundColor
    }
    private var activeColorPicker: ActiveColorPicker?
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SliderTableViewCell.self, forCellReuseIdentifier: "SliderTableViewCell")
        tableView.register(StepperTableViewCell.self, forCellReuseIdentifier: "StepperTableViewCell")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldTableViewCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchTableViewCell")
        tableView.register(ThemeTableViewCell.self, forCellReuseIdentifier: "ThemeTableViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
        navigationItem.title = NSLocalizedString(
            "Settings",
            comment: "The name of the settings menu."
        ).localizedLowercase
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(settingsManager.selectedTheme)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apply(settingsManager.selectedTheme)
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(
                title: NSLocalizedString(
                    "Close",
                    comment: "Title for close key command"
                ),
                action: #selector(close),
                input: UIKeyCommand.inputEscape,
                modifierFlags: [.shift],
                propertyList: nil
            )
        ]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let section = SettingsSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .preferredFontSize:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepperTableViewCell", for: indexPath) as! StepperTableViewCell
            cell.configure(
                text: NSLocalizedString(
                    "Font Size",
                    comment: "A label for the control that allows the user to change the size of text being shown."
                ),
                with: settingsManager.preferredFontSize,
                min: 12,
                max: 500,
                step: 0.1,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                guard let self,
                      settingsManager.preferredFontSize != newValue else {
                    return
                }
                settingsManager.preferredFontSize = newValue
                self.tableView.reloadRows(
                    at: [IndexPath(
                        row: 0,
                        section: SettingsSection.preferredFontName.rawValue
                    )],
                    with: .automatic
                )
            }
            return cell
            
        case .preferredFontName:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            cell.configure(
                text: settingsManager.preferredFontName,
                font: UIFont(name: settingsManager.preferredFontName,
                             size: settingsManager.preferredFontSize),
                theme: settingsManager.selectedTheme
            )
            cell.textFieldTapped = { [weak self] in
                self?.showFontPicker {
                    if #available(iOS 15.0, *) {
                        self?.tableView.reconfigureRows(at: [indexPath])
                    } else {
                        self?.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
            return cell
            
        case .themeSelection:
            if let selectedTheme = settingsManager.selectedTheme {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "ThemeTableViewCell",
                    for: indexPath
                ) as! ThemeTableViewCell
                cell.configure(with: selectedTheme)
                cell.apply(settingsManager.selectedTheme)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "DefaultCell",
                    for: indexPath
                )
                cell.textLabel?.text = NSLocalizedString(
                    "Theme Selection",
                    comment: "A label for the control that allows the user to select a theme."
                ).localizedLowercase
                cell.detailTextLabel?.text = settingsManager.selectedTheme?.name ?? NSLocalizedString("Default", comment: "Default theme name.").localizedLowercase
                cell.accessoryType = .disclosureIndicator
                cell.apply(settingsManager.selectedTheme)
                return cell
            }
            
        case .pixelationScale:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SliderTableViewCell",
                for: indexPath
            ) as! SliderTableViewCell
            cell.configure(
                text: NSLocalizedString(
                    "Pixelation Scale",
                    comment: "A label for the control that allows the user to change the scale of the pixelation effect."
                ),
                with: Float(settingsManager.pixelationScale),
                min: 1,
                max: 20,
                mode: .integer,
                thumbImage: .Large.rectangleCheckered,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.pixelationScale = Double(newValue)
            }
            return cell
            
        case .aspectRatio:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DefaultCell",
                for: indexPath
            )
            let xDimension = min(Int(settingsManager.xDimension), 40)
            let yDimension = min(Int(settingsManager.yDimension), 40)
            cell.textLabel?.text = NSLocalizedString(
                "Aspect Ratio",
                comment: "A label for the control that allows the user to select the aspect ratio."
            ).localizedLowercase
            cell.detailTextLabel?.text = "\(xDimension):\(yDimension)"
            cell.accessoryType = .disclosureIndicator
            cell.apply(settingsManager.selectedTheme)
            return cell
                        
        case .saveWithoutTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString(
                    "Save Without Title",
                    comment: "A label for the control that allows the user to save without a title."
                ),
                isOn: settingsManager.saveWithoutTitle,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.saveWithoutTitle = newValue
            }
            return cell
        case .autocorrectionEnabled:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString(
                    "Autocorrection Enabled",
                    comment: "A label for the control that allows the user to automatically save on paste."
                ).localizedLowercase,
                isOn: settingsManager.autocorrectionEnabled,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.autocorrectionEnabled = newValue
            }
            return cell
        case .forceLowercase:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString(
                    "Force Lowercase",
                    comment: "A label for the control that forces text to lowercase."
                ).localizedLowercase,
                isOn: settingsManager.forceLowercase,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.forceLowercase = newValue
            }
            return cell
        case .showLabels:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString(
                    "Show Labels",
                    comment: "A label for the control that shows labels for the user if they prefer."
                ).localizedLowercase,
                isOn: settingsManager.showLabels,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.showLabels = newValue
            }
            return cell

        case .gallerySortOrder:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString(
                "Sort Order",
                comment: "A label for the control that sets gallery sort order."
            ).localizedLowercase
            cell.detailTextLabel?.text = settingsManager.gallerySortOrder.displayName.localizedLowercase
            cell.accessoryType = .disclosureIndicator
            cell.apply(settingsManager.selectedTheme)
            return cell

        case .defaultTextColor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString(
                "Default Text Color",
                comment: "A label for the control that sets the default text color."
            ).localizedLowercase
            cell.detailTextLabel?.text = nil
            cell.accessoryView = colorSwatch(for: UIColor(hexString: settingsManager.textColorHex) ?? .white)
            cell.apply(settingsManager.selectedTheme)
            return cell

        case .defaultBackgroundColor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString(
                "Default Background Color",
                comment: "A label for the control that sets the default background color."
            ).localizedLowercase
            cell.detailTextLabel?.text = nil
            cell.accessoryView = colorSwatch(for: UIColor(hexString: settingsManager.backgroundColorHex) ?? .white)
            cell.apply(settingsManager.selectedTheme)
            return cell
        }
    }

    private func colorSwatch(for color: UIColor) -> UIView {
        let swatch = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        swatch.backgroundColor = color
        swatch.layer.cornerRadius = 6
        swatch.layer.borderWidth = 1
        swatch.layer.borderColor = UIColor.separator.cgColor
        return swatch
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        
        if section == .themeSelection {
            let themePickerVC = ColorThemePickerViewController(settingsManager: settingsManager) { [weak self] selectedTheme in
                self?.settingsManager.selectedTheme = selectedTheme
                UIView.animate(withDuration: 0.35,
                               delay: 0,
                               options: .curveEaseInOut) {
                    self?.apply(selectedTheme)
                } completion: { _ in
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }

            }
            navigationController?.pushViewController(themePickerVC, animated: true)
        } else if section == .aspectRatio {
            let aspectRatioPickerVC = AspectRatioPickerViewController(settingsManager: settingsManager)
            aspectRatioPickerVC.delegate = self
            navigationController?.pushViewController(aspectRatioPickerVC, animated: true)
        } else if section == .gallerySortOrder {
            showSortOrderPicker(at: indexPath)
        } else if section == .defaultTextColor {
            activeColorPicker = .textColor
            let initial = UIColor(hexString: settingsManager.textColorHex) ?? .white
            showColorPicker(initialColor: initial, at: indexPath)
        } else if section == .defaultBackgroundColor {
            activeColorPicker = .backgroundColor
            let initial = UIColor(hexString: settingsManager.backgroundColorHex) ?? .white
            showColorPicker(initialColor: initial, at: indexPath)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func showFontPicker(_ completion: @escaping () -> Void) {
        let fontViewController = FontsViewController(settingsManager: settingsManager) { [weak self] fontName in
            guard let self else {
                return
            }
            settingsManager.preferredFontName = fontName
            completion()
        }
        
        present(fontViewController)
    }
    
    private func showSortOrderPicker(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: NSLocalizedString("Sort Order", comment: "Title for sort order picker"),
            message: nil,
            preferredStyle: .actionSheet
        )
        for order in GallerySortOrder.allCases {
            let isCurrent = settingsManager.gallerySortOrder == order
            let title = isCurrent ? "✓ \(order.displayName)" : order.displayName
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self else { return }
                settingsManager.gallerySortOrder = order
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Cancel action"),
            style: .cancel
        ))
        if let popover = alert.popoverPresentationController,
           let cell = tableView.cellForRow(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        present(alert, animated: true)
    }

    private func showColorPicker(initialColor: UIColor, at indexPath: IndexPath) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = initialColor
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }

    @objc private func close() {
        dismiss()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.backgroundColor = view.adaptiveBackgroundColor()
        apply(settingsManager.selectedTheme)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: DispatchWorkItem(block: { [weak self] in
            guard let self else {
                return
            }
            apply(settingsManager.selectedTheme)
            tableView.reloadSections(IndexSet(integer: SettingsSection.themeSelection.rawValue),
                                     with: .fade)
        }))
    }
}

extension SettingsViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        applySelectedColor(viewController.selectedColor)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        applySelectedColor(viewController.selectedColor)
        activeColorPicker = nil
    }

    private func applySelectedColor(_ color: UIColor) {
        switch activeColorPicker {
        case .textColor:
            settingsManager.textColorHex = color.toHexString()
            tableView.reloadRows(at: [IndexPath(row: 0, section: SettingsSection.defaultTextColor.rawValue)], with: .none)
        case .backgroundColor:
            settingsManager.backgroundColorHex = color.toHexString()
            tableView.reloadRows(at: [IndexPath(row: 0, section: SettingsSection.defaultBackgroundColor.rawValue)], with: .none)
        case nil:
            break
        }
    }
}

extension SettingsViewController: AspectRatioPickerDelegate {
    func didSelectAspectRatio(width: Int, height: Int) {
        let maxDimension: CGFloat = 512.0
        let maxPixels: CGFloat = 500_000.0
        
        var newWidth = CGFloat(width)
        var newHeight = CGFloat(height)
        
        // Ensure the aspect ratio is maintained and constraints are applied
        if newWidth > maxDimension || newHeight > maxDimension || (newWidth * newHeight > maxPixels) {
            let aspectRatio = newWidth / newHeight
            
            if newWidth > newHeight {
                newWidth = min(maxDimension, sqrt(maxPixels * aspectRatio))
                newHeight = newWidth / aspectRatio
            } else {
                newHeight = min(maxDimension, sqrt(maxPixels / aspectRatio))
                newWidth = newHeight * aspectRatio
            }
        }
        
        settingsManager.xDimension = newWidth
        settingsManager.yDimension = newHeight
        
        // Update the aspect ratio display in the settings
        tableView.reloadRows(at: [IndexPath(row: 0, section: SettingsSection.aspectRatio.rawValue)], with: .automatic)
    }
}
