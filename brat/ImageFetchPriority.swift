//
//  ImageFetchPriority.swift
//  PictureGrid
//
//  Created by Nathan Fennel on 4/10/24.
//

import Foundation

enum ImageFetchPriority: CaseIterable, Comparable {
    case prefetch
    case low
    case medium
    case high

    var urlSessionTaskPriority: Float {
        switch self {
        case .low, .prefetch:
            return URLSessionTask.lowPriority
        case .medium:
            return URLSessionTask.defaultPriority
        case .high:
            return URLSessionTask.highPriority
        }
    }
}
