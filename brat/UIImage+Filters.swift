//
//  UIImage+Filters.swift
//  brat
//
//  Created by Nathan Fennel on 8/5/24.
//

import UIKit

extension UIImage {
    func fastScaled(
        by scale: CGFloat,
        flipHorizontal: Bool = false,
        flipVertical: Bool = false,
        blur: CGFloat = 0
    ) -> UIImage? {
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Apply transformations before drawing
        if flipHorizontal {
            context.translateBy(x: size.width, y: 0)
            context.scaleBy(x: -1.0, y: 1.0)
        }
        
        if !flipVertical {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
        }

        // Draw the image in the context with high-quality interpolation
        context.interpolationQuality = .low
        context.draw(self.cgImage!, in: CGRect(origin: .zero, size: size))

        // Extract the scaled image from the context
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if blur >= 1, let scaledImage = scaledImage {
            return scaledImage.applyBlur(blur)
        }
        
        return scaledImage
    }
    
    func applyBlur(_ blur: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let context = CIContext(options: nil)
        let inputImage = CIImage(cgImage: cgImage)
        
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(blur, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage,
              let cgImageResult = context.createCGImage(outputImage, from: inputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImageResult)
    }
    
    func applyFilters(
        brightness: CGFloat,
        contrast: CGFloat,
        saturation: CGFloat,
        exposure: CGFloat,
        gamma: CGFloat,
        sepia: CGFloat,
        invert: Bool,
        pixelate: CGFloat,
        sharpen: CGFloat,
        monochrome: CGFloat,
        vignette: CGFloat
    ) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let context = CIContext(options: nil)
        var ciImage = CIImage(cgImage: cgImage)
        
        // Apply brightness
        if brightness != 0 {
            if let filter = CIFilter(name: "CIColorControls") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(brightness, forKey: kCIInputBrightnessKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply contrast
        if contrast != 1 {
            if let filter = CIFilter(name: "CIColorControls") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(contrast, forKey: kCIInputContrastKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply saturation
        if saturation != 1 {
            if let filter = CIFilter(name: "CIColorControls") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(saturation, forKey: kCIInputSaturationKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply exposure
        if exposure != 0 {
            if let filter = CIFilter(name: "CIExposureAdjust") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(exposure, forKey: kCIInputEVKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply gamma
        if gamma != 1 {
            if let filter = CIFilter(name: "CIGammaAdjust") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(gamma, forKey: "inputPower")
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply sepia
        if sepia != 0 {
            if let filter = CIFilter(name: "CISepiaTone") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(sepia, forKey: kCIInputIntensityKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply invert
        if invert {
            if let filter = CIFilter(name: "CIColorInvert") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply pixelate
        if pixelate != 0 {
            if let filter = CIFilter(name: "CIPixellate") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(pixelate, forKey: kCIInputScaleKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply sharpen
        if sharpen != 0 {
            if let filter = CIFilter(name: "CISharpenLuminance") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(sharpen, forKey: kCIInputSharpnessKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply monochrome
        if monochrome != 0 {
            if let filter = CIFilter(name: "CIColorMonochrome") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(CIColor(color: UIColor.white), forKey: kCIInputColorKey)
                filter.setValue(monochrome, forKey: kCIInputIntensityKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        // Apply vignette
        if vignette != 0 {
            if let filter = CIFilter(name: "CIVignette") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(vignette, forKey: kCIInputIntensityKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
        }
        
        guard let outputImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outputImage)
    }
}

