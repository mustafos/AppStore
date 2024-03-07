//
//  UIImage+Save.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

extension UIImage {
    func save(to url: URL) -> Bool {
        guard let data = pngData() else {
            AppDelegate.log("Failed to convert image to PNG data.")
            return false
        }
        
        do {
            try data.write(to: url, options: .atomic)
            AppDelegate.log("Image saved successfully at: \(url.path)")
            return true
        } catch {
            AppDelegate.log("Failed to save image: \(error)")
            return false
        }
    }
}
