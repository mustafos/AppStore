//
//  colorManager3D.swift
//  Crafty Craft 5
//
//  Created by 1 on 31.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//




import UIKit
import Foundation

protocol ColorAble3D: AnyObject {
    func updateCollection()
}

extension UIColor {
    static var blackColor: UIColor {
        .init(red: 0, green: 0, blue: 0, alpha: 1)
    }
    static var whiteColor: UIColor {
        .init(red: 1, green: 1, blue: 1, alpha: 1)
    }
}

class ColorManager3D {

    private let defaultColors: [UIColor] = [UIColor.blackColor, UIColor.whiteColor, .red, .green, .yellow, .blue, .cyan, .purple]
    private var colorsArr: [UIColor] = []
    weak var delegate: ColorAble3D?
    var selectedColorIndex = 0
    
    var maxColors = 15
    
    init() {
        self.colorsArr = getColorsFromUserDefaults()
    }

    func getColors() -> [UIColor] {
        return colorsArr
    }
    
    func updateColorsArr(with color: UIColor) {

        if !colorsArr.contains(color) && color != .clear && color.alpha != 0 {

            if colorsArr.count == maxColors {
                colorsArr.removeLast()
            }

            colorsArr.insert(color, at: 0)
            saveColorsToUserDefaults(colors: colorsArr)
            delegate?.updateCollection()

        }
    }
    
    func addNewColor(color: UIColor) {
        if color != .clear, color.alpha != 0 {
            if colorsArr.count == maxColors {
                colorsArr.removeLast()
            }

            colorsArr.insert(color, at: 0)
            saveColorsToUserDefaults(colors: colorsArr)
            delegate?.updateCollection()
        }
    }
    
    func getColor(by index: Int ) -> UIColor {
        
        var colorToReturn = UIColor()
        
        if index <= colorsArr.count - 1 {
            colorToReturn = colorsArr[index]

        } else {
            colorToReturn = .black
        }
        
        return colorToReturn
    }
    
    func isSelctedColor(index: Int ) -> Bool {
        if index == selectedColorIndex {
            return true
        } else {
            return false
        }
    }
    
    //MARK: UIColor -> UserDefaults
    
    // Save array of colors to UserDefaults
    private func saveColorsToUserDefaults(colors: [UIColor]) {
        let colorDataArray = colors.compactMap { $0.encode() }
        UserDefaults.standard.set(colorDataArray, forKey: "SavedColors")
    }
    
    //MARK: UserDefaults -> UIColor

    // Retrieve array of colors from UserDefaults
    private func getColorsFromUserDefaults() -> [UIColor] {
        if let colorDataArray = UserDefaults.standard.array(forKey: "SavedColors") as? [Data] {
            return colorDataArray.compactMap { UIColor.decode(from: $0) }
        }
        return defaultColors
    }
}
