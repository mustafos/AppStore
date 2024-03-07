//
//  Array+substracting_ext.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation

extension Array where Element == Float {
    
    ///self - seondArr = result
    func subtract(_ second: [Float]) -> [Float] {
        // Check if both arrays have the same length
        guard self.count == second.count else {
            print("Arrays should be of the same length for element-wise subtraction.")
            return [0,0,0]
        }
        
        // Subtract the elements of the second array from the first
        return zip(self, second).map(-)
    }
}
