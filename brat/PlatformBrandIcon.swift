import UIKit

/// Small brand-styled glyphs for social aspect-ratio presets (simplified shapes, not official artwork).
enum PlatformBrandIcon: String, CaseIterable, Equatable {
    case instagram
    case tiktok
    case snapchat
    case youtube
    case facebook
    case pinterest
    case linkedIn
    case x

    static func from(titleKey: String) -> PlatformBrandIcon? {
        switch titleKey {
        case "Instagram Story", "Instagram Post", "Instagram Square":
            return .instagram
        case "TikTok":
            return .tiktok
        case "Snapchat":
            return .snapchat
        case "YouTube":
            return .youtube
        case "Facebook Post":
            return .facebook
        case "Pinterest Pin":
            return .pinterest
        case "LinkedIn":
            return .linkedIn
        case "X Post", "X Square":
            return .x
        default:
            return nil
        }
    }

    func image(pointSize: CGFloat = 12) -> UIImage {
        let canvas = CGSize(width: pointSize, height: pointSize)
        let inset = pointSize * 0.06
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = UITraitCollection.current.displayScale
        return UIGraphicsImageRenderer(size: canvas, format: format).image { context in
            let rect = CGRect(origin: .zero, size: canvas).insetBy(dx: inset, dy: inset)
            draw(in: rect, context: context.cgContext)
        }.withRenderingMode(.alwaysOriginal)
    }

    private func draw(in rect: CGRect, context: CGContext) {
        switch self {
        case .instagram:
            drawInstagram(in: rect, context: context)
        case .tiktok:
            drawTikTok(in: rect, context: context)
        case .snapchat:
            drawSnapchat(in: rect, context: context)
        case .youtube:
            drawYouTube(in: rect, context: context)
        case .facebook:
            drawFacebook(in: rect, context: context)
        case .pinterest:
            drawPinterest(in: rect, context: context)
        case .linkedIn:
            drawLinkedIn(in: rect, context: context)
        case .x:
            drawX(in: rect, context: context)
        }
    }

    private func drawInstagram(in rect: CGRect, context: CGContext) {
        let inset = rect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.12)
        let path = UIBezierPath(roundedRect: inset, cornerRadius: inset.width * 0.22)
        UIColor.label.setStroke()
        path.lineWidth = max(1, rect.width * 0.1)
        path.stroke()

        let inner = inset.insetBy(dx: inset.width * 0.22, dy: inset.height * 0.22)
        let circle = UIBezierPath(ovalIn: inner)
        circle.lineWidth = path.lineWidth
        circle.stroke()

