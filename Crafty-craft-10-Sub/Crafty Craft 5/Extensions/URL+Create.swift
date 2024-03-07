//
//  URL+Create.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation

extension URL {
    
    @discardableResult
    /// Create folder iat path,
    /// if it exist then remove and create new one
    /// - Returns: success result
    ///
    func createDir() -> Bool {
        FileManager.default.secureSafeCreateDirectory(at: self)
    }
}
