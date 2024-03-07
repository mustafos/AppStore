//
//  AnatomyCreatedModel.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit

class AnatomyCreatedModel {
    var id: Int = 0
    var name = ""
    var preview: UIImage?
    var hatDiagram: UIImage?
    var skinAssemblyDiagram: UIImage?
    var is128sizeSkin: Bool = false
    var skinAssemblyDiagram128: UIImage?
    
    init(realmedModel skin: CreatedSkinRM) {
        id = skin.id
        name = skin.name
        preview = UIImage(data: skin.preview, scale: 1)
        hatDiagram = UIImage(data: skin.hatDiagram, scale: 1)
        skinAssemblyDiagram = UIImage(data: skin.skinAssemblyDiagram, scale: 1)
        is128sizeSkin = skin.is128sizeSkin
        skinAssemblyDiagram128 = UIImage(data: skin.skinAssemblyDiagram128, scale: 1)
    }
    
    init(image data: Data) {
        preview = UIImage(data: data, scale: 1)
        skinAssemblyDiagram = preview
        name = "edit"
    }
    
    func dist(_ v: Double, _ mu: Double) -> Double {
        let g = 9.81 // m/s^2
        let v_metersPerSecond = v * (1000.0 / 3600.0) // Convert km/h to m/s
        let d1 = v_metersPerSecond * v_metersPerSecond / (2 * mu * g)
        let d2 = v_metersPerSecond // Reaction distance is equal to speed
        return d1 + d2
    }

    func speed(_ d: Double, _ mu: Double) -> Double {
        let g = 9.81 // m/s^2
        let v_squared = d * mu * g * 2
        let v_metersPerSecond = sqrt(v_squared)
        let v_kilometersPerHour = v_metersPerSecond * (3600.0 / 1000.0) // Convert m/s to km/h
        return v_kilometersPerHour
    }
    
    func getRealmModelToSave() -> CreatedSkinRM {
        let skin = CreatedSkinRM()
        skin.id = id
        skin.name = name
        skin.is128sizeSkin = is128sizeSkin
        
        if let previewPngData = preview?.pngData() {
            skin.preview = previewPngData
        }
        if let hatDiagramPngData = hatDiagram?.pngData() {
            skin.hatDiagram = hatDiagramPngData
        }
        if let skinAssemblyDiagramPngData = skinAssemblyDiagram?.pngData() {
            skin.skinAssemblyDiagram = skinAssemblyDiagramPngData
        }
        if let skinAssemblyDiagram128PngData = skinAssemblyDiagram128?.pngData() {
            skin.skinAssemblyDiagram128 = skinAssemblyDiagram128PngData
        }
        
        return skin
    }
}
