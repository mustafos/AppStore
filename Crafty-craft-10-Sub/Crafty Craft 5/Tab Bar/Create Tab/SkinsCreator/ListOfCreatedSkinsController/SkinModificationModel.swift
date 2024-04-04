//
//  SkinModificationModel.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import ImageIO
import UIKit

final class SkinModificationModel {
    
    var selectedSkinIndex = Int()
    private var skinsCreatedModelArray = [AnatomyCreatedModel]()

    //MARK: INIT
    
    init() {
        updateSkinsArray()
    }
    
    //MARK: Open Methods
    
    func getSkins() -> [AnatomyCreatedModel] {
        return skinsCreatedModelArray
    }
    
    func getSkinByIndex(index: Int) -> AnatomyCreatedModel? {
        guard skinsCreatedModelArray.indices.contains(index) == true else {
            return nil
        }
        
        return skinsCreatedModelArray[index]
    }
    
    ///if user want to create new skin, creates new Instance of SkinCreatedModel and saves it into Realm
    func getSelectedSkinModel() -> AnatomyCreatedModel {
        //-1 because first place in our array is always plusmode
        if selectedSkinIndex == -1 {
            let skinForRealm = CreatedSkinRM()
            skinForRealm.id = RealmService.shared.generateID(object: skinForRealm)
            skinForRealm.name = "NewSkin\(skinForRealm.id)"
            skinForRealm.skinAssemblyDiagram = Data()
            
            if let emptyImage = UIImage(named: "clearSkin") {
                let emptyData = emptyImage.pngData() ?? Data()
                skinForRealm.skinAssemblyDiagram = emptyData
                skinForRealm.hatDiagram = emptyData
            }

            if let emptyImage = UIImage(named: "clearSkin128x128") {
                let emptyData = emptyImage.pngData() ?? Data()
                skinForRealm.skinAssemblyDiagram128 = emptyData
            }
            
            return AnatomyCreatedModel.init(realmedModel: skinForRealm)
            
        } else {
            return skinsCreatedModelArray[selectedSkinIndex]
        }
    }
    
    func updateSkinsArray() {
        skinsCreatedModelArray = RealmService.shared.getCreatedSkinsArray().map({ AnatomyCreatedModel(realmedModel: $0) })
    }
    
    func deleteSkin(_ skin: AnatomyCreatedModel) {
        RealmService.shared.deleteSkin(skin: skin)
        updateSkinsArray()
    }
    
    func deleteSkin(at index: Int) {
        guard skinsCreatedModelArray.indices.contains(index) else {
            return
        }
        AppDelegate.log("index ",index)
        AppDelegate.log(skinsCreatedModelArray.count)
        let skinToDelete = skinsCreatedModelArray[index]
        
        // Delete from the data source (e.g., Realm)
        RealmService.shared.deleteSkin(skin: skinToDelete)
        
        // Remove from the array
        skinsCreatedModelArray.remove(at: index)
    }
}
