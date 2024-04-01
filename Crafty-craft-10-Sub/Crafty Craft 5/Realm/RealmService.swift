
import UIKit
import RealmSwift
import Foundation

//
/// Service of basic functions to work with differernt RealmObjects
//
public class RealmService {
    
    public static let shared = RealmService()
    private var coreRM = RealmCore.shared
    
    
//    //MARK: DataBase functions
//
//    func getRealmCacheSizeInKB() -> Double {
//        let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL
//        guard let filePath = defaultRealmPath else { return 0.0 }
//
//        do {
//            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath.path)
//            if let fileSizeNumber = fileAttributes[FileAttributeKey.size] as? NSNumber {
//                let fileSize = fileSizeNumber.doubleValue
//                return fileSize / 1024.0 // Convert bytes to KB
//            }
//        } catch {
//            print("Failed to get file size: \(error.localizedDescription)")
//        }
//
//        return 0.0
//    }
    
    
    
    //MARK: Add & Delete from Realm
    
    /// Save new skins into DB
    func addNewSkin(skin:  CreatedSkinRM ) {
        //        skin.id = generateID(object: skin)
        coreRM.addObject(skin)
    }
    
    ///Delete Created skins
    func deleteSkin(skin: AnatomyCreatedModel) {
        guard let skinForDeleting = self.getCreatedSkinByID(skinID: skin.id) else { return }
        coreRM.delete(skinForDeleting)
    }
    
    func deleteSkin(skin: CreatedSkinRM) {
        coreRM.delete(skin)
    }
    
    //MARK: Get Functions
    
    func getCreatedSkinsArray() -> [CreatedSkinRM] {
        
        let skinsArr = coreRM.loadObjects(ofType: CreatedSkinRM.self).toArray()
        //        guard skinsArr.count > 0 else {
        //            return nil
        //        }
        return skinsArr
    }
    
    func getCreatedSkinByID(skinID: Int?) -> CreatedSkinRM? {
        
        let skinsArr = coreRM.loadObjects(ofType: CreatedSkinRM.self).toArray()
        
        if skinsArr.count > 0 {
            let skin = skinsArr.first(where: { $0.id == skinID })
            
            return skin
            
        } else {
            return nil
        }
    }
    
    
    //MARK: Edit Obj Functions
    
    func editCreatedSkinAssemblyDiagram(createdSkin: AnatomyCreatedModel?, newDiagram: UIImage?) {
        
        guard let diagram = newDiagram else { return }
        guard let localCreatedSkin = createdSkin else { return }
        guard let realmedSkin = self.getCreatedSkinByID(skinID: localCreatedSkin.id) else {
            AppDelegate.log("Skin doesnt exest in RealmDB")
            return
        }
        
        let diagramData = diagram.pngData()
        coreRM.update(realmedSkin, with: ["skinAssemblyDiagram":diagramData])
    }
    
    func editCreatedSkinAssemblyDiagram128(createdSkin: AnatomyCreatedModel?, newDiagram: UIImage?) {
        
        guard let diagram = newDiagram else { return }
        guard let localCreatedSkin = createdSkin else { return }
        guard let realmedSkin = self.getCreatedSkinByID(skinID: localCreatedSkin.id) else { return }
        
        let diagramData = diagram.pngData()
        coreRM.update(realmedSkin, with: ["skinAssemblyDiagram128":diagramData])
    }
    
    func editIsThe128(createdSkin: AnatomyCreatedModel?, newValue: Bool?) {
        
        guard let _ = newValue else { return }
        guard let localCreatedSkin = createdSkin else { return }
        guard let realmedSkin = self.getCreatedSkinByID(skinID: localCreatedSkin.id) else { return }
        
        coreRM.update(realmedSkin, with: ["is128sizeSkin":newValue])
    }
    
    func editIsCreationComplited(createdSkin: AnatomyCreatedModel?, newValue: Bool?) {
        
        guard let _ = newValue else { return }
        guard let localCreatedSkin = createdSkin else { return }
        guard let realmedSkin = self.getCreatedSkinByID(skinID: localCreatedSkin.id) else { return }
        
        coreRM.update(realmedSkin, with: ["isCreationComplited":newValue])
    }
    
