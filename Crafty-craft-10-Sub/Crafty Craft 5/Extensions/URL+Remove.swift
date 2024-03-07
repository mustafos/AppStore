//
//  URL+Remove.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation

extension URL {
    
    @discardableResult
    /// Remove file/folder if it exist
    /// - Returns: success result
    /// 
    func remove() -> Bool {
        let fileManager = FileManager.default
        var result = false
        
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(at: self)
                result = true
            } catch {
                //TODO: process error
            }
        }
        
        return result
    }
}
