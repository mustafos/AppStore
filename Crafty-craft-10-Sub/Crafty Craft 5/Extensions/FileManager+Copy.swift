//
//  FileManager+Copy.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 22.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation

extension FileManager {

    @discardableResult
    public func secureSafeCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            try secureCopyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            AppDelegate.log("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        
        return true
    }
    
    public func secureCopyItem(at srcURL: URL, to dstURL: URL) throws {
        if fileExists(atPath: dstURL.path) {
            try removeItem(at: dstURL)
        }
        try copyItem(at: srcURL, to: dstURL)
    }
    
    @discardableResult
    public func secureSafeMoveItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            try secureMoveItem(at: srcURL, to: dstURL)
        } catch (let error) {
            AppDelegate.log("Cannot move item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        
        return true
    }

    public func secureMoveItem(at srcURL: URL, to dstURL: URL) throws {
        if fileExists(atPath: dstURL.path) {
            try removeItem(at: dstURL)
        }
        try moveItem(at: srcURL, to: dstURL)
    }
    
    @discardableResult
    public func secureSafeCreateDirectory(at srcURL: URL) -> Bool {
        do {
            try secureCreateDirectory(at: srcURL)
        } catch (let error) {
            AppDelegate.log("Cannot create folder at \(srcURL): \(error)")
            return false
        }
        
        return true
    }

    public func secureCreateDirectory(at url: URL) throws {
        if !fileExists(atPath: url.path) {
            try createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}
