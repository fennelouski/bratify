//
//  SettingsManager.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/13/24.
//

import Foundation

class SettingsManager {
    // Thread-safe access pattern
    private let queue = DispatchQueue(
        label: "\(#file)",
        attributes: .concurrent
    )

    // UserDefaults keys
    private enum UserDefaultsKeys: String {
        case wordsPerMinute
        case preferredFontSize
        case preferredFontName
        case selectedTheme
        case histogramAlpha
        case neighborWordsAlpha
        case saveWithoutTitle
        case autoSaveOnPaste
        case autoPasteEnabled
        case useDummyData
    }
    
    // Properties with default values and persistence
    var wordsPerMinute: Int {
        get {
            queue.sync {
                UserDefaults.standard.integer(forKey: UserDefaultsKeys.wordsPerMinute.rawValue) == 0 ? 300 : UserDefaults.standard.integer(forKey: UserDefaultsKeys.wordsPerMinute.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.wordsPerMinute.rawValue)
            }
        }
    }
    
    var preferredFontSize: Double {
        get {
            queue.sync {
                UserDefaults.standard.double(forKey: UserDefaultsKeys.preferredFontSize.rawValue) == 0 ? 48 : UserDefaults.standard.double(forKey: UserDefaultsKeys.preferredFontSize.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.preferredFontSize.rawValue)
            }
        }
    }
    
    var preferredFontName: String {
        get {
            queue.sync {
                UserDefaults.standard.string(forKey: UserDefaultsKeys.preferredFontName.rawValue) ?? "Helvetica"
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.preferredFontName.rawValue)
            }
        }
    }
    
    var selectedTheme: ThemeModel? {
        get {
            queue.sync {
                if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.selectedTheme.rawValue) {
                    return try? JSONDecoder().decode(ThemeModel.self, from: data)
                }
                return .blandTheme1
            }
        }
        set {
            queue.async(flags: .barrier) {
                if let theme = newValue, let data = try? JSONEncoder().encode(theme) {
                    UserDefaults.standard.set(data, forKey: UserDefaultsKeys.selectedTheme.rawValue)
                } else {
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.selectedTheme.rawValue)
                }
            }
        }
    }
    
    var histogramAlpha: Double {
        get {
            queue.sync {
                UserDefaults.standard.double(forKey: UserDefaultsKeys.histogramAlpha.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.histogramAlpha.rawValue)
            }
        }
    }
    
    var neighborWordsAlpha: Double {
        get {
            queue.sync {
                let alpha = UserDefaults.standard.double(forKey: UserDefaultsKeys.neighborWordsAlpha.rawValue)
                return alpha == 0 ? 0.2 : alpha
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.neighborWordsAlpha.rawValue)
            }
        }
    }
    
    var saveWithoutTitle: Bool {
        get {
            queue.sync {
                UserDefaults.standard.bool(forKey: UserDefaultsKeys.saveWithoutTitle.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.saveWithoutTitle.rawValue)
            }
        }
    }
    
    var autoSaveOnPaste: Bool {
        get {
            queue.sync {
                UserDefaults.standard.bool(forKey: UserDefaultsKeys.autoSaveOnPaste.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.autoSaveOnPaste.rawValue)
            }
        }
    }
    
    var autoPasteEnabled: Bool {
        get {
            queue.sync {
                if UserDefaults.standard.object(forKey: UserDefaultsKeys.autoPasteEnabled.rawValue) == nil {
                    return true
                }
                return UserDefaults.standard.bool(forKey: UserDefaultsKeys.autoPasteEnabled.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.autoPasteEnabled.rawValue)
            }
        }
    }
    
    
    var useDummyData: Bool {
        get {
            queue.sync {
                if UserDefaults.standard.object(forKey: UserDefaultsKeys.useDummyData.rawValue) == nil {
                    return false
                }
                return UserDefaults.standard.bool(forKey: UserDefaultsKeys.useDummyData.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.useDummyData.rawValue)
            }
        }
    }
}
