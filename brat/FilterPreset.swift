//
//  FilterPreset.swift
//  brat
//

import UIKit

enum FilterPresetTarget {
    case main
    case background
    case both
}

struct FilterPreset: Identifiable {
    let id: String
    let name: String
    let target: FilterPresetTarget
    let main: ImageFilterSettings?
    let background: ImageFilterSettings?

    func apply(to design: inout Design) {
        switch target {
        case .main:
            if let main { design.applyMainImageFilters(main) }
        case .background:
            if let background { design.applyBackgroundImageFilters(background) }
        case .both:
            if let main { design.applyMainImageFilters(main) }
            if let background { design.applyBackgroundImageFilters(background) }
        }
    }

    private static func settings(_ configure: (inout ImageFilterSettings) -> Void) -> ImageFilterSettings {
        var settings = ImageFilterSettings.default
        configure(&settings)
        return settings
    }

    static let builtIn: [FilterPreset] = [
        FilterPreset(
            id: "none",
            name: NSLocalizedString("None", comment: "Filter preset: reset"),
            target: .both,
            main: .default,
            background: .default
        ),
        FilterPreset(
            id: "brat_punch",
            name: NSLocalizedString("Brat Punch", comment: "Filter preset name"),
            target: .both,
            main: settings {
                $0.contrast = 1.35
                $0.saturation = 1.25
                $0.hue = 52
                $0.vignette = 4
                $0.grain = 0.15
                $0.vibrance = 0.35
                $0.duotoneIntensity = 0.2
                $0.duotoneColorHex = "8ACE00"
            },
            background: settings {
                $0.contrast = 1.2
                $0.saturation = 1.1
                $0.hue = 40
                $0.vignette = 6
                $0.grain = 0.2
                $0.bloom = 0.25
            }
        ),
        FilterPreset(
            id: "soft_dream",
            name: NSLocalizedString("Soft Dream", comment: "Filter preset name"),
            target: .both,
            main: settings {
                $0.saturation = 0.85
                $0.exposure = -0.35
                $0.bloom = 0.35
                $0.vignette = 2
            },
            background: settings {
                $0.saturation = 0.9
                $0.exposure = -0.25
                $0.bloom = 0.4
            }
        ),
        FilterPreset(
            id: "zine",
            name: NSLocalizedString("Zine", comment: "Filter preset name"),
            target: .both,
            main: settings {
                $0.contrast = 1.5
                $0.monochrome = 0.6
                $0.posterizeLevels = 6
                $0.halftone = 12
                $0.grain = 0.25
            },
            background: settings {
                $0.contrast = 1.4
                $0.posterizeLevels = 5
                $0.halftone = 10
                $0.grain = 0.2
            }
        ),
        FilterPreset(
            id: "photo_noir",
            name: NSLocalizedString("Photo Noir", comment: "Filter preset name"),
            target: .both,
            main: settings {
                $0.photoEffect = .noir
                $0.vignette = 8
                $0.grain = 0.18
                $0.contrast = 1.15
            },
            background: settings {
                $0.photoEffect = .noir
                $0.vignette = 10
                $0.grain = 0.22
            }
        ),
        FilterPreset(
            id: "negative_pop",
            name: NSLocalizedString("Negative Pop", comment: "Filter preset name"),
            target: .main,
            main: settings {
                $0.invert = true
                $0.contrast = 1.6
                $0.saturation = 1.3
                $0.sharpen = 0.4
            },
            background: nil
        ),
        FilterPreset(
            id: "warm_fade",
            name: NSLocalizedString("Warm Fade", comment: "Filter preset name"),
            target: .background,
            main: nil,
            background: settings {
                $0.photoEffect = .fade
                $0.colorTemperature = 7200
                $0.sepia = 0.15
                $0.vignette = 3
            }
        ),
        FilterPreset(
            id: "chrome_pop",
            name: NSLocalizedString("Chrome Pop", comment: "Filter preset name"),
            target: .main,
            main: settings {
                $0.photoEffect = .chrome
                $0.vibrance = 0.5
                $0.sharpen = 0.35
            },
            background: nil
        )
    ]
}
