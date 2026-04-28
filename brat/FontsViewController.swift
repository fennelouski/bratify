//
//  FontsViewController.swift
//  PictureGrid
//
//  Created by Nathan Fennel on 4/12/24.
//

import UIKit

class FontsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var fonts: [String] = []
    private var _selectedFontName: String?
    
    var selectedFontName: String? {
        get {
            _selectedFontName
        }
        set {
            _selectedFontName = newValue
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                if let visiblePaths = tableView.indexPathsForVisibleRows {
                    if #available(iOS 15.0, *) {
                        tableView.reconfigureRows(at: visiblePaths)
                    } else {
                        tableView.reloadRows(at: visiblePaths, with: .automatic)
                    }
#if targetEnvironment(macCatalyst)
                    if #available(macCatalyst 15.0, *) {
                        tableView.reconfigureRows(at: visiblePaths)
                    } else {
                        tableView.reloadRows(at: visiblePaths, with: .automatic)
                    }
#endif
                } else {
                    tableView.reloadData()
                }
            }
        }
    }
    
    var onFontSelected: ((String) -> Void)?
    private let settingsManager: SettingsManager

    init(
        settingsManager: SettingsManager,
        onFontSelected: ((String) -> Void)? = nil
    ) {
        self.settingsManager = settingsManager
        self.onFontSelected = onFontSelected
        super.init(
            nibName: nil,
            bundle: nil
        )
        self.selectedFontName = settingsManager.preferredFontName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose Font"
        setupTableView()
        setupFonts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        apply(settingsManager.selectedTheme)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let selectedFont = selectedFontName {
            onFontSelected?(selectedFont)
        }
    }
    
    private func setupFonts() {
        fonts = UIFont.familyNames.sorted().filter { !UIFont.fontNames(forFamilyName: $0).isEmpty }
//        fonts.insert("System Font (SF Pro)", at: 0)  // Insert as the first item
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FontCell.self, forCellReuseIdentifier: FontCell.reuseIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Header")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fonts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FontCell.reuseIdentifier, for: indexPath) as! FontCell
        let fontName = fonts[indexPath.row]
        cell.configure(
            fontName: fontName,
            theme: settingsManager.selectedTheme
        )
        cell.accessoryType = (fontName == selectedFontName) ? .checkmark : .none
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let fontName = fonts[indexPath.row]
        selectedFontName = fontName
        onFontSelected?(fontName)
        tableView.reloadData()
    }
    
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")
        let noneString = NSLocalizedString(
            "None",
            comment: "Fallback text for no selected font"
        )
        let localizedSelectedFontLabel = String(
            format: NSLocalizedString(
                "SelectedFontLabel",
                comment: "Label showing the selected font"
            ),
            selectedFontName ?? noneString
        )

        // Set the text of the header label
        header?.textLabel?.text = localizedSelectedFontLabel
        header?.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        return header
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        44
    }
}
