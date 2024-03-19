//
//  AnatomyCreatedModel.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import UIKit
import Foundation

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
