import Foundation
import SpriteKit

class Canvas: SKSpriteNode {
    
    /// Amount of pixels on a horizontal scale.
    private var width: Int = 0
    
    /// Amount of pixels on a vertical scale.
    private var height: Int = 0
    private var pixelArray = [PictureElement]()
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        super.init(texture: nil, color: .clear, size: CGSize(width: width * PIXEL_SIZE, height: height * PIXEL_SIZE))
        setUpPixelGrid(colorArray: nil)
    }
    
    init(width: Int, height: Int, colorArray: [UIColor]?) {
        self.width = width
        self.height = height
        super.init(texture: nil, color: .clear, size: CGSize(width: width * PIXEL_SIZE, height: height * PIXEL_SIZE))
        setUpPixelGrid(colorArray: colorArray)
    }
    
    func getPixelArray() -> [PictureElement] {
        return pixelArray
    }
    
    func getCanvasWidth() -> Int {
        return width * PIXEL_SIZE
    }
    
    func getCanvasHeight() -> Int {
        return height * PIXEL_SIZE
    }
    
    func getAmountOfPixelsForWidth() -> Int {
        return width
    }
    
    func getAmountOfPixelsForHeight() -> Int {
        return height
    }
    
    func getPixelWidth() -> Int {
        return PIXEL_SIZE
    }
    
    func getScaledPixelWidth() -> CGFloat {
        return getScaledCanvasWidth() / CGFloat(getAmountOfPixelsForWidth())
    }
    
    func getScaledPixelHeight() -> CGFloat {
        return getScaledCanvasHeight() / CGFloat(getAmountOfPixelsForHeight())
    }
    
    /// Helper method that returns a pixel based on the x/y. The x and y position are
    /// ordinated along the standard cartesian axis by the following system: x increasing
    /// in the right direction and y increasing in the up direction.
    func getPixel(x: Int, y: Int) -> PictureElement? {
        let translatedXPosition = x * height
        let translatedYPosition = y
        
        if translatedXPosition + translatedYPosition >= pixelArray.count
            || translatedXPosition < 0 || translatedXPosition >= pixelArray.count
            || translatedYPosition < 0 || translatedYPosition >= pixelArray.count {
            return nil
        }
        
        return pixelArray[translatedXPosition + translatedYPosition]
    }
    
    /// Gets the correct indices for a given pixel node according to the cartesian
    /// coordinate system. Note `getPixel()` for more information.
    func getPosition(pixel forPixel: ScnPixel) -> (Int, Int) {
        let currentIndex = pixelArray.firstIndex(where: {$0 == forPixel})
        let translatedXPosition = currentIndex! / height
        let translatedYPosition = currentIndex! % height
        return (translatedXPosition, translatedYPosition)
    }
    
    /// Returns actual size of canvas width in screen (scale factor included).
    func getScaledCanvasWidth() -> CGFloat {
        return CGFloat(getCanvasWidth()) * xScale
    }
    
    /// Returns actual size of canvas height in screen (scale factor included).
    func getScaledCanvasHeight() -> CGFloat {
        return CGFloat(getCanvasHeight()) * yScale
    }
    
    func getPixelHeight() -> Int {
        return PIXEL_SIZE
    }
    
    func getPixelColorArray() -> [UIColor] {
        return pixelArray.map({ (currentPixel) -> UIColor in
            return currentPixel.fillColor
        })
    }
    
    // MARK: - FIX -
    private func setUpPixelGrid(colorArray: [UIColor]?) {
        
        //var correctIndexx = 0
        for x in 0..<self.width {
            for y in 0..<self.height {
                let pixel = PictureElement()
                //
                //                 This is nasty, but SpriteKit has a stupid bug...
                let xPos = Int(-self.size.width / 2) + x * Int(PIXEL_SIZE)
                let yPos = Int(-self.size.height / 2) + y * Int(PIXEL_SIZE)
                
                pixel.position.x = CGFloat(xPos)
                pixel.position.y = CGFloat(yPos)

                // var  i = y * width + x
                // var i = x * h + y
                
                if let colorArray = colorArray {
//                        pixel.fillColor = colorArray[correctIndexx]
                    let tempX = x
                    let tempY = (height - 1) - y
                    let correctIndex = tempY * width + tempX
                    
                    pixel.fillColor = colorArray[correctIndex]
                    
                    //MARK: Delete me
//                    if  x == 2 && y == 5  {
//                        pixel.fillColor = colorArray[18]
//                    }
                }

                pixelArray.append(pixel)
                self.addChild(pixel)
            }
        }
        
        AppDelegate.log("canvasNodes.count \(pixelArray.count)")
    }
    
    func updatePixels(by colors: [UIColor]) {
        
        for (index, color) in colors.enumerated() {
            let pixel = pixelArray[index]
            pixel.fillColor = color
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func draw(pixel: PictureElement, color: UIColor) {
        pixel.fillColor = color
    }
    
}

extension Canvas {
    func getPixel(at location: CGPoint) -> PictureElement? {
        // Convert the touch location to the coordinate system of the canvas
        let locationInCanvas = convert(location, from: self.scene!)

        let locationIntX = CGFloat(location.x) + self.size.width / 2
        let locationIntY = CGFloat(location.y) + self.size.height / 2
        
        let actualPixelWidth = getScaledPixelWidth()
        let actualPixelHeight = getScaledPixelHeight()
        
        let column = Int(locationIntX / actualPixelWidth)
        let row = Int(locationIntY / actualPixelHeight)
        
        AppDelegate.log("pixelcolumn = \(column), pixelrow \(row)")

        // Check if the row and column are within valid bounds
        guard row >= 0, row < height, column >= 0, column < width else {
            return nil
        }

        // Calculate the index of the pixel in the pixelArray
        let index = row * width + column

        // Check if the index is valid
        guard index >= 0, index < pixelArray.count else {
            return nil
        }

        // Return the pixel at the specified location
        AppDelegate.log("pixelIndex = \(index), pixelColor \(pixelArray[index].fillColor)")
        
        return pixelArray[index]
    }
}