    func editCreatedSkinPreview(createdSkin: AnatomyCreatedModel?, newPreview: UIImage?) {
        
        guard let diagram = newPreview else { return }
        guard let localCreatedSkin = createdSkin else { return }
        guard let realmedSkin = self.getCreatedSkinByID(skinID: localCreatedSkin.id) else { return }
        
        let diagramData = diagram.pngData()
        coreRM.update(realmedSkin, with: ["preview":diagramData])
    }
    
    //use only for hatDiagram, will be deleted in future versions
    //thats why I duplicated the code
    func editHatDiagram(createdSkin: AnatomyCreatedModel?, newHatDiagram: UIImage?) {
        guard let newHatDiagram = newHatDiagram else { return }
        guard let localCreatedSkin = createdSkin else { return }
        guard let realmedSkin = self.getCreatedSkinByID(skinID: localCreatedSkin.id) else { return }
        let diagramData = newHatDiagram.pngData()
        coreRM.update(realmedSkin, with: ["hatDiagram":diagramData])
    }
    
    func editCreatedSkinName(createdSkin: AnatomyCreatedModel?, newName: String) {
        
        guard let localCreatedSkin = createdSkin else { return }
        guard let realmedSkin = self.getCreatedSkinByID(skinID: localCreatedSkin.id) else { return }
        coreRM.update(realmedSkin, with: ["name":newName])
    }
    
}


//MARK: Extensions

extension RealmService {
    
    func convertSkinCreatedModel(skinModel: AnatomyCreatedModel) -> CreatedSkinRM {
        let realmedModel = CreatedSkinRM()
        realmedModel.id = skinModel.id
        realmedModel.name = skinModel.name
        
        if let imgData = skinModel.skinAssemblyDiagram?.pngData() {
            realmedModel.skinAssemblyDiagram = imgData
        }
        
        return realmedModel
    }
}


extension RealmService {
    
    ///Use this func to generate unic ID for object of Any RealmType
    func generateID<T: Object>(object: T) -> Int {
        coreRM.generateID(ofType: T.self)
    }
}


//MARK: - Addons Servers

extension RealmService {
    func addNewAddonEditor(addon: AddonsEdotorRealmSession) {
        coreRM.addObject(addon)
    }
    
    func addNewAddonEditors(addons: [AddonsEdotorRealmSession]) {
        coreRM.addObjects(addons)
    }
    
    func deleteAddon(addon: SavedAddonEnch) {
        guard let addonForDeleting = self.getSavedAddonRM(by: addon.idshka) else {
            return
        }
        coreRM.delete(addonForDeleting)
    }
    
    func getAddonEditorArray() -> [AddonsEdotorRealmSession] {
        let addonEditorArr = coreRM.loadObjects(ofType: AddonsEdotorRealmSession.self).toArray()
        return addonEditorArr
    }
    
    func getSavedAddonRM(by idshka: String) -> SavedAddonRM? {
        let addonArr = RealmService.shared.getArrayOfSavedAddons()
        
        if addonArr.count > 0 {
            let realmedArr = addonArr.first(where: { $0.idshka == idshka })
            
            return realmedArr
            
        } else {
            return nil
        }
    }
    
    func getArrayOfSavedAddons() -> [SavedAddonRM] {
        let addonEditorArr = coreRM.loadObjects(ofType: SavedAddonRM.self).toArray()
        return addonEditorArr
    }
    
    func deleteRealm() {
        let _ = coreRM.resetRealm()
    }
    
    func editAddonEditor(addon: AddonsEdotorRealmSession) {
//        coreRM.update(realmedSkin, with: ["hatDiagram":diagramData])
    }
    
    func addAddonEditable(addon: SavedAddonRM) {
        coreRM.addObject(addon)
    }
    
