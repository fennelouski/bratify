//
//  FilterPresetPickerView.swift
//  brat
//

import UIKit

/// Masonry grid of filter preset preview cards, including "None".
final class FilterPresetPickerView: UIView {

    var onSelectPreset: ((FilterPreset) -> Void)?
    var onDeselectPreset: (() -> Void)?

    private var theme: ThemeModel?
    private var selectedPresetID: String?
    private var lastLayoutWidth: CGFloat = 0

    private lazy var masonryLayout: MasonryLayout = {
        let layout = MasonryLayout()
        layout.delegate = self
        layout.numberOfColumns = 2
        layout.cellPadding = 4
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: masonryLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            FilterPresetCardCell.self,
            forCellWithReuseIdentifier: FilterPresetCardCell.reuseIdentifier
        )
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = collectionView.bounds.width
        if abs(width - lastLayoutWidth) > 0.5 {
            lastLayoutWidth = width
            masonryLayout.invalidateLayout()
        }
    }

    func configure(theme: ThemeModel?, selectedPresetID: String?) {
        self.theme = theme
        self.selectedPresetID = selectedPresetID
        collectionView.reloadData()
    }

    func reloadPreviews() {
        collectionView.reloadData()
    }

    func updateSelection(selectedPresetID: String?) {
        self.selectedPresetID = selectedPresetID
        for cell in collectionView.visibleCells {
            guard let cardCell = cell as? FilterPresetCardCell,
                  let indexPath = collectionView.indexPath(for: cell),
                  FilterPreset.builtIn.indices.contains(indexPath.item) else { continue }
            let preset = FilterPreset.builtIn[indexPath.item]
            cardCell.configure(
                preset: preset,
                theme: theme,
                isSelected: preset.id == selectedPresetID
            )
        }
    }
}

extension FilterPresetPickerView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        FilterPreset.builtIn.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilterPresetCardCell.reuseIdentifier,
            for: indexPath
        ) as! FilterPresetCardCell
        let preset = FilterPreset.builtIn[indexPath.item]
        cell.configure(
            preset: preset,
            theme: theme,
            isSelected: preset.id == selectedPresetID
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let preset = FilterPreset.builtIn[indexPath.item]
        if preset.id == selectedPresetID {
            selectedPresetID = nil
            updateSelection(selectedPresetID: nil)
            onDeselectPreset?()
            return
        }
        selectedPresetID = preset.id
        updateSelection(selectedPresetID: preset.id)
        onSelectPreset?(preset)
    }
}

extension FilterPresetPickerView: MasonryLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        aspectRatioForItemAt indexPath: IndexPath
    ) -> CGFloat {
        guard FilterPreset.builtIn.indices.contains(indexPath.item) else { return 1.0 }
        return FilterPreset.builtIn[indexPath.item].layoutAspectRatio
    }
}
