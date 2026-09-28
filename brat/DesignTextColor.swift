//
//  DesignTextColor.swift
//  brat
//

import UIKit

enum DesignTextColor {
  /// Light text on dark backgrounds, dark text on light backgrounds.
  static func automatic(for style: UIUserInterfaceStyle) -> UIColor {
    switch resolvedUserInterfaceStyle(style) {
    case .dark:
      return .white
    case .light, .unspecified:
      return .black
    @unknown default:
      return .black
    }
  }

  /// Resolves `.unspecified` by walking view → trait collection → screen.
  static func resolvedUserInterfaceStyle(
    _ style: UIUserInterfaceStyle,
    traitCollection: UITraitCollection? = nil,
    view: UIView? = nil
  ) -> UIUserInterfaceStyle {
    if style != .unspecified {
      return style
    }

    if let view {
      let viewStyle = view.traitCollection.userInterfaceStyle
      if viewStyle != .unspecified {
        return viewStyle
      }
      if let window = view.window {
        let windowStyle = window.traitCollection.userInterfaceStyle
        if windowStyle != .unspecified {
          return windowStyle
        }
      }
    }

    if let traitCollection {
      let traitStyle = traitCollection.userInterfaceStyle
      if traitStyle != .unspecified {
        return traitStyle
      }
    }

    if let sceneStyle = foregroundWindowSceneStyle() {
      return sceneStyle
    }

    let screenStyle = UIScreen.main.traitCollection.userInterfaceStyle
    if screenStyle != .unspecified {
      return screenStyle
    }

    return .light
  }

  /// Foreground `UIWindowScene` traits — often the only reliable appearance source on Mac.
  private static func foregroundWindowSceneStyle() -> UIUserInterfaceStyle? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene =
      scenes.first(where: { $0.activationState == .foregroundActive })
      ?? scenes.first
    guard let scene else { return nil }
    let style = scene.traitCollection.userInterfaceStyle
    return style == .unspecified ? nil : style
  }

  static func resolved(_ design: Design, traits: UITraitCollection, view: UIView? = nil) -> UIColor {
    let style = resolvedUserInterfaceStyle(
      traits.userInterfaceStyle,
      traitCollection: traits,
      view: view
    )
    return resolved(design, userInterfaceStyle: style)
  }

  static func resolved(_ design: Design, userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
    if design.usesAutomaticTextColor {
      if design.backgroundImageKey == nil,
         let contrastingColor = contrastingColor(for: design.backgroundColor) {
        return contrastingColor
      }
      return automatic(for: userInterfaceStyle)
    }
    return design.textColor
  }

  private static func contrastingColor(for background: UIColor) -> UIColor? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    guard background.getRed(&red, green: &green, blue: &blue, alpha: &alpha), alpha >= 0.999 else {
      return nil
    }

    return background.relativeLuminance >= 0.17913 ? .black : .white
  }
}