    func editCreatedSkinName(addon: SavedAddonRM, newAddon: SavedAddonEnch) {
        coreRM.update(addon, with: ["idshka" : newAddon.idshka])
        coreRM.update(addon, with: ["displayName" : newAddon.displayName])
        coreRM.update(addon, with: ["displayImage" : newAddon.displayImage])
        coreRM.update(addon, with: ["displayImageData" : newAddon.displayImageData])
        coreRM.update(addon, with: ["id" : newAddon.id])
        coreRM.update(addon, with: ["skin_variants" : newAddon.skin_variants.map { AddonSkinVariantObj(name: $0.name, path: $0.path) }])
        coreRM.update(addon, with: ["health" : newAddon.health])
        coreRM.update(addon, with: ["move_speed" : newAddon.move_speed])
        coreRM.update(addon, with: ["ranged_attack_enabled" : newAddon.ranged_attack_enabled])
        coreRM.update(addon, with: ["ranged_attack_atk_speed" : newAddon.ranged_attack_atk_speed])
        coreRM.update(addon, with: ["ranged_attack_atk_radius" : newAddon.ranged_attack_atk_radius])
        coreRM.update(addon, with: ["ranged_attack_burst_shots" : newAddon.ranged_attack_burst_shots])
        coreRM.update(addon, with: ["ranged_attack_burst_interval" : newAddon.ranged_attack_burst_interval])
        coreRM.update(addon, with: ["ranged_attack_atk_types" : newAddon.ranged_attack_atk_types])
        coreRM.update(addon, with: ["isEnabled" : newAddon.isEnabled])
        coreRM.update(addon, with: ["file" : newAddon.file])
        coreRM.update(addon, with: ["amount" : newAddon.amount])
        if let addonInfo = newAddon.addonLikeSkinInfo {
            let addonInfoRM = CreatedAddonLikeSkinInfo()
            for color in addonInfo.colorArray {
                if let colorRM = ColorRM(color: color) {
                    addonInfoRM.skinColorArray.append(colorRM)
                }
            }
            addonInfoRM.height = addonInfo.height
            addonInfoRM.width = addonInfo.width
            
            coreRM.update(addon, with: ["addonLikeSkinInfo" : addonInfoRM])
        }
    }
    
    func edit(addon: SavedAddonRM, newAddon: SavedAddonRM) {
        coreRM.update(addon, with: ["idshka" : newAddon.idshka])
        coreRM.update(addon, with: ["displayName" : newAddon.displayName])
        coreRM.update(addon, with: ["displayImage" : newAddon.displayImage])
        coreRM.update(addon, with: ["displayImageData" : newAddon.displayImageData])
        coreRM.update(addon, with: ["id" : newAddon.id])
        coreRM.update(addon, with: ["skin_variants" : newAddon.skin_variants.map { AddonSkinVariantObj(name: $0.name, path: $0.path) }])
        coreRM.update(addon, with: ["health" : newAddon.health])
        coreRM.update(addon, with: ["move_speed" : newAddon.move_speed])
        coreRM.update(addon, with: ["ranged_attack_enabled" : newAddon.ranged_attack_enabled])
        coreRM.update(addon, with: ["ranged_attack_atk_speed" : newAddon.ranged_attack_atk_speed])
        coreRM.update(addon, with: ["ranged_attack_atk_radius" : newAddon.ranged_attack_atk_radius])
        coreRM.update(addon, with: ["ranged_attack_burst_shots" : newAddon.ranged_attack_burst_shots])
        coreRM.update(addon, with: ["ranged_attack_burst_interval" : newAddon.ranged_attack_burst_interval])
        coreRM.update(addon, with: ["ranged_attack_atk_types" : newAddon.ranged_attack_atk_types])
        coreRM.update(addon, with: ["isEnabled" : newAddon.isEnabled])
        coreRM.update(addon, with: ["file" : newAddon.file])
        coreRM.update(addon, with: ["amount" : newAddon.amount])
        if let addonInfo = newAddon.addonLikeSkinInfo {
            coreRM.update(addon, with: ["addonLikeSkinInfo" : addonInfo])
        }
    }
    
    func editRecentProprty(for savedAddon: SavedAddonRM, newDate: Date) {
        coreRM.update(savedAddon, with: ["editingDate" : newDate])
    }
    
    func editFilePathToAddon(for savedAddon: SavedAddonRM, newFilePath: String?) {
        guard let newFilePath else {
            AppDelegate.log("newFileUrl Realming gone wrong")
            return
        }
        coreRM.update(savedAddon, with: ["file" : newFilePath])
    }
}
