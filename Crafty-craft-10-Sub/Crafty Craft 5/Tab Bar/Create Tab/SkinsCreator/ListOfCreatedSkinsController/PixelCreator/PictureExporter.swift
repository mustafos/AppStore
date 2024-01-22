import UIKit
import ImageIO
import MobileCoreServices

// Handles the exporting of images to Photos library.
class PictureExporter: NSObject {
    
    var flatPixelArray: [RawPixel]
    private var rawPixelArray: [RawPixel]
    private var canvasWidth: Int
    private var canvasHeight: Int
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    init(colorArray: [UIColor], canvasWidth: Int, canvasHeight: Int) {
        self.rawPixelArray = [RawPixel]()
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        
        
        //let clearPixel = try! RawPixel(inputColor: .clear)
        var clearRawPixelesArray = [RawPixel]()
        for localPixel in colorArray {
            let rawPixel = try! RawPixel(inputColor: localPixel)
            clearRawPixelesArray.append(rawPixel)
        }
        
        flatPixelArray = clearRawPixelesArray
        
        super.init()
        
        // Convert given UIColor array into RawPixel array.
        setUpRawPixelArray(colorArray: colorArray)
    }
    
    convenience init(drawing: Drawing) {
        self.init(colorArray: drawing.colorArray, canvasWidth: Int(drawing.width), canvasHeight: Int(drawing.height))
    }
    
    private func setUpRawPixelArray(colorArray: [UIColor]) {
        colorArray.forEach { (color) in
            do {
                let rawPixel = try RawPixel(inputColor: color)
                rawPixelArray.append(rawPixel)
            } catch {
                AppDelegate.log("RawPixel conversion failed. \(error.localizedDescription)")
                return
            }
        }
    }
    
    /// This method generates an UIImage that can be saved to Photos.
    ///
    /// - Parameters:
    ///   - width: the width of the canvas.
    ///   - height: the height of the canvas.
    ///   - uiHandler: an ui handler for showing an ui update as the method progresses.
    public func generateUIImagefromDrawing(width: Int, height: Int, uiHandler: ((Double) -> Void)? = nil) -> UIImage? {
        
        
        
        
        guard let dataProvider = CGDataProvider(data: NSData(bytes: flatPixelArray, length: flatPixelArray.count * MemoryLayout<RawPixel>.size)) else {
            AppDelegate.log("DataProvider could not be built.")
            return nil
        }
        
        //        let data = Data(
        
        //        // Build the bitmap input for the CGImage conversion.
        //        guard let dataProvider = CGDataProvider(data: NSData(bytes: &rawPixelArray, length: rawPixelArray.count * MemoryLayout<RawPixel>.size)
        //            ) else {
        //                AppDelegate.log("DataProvider could not be built.")
        //                return nil }
        
        uiHandler?(0.25)
        
        // Create CGImage version.
        guard let cgImage = CGImage.init(width: canvasWidth, height: canvasHeight, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: canvasWidth * (MemoryLayout<RawPixel>.size), space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else {
            AppDelegate.log("CGImage could not be created.")
            return nil
        }
        
        uiHandler?(0.5)
        
        // Convert to UIImage for later use in UIImageView.
        guard let uiImage = UIImage(cgImage: cgImage).rotate(radians: -CGFloat.pi / 2.0) else {
            return nil
        }
        
        // Generate Image View for saving image by taking a screenshort.
        let imageView = UIImageView(image: uiImage)
        imageView.backgroundColor = .clear
        imageView.layer.magnificationFilter = CALayerContentsFilter.nearest
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // Take actual screenshot from Image View context.
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.isOpaque, 0.0)
        // imageView.transform = imageView.transform.rotated(by: CGFloat.pi/2)
        imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        guard let snapshotImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        return snapshotImage
    }

    
    // MARK: Test colorinig and saving
    ///    canvas colors into png  skinAssemblyDiagram
    func createImageWithRawPixels(bodyPartSide: Side, image: UIImage?) -> UIImage? {

        let imgSize = CGSize(width: 64, height: 64)
        UIGraphicsBeginImageContextWithOptions(imgSize, false, 1)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        guard let bitmapContext = context.data else {
            return nil
        }
        
        let pixelBuffer = bitmapContext.bindMemory(to: UInt32.self,
                                                   capacity: Int(imgSize.width) * Int(imgSize.height))
        pixelBuffer.initialize(repeating: 0, count: Int(imgSize.width) * Int(imgSize.height))
        
        // Draw the original image
        image?.draw(in: CGRect(origin: .zero, size: imgSize))
        
        // Set the blending mode to copy
        context.setBlendMode(.copy)
        
        
        var correctIndex = 0
        
        // Draw the raw pixels, note that x & y are changed,
        //because of colorArray that is set from sceneKit,
        //where coordinates begit at left bottom corner.
        for x in 0..<bodyPartSide.width {
            for y in (0..<bodyPartSide.height).reversed() {
                let index = y * bodyPartSide.width + x
                guard index < rawPixelArray.count else {
                    continue
                }
                
                let rawPixel = rawPixelArray[correctIndex]
                let color = UIColor(
                    red: CGFloat(rawPixel.r) / 255.0,
                    green: CGFloat(rawPixel.g) / 255.0,
                    blue: CGFloat(rawPixel.b) / 255.0,
                    alpha: CGFloat(rawPixel.a) / 255.0
                )
                
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: bodyPartSide.startX + x,
                                    y: bodyPartSide.startY + y,
                                    width: 1, height: 1))
                correctIndex += 1
            }
        }
        
//        guard let cgImageFromContext = context.makeImage() else { return nil }
        
//        let finalImage = UIImage(cgImage: cgImageFromContext)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
}


