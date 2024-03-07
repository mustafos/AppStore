//
//  URL+DeleteFile.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation

extension URL {
    func removeAllFile(exceptContaining: String) {
        let fileManager = FileManager.default
        guard let items = fileManager.urls(for: self) else {
            return
        }
        for item in items {
            if item.absoluteString.range(of: exceptContaining) == nil {
                // delete file
                do {
                    try FileManager.default.removeItem(atPath: item.path)
                } catch {
                    print("Could not delete file, probably read-only filesystem")
                }
            }
        }
    }
}
