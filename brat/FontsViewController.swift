//
//  FontsViewController.swift
//  PictureGrid
//
//  Created by Nathan Fennel on 4/12/24.
//

import UIKit

class FontsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum PresentationStyle {
        case navigation
        case sidebar
    }

    var presentationStyle: PresentationStyle = .navigation
    var onDone: (() -> Void)?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var fonts: [String] = []
    private var _selectedFontName: String?
    private var didNotifySelectionDuringSession = false

    private let sidebarHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let sidebarTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()

    private lazy var sidebarDoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Done", comment: "Dismiss font picker sidebar").localizedLowercase, for: .normal)
        button.addTarget(self, action: #selector(sidebarDoneTapped), for: .touchUpInside)
        return button
    }()

    private let sidebarSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    private var tableViewTopConstraint: NSLayoutConstraint?

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
        title = "Choose Font".localizedLowercase
        setupSidebarChromeIfNeeded()
        setupTableView()
        setupFonts()
        apply(settingsManager.selectedTheme)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNotifySelectionDuringSession = false
        apply(settingsManager.selectedTheme)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard presentationStyle == .navigation || !didNotifySelectionDuringSession else {
            return
        }
        if let selectedFont = selectedFontName {
            onFontSelected?(selectedFont)
        }
    }

    @objc private func sidebarDoneTapped() {
        onDone?()
    }

    private func setupSidebarChromeIfNeeded() {
        guard presentationStyle == .sidebar else { return }

        view.addSubview(sidebarHeaderView)
        sidebarHeaderView.addSubview(sidebarTitleLabel)
        sidebarHeaderView.addSubview(sidebarDoneButton)
        view.addSubview(sidebarSeparator)

        sidebarTitleLabel.text = title

        NSLayoutConstraint.activate([
            sidebarHeaderView.topAnchor.constraint(equalTo: view.topAnchor),
            sidebarHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sidebarHeaderView.heightAnchor.constraint(equalToConstant: 44),

            sidebarTitleLabel.leadingAnchor.constraint(equalTo: sidebarHeaderView.leadingAnchor, constant: .su2),
            sidebarTitleLabel.centerYAnchor.constraint(equalTo: sidebarHeaderView.centerYAnchor),
            sidebarTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: sidebarDoneButton.leadingAnchor, constant: -.su),

            sidebarDoneButton.trailingAnchor.constraint(equalTo: sidebarHeaderView.trailingAnchor, constant: -.su2),
            sidebarDoneButton.centerYAnchor.constraint(equalTo: sidebarHeaderView.centerYAnchor),

            sidebarSeparator.topAnchor.constraint(equalTo: sidebarHeaderView.bottomAnchor),
            sidebarSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sidebarSeparator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    private func setupFonts() {
        fonts = UIFont.familyNames.sorted().filter { !UIFont.fontNames(forFamilyName: $0).isEmpty }
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FontCell.self, forCellReuseIdentifier: FontCell.reuseIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Header")

        if presentationStyle == .sidebar {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
            tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: sidebarSeparator.bottomAnchor)
        } else {
            tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: view.topAnchor)
        }

        NSLayoutConstraint.activate([
            tableViewTopConstraint!,
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
        didNotifySelectionDuringSession = true
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

        header?.textLabel?.text = localizedSelectedFontLabel.localizedLowercase
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
