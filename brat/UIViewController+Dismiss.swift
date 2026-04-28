//
//  UIViewController+Dismiss.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/13/24.
//

import UIKit

extension UIViewController {
    @objc func dismiss() {
        guard let navigationController, navigationController.viewControllers.last == self else {
            dismiss(animated: true)
            return
        }
        navigationController.popViewController(animated: true)
    }
}
