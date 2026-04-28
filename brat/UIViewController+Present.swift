//
//  UIViewController+Present.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/13/24.
//

import UIKit

extension UIViewController {
    func present(_ viewControllerToPresent: UIViewController) {
        if let navigationController = self.navigationController {
            navigationController.pushViewController(viewControllerToPresent, animated: true)
        } else if let presentingNavigationController = self.presentingViewController as? UINavigationController {
            presentingNavigationController.pushViewController(viewControllerToPresent, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: viewControllerToPresent)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        }
    }
}
