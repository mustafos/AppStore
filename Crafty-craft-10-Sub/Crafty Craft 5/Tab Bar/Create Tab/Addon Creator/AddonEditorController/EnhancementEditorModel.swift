//
//  EnhancementEditorModel.swif
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import UIKit

class EnhancementEditorModel {
    
    enum Kword {
        static let itemKey = "Items"
        static let addonKey = "NPC"
    }
    
    enum Field {
        static let id = "Id"
        static let name = "Name"
        static let enabled = "Enabled"
        static let amount = "Amount"
        static let health = "Health"
        static let moveSpeed = "Move Speed"
        static let attackSpeed = "Attack Speed"
        static let attackRadius = "Attack Radius"
    }
    
    enum ControllerState {
        case item
        case addon
    }
    
    var controllerState: ControllerState = .addon
    var addonModel: SavedAddonEnch
    
    var allow3dEditing: Bool {
        switch controllerState {
        case .item:
            return false
        case .addon:
            return !addonModel.file.isEmpty
        }
    }
    
    var allow2dEditing: Bool {
        switch controllerState {
        case .item:
            return addonModel.displayImage.isEmpty == false
        case .addon:
            return false
        }
    }
    
    private var mcAddonUri: String {
        AddonsEditorContent.mcAddonFilePath + addonModel.file
    }
    
    private(set) var resourcePack: [ResourcePack]?
    
    var currentResourcePack: ResourcePack?
    
    var isEdited: Bool = false
    
    let mcAddonFileManager: AddonFileManagerProtocol
    
    init(addonModel: SavedAddonEnch, mcAddonFileManager: AddonFileManagerProtocol = AddonFileManager()) {
        self.addonModel = addonModel
        self.mcAddonFileManager = mcAddonFileManager
        
        if addonModel.type  == Kword.addonKey {
            controllerState = .addon
        } else {
            controllerState = .item
        }
    }
    
    func getPropretirs() -> [AddonPropertiable] {
        
        var properiesArr = [AddonPropertiable]()
        
        switch controllerState {
        case .item:
            properiesArr = [
                StaticTextProperty(labName: Field.id, labValue: addonModel.id),
                StaticTextProperty(labName: Field.name, labValue: addonModel.displayName),
                SwitchProperty(switchState: addonModel.isEnabled, switchName: Field.enabled),
                DynamicIntProperty(textFieldName: Field.amount, textFieldValue: addonModel.amount)
            ]
        case .addon:
            properiesArr = [
                StaticTextProperty(labName: Field.id, labValue: addonModel.id),
                StaticTextProperty(labName: Field.name, labValue: addonModel.displayName),
                SwitchProperty(switchState: addonModel.isEnabled, switchName: Field.enabled),
                DynamicFloatProperty(textFieldName: Field.health, textFieldValue: addonModel.health),
                DynamicFloatProperty(textFieldName: Field.moveSpeed, textFieldValue: addonModel.move_speed),
                
                DynamicFloatProperty(textFieldName: Field.attackSpeed, textFieldValue: Float(addonModel.ranged_attack_atk_speed)),
                DynamicFloatProperty(textFieldName: Field.attackRadius, textFieldValue: Float(addonModel.ranged_attack_atk_radius)),
            ]
        }
        
        return properiesArr
    }
    
    @discardableResult
    func localMCAddonFileUrl(_ completionHandler: @escaping (URL?) -> Void) -> URL? {
        let fileManager = FileManager.default
        
        var destination: URL {
            let url = fileManager.cachesMCAddonDirectory
            url.createDir()
            
            return url
        }
        
        guard let fileName = addonModel.file.components(separatedBy: "/").last else {
            completionHandler(nil)
            return nil
        }
        
        let url = destination.appendingPathComponent(fileName)
        
        if !fileManager.fileExists(atPath: url.path) {
            
            DropBoxParserFiles.shared.downloadBloodyFileBy(urlPath: mcAddonUri) { data in
                do {
                    try data?.write(to: url)
                    
                    completionHandler(url)
                } catch {
                    AppDelegate.log("!!!")
                    
                    completionHandler(nil)
                }
            }
        } else {
            completionHandler(url)
            
            return url
        }
        
        return nil
    }
    
    var isSavedAddonFile: Bool {
        guard let fileName = addonModel.file.components(separatedBy: "/").last else {
            return false
        }
        
        let fileManager = FileManager.default
        let url = fileManager.cachesMCAddonDirectory.appendingPathComponent(fileName)
        
        return fileManager.fileExists(atPath: url.path)
    }
    
    func unzipAddon(at url: URL) -> URL? {
        mcAddonFileManager.unzipMCAddon(at: url)
    }
    
    func resourcePack(at url: URL) -> [ResourcePack]? {
        resourcePack = mcAddonFileManager.resourcePack(at: url)
        
        return resourcePack
    }
}

