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
    let symbolName: String
    let layoutAspectRatio: CGFloat
    let target: FilterPresetTarget
    let main: ImageFilterSettings?
    let background: ImageFilterSettings?

    /// Settings used for card preview thumbnails (main when present, otherwise background).
    var previewFilterSettings: ImageFilterSettings? {
        main ?? background
    }

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
            symbolName: "photo",
            layoutAspectRatio: 1.0,
            target: .both,
            main: .default,
            background: .default
        ),
        FilterPreset(
            id: "brat_punch",
            name: NSLocalizedString("Brat Punch", comment: "Filter preset name"),
            symbolName: "bolt.fill",
            layoutAspectRatio: 1.15,
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
            symbolName: "sparkles",
            layoutAspectRatio: 0.9,
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
            symbolName: "newspaper",
            layoutAspectRatio: 1.1,
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
            symbolName: "moon.stars",
            layoutAspectRatio: 0.85,
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
            symbolName: "arrow.triangle.2.circlepath",
            layoutAspectRatio: 1.05,
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
            symbolName: "sun.haze",
            layoutAspectRatio: 0.95,
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
            symbolName: "camera.filters",
            layoutAspectRatio: 1.12,
            target: .main,
            main: settings {
                $0.photoEffect = .chrome
                $0.vibrance = 0.5
                $0.sharpen = 0.35
            },
            background: nil
        ),
        FilterPreset(
            id: "cool_ice",
            name: NSLocalizedString("Cool Ice", comment: "Filter preset name"),
            symbolName: "snowflake",
            layoutAspectRatio: 0.88,
            target: .both,
            main: settings {
                $0.colorTemperature = 4200
                $0.colorTint = -18
                $0.saturation = 0.88
                $0.exposure = -0.2
                $0.hue = -12
                $0.vignette = 4
                $0.highlightAmount = 1.15
            },
            background: settings {
                $0.colorTemperature = 4500
                $0.colorTint = -12
                $0.saturation = 0.9
                $0.bloom = 0.3
                $0.vignette = 5
            }
        ),
        FilterPreset(
            id: "instant_vintage",
            name: NSLocalizedString("Instant", comment: "Filter preset name"),
            symbolName: "photo.on.rectangle.angled",
            layoutAspectRatio: 1.08,
            target: .both,
            main: settings {
                $0.photoEffect = .instant
                $0.sepia = 0.12
                $0.vignette = 5
                $0.grain = 0.2
                $0.colorTemperature = 6800
            },
            background: settings {
                $0.photoEffect = .instant
                $0.sepia = 0.1
                $0.vignette = 6
                $0.grain = 0.22
            }
        ),
        FilterPreset(
            id: "pastel_glow",
            name: NSLocalizedString("Pastel", comment: "Filter preset name"),
            symbolName: "cloud.sun.fill",
            layoutAspectRatio: 0.92,
            target: .both,
            main: settings {
                $0.brightness = 0.12
                $0.exposure = 0.2
                $0.saturation = 0.72
                $0.contrast = 0.92
                $0.bloom = 0.45
                $0.vignette = 2
            },
            background: settings {
                $0.brightness = 0.1
                $0.exposure = 0.15
                $0.saturation = 0.78
                $0.bloom = 0.5
            }
        ),
        FilterPreset(
            id: "teal_dusk",
            name: NSLocalizedString("Teal Dusk", comment: "Filter preset name"),
            symbolName: "sunset.fill",
            layoutAspectRatio: 1.14,
            target: .both,
            main: settings {
                $0.contrast = 1.28
                $0.shadowAmount = 0.35
                $0.vignette = 6
                $0.duotoneIntensity = 0.38
                $0.duotoneColorHex = "E85D04"
                $0.saturation = 1.1
            },
            background: settings {
                $0.hue = 195
                $0.colorTint = 14
                $0.contrast = 1.22
                $0.colorTemperature = 5600
                $0.vignette = 7
            }
        ),
        FilterPreset(
            id: "vhs_lofi",
            name: NSLocalizedString("VHS", comment: "Filter preset name"),
            symbolName: "tv",
            layoutAspectRatio: 1.0,
            target: .both,
            main: settings {
                $0.pixelate = 8
                $0.grain = 0.28
                $0.saturation = 0.68
                $0.contrast = 1.12
                $0.colorTemperature = 7100
                $0.hue = 8
            },
            background: settings {
                $0.pixelate = 6
                $0.grain = 0.3
                $0.saturation = 0.72
                $0.colorTemperature = 7400
            }
        ),
        FilterPreset(
            id: "editorial_grain",
            name: NSLocalizedString("Editorial", comment: "Filter preset name"),
            symbolName: "camera.aperture",
            layoutAspectRatio: 0.87,
            target: .both,
            main: settings {
                $0.monochrome = 1
                $0.grain = 0.32
                $0.contrast = 1.45
                $0.unsharpMask = 0.5
                $0.vignette = 7
                $0.photoEffect = .tonal
            },
            background: settings {
                $0.monochrome = 1
                $0.grain = 0.35
                $0.contrast = 1.4
                $0.vignette = 8
            }
        ),
        FilterPreset(
            id: "sunset_duotone",
            name: NSLocalizedString("Sunset", comment: "Filter preset name"),
            symbolName: "circle.lefthalf.filled",
            layoutAspectRatio: 1.06,
            target: .both,
            main: settings {
                $0.duotoneIntensity = 0.55
                $0.duotoneColorHex = "FF6B35"
                $0.contrast = 1.22
                $0.saturation = 0.95
                $0.vignette = 4
            },
            background: settings {
                $0.duotoneIntensity = 0.45
                $0.duotoneColorHex = "C44569"
                $0.contrast = 1.18
                $0.vignette = 5
            }
        ),
        FilterPreset(
            id: "mist_haze",
            name: NSLocalizedString("Mist", comment: "Filter preset name"),
            symbolName: "cloud.fog.fill",
            layoutAspectRatio: 0.93,
            target: .background,
            main: nil,
            background: settings {
                $0.photoEffect = .fade
                $0.colorTemperature = 5800
                $0.bloom = 0.5
                $0.exposure = -0.15
                $0.vignette = 3
            }
        ),
        FilterPreset(
            id: "silk_punch",
            name: NSLocalizedString("Silk Punch", comment: "Filter preset name"),
            symbolName: "star.fill",
            layoutAspectRatio: 1.13,
            target: .main,
            main: settings {
                $0.contrast = 1.55
                $0.saturation = 1.4
                $0.sharpen = 0.5
                $0.vibrance = 0.6
                $0.highlightAmount = 1.2
                $0.unsharpMask = 0.35
            },
            background: nil
        ),
        FilterPreset(
            id: "process_film",
            name: NSLocalizedString("process", comment: "Filter preset name"),
            symbolName: "film",
            layoutAspectRatio: 1.02,
            target: .both,
            main: settings {
                $0.photoEffect = .process
                $0.contrast = 1.18
                $0.saturation = 1.08
                $0.vignette = 4
                $0.grain = 0.18
            },
            background: settings {
                $0.photoEffect = .process
                $0.contrast = 1.12
                $0.saturation = 1.05
                $0.vignette = 5
                $0.grain = 0.2
            }
        ),
        FilterPreset(
            id: "lavender_cobalt",
            name: NSLocalizedString("lavender", comment: "Filter preset name"),
            symbolName: "paintpalette.fill",
            layoutAspectRatio: 0.89,
            target: .both,
            main: settings {
                $0.duotoneIntensity = 0.48
                $0.duotoneColorHex = "9B5DE5"
                $0.contrast = 1.2
                $0.saturation = 0.92
                $0.colorTint = 8
                $0.vignette = 3
            },
            background: settings {
                $0.duotoneIntensity = 0.42
                $0.duotoneColorHex = "3A86FF"
                $0.contrast = 1.16
                $0.colorTemperature = 5200
                $0.vignette = 4
            }
        ),
        FilterPreset(
            id: "acid_neon",
            name: NSLocalizedString("acid", comment: "Filter preset name"),
            symbolName: "bolt.circle.fill",
            layoutAspectRatio: 1.11,
            target: .main,
            main: settings {
                $0.contrast = 1.62
                $0.saturation = 1.55
                $0.hue = 88
                $0.vibrance = 0.75
                $0.sharpen = 0.45
                $0.duotoneIntensity = 0.28
                $0.duotoneColorHex = "39FF14"
                $0.vignette = 3
            },
            background: nil
        ),
        FilterPreset(
            id: "bleach_fade",
            name: NSLocalizedString("bleach", comment: "Filter preset name"),
            symbolName: "drop.halffull",
            layoutAspectRatio: 0.96,
            target: .both,
            main: settings {
                $0.contrast = 1.48
                $0.saturation = 0.55
                $0.exposure = 0.15
                $0.highlightAmount = 1.25
                $0.shadowAmount = 0.4
                $0.vignette = 5
                $0.grain = 0.16
            },
            background: settings {
                $0.contrast = 1.42
                $0.saturation = 0.5
                $0.exposure = 0.1
                $0.highlightAmount = 1.2
                $0.vignette = 6
                $0.grain = 0.18
            }
        ),
        FilterPreset(
            id: "radio_static",
            name: NSLocalizedString("radio", comment: "Filter preset name"),
            symbolName: "antenna.radiowaves.left.and.right",
            layoutAspectRatio: 1.07,
            target: .both,
            main: settings {
                $0.posterizeLevels = 8
                $0.halftone = 6
                $0.contrast = 1.28
                $0.saturation = 0.82
                $0.grain = 0.22
                $0.colorTemperature = 6400
            },
            background: settings {
                $0.posterizeLevels = 7
                $0.halftone = 5
                $0.contrast = 1.22
                $0.saturation = 0.78
                $0.grain = 0.24
            }
        ),
        FilterPreset(
            id: "deep_noir",
            name: NSLocalizedString("deep noir", comment: "Filter preset name"),
            symbolName: "moon.fill",
            layoutAspectRatio: 0.86,
            target: .background,
            main: nil,
            background: settings {
                $0.photoEffect = .noir
                $0.contrast = 1.35
                $0.brightness = -0.08
                $0.exposure = -0.3
                $0.vignette = 9
                $0.grain = 0.26
                $0.shadowAmount = 0.55
            }
        ),
        FilterPreset(
            id: "golden_hour",
            name: NSLocalizedString("golden", comment: "Filter preset name"),
            symbolName: "sun.max.fill",
            layoutAspectRatio: 1.09,
            target: .background,
            main: nil,
            background: settings {
                $0.photoEffect = .fade
                $0.colorTemperature = 7800
                $0.sepia = 0.22
                $0.exposure = 0.12
                $0.bloom = 0.35
                $0.vignette = 4
                $0.saturation = 1.12
            }
        ),
        FilterPreset(
            id: "cyber_cut",
            name: NSLocalizedString("cyber", comment: "Filter preset name"),
            symbolName: "cpu",
            layoutAspectRatio: 0.94,
            target: .main,
            main: settings {
                $0.sharpen = 0.55
                $0.unsharpMask = 0.45
                $0.contrast = 1.38
                $0.colorTemperature = 4400
                $0.colorTint = -22
                $0.saturation = 0.9
                $0.hue = -18
                $0.vignette = 4
            },
            background: nil
        ),
        FilterPreset(
            id: "transfer_paint",
            name: NSLocalizedString("transfer", comment: "Filter preset name"),
            symbolName: "paintbrush.pointed.fill",
            layoutAspectRatio: 1.03,
            target: .both,
            main: settings {
                $0.photoEffect = .transfer
                $0.contrast = 1.14
                $0.saturation = 1.08
                $0.vibrance = 0.25
                $0.vignette = 4
                $0.grain = 0.17
            },
            background: settings {
                $0.photoEffect = .transfer
                $0.contrast = 1.1
                $0.saturation = 1.04
                $0.vignette = 5
                $0.grain = 0.19
            }
        ),
        FilterPreset(
            id: "rose_emerald",
            name: NSLocalizedString("rose emerald", comment: "Filter preset name"),
            symbolName: "leaf.fill",
            layoutAspectRatio: 0.91,
            target: .both,
            main: settings {
                $0.duotoneIntensity = 0.52
                $0.duotoneColorHex = "F72585"
                $0.contrast = 1.2
                $0.saturation = 1.06
                $0.colorTint = 6
                $0.vignette = 3
            },
            background: settings {
                $0.duotoneIntensity = 0.46
                $0.duotoneColorHex = "06D6A0"
                $0.contrast = 1.15
                $0.colorTemperature = 5400
                $0.vignette = 4
            }
        ),
        FilterPreset(
            id: "infrared_pop",
            name: NSLocalizedString("infrared", comment: "Filter preset name"),
            symbolName: "viewfinder.circle",
            layoutAspectRatio: 1.04,
            target: .main,
            main: settings {
                $0.hue = 95
                $0.saturation = 1.48
                $0.vibrance = 0.55
                $0.contrast = 1.24
                $0.colorTemperature = 5800
                $0.colorTint = 12
                $0.vignette = 4
            },
            background: nil
        ),
        FilterPreset(
            id: "ethereal_bloom",
            name: NSLocalizedString("ethereal", comment: "Filter preset name"),
            symbolName: "wand.and.stars",
            layoutAspectRatio: 0.97,
            target: .background,
            main: nil,
            background: settings {
                $0.bloom = 0.65
                $0.contrast = 0.82
                $0.saturation = 0.86
                $0.exposure = 0.2
                $0.brightness = 0.06
                $0.vignette = 2
            }
        ),
        FilterPreset(
            id: "matte_crush",
            name: NSLocalizedString("matte", comment: "Filter preset name"),
            symbolName: "circle.hexagongrid.fill",
            layoutAspectRatio: 1.08,
            target: .both,
            main: settings {
                $0.gamma = 1.38
                $0.brightness = -0.12
                $0.contrast = 0.88
                $0.shadowAmount = 0.62
                $0.saturation = 0.9
                $0.vignette = 6
                $0.grain = 0.18
            },
            background: settings {
                $0.gamma = 1.42
                $0.brightness = -0.1
                $0.contrast = 0.85
                $0.shadowAmount = 0.58
                $0.saturation = 0.86
                $0.vignette = 7
                $0.grain = 0.2
            }
        ),
        FilterPreset(
            id: "candlelight",
            name: NSLocalizedString("Candlelight", comment: "Filter preset name"),
            symbolName: "flame.fill",
            layoutAspectRatio: 0.98,
            target: .background,
            main: nil,
            background: settings {
                $0.colorTemperature = 7600
                $0.sepia = 0.18
                $0.exposure = -0.4
                $0.brightness = -0.05
                $0.saturation = 0.92
                $0.vignette = 3
                $0.bloom = 0.2
            }
        ),
        FilterPreset(
            id: "polaroid_snap",
            name: NSLocalizedString("Polaroid", comment: "Filter preset name"),
            symbolName: "rectangle.portrait",
            layoutAspectRatio: 1.1,
            target: .both,
            main: settings {
                $0.photoEffect = .instant
                $0.contrast = 1.32
                $0.saturation = 0.88
                $0.sepia = 0.08
                $0.exposure = -0.1
                $0.vignette = 4
                $0.grain = 0.16
            },
            background: settings {
                $0.photoEffect = .instant
                $0.contrast = 1.28
                $0.saturation = 0.85
                $0.sepia = 0.1
                $0.vignette = 5
                $0.grain = 0.18
            }
        ),
        FilterPreset(
            id: "midnight_blue",
            name: NSLocalizedString("Midnight Blue", comment: "Filter preset name"),
            symbolName: "moon.circle.fill",
            layoutAspectRatio: 0.88,
            target: .both,
            main: settings {
                $0.duotoneIntensity = 0.5
                $0.duotoneColorHex = "1E3A8A"
                $0.contrast = 1.26
                $0.saturation = 0.78
                $0.colorTemperature = 4800
                $0.colorTint = -8
                $0.exposure = -0.25
                $0.vignette = 5
            },
            background: settings {
                $0.duotoneIntensity = 0.44
                $0.duotoneColorHex = "312E81"
                $0.contrast = 1.2
                $0.saturation = 0.72
                $0.colorTemperature = 5000
                $0.vignette = 6
            }
        ),
        FilterPreset(
            id: "overexposed",
            name: NSLocalizedString("Overexposed", comment: "Filter preset name"),
            symbolName: "sun.max",
            layoutAspectRatio: 1.12,
            target: .both,
            main: settings {
                $0.exposure = 0.45
                $0.brightness = 0.1
                $0.contrast = 0.84
                $0.saturation = 0.8
                $0.bloom = 0.58
                $0.highlightAmount = 1.35
                $0.vignette = 2
            },
            background: settings {
                $0.exposure = 0.38
                $0.brightness = 0.08
                $0.contrast = 0.86
                $0.saturation = 0.82
                $0.bloom = 0.52
                $0.highlightAmount = 1.3
            }
        ),
        FilterPreset(
            id: "punch_mono",
            name: NSLocalizedString("Punch Mono", comment: "Filter preset name"),
            symbolName: "square.fill.on.square.fill",
            layoutAspectRatio: 0.87,
            target: .main,
            main: settings {
                $0.monochrome = 1
                $0.contrast = 1.58
                $0.grain = 0.24
                $0.sharpen = 0.3
                $0.vignette = 5
                $0.unsharpMask = 0.25
            },
            background: nil
        ),
        FilterPreset(
            id: "tonal_lift",
            name: NSLocalizedString("Tonal Lift", comment: "Filter preset name"),
            symbolName: "slider.horizontal.3",
            layoutAspectRatio: 1.05,
            target: .main,
            main: settings {
                $0.photoEffect = .tonal
                $0.vibrance = 0.22
                $0.contrast = 1.12
                $0.saturation = 1.04
                $0.brightness = 0.04
                $0.exposure = 0.08
            },
            background: nil
        )
    ]
}
