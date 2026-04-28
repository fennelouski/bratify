//
//  UIDevice+Admin.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/16/24.
//

import UIKit

extension UIDevice {
    var isAdmin: Bool {
        return name.contains("iP")
    }
}
