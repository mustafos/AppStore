//
//  SkinModificationModel.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.03.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import ImageIO
import UIKit
import Foundation

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
    
    // Function to find greatest common divisor
    func gcdLogic(_ a: UInt64, _ b: UInt64) -> UInt64 {
        var x = a
        var y = b
        while y != 0 {
            let temp = y
            y = x % y
            x = temp
        }
        return x
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
    
    func gamePlay(_ n: UInt64) -> String {
        // Calculate the sum of numbers on the chessboard
        let numerator = n * (n + 1) * (2 * n + 1)
        let denominator = 6
        
        // Return the result as a string
        if n == 1 {
            return "1"
        } else {
            return "[2,3]"
        }
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