protocol AddonPropertiable {}

class SwitchProperty: AddonPropertiable{
    var switchState = true
    var switchName = ""
    
    init(switchState: Bool, switchName: String) {
        self.switchState = switchState
        self.switchName = switchName
    }
}

class DynamicIntProperty: AddonPropertiable {
    var textFieldName = ""
    var textFieldValue: Int = .zero
    
    init(textFieldName: String, textFieldValue: Int) {
        self.textFieldName = textFieldName
        self.textFieldValue = textFieldValue
    }
}

class DynamicFloatProperty: AddonPropertiable {
    var textFieldName = ""
    var textFieldValue: Float = .zero
    
    init(textFieldName: String, textFieldValue: Float) {
        self.textFieldName = textFieldName
        self.textFieldValue = textFieldValue
    }
}

class StaticTextProperty: AddonPropertiable {
    var labName = ""
    var labValue = ""
    
    init(labName: String, labValue: String) {
        self.labName = labName
        self.labValue = labValue
    }
}

class SavedAddonEnch {
    
    var idshka: String = ""
    var displayName: String = ""
    var displayImage: String = ""
    var displayImageData: Data?
    var id: String = ""
    var type: String = ""
    var file: String = ""
    var previewData: Data?
    var addonLikeSkinInfo: AddonLikeSkinInfo?
    
    var skin_variants: [AddonSkinVariant] = .init()
    
    var health: Float = .zero
    var move_speed: Float = .zero
    var ranged_attack_enabled: Bool = false
    var ranged_attack_atk_speed: Double = .zero
    var ranged_attack_atk_radius: Double = .zero
    var ranged_attack_burst_shots: Double = .zero
    var ranged_attack_burst_interval: Double = .zero
    var ranged_attack_atk_types: String?
    
    var isEnabled = false
    var amount: Int = 1
    var editingDate: Date?
    
    //newAddons
    init(realmModel: AddonForDisplay) {
        self.idshka = realmModel.idshka
        self.displayName = realmModel.displayName
        self.displayImage = realmModel.displayImage
        self.displayImageData = realmModel.displayImageData
        self.id = realmModel.id
        self.type = realmModel.type
        self.file = realmModel.file
        
        self.skin_variants = realmModel.skin_variants.map { AddonSkinVariant(name: $0.name, path: $0.path) }
        
        self.health = realmModel.health
        self.move_speed = realmModel.move_speed
        self.ranged_attack_enabled = realmModel.ranged_attack_enabled
        self.ranged_attack_atk_speed = realmModel.ranged_attack_atk_speed
        self.ranged_attack_atk_radius = realmModel.ranged_attack_atk_radius
        self.ranged_attack_burst_shots = realmModel.ranged_attack_burst_shots
        self.ranged_attack_burst_interval = realmModel.ranged_attack_burst_interval
        self.ranged_attack_atk_types = realmModel.ranged_attack_atk_types
        
        addonLikeSkinInfo = realmModel.addonLikeSkinInfo
    }
    
    init(realmModel: SavedAddonRM) {
        self.idshka = realmModel.idshka
        self.displayName = realmModel.displayName
        self.displayImage = realmModel.displayImage
        self.displayImageData = realmModel.displayImageData
        self.id = realmModel.id
        self.type = realmModel.type
        
        self.skin_variants = realmModel.skin_variants.map { AddonSkinVariant(name: $0.name, path: $0.path) }
        
        self.health = realmModel.health
        self.move_speed = realmModel.move_speed
        self.ranged_attack_enabled = realmModel.ranged_attack_enabled
        self.ranged_attack_atk_speed = realmModel.ranged_attack_atk_speed
        self.ranged_attack_atk_radius = realmModel.ranged_attack_atk_radius
        self.ranged_attack_burst_shots = realmModel.ranged_attack_burst_shots
        self.ranged_attack_burst_interval = realmModel.ranged_attack_burst_interval
        self.ranged_attack_atk_types = realmModel.ranged_attack_atk_types
        
        self.isEnabled = realmModel.isEnabled
        self.amount = realmModel.amount
        self.editingDate = realmModel.editingDate
        
        self.file = realmModel.file ?? ""
        
        if realmModel.addonLikeSkinInfo != nil {
            let colors: [UIColor] = realmModel.addonLikeSkinInfo!.skinColorArray.map { UIColor.init(red: CGFloat($0.red),
                                                                                                    green: CGFloat($0.green),
                                                                                                    blue: CGFloat($0.blue),
                                                                                                    alpha: CGFloat($0.alpha))}
            addonLikeSkinInfo = .init(colorArray: colors,
                                      height: realmModel.addonLikeSkinInfo!.height,
                                      width: realmModel.addonLikeSkinInfo!.width)
        }
    }
}
