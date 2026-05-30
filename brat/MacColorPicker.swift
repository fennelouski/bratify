import UIKit

class MacColorPicker {
    static let shared = MacColorPicker()
    private static let delegate = ColorPickerDelegate()
    
    private lazy var colorPickerDelegate: ColorPickerDelegate = ColorPickerDelegate(completion: { _ in })

    private init() {}

    private static func keyRootViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        let window = scene?.windows.first(where: \.isKeyWindow) ?? scene?.windows.first
        return window?.rootViewController
    }

    func showColorPicker(initialColor: UIColor, completion: @escaping (UIColor) -> Void) {
        colorPickerDelegate = ColorPickerDelegate(completion: completion)
        #if targetEnvironment(macCatalyst)
        // Use CustomColorPickerViewController for Mac Catalyst
        let colorPicker = CustomColorPickerViewController()
        colorPicker.delegate = MacColorPicker.delegate
        MacColorPicker.delegate.completion = completion
        
        // Assuming you have a way to present this color picker from the current context
        if let rootVC = Self.keyRootViewController() {
            rootVC.present(colorPicker, animated: true, completion: nil)
        }
        #else
        // Use UIColorPickerViewController for iOS
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = initialColor
        colorPicker.delegate = colorPickerDelegate
        
        // Assuming you have a way to present this color picker from the current context
        if let rootVC = Self.keyRootViewController() {
            rootVC.present(colorPicker, animated: true, completion: nil)
        }
        #endif
    }

    private class ColorPickerDelegate: NSObject, UIColorPickerViewControllerDelegate, CustomColorPickerDelegate {
        var completion: ((UIColor) -> Void)? = nil

        init(completion: ((UIColor) -> Void)? = nil) {
            self.completion = completion
        }

        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            completion?(viewController.selectedColor)
        }

        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            completion?(viewController.selectedColor)
        }

        func customColorPicker(_ picker: CustomColorPickerViewController, didSelect color: UIColor) {
            completion?(color)
        }
    }
}
