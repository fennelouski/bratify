import UIKit

extension Design {
    func generateImage(
        with imageService: ImageService,
        onBackgroundImageLoadFailed: (() -> Void)? = nil,
        callback: @escaping (UIImage?, String) -> Void
    ) {
        let size = CGSize(width: width, height: height)

        if let cachedImage = imageService.memoryCache.object(forKey: description as NSString),
           isValidImage(cachedImage, expectedSize: size) {
            callback(cachedImage, description)
            return
        }

#if !targetEnvironment(macCatalyst)
        guard blur >= 1 else {
            let lowercasedText = text

            let designView = DesignView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: size.width / pixelationScale,
                    height: size.height / pixelationScale
                ),
                imageService: imageService
            )
            designView.onBackgroundImageLoadFailed = onBackgroundImageLoadFailed
            designView.configure(
                with: lowercasedText,
                backgroundColor: backgroundColor,
                fontName: fontName,
                fontSize: fontSize / pixelationScale,
                stretch: stretch,
                imageName: backgroundImageKey,
                design: self
            ) { updatedDesignView in
                DispatchQueue.main.async {
                    let renderer = UIGraphicsImageRenderer(size: updatedDesignView.bounds.size)
                    let image = renderer.image { ctx in
                        updatedDesignView.drawHierarchy(in: updatedDesignView.bounds, afterScreenUpdates: true)
                    }

                    let scaledImage = image.scaled(by: self.pixelationScale)

                    var finalImage: UIImage? = scaledImage ?? image
                    if self.blur >= 1 {
                        finalImage = finalImage?.applyBlur(self.blur)
                    }

                    finalImage = finalImage?.applyFilters(
                        brightness: self.brightness,
                        contrast: self.contrast,
                        saturation: self.saturation,
                        exposure: self.exposure,
                        gamma: self.gamma,
                        sepia: self.sepia,
                        invert: self.invert,
                        pixelate: self.pixelate,
                        sharpen: self.sharpen,
                        monochrome: self.monochrome,
                        vignette: self.vignette
                    )

                    DispatchQueue.main.async {
                        callback(finalImage, self.description)
                    }

                    if let finalImage = finalImage {
                        imageService.memoryCache.setObject(
                            finalImage,
                            forKey: self.description as NSString
                        )
                    }
                }
            }

            return
        }
#endif

        let designView = DesignView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: size.width / self.pixelationScale,
                height: size.height / self.pixelationScale
            ),
            imageService: imageService
        )

        designView.onBackgroundImageLoadFailed = onBackgroundImageLoadFailed

        let lowercasedText = self.text.localizedLowercase

        designView.configure(
            with: lowercasedText,
            backgroundColor: self.backgroundColor,
            fontName: self.fontName,
            fontSize: self.fontSize / self.pixelationScale,
            stretch: self.stretch,
            imageName: self.backgroundImageKey,
            design: self
        ) { updatedDesignView in
            let designViewBounds = updatedDesignView.bounds.size

            let renderer = UIGraphicsImageRenderer(size: designViewBounds)
            let image = renderer.image { ctx in
                updatedDesignView.layer.render(in: ctx.cgContext)
            }

            DispatchQueue.global(qos: .userInitiated).async {
                var finalImage = image.fastScaled(by: self.pixelationScale, blur: self.blur)

                finalImage = finalImage?.applyFilters(
                    brightness: self.brightness,
                    contrast: self.contrast,
                    saturation: self.saturation,
                    exposure: self.exposure,
                    gamma: self.gamma,
                    sepia: self.sepia,
                    invert: self.invert,
                    pixelate: self.pixelate,
                    sharpen: self.sharpen,
                    monochrome: self.monochrome,
                    vignette: self.vignette
                )

                if let finalImage = finalImage {
                    imageService.memoryCache.setObject(finalImage, forKey: self.description as NSString)
                }

                DispatchQueue.main.async {
                    callback(finalImage, description)
                }
            }
        }
    }

    func isValidImage(_ image: UIImage, expectedSize: CGSize) -> Bool {
        if image.size != expectedSize {
            return false
        }

        guard let cgImage = image.cgImage else { return false }
        let alphaInfo = cgImage.alphaInfo
        if alphaInfo == .none || alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast {
            return false
        }

        let context = CIContext()
        let inputImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIAreaAverage")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(cgRect: inputImage.extent), forKey: kCIInputExtentKey)

        guard let outputImage = filter?.outputImage else {
            return false
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())

        let red = CGFloat(bitmap[0]) / 255.0
        let green = CGFloat(bitmap[1]) / 255.0
        let blue = CGFloat(bitmap[2]) / 255.0
        let alpha = CGFloat(bitmap[3]) / 255.0

        guard let backgroundComponents = backgroundColor.cgColor.components, backgroundComponents.count >= 3 else {
            return false
        }
        let backgroundRed = backgroundComponents[0]
        let backgroundGreen = backgroundComponents[1]
        let backgroundBlue = backgroundComponents[2]

        let colorDifference = abs(red - backgroundRed) + abs(green - backgroundGreen) + abs(blue - backgroundBlue)

        return colorDifference <= 0.1 && alpha >= 1.0
    }
}
