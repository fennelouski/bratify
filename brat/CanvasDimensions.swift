import CoreGraphics

enum CanvasDimensions {
    static let maxDimension: CGFloat = 512
    static let maxPixels: CGFloat = 500_000

    static func pixelSize(forAspectWidth width: Int, height: Int) -> (width: CGFloat, height: CGFloat) {
        pixelSize(forAspectWidth: CGFloat(width), height: CGFloat(height))
    }

    /// Converts aspect-ratio components (e.g. 4×5, 9×16, or full pixel sizes) into canvas pixel dimensions.
    /// Preset integers are ratios, not literal pixels — the longer edge is scaled to `maxDimension` unless
    /// the input is already larger (e.g. a photo’s native size), in which case it is scaled down only.
    static func pixelSize(forAspectWidth width: CGFloat, height: CGFloat) -> (width: CGFloat, height: CGFloat) {
        guard width > 0, height > 0 else {
            return (maxDimension, maxDimension)
        }

        var newWidth = width
        var newHeight = height

        let longerEdge = max(newWidth, newHeight)
        if longerEdge < maxDimension {
            let scaleUp = maxDimension / longerEdge
            newWidth *= scaleUp
            newHeight *= scaleUp
        }

        if newWidth > maxDimension || newHeight > maxDimension || (newWidth * newHeight > maxPixels) {
            let aspectRatio = newWidth / newHeight
            if newWidth > newHeight {
                newWidth = min(maxDimension, sqrt(maxPixels * aspectRatio))
                newHeight = newWidth / aspectRatio
            } else {
                newHeight = min(maxDimension, sqrt(maxPixels / aspectRatio))
                newWidth = newHeight * aspectRatio
            }
        }

        return (newWidth, newHeight)
    }

    static func simplifiedRatio(width: Int, height: Int) -> (Int, Int) {
        guard width > 0, height > 0 else { return (1, 1) }
        let divisor = gcd(width, height)
        return (width / divisor, height / divisor)
    }

    static func simplifiedRatio(width: CGFloat, height: CGFloat) -> (Int, Int) {
        let w = max(1, Int(width.rounded()))
        let h = max(1, Int(height.rounded()))
        return simplifiedRatio(width: w, height: h)
    }

    static func matchesRatio(
        canvasWidth: CGFloat,
        canvasHeight: CGFloat,
        presetWidth: Int,
        presetHeight: Int
    ) -> Bool {
        guard canvasWidth > 0, canvasHeight > 0, presetWidth > 0, presetHeight > 0 else {
            return false
        }
        let canvas = simplifiedRatio(width: canvasWidth, height: canvasHeight)
        let preset = simplifiedRatio(width: presetWidth, height: presetHeight)
        return canvas.0 == preset.0 && canvas.1 == preset.1
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var x = abs(a)
        var y = abs(b)
        while y != 0 {
            let remainder = x % y
            x = y
            y = remainder
        }
        return max(x, 1)
    }
}
