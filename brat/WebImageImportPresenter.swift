import SwiftUI
import UIKit
import WebImagePicker

/// Hosts ``WebImagePicker`` from UIKit and saves the result through the same disk path as the photo library picker.
enum WebImageImportPresenter {

    /// Presents a form-sheet ``WebImagePicker`` (modal). The editor uses ``embed(_:in:container:)`` instead; keep this for other UIKit hosts.
    @MainActor
    static func present(
        from presenter: UIViewController,
        imageService: ImageService,
        initialURLString: String? = nil,
        onImagePicked: @escaping (String) -> Void
    ) {
        let host = makeHostingController(
            imageService: imageService,
            initialURLString: initialURLString,
            onCancel: {
                presenter.dismiss(animated: true)
            },
            onImagePicked: { imageName in
                onImagePicked(imageName)
                presenter.dismiss(animated: true)
            }
        )
        host.modalPresentationStyle = UIModalPresentationStyle.formSheet
        if let sheet = host.sheetPresentationController {
            sheet.detents = [UISheetPresentationController.Detent.large()]
            sheet.prefersGrabberVisible = true
        }
        presenter.present(host, animated: true)
    }

    /// Embeds ``WebImagePicker`` edge-to-edge in a container (compact bottom panel).
    @MainActor
    static func embed(
        _ host: UIHostingController<WebImagePicker>,
        in parent: UIViewController,
        container: UIView
    ) {
        embed(host, in: parent, container: container, contentLeadingAnchor: container.leadingAnchor)
    }

    /// Embeds ``WebImagePicker`` in a trailing sidebar container.
    @MainActor
    static func embed(
        _ host: UIHostingController<WebImagePicker>,
        in parent: UIViewController,
        container: UIView,
        contentLeadingAnchor: NSLayoutXAxisAnchor
    ) {
        if host.parent != nil {
            host.willMove(toParent: nil)
            host.view.removeFromSuperview()
            host.removeFromParent()
        }
        parent.addChild(host)
        container.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: container.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: contentLeadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        host.didMove(toParent: parent)
    }

    @MainActor
    static func makeHostingController(
        imageService: ImageService,
        initialURLString: String? = nil,
        onCancel: @escaping () -> Void,
        onImagePicked: @escaping (String) -> Void
    ) -> UIHostingController<WebImagePicker> {
        let configuration = makeConfiguration(initialURLString: initialURLString)
        let rootView = WebImagePicker(
            configuration: configuration,
            onCancel: onCancel,
            onPick: { selections in
                guard let imageName = saveFirstImage(from: selections, imageService: imageService) else {
                    onCancel()
                    return
                }
                onImagePicked(imageName)
            }
        )
        return UIHostingController(rootView: rootView)
    }

    /// Refreshes callbacks on a reused hosting controller (compact panel / sidebar re-present).
    @MainActor
    static func updateHostingController(
        _ host: UIHostingController<WebImagePicker>,
        imageService: ImageService,
        initialURLString: String? = nil,
        onCancel: @escaping () -> Void,
        onImagePicked: @escaping (String) -> Void
    ) {
        host.rootView = WebImagePicker(
            configuration: makeConfiguration(initialURLString: initialURLString),
            onCancel: onCancel,
            onPick: { selections in
                guard let imageName = saveFirstImage(from: selections, imageService: imageService) else {
                    onCancel()
                    return
                }
                onImagePicked(imageName)
            }
        )
    }

    static func makeConfiguration(initialURLString: String? = nil) -> WebImagePickerConfiguration {
        WebImagePickerConfiguration(
            selectionLimit: 1,
            allowedURLSchemes: ["https"],
            extractionMode: .webView,
            initialURLString: initialURLString,
            automaticallyLoadOnAppear: initialURLString.map {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            } ?? false
        )
    }

    @MainActor
    private static func saveFirstImage(
        from selections: [WebImageSelection],
        imageService: ImageService
    ) -> String? {
        guard let image = firstUIImage(from: selections) else { return nil }
        let imageName = UUID().uuidString
        imageService.saveImageToDisk(
            image,
            addToInMemoryCache: true,
            withName: imageName,
            compressionQuality: 0.7
        )
        return imageName
    }

    private static func firstUIImage(from selections: [WebImageSelection]) -> UIImage? {
        for selection in selections {
            if let image = selection.makeUIImage() {
                return image
            }
            if !selection.data.isEmpty, let image = UIImage(data: selection.data) {
                return image
            }
            if let url = selection.temporaryFileURL,
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                return image
            }
        }
        return nil
    }
}
