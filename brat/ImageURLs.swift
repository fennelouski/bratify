//
//  ImageURLs.swift
//  PictureGrid
//
//  Created by Nathan Fennel on 4/20/24.
//

import Foundation

struct ImageURLs: Codable, Equatable, Hashable {
    enum Size: CaseIterable, Codable, Equatable, Hashable {
        case thumbnail
        case small
        case medium
        case regular
        case large
        case raw
    }
    
    let thumbnail: String?
    let small: String?
    let medium: String?
    let regular: String?
    let large: String?
    let raw: String?
    
    init(thumbnail: String? = nil,
         small: String? = nil,
         medium: String? = nil,
         regular: String? = nil,
         large: String? = nil,
         raw: String? = nil) {
        self.thumbnail = thumbnail
        self.small = small
        self.medium = medium
        self.regular = regular
        self.large = large
        self.raw = raw
    }
}

extension ImageURLs {
    func closestSize(to size: ImageURLs.Size) -> String? {
        switch size {
        case .thumbnail:
            return thumbnail ?? small ?? medium ?? regular ?? large ?? raw
        case .small:
            return small ?? thumbnail ?? medium ?? regular ?? large ?? raw
        case .medium:
            return medium ?? regular ?? small ?? large ?? raw ?? thumbnail
        case .regular:
            return regular ?? large ?? raw ?? medium ?? small ?? thumbnail
        case .large:
            return large ?? raw ?? regular ?? medium ?? small ?? thumbnail
        case .raw:
            return raw ?? large ?? regular ?? medium ?? small ?? thumbnail
        }
    }
    
    func sizesToTry(to size: ImageURLs.Size?) -> [String] {
        guard let size else {
            return []
        }
        switch size {
        case .thumbnail:
            return [thumbnail, small, medium, regular, large, raw].compactMap({ $0 })
        case .small:
            return [small, thumbnail, medium, regular, large, raw].compactMap({ $0 })
        case .medium:
            return [medium, regular, small, large, raw, thumbnail].compactMap({ $0 })
        case .regular:
            return [regular, large, raw, medium, small, thumbnail].compactMap({ $0 })
        case .large:
            return [large, raw, regular, medium, small, thumbnail].compactMap({ $0 })
        case .raw:
            return [raw, large, regular, medium, small, thumbnail].compactMap({ $0 })
        }
    }
    
    func contains(_ urlToCheck: String?) -> Bool {
        guard let url = urlToCheck else {
            return false
        }
        
        if let thumbnail,
           thumbnail == urlToCheck {
            return true
        }
        
        if let small,
           small == urlToCheck {
            return true
        }
        
        if let medium,
           medium == urlToCheck {
            return true
        }
        
        if let regular,
           regular == urlToCheck {
            return true
        }
        
        if let large,
           large == urlToCheck {
            return true
        }
        
        if let raw,
           raw == urlToCheck {
            return true
        }
        
        return false
    }
}

extension ImageURLs: Selectable {
    var selectableId: any Hashable {
        return id
    }
    
    var id: String {
        return sizesToTry(to: Size.allCases.last).first ?? ""
    }
}
