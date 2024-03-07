//
//  Extension_UIColor+brightness.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

fileprivate extension CGFloat {

    func clampValueBetween(min: CGFloat, max: CGFloat) -> CGFloat {
        if self < min {
            return min
        } else if self > max {
            return max
        } else {
            return self
        }
    }
        
    func convertToColorChannel() -> CGFloat {
        let min: CGFloat = 0
        let max: CGFloat = 1
        let modifier: CGFloat = 1
        if self < min {
            return self + modifier
        } else if self > max {
            return self - max
        } else {
            return self
        }
    }
    
    func convertValuesToRGB(temp1: CGFloat, temp2: CGFloat) -> CGFloat {
       if 6 * self < 1 {
           return temp2 + (temp1 - temp2) * 6 * self
       } else if 2 * self < 1 {
           return temp1
       } else if 3 * self < 2 {
           return temp2 + (temp1 - temp2) * (0.666 - self) * 6
       } else {
           return temp2
       }
   }
}


extension UIColor {
    static let blue = UIColor(hex: 0x5690FF)
    static let lightBlue = UIColor(hex: 0xEDF3FF)

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF)
    }

    
    var skinRgbaColorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }

    func withLuminosity(_ newLuminosity: CGFloat) -> UIColor {
        let coreColour = CIColor(color: self)
        var red = coreColour.red
        var green = coreColour.green
        var blue = coreColour.blue
        let alpha = coreColour.alpha
        
        red = red.clampValueBetween(min: 0, max: 1)
        green = green.clampValueBetween(min: 0, max: 1)
        blue = blue.clampValueBetween(min: 0, max: 1)
        
        guard let minRGB = [red, green, blue].min(), let maxRGB = [red, green, blue].max() else {
            return self
        }
        
        var luminosity = (minRGB + maxRGB) / 2

        var saturation: CGFloat = 0

        if luminosity <= 0.5 {
            saturation = (maxRGB - minRGB)/(maxRGB + minRGB)
        } else if luminosity > 0.5 {
            saturation = (maxRGB - minRGB)/(2.0 - maxRGB - minRGB)
        }

        var hue: CGFloat = 0
        if red == maxRGB {
            hue = (green - blue) / (maxRGB - minRGB)
        } else if green == maxRGB {
            hue = 2.0 + ((blue - red) / (maxRGB - minRGB))
        } else if blue == maxRGB {
            hue = 4.0 + ((red - green) / (maxRGB - minRGB))
        }
        

        if hue < 0 {
            hue += 360
        } else {
            hue = hue * 60
        }
        
        luminosity = newLuminosity
        

        if saturation == 0 {
            return UIColor(red: 1.0 * luminosity, green: 1.0 * luminosity, blue: 1.0 * luminosity, alpha: alpha)
        }
        if saturation.isNaN {
            if red != 1 {
                luminosity = 1 - luminosity
            }
            return UIColor(red: 1.0 * luminosity, green: 1.0 * luminosity, blue: 1.0 * luminosity, alpha: alpha)
        }

        var temporaryVariableOne: CGFloat = 0
        if luminosity < 0.5 {
            temporaryVariableOne = luminosity * (1 + saturation)
        } else {
            temporaryVariableOne = luminosity + saturation - luminosity * saturation
        }
        
        let temporaryVariableTwo = 2 * luminosity - temporaryVariableOne
        
        let convertedHue = hue / 360
        
        let tempRed = (convertedHue + 0.333).convertToColorChannel()
        let tempGreen = convertedHue.convertToColorChannel()
        let tempBlue = (convertedHue - 0.333).convertToColorChannel()

        let newRed = tempRed.convertValuesToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newGreen = tempGreen.convertValuesToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newBlue = tempBlue.convertValuesToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
    }
}
