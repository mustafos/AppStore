//
//  URL+Create.swift
//  Crafty Craft 5
//
//  Created by dev on 17.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
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