        let dot = CGRect(
            x: inset.maxX - inset.width * 0.28,
            y: inset.minY + inset.height * 0.06,
            width: inset.width * 0.16,
            height: inset.height * 0.16
        )
        UIColor.label.setFill()
        UIBezierPath(ovalIn: dot).fill()
    }

    private func drawTikTok(in rect: CGRect, context: CGContext) {
        let w = rect.width
        let h = rect.height
        let note = UIBezierPath()
        note.move(to: CGPoint(x: rect.minX + w * 0.38, y: rect.minY + h * 0.08))
        note.addCurve(
            to: CGPoint(x: rect.minX + w * 0.38, y: rect.maxY - h * 0.12),
            controlPoint1: CGPoint(x: rect.minX + w * 0.05, y: rect.minY + h * 0.35),
            controlPoint2: CGPoint(x: rect.minX + w * 0.05, y: rect.maxY - h * 0.2)
        )
        note.addLine(to: CGPoint(x: rect.minX + w * 0.55, y: rect.maxY - h * 0.12))
        note.addCurve(
            to: CGPoint(x: rect.minX + w * 0.55, y: rect.minY + h * 0.45),
            controlPoint1: CGPoint(x: rect.minX + w * 0.72, y: rect.maxY - h * 0.2),
            controlPoint2: CGPoint(x: rect.minX + w * 0.72, y: rect.minY + h * 0.55)
        )
        note.addLine(to: CGPoint(x: rect.minX + w * 0.72, y: rect.minY + h * 0.08))
        note.addLine(to: CGPoint(x: rect.minX + w * 0.88, y: rect.minY + h * 0.2))
        note.addLine(to: CGPoint(x: rect.minX + w * 0.88, y: rect.minY + h * 0.42))
        note.addLine(to: CGPoint(x: rect.minX + w * 0.72, y: rect.minY + h * 0.34))
        note.close()

        UIColor.label.setFill()
        note.fill()

        UIColor.systemCyan.setFill()
        let accent = UIBezierPath(ovalIn: CGRect(
            x: rect.minX + w * 0.12,
            y: rect.minY + h * 0.52,
            width: w * 0.22,
            height: h * 0.22
        ))
        accent.fill()

        UIColor.systemPink.setFill()
        let accent2 = UIBezierPath(ovalIn: CGRect(
            x: rect.minX + w * 0.2,
            y: rect.minY + h * 0.62,
            width: w * 0.18,
            height: h * 0.18
        ))
        accent2.fill()
    }

    private func drawSnapchat(in rect: CGRect, context: CGContext) {
        let w = rect.width
        let h = rect.height
        context.setFillColor(UIColor(red: 1, green: 0.99, blue: 0, alpha: 1).cgColor)
        context.fill(rect)

        let ghost = UIBezierPath()
        ghost.move(to: CGPoint(x: rect.midX, y: rect.minY + h * 0.1))
        ghost.addCurve(
            to: CGPoint(x: rect.minX + w * 0.18, y: rect.minY + h * 0.42),
            controlPoint1: CGPoint(x: rect.midX - w * 0.05, y: rect.minY + h * 0.1),
            controlPoint2: CGPoint(x: rect.minX + w * 0.12, y: rect.minY + h * 0.22)
        )
        ghost.addCurve(
            to: CGPoint(x: rect.minX + w * 0.14, y: rect.maxY - h * 0.08),
            controlPoint1: CGPoint(x: rect.minX + w * 0.08, y: rect.minY + h * 0.58),
            controlPoint2: CGPoint(x: rect.minX + w * 0.02, y: rect.maxY - h * 0.18)
        )
        ghost.addLine(to: CGPoint(x: rect.minX + w * 0.28, y: rect.maxY - h * 0.2))
        ghost.addLine(to: CGPoint(x: rect.minX + w * 0.36, y: rect.maxY - h * 0.05))
        ghost.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - h * 0.16))
        ghost.addLine(to: CGPoint(x: rect.maxX - w * 0.36, y: rect.maxY - h * 0.05))
        ghost.addLine(to: CGPoint(x: rect.maxX - w * 0.28, y: rect.maxY - h * 0.2))
        ghost.addLine(to: CGPoint(x: rect.maxX - w * 0.14, y: rect.maxY - h * 0.08))
        ghost.addCurve(
            to: CGPoint(x: rect.maxX - w * 0.18, y: rect.minY + h * 0.42),
            controlPoint1: CGPoint(x: rect.maxX - w * 0.02, y: rect.maxY - h * 0.18),
            controlPoint2: CGPoint(x: rect.maxX - w * 0.08, y: rect.minY + h * 0.58)
        )
        ghost.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY + h * 0.1),
            controlPoint1: CGPoint(x: rect.maxX - w * 0.12, y: rect.minY + h * 0.22),
            controlPoint2: CGPoint(x: rect.midX + w * 0.05, y: rect.minY + h * 0.1)
        )
        ghost.close()

        UIColor.white.setFill()
        ghost.fill()

        let eyeY = rect.minY + h * 0.4
        let eyeW = w * 0.1
        UIColor.black.setFill()
        UIBezierPath(ovalIn: CGRect(x: rect.midX - w * 0.16, y: eyeY, width: eyeW, height: eyeW * 1.2)).fill()
        UIBezierPath(ovalIn: CGRect(x: rect.midX + w * 0.06, y: eyeY, width: eyeW, height: eyeW * 1.2)).fill()
    }

    private func drawYouTube(in rect: CGRect, context: CGContext) {
        let bg = rect.insetBy(dx: rect.width * 0.04, dy: rect.height * 0.18)
        let path = UIBezierPath(roundedRect: bg, cornerRadius: bg.height * 0.2)
        UIColor.systemRed.setFill()
        path.fill()

        let play = UIBezierPath()
        let cx = bg.midX + bg.width * 0.04
        let cy = bg.midY
        let r = min(bg.width, bg.height) * 0.22
        play.move(to: CGPoint(x: cx - r * 0.35, y: cy - r))
        play.addLine(to: CGPoint(x: cx + r * 0.85, y: cy))
        play.addLine(to: CGPoint(x: cx - r * 0.35, y: cy + r))
        play.close()
        UIColor.white.setFill()
        play.fill()
    }

    private func drawFacebook(in rect: CGRect, context: CGContext) {
        UIColor.systemBlue.setFill()
        UIBezierPath(ovalIn: rect.insetBy(dx: rect.width * 0.04, dy: rect.height * 0.04)).fill()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: rect.height * 0.62),
            .foregroundColor: UIColor.white,
        ]
        let text = "f" as NSString
        let size = text.size(withAttributes: attrs)
        text.draw(
            at: CGPoint(x: rect.midX - size.width * 0.48, y: rect.midY - size.height * 0.52),
            withAttributes: attrs
        )
    }

    private func drawPinterest(in rect: CGRect, context: CGContext) {
        UIColor.systemRed.setFill()
        UIBezierPath(ovalIn: rect.insetBy(dx: rect.width * 0.04, dy: rect.height * 0.04)).fill()

        let p = UIBezierPath()
        let c = rect.insetBy(dx: rect.width * 0.22, dy: rect.height * 0.14)
        p.move(to: CGPoint(x: c.midX, y: c.minY))
        p.addLine(to: CGPoint(x: c.maxX, y: c.minY + c.height * 0.35))
        p.addCurve(
            to: CGPoint(x: c.midX + c.width * 0.05, y: c.maxY),
            controlPoint1: CGPoint(x: c.maxX, y: c.maxY - c.height * 0.1),
            controlPoint2: CGPoint(x: c.midX + c.width * 0.35, y: c.maxY)
        )
        p.addLine(to: CGPoint(x: c.midX - c.width * 0.08, y: c.minY + c.height * 0.58))
        p.addLine(to: CGPoint(x: c.midX - c.width * 0.08, y: c.maxY - c.height * 0.08))
        p.addLine(to: CGPoint(x: c.minX + c.width * 0.08, y: c.maxY - c.height * 0.08))
        p.addLine(to: CGPoint(x: c.minX + c.width * 0.08, y: c.minY + c.height * 0.42))
        p.addCurve(
            to: CGPoint(x: c.midX, y: c.minY),
            controlPoint1: CGPoint(x: c.minX, y: c.minY + c.height * 0.12),
            controlPoint2: CGPoint(x: c.midX - c.width * 0.2, y: c.minY)
        )
        p.close()
        UIColor.white.setFill()
        p.fill()
    }

    private func drawLinkedIn(in rect: CGRect, context: CGContext) {
        let bg = rect.insetBy(dx: rect.width * 0.02, dy: rect.height * 0.12)
        let path = UIBezierPath(roundedRect: bg, cornerRadius: bg.width * 0.12)
        UIColor(red: 0.0, green: 0.47, blue: 0.71, alpha: 1).setFill()
        path.fill()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: rect.height * 0.42),
            .foregroundColor: UIColor.white,
        ]
        let text = "in" as NSString
        let size = text.size(withAttributes: attrs)
        text.draw(
            at: CGPoint(x: bg.midX - size.width * 0.5, y: bg.midY - size.height * 0.52),
            withAttributes: attrs
        )
    }

    private func drawX(in rect: CGRect, context: CGContext) {
        UIColor.label.setStroke()
        let path = UIBezierPath()
        let inset = rect.insetBy(dx: rect.width * 0.2, dy: rect.height * 0.2)
        path.move(to: inset.origin)
        path.addLine(to: CGPoint(x: inset.maxX, y: inset.maxY))
        path.move(to: CGPoint(x: inset.maxX, y: inset.minY))
        path.addLine(to: CGPoint(x: inset.minX, y: inset.maxY))
        path.lineWidth = max(1.2, rect.width * 0.14)
        path.lineCapStyle = .round
        path.stroke()
    }
}

extension AspectRatioPreset {
    var platformIcons: [PlatformBrandIcon] {
        var seen = Set<PlatformBrandIcon>()
        return titleKeys.compactMap { key in
            guard let icon = PlatformBrandIcon.from(titleKey: key), !seen.contains(icon) else {
                return nil
            }
            seen.insert(icon)
            return icon
        }
    }
}
