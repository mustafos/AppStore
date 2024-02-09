//
//  UIImage+Save.swift
//  Crafty Craft 5
//
//  Created by dev on 03.08.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
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
