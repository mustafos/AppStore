//
//  Array+substracting_ext.swift
//  Crafty Craft 5
//
//  Created by 1 on 23.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
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
