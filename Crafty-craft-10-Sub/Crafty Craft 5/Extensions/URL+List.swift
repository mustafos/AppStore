//
//  URL+List.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation

extension URL {
    
    /// Get list of files at current path
    /// - Returns: list of files
    /// 
    func filesList() -> [URL] {
        let fileManager = FileManager.default
        
        var files: [URL] = .init()
        if let enumerator = fileManager.enumerator(at: self, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch { AppDelegate.log(error, fileURL) }
            }
            AppDelegate.log(files)
        }
        
        return files
    }
}
