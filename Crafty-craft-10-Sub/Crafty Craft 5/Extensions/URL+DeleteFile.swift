//
//  URL+DeleteFile.swift
//  Crafty Craft 5
//
//  Created by Vitaliy Polezhay on 05.10.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
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
