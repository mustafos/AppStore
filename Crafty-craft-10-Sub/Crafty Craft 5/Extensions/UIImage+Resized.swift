//
//  UIImage.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func resizedImage(named: String, size: CGSize) -> UIImage? {
        guard let image = UIImage(named: named) else { return nil }
        
        return image.resizedImage(targetSize: size)
    }
    
    func resizedImage(targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}


/// Taken from https://stackoverflow.com/a/34599236/7217195
extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
            // Determine the scale factor that preserves aspect ratio
            let widthRatio = (targetSize.width + 1) / size.width
            let heightRatio = (targetSize.height + 1) / size.height
            
            let scaleFactor = min(widthRatio, heightRatio)
            
            // Compute the new image size that preserves aspect ratio
            let scaledImageSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )

            // Draw and return the resized UIImage
            let renderer = UIGraphicsImageRenderer(
                size: scaledImageSize
            )

            let scaledImage = renderer.image { _ in
                self.draw(in: CGRect(
                    origin: .zero,
                    size: scaledImageSize
                ))
            }
            
            return scaledImage
        }
    
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
    
    func rotate(radians: CGFloat) -> UIImage? {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            defer { UIGraphicsEndImageContext() }
            
            // Translate to the center
            context.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            
            // Apply rotation
            context.rotate(by: radians)
            
            // Draw the image so its center aligns with the context center
            draw(in: CGRect(x: -size.width / 2.0, y: -size.height / 2.0, width: size.width, height: size.height))
            
            if let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                return rotatedImage
            }
        }
        return nil
    }

    
}

extension UIImage {
    
    //Extracts fullArray
    //IMg 64x64 -> particular sizes[UIColor] This is final method
    func extractPixelColors(width: Int? = nil, height: Int? = nil, startX: Int? = nil, startY: Int? = nil) -> [UIColor]? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let imgTotalWidth = Int(self.size.width)
        let imgTotalHeight = Int(self.size.height)
        
        let rectWidth = width ?? imgTotalWidth
        let rectHeight = height ?? imgTotalHeight
        
        let localStartX = startX ?? 0
        let localStartY = startY ?? 0
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * imgTotalWidth
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: bytesPerRow * imgTotalHeight)
        
        guard let context = CGContext(data: &pixelData,
                                      width: imgTotalWidth,
                                      height: imgTotalHeight,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: imgTotalWidth, height: imgTotalHeight))
        
        var colorArray: [UIColor] = []
        var coloredPixelsArr = [UIColor]()
        for y in 0..<rectHeight {
        for x in 0..<rectWidth {
                let offsetX = x + localStartX
                let offsetY = y + localStartY
                let offset = (offsetY * imgTotalWidth + offsetX) * bytesPerPixel
                let red = CGFloat(pixelData[offset]) / 255.0
                let green = CGFloat(pixelData[offset + 1]) / 255.0
                let blue = CGFloat(pixelData[offset + 2]) / 255.0
                let alpha = CGFloat(pixelData[offset + 3]) / 255.0
                
                let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                colorArray.append(color)
                
                if color.alpha != 0 {
                    coloredPixelsArr.append(color)
                }
            }
        }
        
        //        AppDelegate.log("coloredPixelsArr.count = \(coloredPixelsArr.count)")
        
        return colorArray
    }
    
    
}


extension UIImage {
    
    func extractSubImage(startX: CGFloat = 0, startY: CGFloat = 0, width: CGFloat, height: CGFloat) -> UIImage? {
        let rect = CGRect(x: startX, y: startY, width: width, height: height)
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        guard let croppedCGImage = cgImage.cropping(to: rect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage)
    }
    
}


//MARK: Apply Alpha to Image

extension UIImage {
    func withAlphaComponent(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}


//MARK: Pixelized effect with risize

extension UIImage {
    
    func resizeAspectFit(to targetSize: CGSize = .init(width: 64, height: 64), targetScale: CGFloat? = nil) -> UIImage {
        
        guard CGSize(width: size.width * scale, height: size.height * scale) != targetSize else {
            // skip for same size
            return self
        }
        
        // Determine the scale factor that preserves aspect ratio
        let scaleFactor: CGFloat
        if size.width > size.height {
            scaleFactor = targetSize.width / size.width
        } else {
            scaleFactor = targetSize.height / size.height
        }
        
        // Compute the new image size that preserves aspect ratio fill
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        // Draw and return the resized UIImage
        let format: UIGraphicsImageRendererFormat = .init()
        if let scale = targetScale {
            format.scale = scale
        }
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize, format: format)

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
    
    var squared: UIImage? {
        
        guard size.width != size.height else {
            // skip for same size
            return self
        }
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        let length = max(cgImage.width, cgImage.height)
        
        let x: Int = abs(cgImage.width / 2 - length / 2)
        let y: Int = cgImage.height / 2 - length / 2
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: length, height: length))
        
        let img = renderer.image { ctx in
            var transform = CGAffineTransform(scaleX: 1, y: -1)
            transform = transform.translatedBy(x: 0, y: -CGFloat(height))
            ctx.cgContext.concatenate(transform)
            ctx.cgContext.draw(cgImage, in: .init(x: x, y: y, width: width, height: height))
        }
        
        return img
    }
    
    func pixelateAndResize(to targetSize: CGSize = .init(width: 64, height: 64)) -> UIImage? {
        // Step 1: Pixelate the image
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        draw(in: CGRect(origin: .zero, size: size))
        let pixelatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Step 2: Resize the pixelated image to the target size
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        pixelatedImage?.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

