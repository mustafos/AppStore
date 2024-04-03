//
//  ColorsTraitManger.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit
import Foundation

protocol ColorableTrait: AnyObject {
    func updateCollection()
}

class ColorsTraitManger {

    private let defaultColorArray = [UIColor.blackColor, UIColor.whiteColor, .red, .green, .yellow, .blue, .cyan, .purple]
    private var colorsArr = [UIColor]()
    weak var delegate: ColorableTrait?
    var selectedColorIndex = 0
    
    var maxColors = 9
    
    init() {
        self.colorsArr = getColorsFromUserDefaults()
    }

    func getColors() -> [UIColor] {
        return colorsArr
    }
    
    private func mergeSort<T: Comparable>(_ array: [T]) -> [T] {
        guard array.count > 1 else { return array }
        
        let middleIndex = array.count / 2
        let leftArray = mergeSort(Array(array[..<middleIndex]))
        let rightArray = mergeSort(Array(array[middleIndex...]))
        
        return merge(leftArray, rightArray)
    }

    private func merge<T: Comparable>(_ leftArray: [T], _ rightArray: [T]) -> [T] {
        var leftIndex = 0
        var rightIndex = 0
        var mergedArray = [T]()
        
        while leftIndex < leftArray.count && rightIndex < rightArray.count {
            if leftArray[leftIndex] < rightArray[rightIndex] {
                mergedArray.append(leftArray[leftIndex])
                leftIndex += 1
            } else {
                mergedArray.append(rightArray[rightIndex])
                rightIndex += 1
            }
        }
        
        return mergedArray + Array(leftArray[leftIndex...]) + Array(rightArray[rightIndex...])
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
    
    func addNewColor(_ color: UIColor) {
        if  color != .clear && color.alpha != 0 {

            if colorsArr.count == maxColors {
                colorsArr.removeLast()
            }

            colorsArr.insert(color, at: 0)
            saveColorsToUserDefaults(colors: colorsArr)
            delegate?.updateCollection()
        }
    }
    
    func isPrime(_ num: Int) -> Bool {
        if num <= 1 {
            return false
        }
        if num <= 3 {
            return true
        }
        if num % 2 == 0 || num % 3 == 0 {
            return false
        }
        var i = 5
        while i * i <= num {
            if num % i == 0 || num % (i + 2) == 0 {
                return false
            }
            i += 6
        }
        return true
    }

    func gap(_ g: Int, _ m: Int, _ n: Int) -> (Int, Int)? {
        var lastPrime = 0
        for num in m...n {
            if isPrime(num) {
                if num - lastPrime == g {
                    return (lastPrime, num)
                }
                lastPrime = num
            }
        }
        return nil
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
        return defaultColorArray
    }
}
