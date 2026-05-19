//
//  BackgroundImagePickerViewController.swift
//  brat
//

import PhotosUI
import UIKit

/// Embeddable photo library picker for the leading Mac/Catalyst sidebar.
final class BackgroundImagePickerViewController: UIViewController, PHPickerViewControllerDelegate {

    var onDone: (() -> Void)?
    var onImagePicked: ((UIImage) -> Void)?

    private var embeddedPhotoPicker: PHPickerViewController?

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
        button.setTitle(
            NSLocalizedString("Done", comment: "Dismiss background image picker sidebar").localizedLowercase,
            for: .normal
        )
        button.addTarget(self, action: #selector(sidebarDoneTapped), for: .touchUpInside)
        return button
    }()

    private let sidebarSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        sidebarTitleLabel.text = NSLocalizedString(
            "Background Image",
            comment: "Title for background image picker sidebar"
        ).localizedLowercase
        setupSidebarChrome()
        setupPhotoPickerIfNeeded()
    }

    @objc private func sidebarDoneTapped() {
        onDone?()
    }

    private func setupSidebarChrome() {
        view.addSubview(sidebarHeaderView)
        sidebarHeaderView.addSubview(sidebarTitleLabel)
        sidebarHeaderView.addSubview(sidebarDoneButton)
        view.addSubview(sidebarSeparator)

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

    private func setupPhotoPickerIfNeeded() {
        guard embeddedPhotoPicker == nil else { return }

        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        embeddedPhotoPicker = picker

        addChild(picker)
        view.addSubview(picker.view)
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.view.topAnchor.constraint(equalTo: sidebarSeparator.bottomAnchor),
            picker.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            picker.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            picker.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        picker.didMove(toParent: self)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let result = results.first else { return }

        let provider = result.itemProvider
        guard provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.onImagePicked?(image)
            }
        }
    }
}
