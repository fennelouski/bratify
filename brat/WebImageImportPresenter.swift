import SwiftUI
import UIKit
import WebImagePicker

/// Hosts ``WebImagePicker`` from UIKit and saves the result through the same disk path as the photo library picker.
enum WebImageImportPresenter {

    /// Presents a form-sheet ``WebImagePicker``. On success, images are written via `imageService` and `onImagePicked` receives the new asset name (first decoded image when multiple are returned).
    @MainActor
    static func present(
        from presenter: UIViewController,
        imageService: ImageService,
        initialURLString: String? = nil,
        onImagePicked: @escaping (String) -> Void
    ) {
        let configuration = WebImagePickerConfiguration(
            selectionLimit: 1,
            allowedURLSchemes: ["https"],
            extractionMode: .webView,
            initialURLString: initialURLString,
            automaticallyLoadOnAppear: initialURLString.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? false
        )

        let rootView = WebImagePicker(
            configuration: configuration,
            onCancel: {
                presenter.dismiss(animated: true)
            },
            onPick: { selections in
                guard let image = firstUIImage(from: selections) else {
                    presenter.dismiss(animated: true)
                    return
                }
                let imageName = UUID().uuidString
                imageService.saveImageToDisk(
                    image,
                    addToInMemoryCache: true,
                    withName: imageName,
                    compressionQuality: 0.7
                )
                onImagePicked(imageName)
                presenter.dismiss(animated: true)
            }
        )

        let host = UIHostingController(rootView: rootView)
        host.modalPresentationStyle = UIModalPresentationStyle.formSheet
        if let sheet = host.sheetPresentationController {
            sheet.detents = [UISheetPresentationController.Detent.large()]
            sheet.prefersGrabberVisible = true
        }
        presenter.present(host, animated: true)
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
