//
//  FileManager+Path.swift
//  Crafty Craft 5
//
//  Created by dev on 21.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation

extension FileManager {
    // Get user's cache directory path
    var documentDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Get user's cache directory path
    var cachesDirectory: URL {
        urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    // Get user's mcaddons directory path in cache
    var cachesMCAddonDirectory: URL {
        cachesDirectory.appendingPathComponent("mcaddons")
    }
    
    // Get user's mcaddons directory path in cache
    var cachesSkinDirectory: URL {
        cachesDirectory.appendingPathComponent("skin")
    }
    
    // get list of files and folders in directory
    func urls(for directory: URL, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let fileURLs = try? contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
