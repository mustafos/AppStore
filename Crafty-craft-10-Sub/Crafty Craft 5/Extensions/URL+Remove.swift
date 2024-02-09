//
//  URL+Remove.swift
//  Crafty Craft 5
//
//  Created by dev on 14.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
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
