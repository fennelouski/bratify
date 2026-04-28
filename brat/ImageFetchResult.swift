//
//  ImageFetchResult.swift
//  PictureGrid
//
//  Created by Nathan Fennel on 4/10/24.
//

import UIKit

enum ImageFetchResult {
    case success(image: UIImage, url: String)
    case failure(error: Error, url: String)
}
