//
//  SaveRecsourceManager.swift
//  Crafty Craft 5
//
//  Created by 1 on 16.09.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

protocol AddonSaveable: AnyObject {
    
    func saved(name: String, geometry: URL, texture: URL, preview: URL) -> URL?
}

final class SaveRecsourceManager {

    private enum Constants {
        static let dir = "Data"
        static let dataName = "data.json"
        static let textureName = "texture.png"
        static let previewName = "preview.png"
    }
    
    private let data: Data
    private var texture: UIImage
    private var preview: UIImage?

    private let model: ResourcePack
    private weak var delegate: AddonSaveable?
    
    /// Path for Unity3D data dir
    ///
    private var destination: URL {
        let fileManager = FileManager.default
        let url = fileManager.documentDirectory.appendingPathComponent(Constants.dir)
        url.createDir()
        
        return url
    }
    
    init(model: ResourcePack, delegate: AddonSaveable?) {
        self.model = model
        self.delegate = delegate
        
        self.texture = UIImage(data: model.image)!
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model.geometry) {
            self.data = data
        } else {
            self.data = Data()
        }
        
    }
    
    func updateTexture(newTexture: UIImage) {
        texture = newTexture
    }
    
    func updatePreview(newPreview: UIImage) {
        preview = newPreview
    }
    
    func setupResources() {
        cleanResources()
        
        setupData()
        setupTexture()
        setupPreview()
    }
    
    var dataUrl: URL {
        destination.appendingPathComponent(Constants.dataName)
    }
    
    var textureUrl: URL {
        destination.appendingPathComponent(Constants.textureName)
    }
    
    var previewUrl: URL {
        destination.appendingPathComponent(Constants.previewName)
    }
    
    public func saveResourcess(with name: String) -> URL? {
        // Unity already processed files need save it to mcaddon
        return delegate?.saved(name: name, geometry: dataUrl, texture: textureUrl, preview: previewUrl)
    }
    
    /// remove old files at Unity3d folder if exist
    ///
    private func cleanResources() {
        let fileManager = FileManager.default
        
        for url in [dataUrl, textureUrl] {
            if fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(at: url)
                    AppDelegate.log("file removed at: \(url.path)")
                } catch {
                    AppDelegate.log("Failed to remove file: \(error)")
                }
            }
        }
    }
    
    private func generateRandomCharacter() -> Character {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomIndex = Int.random(in: 0..<characters.count)
        return characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
    }
    
    private func setupData() {
        
        let fileURL = destination.appendingPathComponent(Constants.dataName)

        do {
            try data.write(to: fileURL)
            AppDelegate.log("Image saved successfully at: \(fileURL.path)")
        } catch {
            AppDelegate.log("Failed to save image: \(error)")
        }
    }
    
    private func setupTexture() {
        guard let data = texture.pngData() else {
            AppDelegate.log("Failed to convert textureImg to PNG data.")
            return
        }

        let fileURL = destination.appendingPathComponent(Constants.textureName)

        do {
            try data.write(to: fileURL)
            AppDelegate.log("Image saved successfully at: \(fileURL.path)")
        } catch {
            AppDelegate.log("Failed to save textureData: \(error)")
        }
    }
    
    private func setupPreview() {
        guard let localData = preview?.pngData() else {
            AppDelegate.log("Failed to convert previewImg to PNG data.")
            return
        }
        
        let fileURL = destination.appendingPathComponent(Constants.previewName)
        
        do {
            try localData.write(to: fileURL)
            AppDelegate.log("Image saved successfully at: \(fileURL.path)")
        } catch {
            AppDelegate.log("Failed to save image: \(error)")
        }
    }
}
