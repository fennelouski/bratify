//
//  ColorThemePickerViewController.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

class ColorThemePickerViewController: UIViewController {
    private let themes: [ThemeModel] = .defaults
    
    private let collectionView: UICollectionView
    private var completion: ((ThemeModel) -> Void)?
    private let settingsManager: SettingsManager
    private var reloadWorkItem: DispatchWorkItem?

    init(settingsManager: SettingsManager,
         completion: @escaping (ThemeModel) -> Void) {
        self.settingsManager = settingsManager
        self.completion = completion
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 20,
            right: 20
        )
        
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        super.init(
            nibName: nil,
            bundle: nil
        )
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(
            ThemeCollectionViewCell.self,
            forCellWithReuseIdentifier: "ThemeCell"
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        title = NSLocalizedString("Pick A Theme", comment: "Title of the view that allows a user to pick a set of colors with which will paint the entire app.")
        updateBackgroundColor()
        collectionView.backgroundColor = .clear
    }
    
    @objc private func close() {
        dismiss()
    }
}

// UICollectionView DataSource and Delegate
extension ColorThemePickerViewController: UICollectionViewDataSource,
                                          UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return themes.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ThemeCell",
            for: indexPath
        ) as! ThemeCollectionViewCell
        cell.themeModel = themes[indexPath.item]
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedTheme = themes[indexPath.item]
        completion?(selectedTheme)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalAvailableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - .su2 * 2
        let numberOfColumns = Int(totalAvailableWidth / .su38)
        let cellWidth = (totalAvailableWidth / CGFloat(max(1, numberOfColumns)))
        let aspectRatio: CGFloat = 16 / 16
        let cellHeight = cellWidth / aspectRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateBackgroundColor()
    }
    
    private func updateBackgroundColor() {
        view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? settingsManager.selectedTheme?.darkModeColors.backgroundColor : settingsManager.selectedTheme?.lightModeColors.backgroundColor
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        reloadCollectionViewWithDebounce()
    }
    
    func reloadCollectionViewWithDebounce() {
        // Cancel any existing work item to debounce
        reloadWorkItem?.cancel()
        
        // Create a new work item with the reloading task
        reloadWorkItem = DispatchWorkItem { [weak self] in
            self?.collectionView.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.25,
            execute: reloadWorkItem!
        )
    }
}
