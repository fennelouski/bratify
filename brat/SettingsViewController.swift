//
//  SettingsViewController.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/13/24.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    private let settingsManager: SettingsManager
    
    enum SettingsSection: Int, CaseIterable {
        case wordsPerMinute
        case preferredFontSize
        case preferredFontName
        case themeSelection
        case histogramAlpha
        case neighborWordsAlpha
        case saveWithoutTitle
        case autoSaveOnPaste
        case autoPasteEnabled
        case useDummyData
        
        static var allCases: [SettingsSection] {
            var baseSet: [SettingsSection] = [
                .wordsPerMinute,
                .preferredFontSize,
                .preferredFontName,
                .themeSelection,
                .histogramAlpha,
                .neighborWordsAlpha,
                .saveWithoutTitle,
                .autoSaveOnPaste,
                .autoPasteEnabled
            ]
            if UIDevice.current.isAdmin {
                baseSet.append(.useDummyData)
            }
            return baseSet
        }
    }
    
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
        
        navigationItem.title = NSLocalizedString("Settings", comment: "The name of the settings menu.")
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        apply(settingsManager.selectedTheme)
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(
                title: NSLocalizedString("Close", comment: "Title for close key command"),
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
        case .wordsPerMinute:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTableViewCell", for: indexPath) as! SliderTableViewCell
            cell.configure(
                text: NSLocalizedString("Words Per Minute", comment: "A label indicating that the setting the user is going to change affects how many words per minute will be shown on screen."),
                with: Float(settingsManager.wordsPerMinute),
                min: 80,
                max: 900,
                mode: .integer,
                thumbImage: .Large.hareCircleFill,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.wordsPerMinute = Int(newValue)
            }
            return cell
            
        case .preferredFontSize:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepperTableViewCell", for: indexPath) as! StepperTableViewCell
            cell.configure(
                text: NSLocalizedString("Font Size", comment: "A label for the control that allows the user to change the size of text being shown."),
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
                )
                cell.detailTextLabel?.text = settingsManager.selectedTheme?.name ?? NSLocalizedString("Default", comment: "Default theme name.")
                cell.accessoryType = .disclosureIndicator
                cell.apply(settingsManager.selectedTheme)
                return cell
            }
            
        case .histogramAlpha:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "SliderTableViewCell",
                for: indexPath
            ) as! SliderTableViewCell
            cell.configure(
                text: NSLocalizedString(
                    "Histogram Alpha",
                    comment: "A label for the control that allows the user to change the alpha of the histogram."
                ),
                with: Float(settingsManager.histogramAlpha),
                min: 0,
                max: 1,
                mode: .alpha,
                thumbImage: .Large.chartBarFill,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.histogramAlpha = Double(newValue)
            }
            return cell
            
        case .neighborWordsAlpha:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTableViewCell", for: indexPath) as! SliderTableViewCell
            cell.configure(
                text: NSLocalizedString(
                    "Neighbor Words Alpha",
                    comment: "A label for the control that allows the user to change the alpha of the neighbor words."
                ),
                with: Float(settingsManager.neighborWordsAlpha),
                min: 0,
                max: 1,
                mode: .alpha,
                thumbImage: UIImage.Large.circleDotted,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.neighborWordsAlpha = Double(newValue)
            }
            return cell
            
        case .saveWithoutTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Save Without Title", comment: "A label for the control that allows the user to save without a title."),
                isOn: settingsManager.saveWithoutTitle,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.saveWithoutTitle = newValue
            }
            return cell
            
        case .autoSaveOnPaste:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Auto Save on Paste", comment: "A label for the control that allows the user to automatically save on paste."),
                isOn: settingsManager.autoSaveOnPaste,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.autoSaveOnPaste = newValue
            }
            return cell
        case .autoPasteEnabled:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Auto Paste From Clipboard", comment: "A label for the control that allows the user to automatically paste what's on their clipboard."),
                isOn: settingsManager.autoPasteEnabled,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.autoPasteEnabled = newValue
            }
            return cell
        case .useDummyData:
            guard UIDevice.current.isAdmin else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Show Sample Articles", comment: "A label for the control that allows the user to see sample articles which shipped with the app."),
                isOn: settingsManager.useDummyData,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.useDummyData = newValue
            }
            return cell
        }
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
